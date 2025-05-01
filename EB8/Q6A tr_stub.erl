-module(tr).
-compile(nowarn_export_all).
-compile(export_all).
%% Name: Bhagawat Chapagain
%% Name: Konstantinos Mokos

start() ->
    P0 = spawn(?MODULE,node_loop,[]),
    P1 = spawn(?MODULE,node_loop,[]),
    P2 = spawn(?MODULE,node_loop,[]),
    P3 = spawn(?MODULE,node_loop,[]),
    P4 = spawn(?MODULE,node_loop,[]),
    io:format("P0 is ~p~n",[P0]), io:format("P1 is ~p~n",[P1]),
    io:format("P2 is ~p~n",[P2]), io:format("P3 is ~p~n",[P3]),
    io:format("P4 is ~p~n",[P4]),
    M=#{0 => P0,1 => P1,2 => P2,3 => P3,4 => P4 },
    P0!{P4,P1,M},
    P1!{P0,P2,M},
    P2!{P1,P3,M},
    P3!{P2,P4,M},
    P4!{P3,P0,M},
    P1!{P0,{free,ok,ok,ok}}, %% Place token in the ring
    ok.

node_loop() -> 
    receive
	{Left,Right,M} ->
	    node_loop(Left,Right,M,repeater)
    end.

node_loop(Left,Right,M,repeater) ->
    receive
	{Left,{busy,Origin,Recip,PayLoad}} when Recip==self() ->
	    io:format("~p got ~w from ~p\n",[self(),PayLoad,Origin]),
	    complete;
	{Left,Token} ->  %% forwarding token
	    complete
    after
	0 -> %% send a new 
	    PayLoad = rand:uniform(100),  
	    {ok, Recip} = maps:find(rand:uniform(5)-1,M),  
	    node_loop(Left,Right,PayLoad,Recip,M,sender)
    end.

node_loop(Left,Right,PayLoad,Recip,M,sender) ->
    receive
	{Left,{free,_,_,_}} ->
	    io:format("~p sending ~w to ~p\n",[self(),PayLoad,Recip]),
	    complete;
	{Left,{busy,Origin,Recip2,PayLoad2}} when Recip2==self() ->
	    io:format("~p got ~w from ~p\n",[self(),PayLoad2,Origin]),
	    io:format("~p sending ~w to ~p\n",[self(),PayLoad,Recip]),
	    complete;
	{Left,Token} -> %% forward token
	    complete
    end.
		










