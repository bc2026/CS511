-module(ex2).
-compile(export_all).


start()->
    S = spawn(?MODULE, server, []),
    [spawn(?MODULE, client, [S]) || _ <- lists:seq(1,100)].

client(S) ->
        S!{start, self()},
        S!{add, "h", self()},
        S!{add, "i", self()},
        S!{done, self()},
        receive
            {S, Str} ->
                    io:format("Done: ~p ~s~n", [self(), Str])
        end.


server() ->
    receive
        {start, From} ->
            spawn(?MODULE, client_session, [From, []]),
            server()
    end.

client_session(ClientPid, L) ->
    receive
        {add, Char, From} when From =:= ClientPid ->
            client_session(ClientPid, L ++ [Char]);
        {done, From} when From =:= ClientPid ->
            From ! {self(), lists:concat(L)};
        stop ->
            ok
    end.
