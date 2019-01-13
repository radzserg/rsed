defmodule Rsed.Event do
  @enforce_keys [:name]
  defstruct [:name, :data]
end