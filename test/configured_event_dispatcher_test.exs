defmodule Rsed.Test.ConfiguredEventDispatcherTest do
  use ExUnit.Case, async: true

  import Rsed.Test.SubscriberAssert

  alias Rsed.Test.ConfiguredEventDispatcher

  setup do
    test_file_path = System.cwd() <> "/test/files"
    File.rm_rf!(test_file_path)
    File.mkdir(test_file_path)

    dispatcher = start_supervised!(ConfiguredEventDispatcher)
    %{event_dispatcher: dispatcher}
  end

  test "subscribed listeners handle event" do
    event = %Rsed.Event{name: :test_event_2, data: %{"some data" => 1}}

    assert :ok == ConfiguredEventDispatcher.dispatch(event)
    Process.sleep(1000)

    assert callback_worked(Rsed.Test.TestListener, :handler_2)
  end
end
