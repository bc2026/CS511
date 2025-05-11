-module(ex3).
-compile(export_all).


start() ->
    ClientPid = spawn(?MODULE, client, []),  % spawn the client process
    ServerPid = spawn(?MODULE, server, [0, ClientPid]),  % spawn the server process and capture its PID
    io:format("Server PID: ~p~n", [ServerPid]),  % print the Server PID to the console
    ServerPid.  % return the Server PID


client() ->
    receive
        {ok, Count} -> io:format("Received continue ~p time(s)~n", [Count]);
        {_} -> io:format("u fucked up bro")
    end,
    client().

server(Count, From) ->
    receive
        {continue} -> 
            server(Count + 1, From);
     
        {counter} -> 
            From ! {ok, Count},
            server(Count, From)
    end.
