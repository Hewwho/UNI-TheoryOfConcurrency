%%%-------------------------------------------------------------------
%%% @author maszl
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. lis 2019 13:49
%%%-------------------------------------------------------------------
-module(t).
-author("maszl").

-export([start/0, producer_spawner/2, consumer_spawner/2, buffer_spawner/2, buffer_server/2, buffer/3, producer/2, consumer/1]).


start() ->
  Producers = 58,
  Consumers = 73,
  Buffers = 64,

  ID_buffer_server = spawn_link(t, buffer_server, [[], []]),

  buffer_spawner(ID_buffer_server, Buffers),
  producer_spawner(ID_buffer_server, Producers),
  consumer_spawner(ID_buffer_server, Consumers).



producer_spawner(ID_buffer_server, 0) ->
  ok;

producer_spawner(ID_buffer_server, Producers) ->
  spawn_link(t, producer, [ID_buffer_server, Producers-1]),

  producer_spawner(ID_buffer_server, Producers-1).


consumer_spawner(ID_buffer_server, 0) ->
  ok;

consumer_spawner(ID_buffer_server, Consumers) ->
  spawn_link(t, consumer, [ID_buffer_server]),

  consumer_spawner(ID_buffer_server, Consumers-1).


buffer_spawner(ID_buffer_server, 0) ->
  ok;

buffer_spawner(ID_buffer_server, Buffers) ->
  spawn_link(t, buffer, [ID_buffer_server, true, -1]),

  buffer_spawner(ID_buffer_server, Buffers-1).



producer(ID_buffer_server, Value) ->
  ID_buffer_server ! {producer, self()},

  receive
    {buffer_server, ID_buffer} ->
      ID_buffer ! {producer, self(), Value},
      receive
        {buffer} ->
          io:format("~p PRODUCED: ~p~n", [self(), Value])
      end
  end,

  producer(ID_buffer_server, Value).


consumer(ID_buffer_server) ->
  ID_buffer_server ! {consumer, self()},

  receive
    {buffer_server, ID_buffer} ->
      ID_buffer ! {consumer, self()},
      receive
        {buffer, Value} ->
          io:format("~p CONSUMED: ~p~n", [self(), Value])
      end
  end,

  consumer(ID_buffer_server).



buffer_server(List_P, List_C) ->
  if
    length(List_P) > 0 ->
      receive
        {buffer, empty, ID_buffer} ->
          {ID_producer_L, List_P2} = lists:split(1, List_P),
          ID_producer = lists:last(ID_producer_L),
          ID_producer ! {buffer_server, ID_buffer},
          buffer_server(List_P2, List_C)
      after
        0 ->
          buffer_server_C(List_P, List_C)
      end;
    true ->
      if
        length(List_C) > 0 ->
          receive
            {buffer, full, ID_buffer} ->
              {ID_consumer_L, List_C2} = lists:split(1, List_C),
              ID_consumer = lists:last(ID_consumer_L),
              ID_consumer ! {buffer_server, ID_buffer},
              buffer_server(List_P, List_C2)
          after
            0 ->
              buffer_server_P(List_P, List_C)
          end;
        true ->
          receive
            {producer, ID_producer} ->
              receive
                {buffer, empty, ID_buffer} ->
                  ID_producer ! {buffer_server, ID_buffer}
              after
                0 ->
                  buffer_server_C(lists:append(List_P, [ID_producer]), List_C)
              end;

            {consumer, ID_consumer} ->
              receive
                {buffer, full, ID_buffer} ->
                  ID_consumer ! {buffer_server, ID_buffer}
              after
                0 ->
                  buffer_server_P(List_P, lists:append(List_C, [ID_consumer]))
              end
          end
      end
  end,

  buffer_server(List_P, List_C).



buffer(ID_buffer_server, Empty, Value) ->
  if
    Empty == true ->
      ID_buffer_server ! {buffer, empty, self()},

      receive
        {producer, ID_producer, Value_producer} ->
          timer:sleep(500),
          ID_producer ! {buffer},
          buffer(ID_buffer_server, false, Value_producer)
      end;

    true ->
      ID_buffer_server ! {buffer, full, self()},

      receive
        {consumer, ID_consumer} ->
          timer:sleep(500),
          ID_consumer ! {buffer, Value},
          buffer(ID_buffer_server, true, -1)
      end
  end.



buffer_server_P(List_P, List_C) ->
  if
    length(List_P) > 0 ->
      receive
        {buffer, empty, ID_buffer} ->
          {ID_producer_L, List_P2} = lists:split(1, List_P),
          ID_producer = lists:last(ID_producer_L),
          ID_producer ! {buffer_server, ID_buffer},
          buffer_server(List_P2, List_C)
      after
        0 ->
          buffer_server_C(List_P, List_C)
      end;
    true ->
      receive
        {producer, ID_producer} ->
          receive
            {buffer, empty, ID_buffer} ->
              ID_producer ! {buffer_server, ID_buffer}
          after
            0 ->
              buffer_server_C(lists:append(List_P, [ID_producer]), List_C)
          end
      end
  end,

  buffer_server(List_P, List_C).


buffer_server_C(List_P, List_C) ->
  if
    length(List_C) > 0 ->
      receive
        {buffer, full, ID_buffer} ->
          {ID_consumer_L, List_C2} = lists:split(1, List_C),
          ID_consumer = lists:last(ID_consumer_L),
          ID_consumer ! {buffer_server, ID_buffer},
          buffer_server(List_P, List_C2)
      after
        0 ->
          buffer_server_P(List_P, List_C)
      end;
    true ->
      receive
        {consumer, ID_consumer} ->
          receive
            {buffer, full, ID_buffer} ->
              ID_consumer ! {buffer_server, ID_buffer}
          after
            0 ->
              buffer_server_P(List_P, lists:append(List_C, [ID_consumer]))
          end
      end
  end,

  buffer_server(List_P, List_C).




%%%%%-------------------------------------------------------------------
%%%%% @author maszl
%%%%% @copyright (C) 2019, <COMPANY>
%%%%% @doc
%%%%%
%%%%% @end
%%%%% Created : 27. lis 2019 13:49
%%%%%-------------------------------------------------------------------
%%-module(t).
%%-author("maszl").
%%
%%-export([start/0, producer_spawner/2, consumer_spawner/2, buffer_spawner/2, buffer_server/2, buffer/3, producer/2, consumer/1]).
%%
%%
%%start() ->
%%  Producers = 58,
%%  Consumers = 73,
%%  Buffers = 64,
%%
%%  ID_buffer_server = spawn_link(t, buffer_server, [0, erlang:timestamp()]),
%%
%%  buffer_spawner(ID_buffer_server, Buffers),
%%  producer_spawner(ID_buffer_server, Producers),
%%  consumer_spawner(ID_buffer_server, Consumers).
%%
%%
%%
%%producer_spawner(ID_buffer_server, 0) ->
%%  ok;
%%
%%producer_spawner(ID_buffer_server, Producers) ->
%%  spawn_link(t, producer, [ID_buffer_server, Producers-1]),
%%
%%  producer_spawner(ID_buffer_server, Producers-1).
%%
%%
%%consumer_spawner(ID_buffer_server, 0) ->
%%  ok;
%%
%%consumer_spawner(ID_buffer_server, Consumers) ->
%%  spawn_link(t, consumer, [ID_buffer_server]),
%%
%%  consumer_spawner(ID_buffer_server, Consumers-1).
%%
%%
%%buffer_spawner(ID_buffer_server, 0) ->
%%  ok;
%%
%%buffer_spawner(ID_buffer_server, Buffers) ->
%%  spawn_link(t, buffer, [ID_buffer_server, true, -1]),
%%
%%  buffer_spawner(ID_buffer_server, Buffers-1).
%%
%%
%%
%%producer(ID_buffer_server, Value) ->
%%  ID_buffer_server ! {producer, self()},
%%
%%  receive
%%    {buffer_server, timeout} ->
%%      producer(ID_buffer_server, Value);
%%
%%    {buffer_server, ID_buffer} ->
%%      ID_buffer ! {producer, self(), Value},
%%      receive
%%        {buffer} ->
%%          io:format("~p PRODUCED: ~p~n", [self(), Value])
%%      end
%%  end,
%%
%%  producer(ID_buffer_server, Value).
%%
%%
%%consumer(ID_buffer_server) ->
%%  ID_buffer_server ! {consumer, self()},
%%
%%  receive
%%    {buffer_server, timeout} ->
%%      consumer(ID_buffer_server);
%%
%%    {buffer_server, ID_buffer} ->
%%      ID_buffer ! {consumer, self()},
%%      receive
%%        {buffer, Value} ->
%%          io:format("~p CONSUMED: ~p~n", [self(), Value])
%%      end
%%  end,
%%
%%  consumer(ID_buffer_server).
%%
%%
%%
%%buffer_server(Counter, Time) ->
%%  if
%%    Counter == 1000 ->
%%      io:format("TIME: ~p~n", [timer:now_diff(erlang:timestamp(), Time) / 1000000]),
%%      erlang:halt();
%%    true ->
%%      receive
%%        {producer, ID_producer} ->
%%          receive
%%            {buffer, empty, ID_buffer} ->
%%              ID_producer ! {buffer_server, ID_buffer}
%%          after
%%            0 ->
%%              ID_producer ! {buffer_server, timeout},
%%              buffer_server_C(Counter, Time)
%%          end;
%%
%%        {consumer, ID_consumer} ->
%%          receive
%%            {buffer, full, ID_buffer} ->
%%              ID_consumer ! {buffer_server, ID_buffer}
%%          after
%%            0 ->
%%              ID_consumer ! {buffer_server, timeout},
%%              buffer_server_P(Counter, Time)
%%          end
%%      end,
%%
%%      buffer_server(Counter + 1, Time)
%%  end.
%%
%%
%%
%%buffer(ID_buffer_server, Empty, Value) ->
%%  if
%%    Empty == true ->
%%      ID_buffer_server ! {buffer, empty, self()},
%%
%%      receive
%%        {producer, ID_producer, Value_producer} ->
%%          timer:sleep(500),
%%          ID_producer ! {buffer},
%%          buffer(ID_buffer_server, false, Value_producer)
%%      end;
%%
%%    true ->
%%      ID_buffer_server ! {buffer, full, self()},
%%
%%      receive
%%        {consumer, ID_consumer} ->
%%          timer:sleep(500),
%%          ID_consumer ! {buffer, Value},
%%          buffer(ID_buffer_server, true, -1)
%%      end
%%  end.
%%
%%
%%buffer_server_P(Counter, Time) ->
%%  receive
%%    {producer, ID_producer} ->
%%      receive
%%        {buffer, empty, ID_buffer} ->
%%          ID_producer ! {buffer_server, ID_buffer}
%%      after
%%        0 ->
%%          buffer_server_C(Counter, Time)
%%      end
%%  end,
%%
%%  buffer_server(Counter + 1, Time).
%%
%%
%%buffer_server_C(Counter, Time) ->
%%  receive
%%    {consumer, ID_consumer} ->
%%      receive
%%        {buffer, full, ID_buffer} ->
%%          ID_consumer ! {buffer_server, ID_buffer}
%%      after
%%        0 ->
%%          buffer_server_P(Counter, Time)
%%      end
%%  end,
%%
%%  buffer_server(Counter + 1, Time).