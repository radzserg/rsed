defmodule Rsed.Test.EventDispatcher do
  use ExUnit.Case, async: true

  setup do
    test_file_path = System.cwd() <> "/test/files"
    File.rm_rf!(test_file_path)
    File.mkdir(test_file_path)

    dispatcher = start_supervised!(Rsed.EventDispatcher)
    %{event_dispatcher: dispatcher}
  end

  test "it dispatches event" do
    Rsed.EventDispatcher.add_subscriber(Rsed.Test.TestSubscriber)
    Rsed.EventDispatcher.add_subscriber(Rsed.Test.TestSubscriber2)
    event = %Rsed.Event{name: :test_event_2, data: %{"some data" => 1}}
    assert :ok == Rsed.EventDispatcher.dispatch(event)

    # give some time for async tasks handlers
    Process.sleep(1000)

    assert_callback_worked(Rsed.Test.TestSubscriber2, :handler_2)
    refute_callback_worked(Rsed.Test.TestSubscriber, :handler_2)
  end

  test "it adds subscriber" do
    Rsed.EventDispatcher.add_subscriber(Rsed.Test.TestSubscriber)
    Rsed.EventDispatcher.add_subscriber(Rsed.Test.TestSubscriber)
    Rsed.EventDispatcher.add_subscriber(Rsed.Test.TestSubscriber2)
    assert %{Rsed.Test.TestSubscriber => Rsed.Test.TestSubscriber,
      Rsed.Test.TestSubscriber2 => Rsed.Test.TestSubscriber2} == Rsed.EventDispatcher.subscribers()
  end

  defp refute_callback_worked(subscriber, func_name) do
    refute File.exists?(test_subscriber_path(subscriber, func_name))
  end

  defp assert_callback_worked(subscriber, func_name) do
    assert File.exists?(test_subscriber_path(subscriber, func_name))
  end

  defp test_subscriber_path(subscriber, func_name) do
    file_name = List.last(String.split(to_string(subscriber), ".")) <> "_#{func_name}.txt"
    System.cwd() <> "/test/files/#{file_name}"
  end

end