-module(ex1).
-compile(export_all).

start(N) ->
	C = spawn(?MODULE, counter_server, [0]),
	[spawn(?MODULE, turnstile, [C,50]) || _ <- lists:seq(1,N)],
	C.

counter_server(State)->
	receive
		{increment} ->
			counter_server(State + 1);
		{get, From}->
			From ! {count, State},
			counter_server(State);	
		stop -> ok
	end.
turnstile(C,N) ->
	lists:foreach(fun(_) -> C ! {increment} end, lists:seq(1, N)),
	io:format("Turnstile turned ~p times!~n", [N]).


