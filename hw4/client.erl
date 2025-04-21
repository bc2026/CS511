-module(client).

-export([main/1, initial_state/2]).

-include_lib("./defs.hrl").

-spec main(_InitialState) -> _.
-spec listen(_State) -> _.
-spec initial_state(_Nick, _GuiName) -> _InitialClientState.
-spec loop(_State, _Request, _Ref) -> _.
-spec do_join(_State, _Ref, _ChatName) -> _.
-spec do_leave(_State, _Ref, _ChatName) -> _.
-spec do_new_nick(_State, _Ref, _NewNick) -> _.
-spec do_new_incoming_msg(_State, _Ref, _SenderNick, _ChatName, _Message) -> _.

%% Receive messages from GUI and handle them accordingly
%% All handling can be done in loop(...)
main(InitialState) ->
    %% The client tells the server it is connecting with its initial nickname.
    %% This nickname is guaranteed unique system-wide as long as you do not assign a client
    %% the nickname in the form "user[number]" manually such that a new client happens
    %% to generate the same random number as you assigned to your client.
    whereis(server)!{self(), connect, InitialState#cl_st.nick},
    %% if running test suite, tell test suite that client is up
    case whereis(testsuite) of
	undefined -> ok;
	TestSuitePID -> TestSuitePID!{client_up, self()}
    end,
    %% Begins listening
    listen(InitialState).

%% This method handles all incoming messages from either the GUI or the
%% chatrooms that are not directly tied to an ongoing request cycle.
listen(State) ->
    receive
        {request, From, Ref, Request} ->
	    %% the loop method will return a response as well as an updated
	    %% state to pass along to the next cycle
            {Response, NextState} = loop(State, Request, Ref),
	    case Response of
		{dummy_target, Resp} ->
		    io:format("Use this for whatever you would like~n"),
		    From!{result, self(), Ref, {dummy_target, Resp}},
		    listen(NextState);
		%% if shutdown is received, terminate
		shutdown ->
		    ok_shutdown;
		%% terminate if GUI receives a quit instruction
		ack_quit ->
		    From ! {result, self(), Ref, ack_quit},
		    exit(normal);
		%% if ok_msg_received, then we don't need to reply to sender.
		ok_msg_received ->
		    listen(NextState);
		%% otherwise, reply to sender with response
		_ ->
		    From!{result, self(), Ref, Response},
		    listen(NextState)
	    end
    end.

%% This function just initializes the default state of a client.
%% This should only be used by the GUI. Do not change it, as the
%% GUI code we provide depends on it.
initial_state(Nick, GUIName) ->
    #cl_st { gui = GUIName, nick = Nick, con_ch = maps:new() }.

%% ------------------------------------------
%% loop handles each kind of request from GUI
%% ------------------------------------------
loop(State, Request, Ref) ->
    case Request of
	%% GUI requests to join a chatroom with name ChatName
	{join, ChatName} ->
	    do_join(State, Ref, ChatName);

	%% GUI requests to leave a chatroom with name ChatName
	{leave, ChatName} ->
	    do_leave(State, Ref, ChatName);

	%% GUI requests to send an outgoing message Message to chatroom ChatName
	{outgoing_msg, ChatName, Message} ->
	    do_msg_send(State, Ref, ChatName, Message);

	%% GUI requests the nickname of client
	whoami ->
	   {State#cl_st.nick, State};

	%% GUI requests to update nickname to Nick
	{nick, Nick} ->
            do_new_nick(State, Ref, Nick);

	%% GUI requesting to quit completely
	quit ->
	    do_quit(State, Ref);

	%% Chatroom with name ChatName has sent an incoming message Message
	%% from sender with nickname SenderNick
	{incoming_msg, SenderNick, ChatName, Message} ->
	    do_new_incoming_msg(State, Ref, SenderNick, ChatName, Message);

	{get_state} ->
	    {{get_state, State}, State};

	%% Somehow reached a state where we have an unhandled request.
	%% Without bugs, this should never be reached.
	_ ->
	    io:format("Client: Unhandled Request: ~w~n", [Request]),
	    {unhandled_request, State}
    end.

do_join(State, Ref, ChatName) ->
    ConCh = State#cl_st.con_ch,
    % Check if we're already in the chatroom
    case maps:is_key(ChatName, ConCh) of
        true ->
            {err, State};
        false ->
            % Send join request to server
            ServerPid = whereis(server),
            ServerPid ! {self(), Ref, join, ChatName},

            receive
                {server, join_result, {ok, ChatroomPID, History}} ->
                    % Update client state to track this chatroom
                    NewConCh = maps:put(ChatName, ChatroomPID, ConCh),
                    NewState = State#cl_st{con_ch = NewConCh},
                    {History, NewState};

                {server, join_result, err} ->
                    {err, State}
            after 2000 ->
                {{error, timeout}, State}
            end
    end.


do_leave(State, Ref, ChatName) ->
    ConCh = State#cl_st.con_ch,

    case maps:is_key(ChatName, ConCh) of
        false ->
            {err, State};  %% Not connected to this chatroom

        true ->
            ServerPid = whereis(server),
            ServerPid ! {self(), Ref, leave, ChatName},

            receive
                {server, leave_result, ok} ->
                    NewConCh = maps:remove(ChatName, ConCh),
                    NewState = State#cl_st{con_ch = NewConCh},
                    {ok, NewState};

                {server, leave_result, err} ->
                    {err, State}
            after 2000 ->
                {{error, leave_timeout}, State}
            end
    end.


do_new_nick(State, Ref, NewNick) ->
    case State#cl_st.nick =:= NewNick of
        true ->
            {err_same, State};

        false ->
            ServerPid = whereis(server),
            ServerPid ! {self(), Ref, nick, NewNick},
            receive
                {server, change_nick_result, ok} ->
                    NewState = State#cl_st{nick = NewNick},
                    {ok_nick, NewState};  

                {server, change_nick_result, {error, nickname_in_use}} ->
                    {err_nick_used, State};

                {server, change_nick_result, {error, no_such_nick}} ->
                    {err_unknown, State}
            after 2000 ->
                {{error, nick_change_timeout}, State}
            end
    end.


do_msg_send(State, Ref, ChatName, Message) ->
    ConCh = State#cl_st.con_ch,
    case maps:find(ChatName, ConCh) of
        error ->
            %% Chatroom not joined
            {{error, not_in_chatroom}, State};
        {ok, ChatroomPID} ->
            ChatroomPID ! {self(), Ref, message, Message},
            %% Return nickname too so GUI can show: Nick: Message
            { {ok, State#cl_st.nick}, State }
    end.

do_new_incoming_msg(State, _Ref, CliNick, ChatName, Msg) ->
    gen_server:call(list_to_atom(State#cl_st.gui),
                    {msg_to_GUI, ChatName, CliNick, Msg}),
    {ok_msg_received, State}.

do_quit(State, Ref) ->
    ServerPid = whereis(server),
    ServerPid ! {self(), Ref, quit},

    receive
        {server, quit_ack} ->
            {ack_quit, State}
    after 1000 ->
        {{error, quit_timeout}, State}
    end.




