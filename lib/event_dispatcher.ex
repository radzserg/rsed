defmodule Rsed.EventDispatcher do
  @moduledoc """
    EventDispatcher component implements the Mediator and Observer design patterns
    to make all these things possible and to make your projects truly extensible.
  """
  defmacro __using__(opts) do
    name = Keyword.get(opts, :name)
    quote do

      use GenServer

      @doc """
      Starts the registry.
      """
      def start_link(_opts \\ []) do
        GenServer.start_link(__MODULE__, :ok, name: my_name())
      end

      defp my_name() do
        unquote(name)
      end

      @doc """
      Dispatches an event  to all registered listeners and subscribers
      """
      @spec dispatch(event :: Rsed.Event.t) :: term
      def dispatch(event = %Rsed.Event{}) do
        GenServer.cast(my_name(), {:dispatch, event})
      end

      @doc """
      Adds an event subscriber

      The subscriber is asked for all the events it is
      interested in and added as a listener for these events.

      """
      @spec add_subscriber(subscriber :: module()) :: term
      def add_subscriber(subscriber) do
        GenServer.call(my_name(), {:add_subscriber, subscriber})
      end

      @doc """
      Adds an event listener that listens on the specified events.
      """
      @spec add_listener(event_name :: String.t(), listener :: {module :: module(), callback: atom()}, priority :: integer()) :: term
      def add_listener(event_name, listener, priority \\ 0) do
        GenServer.call(my_name(), {:add_listener, event_name, listener, priority})
      end

      def init(:ok) do
        listeners = if Keyword.has_key?(__MODULE__.__info__(:functions), :configure) do
          apply(__MODULE__, :configure, [])
        else
          %{}
        end

        {:ok, listeners}
      end

      def handle_call({:add_subscriber, subscriber}, _from, listeners) do
        listeners = Rsed.ListenersBag.add_subscriber(listeners, subscriber)
        {:reply, :ok, listeners}
      end

      def handle_call({:add_listener, event_name, callback, priority}, _from, listeners) do
        listeners = Rsed.ListenersBag.add_listener(listeners, event_name, callback, priority)
        {:reply, :ok, listeners}
      end

      def handle_cast({:dispatch, event}, state) do
        Rsed.ListenersBag.get_event_handlers(state, event.name)
        |> Enum.map(fn {module, func_name, _} ->
          apply(module, func_name, [event])
        end)

        {:noreply, state}
      end
    end
  end
end
