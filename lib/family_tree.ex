defmodule FamilyTree do
  @moduledoc """
  Documentation for `FamilyTree`.
  """

  @doc """
  Add a person to the family.

  ## Examples

      iex> FamilyTree.add_person("Naruto Uzumaki")
      :ok
      iex> FamilyTree.get_person("Naruto Uzumaki")
      %Person{name: "Naruto Uzumaki", other_attrs: %{}}
      iex> FamilyTree.get_person("Monkey D. Luffy")
      nil
  """
  def add_person(name, other_attrs \\ []) do
    person = Person.new(name, other_attrs)
    {:ok, table} = :dets.open_file(:persons, [type: :set])
    try do
      :dets.insert(table, {person.name, person})
    after
      :dets.close(table)
    end
  end

  def get_person(name) do
    {:ok, table} = :dets.open_file(:persons, [type: :set])
    try do
      case :dets.lookup(table, name) |> Enum.map(fn {_, person} -> person end) do
        [head] -> head
        _ -> nil
      end
    after
      :dets.close(table)
    end
  end
end
