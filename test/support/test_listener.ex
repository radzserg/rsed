defmodule Rsed.Test.TestListener do

  def handler_2(event = %Rsed.Event{}) do
    file_name = List.last(String.split(to_string(__MODULE__), ".")) <> "_handler_1.txt"
    file_path = System.cwd() <> "/test/files/#{file_name}"
    File.write(file_path, "I'm event 2 handler, got event #{event.name} #{file_name}")
  end

end
