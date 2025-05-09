-module(shipping).
-compile(export_all).
-include_lib("./shipping.hrl").

get_ship(Shipping_State, Ship_ID) ->
    {shipping_state, ShipList, _, _, _, _, _} = Shipping_State,
    case lists:keyfind(Ship_ID, 2, ShipList) of
        false -> throw({error, {ship_not_found, Ship_ID}});
        Ship -> Ship
    end.

get_container(Shipping_State, Container_ID) ->
    {shipping_state, _ShipList, ContainersList, _, _, _,_} = Shipping_State,
    case lists:keyfind(Container_ID, 2, ContainersList) of
        false -> throw(error);
        Container -> Container
    end.

get_port(Shipping_State, Port_ID) ->
    {shipping_state, _ShipList, _ContainersList, PortList, _, _, _} = Shipping_State,
    case lists:keyfind(Port_ID, 2, PortList) of 
        false -> throw(error);
        Port -> Port
    end.

get_occupied_docks_helper(L) ->
    case L of 
        [] -> [];
        [{_, Dock, _} | T] ->
            [Dock | get_occupied_docks_helper(T)]
    end.

get_occupied_docks(Shipping_State, Port_ID) ->
    {shipping_state, _ShipList, _ContainersList, _PortList, LocationsList, _, _} = Shipping_State,
    L = lists:filter(fun({Key, _, _}) -> Key =:= Port_ID end, LocationsList),
    get_occupied_docks_helper(L).



get_ship_location_helper([{PortID, Dock, _}])->
    {PortID, Dock}.

get_ship_location(Shipping_State, Ship_ID) ->
    %% PortID with get_port
    %% DockID by looking up the name in that port
    {shipping_state, _ShipList, _ContainersList, _PortList, LocationsList, _, _} = Shipping_State,
    case lists:filter(fun({_, _, Key}) -> Key =:= Ship_ID end, LocationsList) of
        [] -> throw(error);
        L -> get_ship_location_helper(L)
    end.


get_container_weight_helper(Shipping_State, [H | T]) ->
    try
        case get_container(Shipping_State, H) of
            {container, H, Weight} ->
                Weight + get_container_weight_helper(Shipping_State, T)
        end
    catch
        throw:error ->
            throw(error)
    end;

get_container_weight_helper(_, []) ->
    0.    

get_container_weight(Shipping_State, Container_IDs) -> 
    get_container_weight_helper(Shipping_State, Container_IDs).


get_ship_weight(Shipping_State, Ship_ID) ->
    
    try
        case get_ship(Shipping_State, Ship_ID) of
            {ship,Ship_ID, _, _} ->
                {shipping_state, _ShipList, _ContainersList, _PortList, _LocationsList, Ship_Inventory, _} = Shipping_State,
                Container_IDs = maps:get(Ship_ID, Ship_Inventory),
                get_container_weight(Shipping_State, Container_IDs)
            end
    catch 
        throw:error -> throw(error)
    end.





%% Determines whether all of the elements of Sub_List are also elements of Target_List
%% @returns true is all elements of Sub_List are members of Target_List; false otherwise
is_sublist(Target_List, Sub_List) ->
    lists:all(fun (Elem) -> lists:member(Elem, Target_List) end, Sub_List).



%% Prints out the current shipping state in a more friendly format
print_state(Shipping_State) ->
    io:format("--Ships--~n"),
    _ = print_ships(Shipping_State#shipping_state.ships, Shipping_State#shipping_state.ship_locations, Shipping_State#shipping_state.ship_inventory, Shipping_State#shipping_state.ports),
    io:format("--Ports--~n"),
    _ = print_ports(Shipping_State#shipping_state.ports, Shipping_State#shipping_state.port_inventory).


%% helper function for print_ships
get_port_helper([], _Port_ID) -> error;
get_port_helper([ Port = #port{id = Port_ID} | _ ], Port_ID) -> Port;
get_port_helper( [_ | Other_Ports ], Port_ID) -> get_port_helper(Other_Ports, Port_ID).


print_ships(Ships, Locations, Inventory, Ports) ->
    case Ships of
        [] ->
            ok;
        [Ship | Other_Ships] ->
            {Port_ID, Dock_ID, _} = lists:keyfind(Ship#ship.id, 3, Locations),
            Port = get_port_helper(Ports, Port_ID),
            {ok, Ship_Inventory} = maps:find(Ship#ship.id, Inventory),
            io:format("Name: ~s(#~w)    Location: Port ~s, Dock ~s    Inventory: ~w~n", [Ship#ship.name, Ship#ship.id, Port#port.name, Dock_ID, Ship_Inventory]),
            print_ships(Other_Ships, Locations, Inventory, Ports)
    end.

print_containers(Containers) ->
    io:format("~w~n", [Containers]).

print_ports(Ports, Inventory) ->
    case Ports of
        [] ->
            ok;
        [Port | Other_Ports] ->
            {ok, Port_Inventory} = maps:find(Port#port.id, Inventory),
            io:format("Name: ~s(#~w)    Docks: ~w    Inventory: ~w~n", [Port#port.name, Port#port.id, Port#port.docks, Port_Inventory]),
            print_ports(Other_Ports, Inventory)
    end.
%% This functions sets up an initial state for this shipping simulation. You can add, remove, or modidfy any of this content. This is provided to you to save some time.
%% @returns {ok, shipping_state} where shipping_state is a shipping_state record with all the initial content.

% add_items_to_ship(ShipCap, Containers) ->
    

verify_containers_at_port(Shipping_State, Curr_Port, Container_IDs) ->
    %% just need to verify container_ids has all members as containers_at_port
    {shipping_state, _ShipList, _ContainersList, _PortList, _LocationsList, _Ship_Inventory, Port_Inventory} = Shipping_State,
    Containers_At_Port = maps:get(Curr_Port, Port_Inventory),
    is_sublist(Containers_At_Port, Container_IDs).

load_ship(Shipping_State, Ship_ID, Container_IDs) ->
    {Curr_Port, _} = get_ship_location(Shipping_State, Ship_ID),
    {shipping_state, _ShipList, _ContainersList, _PortList, _LocationsList, Ship_Inventory, Port_Inventory} = Shipping_State,

    case verify_containers_at_port(Shipping_State, Curr_Port, Container_IDs) of
        true ->  
            CurrContainerList = maps:get(Ship_ID, Ship_Inventory),  
            {ship, _, _, ShipCap} = get_ship(Shipping_State, Ship_ID),
            NewContainerList = lists:append(CurrContainerList, Container_IDs),

            if 
                length(NewContainerList) =< ShipCap ->
                    NewPortContainerList = lists:subtract(maps:get(Curr_Port, Port_Inventory), Container_IDs),
                    NewPortInventory = maps:put(Curr_Port, NewPortContainerList, Port_Inventory),
                    NewShipInventory = maps:put(Ship_ID, NewContainerList, Ship_Inventory),
                    NewShippingState = Shipping_State#shipping_state{ship_inventory = NewShipInventory, port_inventory = NewPortInventory},
                    {ok, NewShippingState};
                true -> throw(error)
            end;
        false -> throw(error)
    end.


unload_ship_all(Shipping_State, Ship_ID) ->
    {Curr_Port, _} = get_ship_location(Shipping_State, Ship_ID),
    {shipping_state, _ShipList, _ContainersList, _PortList, _LocationsList, Ship_Inventory, Port_Inventory} = Shipping_State,
    
    ShipContainerList = maps:get(Ship_ID, Ship_Inventory),
    PortContainerList = maps:get(Curr_Port, Port_Inventory),

    TotalAfterUnload = length(PortContainerList) + length(ShipContainerList),
    {port, _, _, _, PortCapacity} = get_port(Shipping_State, Curr_Port),
 
    if 
        TotalAfterUnload =< PortCapacity -> 
            NewPortContainerList = lists:append(PortContainerList, ShipContainerList),
            NewShipInventory = maps:put(Ship_ID, [], Ship_Inventory),
            NewPortInventory = maps:put(Curr_Port, NewPortContainerList, Port_Inventory),
            NewShippingState = Shipping_State#shipping_state{ship_inventory = NewShipInventory, port_inventory = NewPortInventory},
            {ok, NewShippingState};
        true -> throw(error)
    end.


unload_ship_helper([], _L) -> true;
unload_ship_helper([H | T], L) ->
    case lists:member(H, L) of
        true -> unload_ship_helper(T, L);
        false -> false
    end.

unload_ship(Shipping_State, Ship_ID, Container_IDs) ->
    {Curr_Port, _} = get_ship_location(Shipping_State, Ship_ID),
    {shipping_state, _ShipList, _ContainersList, _PortList, _LocationsList, Ship_Inventory, Port_Inventory} = Shipping_State,
    
    ShipContainerList = maps:get(Ship_ID, Ship_Inventory),
    PortContainerList = maps:get(Curr_Port, Port_Inventory),

    ValidUnload = is_sublist(ShipContainerList, Container_IDs),
    TotalAfterUnload = length(PortContainerList) + length(Container_IDs),
    {port, _, _, _, PortCapacity} = get_port(Shipping_State, Curr_Port),

    if 
        ValidUnload andalso TotalAfterUnload =< PortCapacity -> 
            NewPortContainerList = lists:append(PortContainerList, Container_IDs),
            NewShipContainerList = lists:subtract(ShipContainerList, Container_IDs),
            NewShipInventory = maps:put(Ship_ID, NewShipContainerList, Ship_Inventory),
            NewPortInventory = maps:put(Curr_Port, NewPortContainerList, Port_Inventory),
            NewShippingState = Shipping_State#shipping_state{ship_inventory = NewShipInventory, port_inventory = NewPortInventory},
            {ok, NewShippingState};
        true -> throw(error)
    end.

set_sail(Shipping_State, Ship_ID, {Port_ID, Dock}) ->
    {shipping_state, ShipList, ContainersList, PortList, LocationsList, ShipInventory, PortInventory} = Shipping_State,

    % Ensure the port exists
    Port = case lists:keyfind(Port_ID, #port.id, PortList) of
        false -> throw({error, port_not_found});
        P -> P
    end,

    % Ensure the dock exists at the port
    case lists:member(Dock, Port#port.docks) of
        false -> throw({error, invalid_dock});
        true -> ok
    end,

    % Ensure dock is not occupied
    OccupiedDocks = get_occupied_docks(Shipping_State, Port_ID),
    case lists:member(Dock, OccupiedDocks) of
        true -> throw({error, dock_occupied});
        false -> ok
    end,

    % Replace ship location in-place
UpdatedLocations = lists:map(
    fun({P, D, ID}) ->
        case ID =:= Ship_ID of
            true -> {Port_ID, Dock, Ship_ID};
            false -> {P, D, ID}
        end
    end,
    LocationsList
),

    % Return the updated state wrapped in {ok, ...}
    {ok, Shipping_State#shipping_state{
        ship_locations = UpdatedLocations
    }}.



shipco() ->
    Ships = [#ship{id=1,name="Santa Maria",container_cap=20},
              #ship{id=2,name="Nina",container_cap=20},
              #ship{id=3,name="Pinta",container_cap=20},
              #ship{id=4,name="SS Minnow",container_cap=20},
              #ship{id=5,name="Sir Leaks-A-Lot",container_cap=20}
             ],
    Containers = [
                  #container{id=1,weight=200},
                  #container{id=2,weight=215},
                  #container{id=3,weight=131},
                  #container{id=4,weight=62},
                  #container{id=5,weight=112},
                  #container{id=6,weight=217},
                  #container{id=7,weight=61},
                  #container{id=8,weight=99},
                  #container{id=9,weight=82},
                  #container{id=10,weight=185},
                  #container{id=11,weight=282},
                  #container{id=12,weight=312},
                  #container{id=13,weight=283},
                  #container{id=14,weight=331},
                  #container{id=15,weight=136},
                  #container{id=16,weight=200},
                  #container{id=17,weight=215},
                  #container{id=18,weight=131},
                  #container{id=19,weight=62},
                  #container{id=20,weight=112},
                  #container{id=21,weight=217},
                  #container{id=22,weight=61},
                  #container{id=23,weight=99},
                  #container{id=24,weight=82},
                  #container{id=25,weight=185},
                  #container{id=26,weight=282},
                  #container{id=27,weight=312},
                  #container{id=28,weight=283},
                  #container{id=29,weight=331},
                  #container{id=30,weight=136}
                 ],
    Ports = [
             #port{
                id=1,
                name="New York",
                docks=['A','B','C','D'],
                container_cap=200
               },
             #port{
                id=2,
                name="San Francisco",
                docks=['A','B','C','D'],
                container_cap=200
               },
             #port{
                id=3,
                name="Miami",
                docks=['A','B','C','D'],
                container_cap=200
               }
            ],
    %% {port, dock, ship}
    Locations = [
                 {1, 'B',  1},
                 {1, 'A', 3},
                 {3, 'C', 2},
                 {2, 'D', 4},
                 {2, 'B', 5}
                ],
    Ship_Inventory = #{
    
      1=>[14,15,9,2,6],
      2=>[1,3,4,13],
      3=>[],
      4=>[2,8,11,7],
      5=>[5,10,12]},
    Port_Inventory = #{
        % Container IDs mapped to each port id
      1=>[16,17,18,19,20],
      2=>[21,22,23,24,25],
      3=>[26,27,28,29,30]
     },
    #shipping_state{ships = Ships, containers = Containers, ports = Ports, ship_locations = Locations, ship_inventory = Ship_Inventory, port_inventory = Port_Inventory}.
