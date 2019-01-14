defmodule Rsed.Test.SubscriberAssert do

  def callback_worked(subscriber, func_name) do
    File.exists?(test_subscriber_path(subscriber, func_name))
  end

  defp test_subscriber_path(subscriber, func_name) do
    file_name = List.last(String.split(to_string(subscriber), ".")) <> "_#{func_name}.txt"
    System.cwd() <> "/test/files/#{file_name}"
  end

end
