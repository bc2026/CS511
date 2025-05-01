-module(ex6).
-compile(export_all).

%%% Prime check logic
is_prime(N) when N < 2 ->
    false;
is_prime(2) ->
    true;
is_prime(N) when N rem 2 == 0 ->
    false;
is_prime(N) ->
    is_prime(N, 3).

is_prime(N, F) when F * F > N ->
    true;
is_prime(N, F) when N rem F == 0 ->
    false;
is_prime(N, F) ->
    is_prime(N, F + 2).

%%% Entry point
start(N) ->
    S = spawn(?MODULE, server, []),
    [spawn(?MODULE, client, [S, X]) || X <- lists:seq(1, N)].

%%% Client sends number to check
client(S, N) ->
    S ! {check, N, self()},
    receive
        {N, Result} ->
            io:format("~p: ~p is prime? ~p~n", [self(), N, Result])
    end.

%%% Server handles check requests
server() ->
    receive
        {check, N, From} ->
            From ! {N, is_prime(N)},
            server();  % loop again
        _ ->
            server()
    end.
