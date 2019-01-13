defmodule Rsed.EventDispatcher do
  @moduledoc """
  Documentation for Rsed.
  """


  # https://hexdocs.pm/elixir/GenServer.html
  # http://blog.plataformatec.com.br/2016/11/replacing-genevent-by-a-supervisor-genserver/

  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    {:ok, pid} = GenServer.start_link(__MODULE__, :ok, opts)
    Process.register(pid, __MODULE__)
    Process.monitor(pid)
    {:ok, pid}
  end

  # @todo save in process state
  defp my_pid() do
    Process.whereis(__MODULE__)
  end

  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  def dispatch(event = %Rsed.Event{}) do
    GenServer.cast(my_pid(), {:dispatch, event})

#    filter_subscribers(event.name, Rsed.EventDispatcher.subscribers())
#    |> Enum.map(fn ({module, func_name}) ->
#      IO.inspect module
#      IO.inspect func_name
#      apply(module, func_name, [event])
#    end)
  end

  defp filter_subscribers(needed_event_name, subscribers) do
    Enum.map(subscribers, fn ({_, subscriber}) ->
      subscriber.get_subscriber_events()
      |> Enum.map(fn ({name, callback}) ->
        if name == needed_event_name, do: {subscriber, callback}
      end)
      |> Enum.filter(&!is_nil(&1))
    end)
    |> Enum.map(&List.first(&1))
    |> Enum.filter(&!is_nil(&1))
  end

  def subscribers() do
    GenServer.call(my_pid(), {:subscribers})
  end

  def add_subscriber(subscriber) do
    GenServer.call(my_pid(), {:add_subscriber, subscriber})
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{subscribers: %{}, listeners: %{}}}
  end

  def handle_call({:subscribers}, _from, state) do
    {:reply, Map.get(state, :subscribers), state}
  end

  def handle_call({:add_subscriber, subscriber}, _from, state) do
    subscribers = Map.get(state, :subscribers)
                  |> Map.put(subscriber, subscriber)
    state = %{state | subscribers: subscribers}
    {:reply, :ok, state}
  end


  # @todo handle_cast
  def handle_cast({:dispatch, event}, state) do
    filter_subscribers(event.name, Map.get(state, :subscribers))
    |> Enum.map(fn ({module, func_name}) ->
      apply(module, func_name, [event])
    end)

    {:noreply, state}
  end
end