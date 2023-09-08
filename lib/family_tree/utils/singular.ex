defmodule FamilyTree.Utils.Singular do
  @doc """
  Convert plurals to singular form of relations. Nothing fancy.
  Though I believe using wordnet to properly account for all cases (of English language at least) will give us better results.
  Nonetheless, the space and time savings for now is worth leaving this as-is.
  """
  def to_singular(relation) do
    case relation do
      "children" -> "child"
      "wives" -> "wife"
      _ -> String.replace_trailing(relation, "s", "")
    end
  end
end
