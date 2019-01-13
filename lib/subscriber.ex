defmodule Rsed.Subscriber do
  @callback get_subscriber_events() :: map()
end
