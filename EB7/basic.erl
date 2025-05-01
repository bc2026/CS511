
-module(basic).  % Module name must match the filename (without .erl)
-export([mult/2, double/1, distance/2, my_and/2, my_or/2, fib/1]).

mult(X,Y) -> X*Y.
double(X) -> 2*X.
distance(X,Y) -> math:sqrt(math:pow(X,2) +  math:pow(Y,2)).

my_and(X,Y) -> 
	if
	       	X==true, Y == true -> true;
		true -> false
	end.


my_or(X,Y) ->
	if
		X ==  true -> true;
		Y == true -> true;
		true -> false
	end.


fib(X) -> 
			if
				X == 0 -> 0;
				X == 1 -> 1;
				true -> fib(X-2) + fib(X-1)
			end.



fib_tr(0, A) -> 0;
fib_tr(1, A) -> 1;
fib_tr(N,A) -> when N > 1 -> A + fib_tr(N-1, fib_tr(N)).
	
