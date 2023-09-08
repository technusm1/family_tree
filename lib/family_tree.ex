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

  @doc """
  Define a relationship in the relationship dictionary.

  Relationships can be:
  - complementary of each other, for e.g. Parent-Child (If x is Parent of y, then y is Child of x)
  - self-complementary, for e.g. Sibling (If x is Sibling of y, then y is Sibling of x)

    ## Examples

      iex> FamilyTree.add_relationship("parent", "child")
      :ok

  """
  def add_relationship(relationship1, relationship2) do
    {:ok, table} = :dets.open_file(:relationship_complements_vocabulary, [type: :set])
    try do
      with :ok <- :dets.insert(table, {relationship1,relationship2}),
         :ok <- :dets.insert(table, {relationship2,relationship1}) do
        :ok
      end
    after
      :dets.close(table)
    end
  end

  @doc """
  Sets alias of a given relationship for given conditions.

    ## Examples

      iex> FamilyTree.set_relationship("parent", "father", [gender: "male"])
      :ok

  """
  def set_relationship(relationship, relationship_alias, conditions_list) do
    {:ok, table} = :dets.open_file(:relationship_alias_vocabulary, [type: :set])
    try do
      with :ok <- :dets.insert(table, {{relationship, relationship_alias}, conditions_list |> Enum.into(%{})}),
         :ok <- :dets.insert(table, {{relationship_alias, relationship}, conditions_list |> Enum.into(%{})}) do
        :ok
      end
    after
      :dets.close(table)
    end
  end

  @doc """
  Given a relationship or its alias, return the main relationship and the conditions that satisfy the alias

    ## Examples

      iex> FamilyTree.set_relationship("parent", "father", [gender: "male"])
      :ok
      iex> FamilyTree.get_relationship_and_cond_for_alias("father")
      {:ok, "parent", %{gender: "male"}}

  """
  def get_relationship_and_cond_for_alias(relationship_or_alias) do
    {:ok, table} = :dets.open_file(:relationship_alias_vocabulary, [type: :set])
    try do
      case get_complementary_relation_of(relationship_or_alias) do
        {:ok, _} -> {:ok, relationship_or_alias, %{}}
        _ ->
          with [{relationship_or_alias_2, conditions}] <- :dets.select(table, [{{{:"$1", relationship_or_alias}, :"$2"}, [], [{{:"$1", :"$2"}}]}]) do
            {:ok, relationship_or_alias_2, conditions}
          else
            _ -> {:error, "Relation not defined."}
          end
      end
    after
      :dets.close(table)
    end
  end

  @doc """
  Get complementary relation of the given relationship.

  Relationships can be:
  - complementary of each other, for e.g. Parent-Child (If x is Parent of y, then y is Child of x)
  - self-complementary, for e.g. Sibling (If x is Sibling of y, then y is Sibling of x)

    ## Examples

      iex> FamilyTree.add_relationship("parent", "child")
      :ok
      iex> FamilyTree.get_complementary_relation_of("parent")
      {:ok, "child"}
      iex> FamilyTree.get_complementary_relation_of("child")
      {:ok, "parent"}

  """
  def get_complementary_relation_of(relationship) do
    {:ok, table} = :dets.open_file(:relationship_complements_vocabulary, [type: :set])
    try do
      # :ets.fun2ms(fn {relation, complement} when relation==relationship -> complement end)
      result = with [complement] <- :dets.select(table, [{{:"$1", :"$2"}, [{:==, :"$1", relationship}], [:"$2"]}]) do
        {:ok, complement}
      end
      if result != [] and result != nil, do: result, else: {:error, "Complement relation for #{relationship} not found."}
    after
      :dets.close(table)
    end
  end
end
