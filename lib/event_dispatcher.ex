defmodule Rsed.EventDispatcher do
  @moduledoc """
    EventDispatcher component implements the Mediator and Observer design patterns
    to make all these things possible and to make your projects truly extensible.
  """

  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    {:ok, pid} = GenServer.start_link(__MODULE__, :ok, opts)
    Process.register(pid, __MODULE__)
    {:ok, pid}
  end

  # @todo think about better way how can we keep my pid
  defp my_pid() do
    Process.whereis(__MODULE__)
  end

  @doc """
  Dispatches an event  to all registered listeners and subscribers
  """
  @spec dispatch(event :: Rsed.Event.t) :: term
  def dispatch(event = %Rsed.Event{}) do
    GenServer.cast(my_pid(), {:dispatch, event})
  end

  @doc """
  Adds an event subscriber

  The subscriber is asked for all the events it is
  interested in and added as a listener for these events.

  """
  @spec add_subscriber(subscriber :: module()) :: term
  def add_subscriber(subscriber) do
    GenServer.call(my_pid(), {:add_subscriber, subscriber})
  end

  @doc """
  Adds an event listener that listens on the specified events.
  """
  @spec add_listener(event_name :: String.t(), listener :: {module :: module(), callback: atom()}) :: term
  def add_listener(event_name, listener) do
    GenServer.call(my_pid(), {:add_listener, event_name, listener})
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:add_subscriber, subscriber}, _from, listeners) do
    listeners = Rsed.ListenersBag.add_subscriber(listeners, subscriber)
    {:reply, :ok, listeners}
  end

  def handle_call({:add_listener, event_name, callback}, _from, listeners) do
    listeners = Rsed.ListenersBag.add_listener(listeners, event_name, callback)
    {:reply, :ok, listeners}
  end

  def handle_cast({:dispatch, event}, state) do
    Map.get(state, event.name, [])
    |> Enum.map(fn {module, func_name, _} ->
      apply(module, func_name, [event])
    end)

    {:noreply, state}
  end
end
