-module(bar).
-compile(export_all).
-compile(nowarn_export_all).

start(P, J) ->
    S = spawn(?MODULE, server, [0]),  % Initial: 0 patriots counted
    [spawn(?MODULE, patriots, [S]) || _ <- lists:seq(1, P)],
    [spawn(?MODULE, jets, [S]) || _ <- lists:seq(1, J)].

patriots(S) ->
    S ! {self(), patriot}.

jets(S) ->
    S ! {self(), jet},
    receive
        ok -> io:format("Jet ~p allowed in~n", [self()])
    end.

server(Patriots) ->
    receive
        {_, patriot} ->
            server(Patriots + 1);

        {From, jet} ->
            case Patriots >= 2 of
                true ->
                    From ! ok,
                    server(Patriots - 2);
                false ->
                    %% Not enough patriots yet, retry later
                    timer:sleep(10),
                    self() ! {From, jet},
                    server(Patriots)
            end
    end.
