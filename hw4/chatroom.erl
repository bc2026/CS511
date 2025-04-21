-module(chatroom).

-include_lib("./defs.hrl").

-export([start_chatroom/1]).

-spec start_chatroom(_ChatName) -> _.
-spec loop(_State) -> _.
-spec do_register(_State, _Ref, _ClientPID, _ClientNick) -> _NewState.
-spec do_unregister(_State, _ClientPID) -> _NewState.
-spec do_update_nick(_State, _ClientPID, _NewNick) -> _NewState.
-spec do_propegate_message(_State, _Ref, _ClientPID, _Message) -> _NewState.

start_chatroom(ChatName) ->
    loop(#chat_st{name = ChatName,
		  registrations = maps:new(), history = []}),
    ok.

loop(State) ->
    NewState =
	receive
	    %% Server tells this chatroom to register a client
	    {_ServerPID, Ref, register, ClientPID, ClientNick} ->
		do_register(State, Ref, ClientPID, ClientNick);
	    %% Server tells this chatroom to unregister a client
	    {_ServerPID, _Ref, unregister, ClientPID} ->
		do_unregister(State, ClientPID);
	    %% Server tells this chatroom to update the nickname for a certain client
	    {_ServerPID, _Ref, update_nick, ClientPID, NewNick} ->
		do_update_nick(State, ClientPID, NewNick);
	    %% Client sends a new message to the chatroom, and the chatroom must
	    %% propegate to other registered clients
	    {ClientPID, Ref, message, Message} ->
		do_propegate_message(State, Ref, ClientPID, Message);
	    {TEST_PID, get_state} ->
		TEST_PID!{get_state, State},
		loop(State)
end,
    loop(NewState).

do_register(State, _Ref, ClientPID, ClientNick) ->
    OldRegs = State#chat_st.registrations,
    NewRegs = maps:put(ClientPID, ClientNick, OldRegs),
    NewState = State#chat_st{registrations = NewRegs},
    NewState.


do_unregister(State, ClientPID) ->
    Regs = State#chat_st.registrations,
    NewRegs = maps:remove(ClientPID, Regs),
    State#chat_st{registrations = NewRegs}.



do_update_nick(State, ClientPID, NewNick) ->
    OldRegs = State#chat_st.registrations,
    case maps:is_key(ClientPID, OldRegs) of
        true ->
            NewRegs = maps:put(ClientPID, NewNick, OldRegs),
            State#chat_st{registrations = NewRegs};
        false ->
            State
    end.


do_propegate_message(State, _Ref, ClientPID, Message) ->
    Regs = State#chat_st.registrations,
    History = State#chat_st.history,

    % Get sender's nickname
    SenderNick = maps:get(ClientPID, Regs),

    % Append to history
    NewHistory = [{SenderNick, Message} | History],

    % Notify all clients except the sender
    lists:foreach(
        fun({Pid, _Nick}) ->
            if
                Pid =/= ClientPID ->
                    Pid ! {incoming_msg, SenderNick, State#chat_st.name, Message};
                true ->
                    ok
            end
        end,
        maps:to_list(Regs)
    ),

    State#chat_st{history = NewHistory}.
