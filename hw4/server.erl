-module(server).

-export([start_server/0]).

-include_lib("./defs.hrl").

-spec start_server() -> _.
-spec loop(_State) -> _.
-spec do_join(_ChatName, _ClientPID, _Ref, _State) -> _.
-spec do_leave(_ChatName, _ClientPID, _Ref, _State) -> _.
-spec do_new_nick(_State, _Ref, _ClientPID, _NewNick) -> _.
-spec do_client_quit(_State, _Ref, _ClientPID) -> _NewState.

start_server() ->
    catch(unregister(server)),
    register(server, self()),
    case whereis(testsuite) of
	undefined -> ok;
	TestSuitePID -> TestSuitePID!{server_up, self()}
    end,
    loop(
      #serv_st{
	 nicks = maps:new(), %% nickname map. client_pid => "nickname"
	 registrations = maps:new(), %% registration map. "chat_name" => [client_pids]
	 chatrooms = maps:new() %% chatroom map. "chat_name" => chat_pid
	}
     ).

loop(State) ->
    receive 
	%% initial connection
	{ClientPID, connect, ClientNick} ->
	    NewState =
		#serv_st{
		   nicks = maps:put(ClientPID, ClientNick, State#serv_st.nicks),
		   registrations = State#serv_st.registrations,
		   chatrooms = State#serv_st.chatrooms
		  },
	    loop(NewState);
	%% client requests to join a chat
	{ClientPID, Ref, join, ChatName} ->
	    NewState = do_join(ChatName, ClientPID, Ref, State),
	    loop(NewState);
	%% client requests to join a chat
	{ClientPID, Ref, leave, ChatName} ->
	    NewState = do_leave(ChatName, ClientPID, Ref, State),
	    loop(NewState);
	%% client requests to register a new nickname
	{ClientPID, Ref, nick, NewNick} ->
	    NewState = do_new_nick(State, Ref, ClientPID, NewNick),
	    loop(NewState);
	%% client requests to quit
	{ClientPID, Ref, quit} ->
	    NewState = do_client_quit(State, Ref, ClientPID),
	    loop(NewState);
	{TEST_PID, get_state} ->
	    TEST_PID!{get_state, State},
	    loop(State)
    end.

do_join(ChatName, ClientPID, Ref, State) ->
    RegMap = State#serv_st.registrations,
    ChatMap = State#serv_st.chatrooms,
    Nicks = State#serv_st.nicks,

    % 1. Already in chatroom?
    ClientList = maps:get(ChatName, RegMap, []),
    case lists:member(ClientPID, ClientList) of
        true ->
            ClientPID ! {server, join_result, err},
            State;
        false ->
            % 2. Ensure chatroom process exists
            {ChatroomPID, UpdatedChatMap} =
                case maps:find(ChatName, ChatMap) of
                    {ok, Pid} -> {Pid, ChatMap};
                    error ->
                        Pid = spawn(chatroom, start_chatroom, [ChatName]),
                        {Pid, maps:put(ChatName, Pid, ChatMap)}
                end,

            % 3. Register client to chatroom
            Nick = maps:get(ClientPID, Nicks),
            ChatroomPID ! {self(), Ref, register, ClientPID, Nick},

            % 4. Get history (you could add message passing here, but assume chatroom replies with list)
            ChatroomPID ! {self(), get_state},
            History =
                receive
                    {get_state, #chat_st{history = Hist}} -> Hist
                after 1000 ->
                    [] % fallback
                end,

            % 5. Update registration
            NewRegMap = maps:put(ChatName, [ClientPID | ClientList], RegMap),

            % 6. Reply to client and return updated state
            ClientPID ! {server, join_result, {ok, ChatroomPID, History}},
            State#serv_st{registrations = NewRegMap, chatrooms = UpdatedChatMap}
    end.


do_leave(ChatName, ClientPID, Ref, State) ->
    RegMap = State#serv_st.registrations,
    ChatMap = State#serv_st.chatrooms,

    % Check if the chatroom exists
    case maps:find(ChatName, RegMap) of
        error ->
            ClientPID ! {server, leave_result, err},
            State;

        {ok, ClientList} ->
            case lists:member(ClientPID, ClientList) of
                false ->
                    ClientPID ! {server, leave_result, err},
                    State;

                true ->
                    % Remove client from chatroom registration list
                    NewClientList = lists:delete(ClientPID, ClientList),
                    NewRegMap = maps:put(ChatName, NewClientList, RegMap),

                    % Send message to chatroom to unregister
                    ChatroomPID = maps:get(ChatName, ChatMap),
                    ChatroomPID ! {self(), Ref, unregister, ClientPID},

                    % Acknowledge leave
                    ClientPID ! {server, leave_result, ok},

                    State#serv_st{registrations = NewRegMap}
            end
    end.



get_chatrooms_of_client(ClientPID, RegistrationsMap, ChatroomMap) ->
    maps:fold(fun(ChatName, ClientList, Acc) ->
        case lists:member(ClientPID, ClientList) of
            true ->
                case maps:find(ChatName, ChatroomMap) of
                    {ok, Pid} -> [Pid | Acc];
                    error -> Acc
                end;
            false -> Acc
        end
    end, [], RegistrationsMap).


do_new_nick(State, Ref, ClientPID, NewNick) ->
    Nicks = State#serv_st.nicks,

    % Check if new nick is already in use
    case lists:member(NewNick, maps:values(Nicks)) of
        true ->
            ClientPID ! {server, change_nick_result, {error, nickname_in_use}},
            State;

        false ->
            case maps:find(ClientPID, Nicks) of
                error ->
                    ClientPID ! {server, change_nick_result, {error, no_such_nick}},
                    State;

                {ok, _OldNick} ->
                    % Update nickname mapping
                    NewNicks = maps:put(ClientPID, NewNick, Nicks),

                    % Notify all chatrooms about the nickname change
                    ChatroomPIDs = get_chatrooms_of_client(
                        ClientPID,
                        State#serv_st.registrations,
                        State#serv_st.chatrooms
                    ),
                    lists:foreach(
                        fun(Pid) -> Pid ! {self(), Ref, update_nick, ClientPID, NewNick} end,
                        ChatroomPIDs
                    ),

                    % Send confirmation and update server state
                    ClientPID ! {server, change_nick_result, ok},
                    State#serv_st{nicks = NewNicks}
            end
    end.


do_client_quit(State, Ref, ClientPID) ->
    Nicks = State#serv_st.nicks,
    RegMap = State#serv_st.registrations,
    ChatMap = State#serv_st.chatrooms,

    % Remove client from all chatrooms
    NewRegMap = maps:map(
        fun(_ChatName, ClientList) ->
            lists:delete(ClientPID, ClientList)
        end,
        RegMap
    ),

    % Notify each chatroom that client has quit
    ChatroomPIDs = get_chatrooms_of_client(ClientPID, RegMap, ChatMap),
    lists:foreach(
        fun(Pid) ->
            Pid ! {self(), Ref, unregister, ClientPID}
        end,
        ChatroomPIDs
    ),

    % Remove client from nickname map
    NewNicks = maps:remove(ClientPID, Nicks),

    % Respond to client
    ClientPID ! {server, quit_ack},

    State#serv_st{
        nicks = NewNicks,
        registrations = NewRegMap
    }.


