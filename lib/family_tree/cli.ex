defmodule FamilyTree.Cli do
  def main(["add", "person", name | other_attrs]) do
    other_attrs_list = if other_attrs == [], do: [], else: hd(other_attrs) |> String.trim("\"") |> String.split(";") |> Keyword.new(fn pair_str ->
      [attr, val] = pair_str |> String.split(":")
      {String.to_atom(attr), val}
    end)
    result = FamilyTree.add_person(name, other_attrs_list)
    case result do
      {:error, reason} -> IO.puts(:stderr, "FAILED TO add person: #{reason}")
      :ok -> nil
    end
  end

  def main(["add", "relationship", relationship1, relationship2]) do
    result = FamilyTree.add_relationship(relationship1, relationship2)
    case result do
      {:error, reason} -> IO.puts(:stderr, "FAILED TO add relationship: #{reason}")
      :ok -> nil
    end
  end

  def main(["add", "relationship", relationship1]) do
    result = FamilyTree.add_relationship(relationship1, relationship1)
    case result do
      {:error, reason} -> IO.puts(:stderr, "FAILED TO add relationship: #{reason}")
      :ok -> nil
    end
  end

  def main(["set", "relationship", relationship, relationship_alias | conditions_list]) do
    conditions_list = if conditions_list == [], do: [], else: hd(conditions_list) |> String.trim("\"") |> String.split(";") |> Keyword.new(fn pair_str ->
      [attr, val] = pair_str |> String.split(":")
      {String.to_atom(attr), val}
    end)
    case FamilyTree.set_relationship(relationship, relationship_alias, conditions_list) do
      :ok -> IO.puts("#{relationship} will be called #{relationship_alias} when #{relationship} [#{conditions_list |> Enum.map(fn {k, v} -> "#{Atom.to_string(k)}: \"#{v}\"" end) |> Enum.join(", ")}]")
      {:error, reason} -> IO.puts(:stderr, "FAILED TO set relationship: #{reason}")
    end
  end

  def main(["connect", name1, "as", relationship, "of", name2]) do
    result = FamilyTree.connect(name1, name2, relationship)
    case result do
      {:error, reason} -> IO.puts(:stderr, "FAILED TO CONNECT: #{reason}")
      :ok -> nil
      _ -> IO.puts("CONNECT returned result: #{result}")
    end
  end

  def main(["count", relation, "of", name]) do
    singular_relation = FamilyTree.Utils.Singular.to_singular(relation)
    result = FamilyTree.find_relation_count_of(name, singular_relation)
    IO.puts("No. of #{relation} of #{name}: #{result}")
  end

  def main(["--detail", relation, "of", name]) do
    singular_relation = FamilyTree.Utils.Singular.to_singular(relation)
    result = FamilyTree.find_relation_of(name, singular_relation)
             |> Stream.map(fn name -> FamilyTree.get_person(name) end)
             |> Enum.map(fn person -> "#{person.name} [#{person.other_attrs |> Enum.map(fn {k, v} -> "#{Atom.to_string(k)}: \"#{v}\"" end) |> Enum.join(", ")}]\n" end)
    IO.write("#{relation} of #{name}:\n")
    IO.write("-----------------------\n")
    IO.write("#{result}")
  end

  def main([relation, "of", name]) do
    singular_relation = FamilyTree.Utils.Singular.to_singular(relation)
    result = FamilyTree.find_relation_of(name, singular_relation)
    IO.puts("#{relation} of #{name}: #{result |> Enum.join(", ")}")
  end

  def main(["-h"]) do
    IO.puts("USAGE:\tfamily_tree <COMMAND> <opts>")
    opts_list = [
      ["-h | --help", "Display this help section."],
      ["add person <person>", "Adds a person named <person> to the family tree."],
      ["add relationship <relation_1> <relation_2>", "Defines a relationship pair and stores it in relationship vocabulary. E.g. \"add relationship father child\" defines and stores a father-child relationship."],
      ["set relationship <relation_1> <alias> <attribute>:<value>;[<attribute>:<value>]*", "Relationship named <relation_1> will be called <alias> when the person associated has given characteristics. E.g. set relationship parent father gender:male will change parent to father for males."],
      ["connect <person_1> as <relation> of <person_2>", "Creates a <relation> between <person_1> and <person_2>. E.g. If we use \"connect John as father of James\", then John is father of James and James is child of John."],
      ["count <relation> of <person>", "Returns count of all <relation> of a person named <person>. E.g. To get count of all children of John, we'll use \"count child of John\""],
      ["<relation> of <person>", "Returns the list of persons that are related to <person> by the relation <relation>."]
    ]
    opts_list |> FamilyTree.Utils.TableFormatter.format() |> IO.puts()
  end

  def main(["--help"]), do: main(["-h"])

  def main(_), do: IO.puts("Incorrect usage: Use -h or --help to display usage options.")
end
