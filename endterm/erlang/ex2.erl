-module(ex2).
-compile(export_all).

start() ->
    S = spawn(?MODULE, server, [self(), ""]),
    [spawn(?MODULE, client, [S]) || _ <- lists:seq(1, 100000)].

client(S) ->
    S ! {add, "h", self()},
    S ! {add, "e", self()},
    S ! {add, "lly", self()},
    S ! {add, "l", self()},
    S ! {add, "o", self()},
    S ! {done, self()},
    receive
        {From, Str} ->
            io:format("Done: ~p ~s~n", [From, Str])
    end.

server(Pid, S) ->
    receive 
        {add, Char, From} ->
            server(Pid, S ++ Char);
        {done, From} ->
            From ! {self(), S};
        _ ->
            server(Pid, S)
    end.
