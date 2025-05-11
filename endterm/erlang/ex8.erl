%% ex8.erl
-module(ex8).
-compile(export_all).

start() ->
    ClientPid = spawn(?MODULE, client, []),  % spawn the client process
    ServerPid = spawn(?MODULE, server, [ClientPid]),  % spawn the server process and capture its PID
    io:format("Server PID: ~p~n", [ServerPid]),  % print the Server PID to the console
    ServerPid.  % return the Server PID

client() ->
    receive
        {Ref, correct} -> 
            io:format("[~p] You got it!~n", [Ref]);
        {Ref, incorrect} -> 
            io:format("[~p] That wasn't it, guess again:~n", [Ref])
    end,
    client().  % Tail recursive call to keep the client running

server(ClientPid) ->
    io:format("Let's get started. Take a guess:~n"),
    server_loop(ClientPid).

server_loop(ClientPid) ->
    receive
        {From, Ref, Guess} -> 
            Number = 7,
            if
                Guess == Number -> 
                    ClientPid ! {Ref, correct};  % Send correct message to client
                true -> 
                    ClientPid ! {Ref, incorrect}  % Send incorrect message to client
            end,
            server_loop(ClientPid)  % Tail recursive call to continue receiving messages
    end.
