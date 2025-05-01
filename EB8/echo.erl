-module(echo).
-compile(nowarn_export_all).
-compile(export_all).
%% Name: Bhagawat Chapagain
%% Name: Konstantinos Mokos

start() ->
    P = spawn(?MODULE,set_neighbor,[initiator]),
    Q = spawn(?MODULE,set_neighbor,[noninitiator]),
    R = spawn(?MODULE,set_neighbor,[noninitiator]),
    S = spawn(?MODULE,set_neighbor,[noninitiator]),
    T = spawn(?MODULE,set_neighbor,[noninitiator]),
    io:format("P is ~p~n",[P]), io:format("Q is ~p~n",[Q]),
    io:format("R is ~p~n",[R]), io:format("S is ~p~n",[S]),
    io:format("T is ~p~n",[T]),
    P![Q,S,T],
    Q![P,S,T,R],
    R![Q],
    S![P,Q,T],
    T![S,P,Q],
    ok.

set_neighbor(Init) ->
    receive
        NPIDs ->
            case Init of
                initiator ->  %% Initiator node: send first wave
                    [ Pid!{self(),[]} || Pid <- NPIDs ];
                noninitiator ->  %% Noninitiator node
                    ok
            end,
            loop(Init,NPIDs,0,undef,[])
    end.

%% Noninitiator node and parent undef
%% - Wait for first message.
%% - Set parent
%% - If there is more than one neighbor, send wave forward to them (except parent) 
%% - Otherwise, send wave back to parent
loop(noninitiator,NPIDs,0,undef,[]) -> 
    receive
        {From,_Subtree} ->
            if
                length(NPIDs)>1 ->  %% have more than one neighbor, send wave forward
                    [ Nei!{self(),[]} || Nei <- lists:delete(From,NPIDs) ],
                    loop(noninitiator,NPIDs,1,From,[]);
                true ->             %% only one neighbor, send wave to parent
                    From!{self(),[{self(),parent_of,From}]},
                    ok
            end
    end;

%% Noninitiator node with parent already defined behaves as follows:
%% - receive {From,Subtree} message
%% - if got replies from all neighbors except parent, send parent the collected subtree
%% - otherwise, wait for more messages (recursive call)  
%% Rec: counts number of messages received
loop(noninitiator, NPIDs, Rec, Parent, Tree) ->
    receive
        {From, Subtree} ->
            NewTree = Subtree ++ Tree,
            % We expect messages from all neighbors except parent
            % So we need to check if we received (length(NPIDs) - 1) messages
            if
                Rec == length(NPIDs) - 1 ->
                    Parent!{self(), [{Parent,parent_of,self()} | NewTree]},
                    ok;
                true ->
                    loop(noninitiator, NPIDs, Rec+1, Parent, NewTree)
            end
    end;

%% Initiator node behaves as follows:
%% - receive {From,Subtree} message
%% - if got replies from all neighbors, print out spanning tree
%% - otherwise, wait for more messages (recursive call)  
loop(initiator, NPIDs, Rec, undef, Tree) ->
    receive 
        {From, Subtree} ->
            NewTree = Subtree ++ Tree,
            NewRec = Rec + 1,
            if  
                NewRec == length(NPIDs) -> 
                    io:format("done ~w~n", [NewTree]);
                true -> 
                    loop(initiator, NPIDs, NewRec, undef, NewTree)
            end
    end.