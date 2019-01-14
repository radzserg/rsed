defmodule Rsed.Event do
  @enforce_keys [:name]
  defstruct [:name, :data]

  @type t :: %Rsed.Event{
    name: String.t(),
    data: any(),
  }
end
