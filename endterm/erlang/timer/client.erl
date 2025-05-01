-module(client).
-compile(export_all).

start() ->
    spawn(?MODULE, loop, []).

loop() ->
    receive
        {tick} ->
            io:format("~p received a tick at ~p~n", [self(), erlang:system_time(millisecond)]),
            loop()
    end.
