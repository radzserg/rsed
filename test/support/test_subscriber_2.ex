defmodule Rsed.Test.TestSubscriber2 do
  @behaviour Rsed.Subscriber

  def get_subscriber_events() do
    %{
      test_event_2: :handler_2,
      test_event_3: :test_event_3_handler,
      test_event_4: [
        handler_6: 200,
        handler_5: 100
      ]
    }
  end

  def handler_2(event = %Rsed.Event{}) do
    file_name = List.last(String.split(to_string(__MODULE__), ".")) <> "_handler_2.txt"
    file_path = System.cwd() <> "/test/files/#{file_name}"
    File.write(file_path, "I'm event 2 handler, got event #{event.name} #{file_name}")
  end
end
