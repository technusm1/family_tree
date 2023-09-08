defmodule Person do
  @enforce_keys [:name]
  defstruct name: nil, other_attrs: %{}

  def new(name, other_attrs \\ []) do
    %__MODULE__{
      name: name,
      other_attrs: Enum.into(other_attrs, %{})
    }
  end
end
