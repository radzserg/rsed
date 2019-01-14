defmodule Rsed.Test.CustomEventDispatcher do
  use Rsed.EventDispatcher,
    name: :my_test_event_dispatcher
#    listeners: %{
#      test_event_2: [
#        {Rsed.Test.TestListener, :handler_2, 0}
#      ]
#    }
end

defmodule Rsed.Test.EventDispatcher do
  use ExUnit.Case, async: true

  import Rsed.Test.SubscriberAssert

  alias Rsed.Test.CustomEventDispatcher, as: EventDispatcher

  setup do
    test_file_path = System.cwd() <> "/test/files"
    File.rm_rf!(test_file_path)
    File.mkdir(test_file_path)

    dispatcher = start_supervised!(EventDispatcher)
    %{event_dispatcher: dispatcher}
  end

  test "subscribed subscribers handle event" do
    EventDispatcher.add_subscriber(Rsed.Test.TestSubscriber)
    EventDispatcher.add_subscriber(Rsed.Test.TestSubscriber2)
    event = %Rsed.Event{name: :test_event_2, data: %{"some data" => 1}}

    assert :ok == EventDispatcher.dispatch(event)
    Process.sleep(1000)

    assert callback_worked(Rsed.Test.TestSubscriber2, :handler_2)
    refute callback_worked(Rsed.Test.TestSubscriber, :handler_2)
  end

  test "subscribed listeners handle event" do
    EventDispatcher.add_listener(:test_event_2, {Rsed.Test.TestListener, :handler_2})
    event = %Rsed.Event{name: :test_event_2, data: %{"some data" => 1}}

    assert :ok == EventDispatcher.dispatch(event)
    Process.sleep(1000)

    assert callback_worked(Rsed.Test.TestListener, :handler_2)
  end
end
