-module(turnstile).
-compile(export_all).


start(N)->%%SpawnsacounterandNturnstileclients
    C = spawn(?MODULE,counter_server,[0]),
    [spawn(?MODULE,turnstile,[C,50])||_<-lists:seq(1,N)],
    C.

counter_server(State)-> 
    receive
        {increment, N} ->
            counter_server(State + N);
        {get, Pid} -> Pid ! {value, State},
            counter_server(State);
        stop -> ok
    end.


turnstile(C,N)->
    C ! {increment, N},
    C ! {get, self()},
     receive
        {value, Value} ->
            io:format("Turnstile ~p: Counter = ~p~n", [self(), Value])
    end.