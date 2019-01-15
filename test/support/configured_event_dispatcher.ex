defmodule Rsed.Test.ConfiguredEventDispatcher do
  use Rsed.EventDispatcher,
      name: :my_test_event_dispatcher_configured

  def configure(listeners \\ %{}) do
    listeners
    |> Rsed.ListenersBag.add_listener(:test_event_2, {Rsed.Test.TestListener, :handler_2})
    |> Rsed.ListenersBag.add_subscriber(Rsed.Test.TestSubscriber)
  end
end