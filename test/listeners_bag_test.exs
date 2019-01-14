defmodule Rsed.Test.ListenerBagDispatcher do
  use ExUnit.Case, async: true

  test "it adds all subscribed events to empty listeners" do
    listeners = %{}

    expected_listeners = %{
      test_event_2: [{Rsed.Test.TestSubscriber2, :handler_2, 0}],
      test_event_3: [{Rsed.Test.TestSubscriber2, :test_event_3_handler, 0}],
      test_event_4: [
        {Rsed.Test.TestSubscriber2, :handler_5, 100},
        {Rsed.Test.TestSubscriber2, :handler_6, 200}
      ]
    }

    assert expected_listeners == Rsed.ListenersBag.add_subscriber(listeners, Rsed.Test.TestSubscriber2)
  end

  test "it adds subscriber to listeners" do
    listeners = %{
      test_event_2: [{Rsed.Test.TestSubscriber, :handler_2, 100}],
      test_event_5: [{Rsed.Test.TestSubscriber, :handler_5, 100}],
    }

    expected_listeners = %{
      test_event_2: [
        {Rsed.Test.TestSubscriber2, :handler_2, 0},
        {Rsed.Test.TestSubscriber, :handler_2, 100}
      ],
      test_event_5: [{Rsed.Test.TestSubscriber, :handler_5, 100}],
      test_event_3: [{Rsed.Test.TestSubscriber2, :test_event_3_handler, 0}],
      test_event_4: [
        {Rsed.Test.TestSubscriber2, :handler_5, 100},
        {Rsed.Test.TestSubscriber2, :handler_6, 200}
      ]
    }

    assert expected_listeners == Rsed.ListenersBag.add_subscriber(listeners, Rsed.Test.TestSubscriber2)
  end

  test "it adds subscriber callback to listeners" do
    listeners = %{
      test_event_2: [{Rsed.Test.TestSubscriber, :handler_2, 100}],
      test_event_5: [{Rsed.Test.TestSubscriber, :handler_5, 100}],
    }

    expected_listeners = %{
      test_event_2: [
        {Rsed.Test.TestSubscriber, :handler_2, 100},
        {Rsed.Test.TestListener, :handler_2, 300},
      ],
      test_event_5: [{Rsed.Test.TestSubscriber, :handler_5, 100}],
    }

    assert expected_listeners == Rsed.ListenersBag.add_listener(listeners, :test_event_2,
      {Rsed.Test.TestListener, :handler_2}, 300)
  end

end
