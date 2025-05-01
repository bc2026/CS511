-module(my_timer).
-compile(export_all).

start(Frequency, PIDs) ->
    spawn(?MODULE, my_timer, [Frequency, PIDs]).

my_timer(_, []) ->
    ok;

my_timer(Frequency, [H | T]) ->
    L = [],
    receive
        {register, PID} -> L ++ PID,
        {confirm_reg, PID};
        {PID} ->
            if 
                !lists:member(PID, L) -> {not_regsitered, PID}
                true ->
                    timer:sleep(Frequency),
                    H ! {tick},
                    my_timer(Frequency, T).
            end.
