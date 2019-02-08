-module(map_and_rec).

-author("Me break").

%% map_and_rec: map_and_rec library's entry point.

-export([order_map/4, to_map/2, to_map_list/3, to_rec/1,
	 to_rec_list/2]).

%% This Path is the path to the file in which your record definitions are found
%%-include("/home/fokam/bleashup/src/bleashup_rec.hrl").
%%---EX---%%
-include("../../../../../src/bleashup_rec.hrl").

-define(FIELDS(Rec_name),
	fun () ->
		Records = records(), maps:get(Rec_name, Records)
	end()).

%% API

%%====================================================================
%% API functions
%%====================================================================
to_rec_list([], _) -> [];
to_rec_list([Head | Tail], RecName) ->
    [to_rec({Head, RecName})] ++ to_rec_list(Tail, RecName).

-spec to_rec({map(), atom()}) -> tuple().

to_rec({Map, Record_name}) ->
    Keys = maps:keys(Map),
    [Head | _] = Keys,
    Binary = erlang:is_binary(Head),
    % New_map = order_map(Map, Record_fields, maps:new(),Binary),
    New_record = {Record_name},
    Res = recorder(Map, ?FIELDS(Record_name), New_record, 2,
		   Binary),
    Res.

to_map_list([], _, _) -> [];
to_map_list([Head | Tail], RecName, Action) ->
    [to_map({RecName, Head}, Action)] ++
      to_map_list(Tail, RecName, Action).

-spec to_map({atom(), atom(), tuple()}, atom) -> map().

                               %%% tuple() represents where you will have to put your record

to_map({Record_name, Record}, Option) ->
    Rec_list = tuple_to_list(Record),
    New_rec_list = lists:delete(Record_name, Rec_list),
    mapper(?FIELDS(Record_name), New_rec_list, #{}, Option).

%%====================================================================
%% Internal functions
%%====================================================================

order_map(_, [], New_map, _) -> New_map;
order_map(Old_map, [Head | Tail], Map, Binary) ->
    New_head = case Binary of
		 true ->
		     erlang:list_to_binary(erlang:atom_to_list(Head));
		 false -> erlang:list_to_binary(Head)
	       end,
    New_map = maps:put(New_head,
		       maps:get(New_head, Old_map), Map),
    order_map(Old_map, Tail, New_map, Binary).

recorder(_Map, [], Record, _Position, _) -> Record;
recorder(Map, [Head | Tail], Record, Position,
	 Binary) ->
    New_head = case Binary of
		 true ->
		     Temp = erlang:atom_to_list(Head),
		     erlang:list_to_binary(Temp);
		 false -> erlang:atom_to_list(Head)
	       end,
    Value = maps:get(New_head, Map),
    case erlang:is_map(Value) of
      true ->
	  New_record = erlang:insert_element(Position, Record,
					     to_rec({Value, Head})),
	  recorder(Map, Tail, New_record, Position + 1, Binary);
      false ->
	  case erlang:is_list(Value) of
	    true ->
		[Temp_head | _] = Value,
		case erlang:is_map(Temp_head) of
		  true ->
		      New_recod = erlang:insert_element(Position, Record,
							to_rec_list(Value, Head,
								    [])),
		      recorder(Map, Tail, New_recod, Position + 1, Binary);
		  false ->
		      New_record = erlang:insert_element(Position, Record,
							 Value),
		      recorder(Map, Tail, New_record, Position + 1, Binary)
		end;
	    false ->
		New_record = erlang:insert_element(Position, Record,
						   Value),
		recorder(Map, Tail, New_record, Position + 1, Binary)
	  end
    end.

to_rec_list([], _, Acc) -> Acc;
to_rec_list([Head | Tail], Record_name, Acc) ->
    Rec = to_rec({Head, Record_name}),
    to_rec_list(Tail, Record_name, Acc ++ [Rec]).

%% to_map internal implementation
mapper([], _, Map, _Option) -> Map;
mapper([Head_name | Tail_name],
       [Head_element | Tail_element], Map, Option) ->
    New_head_name = case Option of
		      binary ->
			  erlang:list_to_binary(erlang:atom_to_list(Head_name));
		      string -> erlang:atom_to_list(Head_name)
		    end,
    case erlang:is_tuple(Head_element) of
      true ->
	  [Head | _] = erlang:tuple_to_list(Head_element),
	  New_head_element = to_map({Head, Head_element}, Option),
	  New_map = maps:put(New_head_name, New_head_element,
			     Map),
	  mapper(Tail_name, Tail_element, New_map, Option);
      false ->
	  case erlang:is_list(Head_element) of
	    true ->
		[Head | _] = Head_element,
		case erlang:is_tuple(Head) of
		  true ->
		      New_head_element = to_map_list(Head_element, Head_name,
						     Option, []),
		      New_map = maps:put(New_head_name, New_head_element,
					 Map),
		      mapper(Tail_name, Tail_element, New_map, Option);
		  false ->
		      New_map = maps:put(New_head_name, Head_element, Map),
		      mapper(Tail_name, Tail_element, New_map, Option)
		end;
	    false ->
		New_map = maps:put(New_head_name, Head_element, Map),
		mapper(Tail_name, Tail_element, New_map, Option)
	  end
    end.

to_map_list([], _, _, Acc) -> Acc;
to_map_list([Head | Tail], Record_name, Option, Acc) ->
    Map = to_map({Record_name, Head}, Option),
    to_map_list(Tail, Record_name, Option, Acc ++ [Map]).

%%Todo : this data is to be provided by the programer or user
records() ->
    %% This data is for my own project that i will like to use the library in.
    %% The programer is supposed to replace this by his own record data
    %% following the pattern record_name => record_info(fields,record_name).
    #{about => record_info(fields, about),
      current_event => record_info(fields, current_event),
      update => record_info(fields, update),
      location => record_info(fields, location),
      period => record_info(fields, period),
      presence => record_info(fields, presence),
      updated_offline => record_info(fields, updated_offline),
      time => record_info(fields, time),
      new_time => record_info(fields, time),
      new_date => record_info(fields, date),
      date => record_info(fields, date),
      new_event => record_info(fields, new_event),
      past_event => record_info(fields, past_event),
      updated => record_info(fields, updated),
      participant => record_info(fields, participant),
      session => record_info(fields, session),
      invitation => record_info(fields, invitation),
      users => record_info(fields, users),
      reschedule => record_info(fields, reschedule),
      reschedules => record_info(fields, reschedules),
      updates => record_info(fields, updates),
      about_update => record_info(fields, about_update),
      participant_update =>
	  record_info(fields, participant_update),
      period_update => record_info(fields, period_update),
      location_update =>
	  record_info(fields, location_update)
     %% .
     %% .
     %% .
     %% .
    }.
	

%% End of Module.
