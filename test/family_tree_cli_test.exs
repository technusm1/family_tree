defmodule FamilyTreeCliTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureIO

  doctest FamilyTree

  describe "real world usage test" do
    setup [:clear_db]

    test "with simple realworld program commands" do
      cmd(~s(add person "Naruto Uzumaki"))
      cmd(~s(add person "Minato Namikaze"))
      cmd(~s(add relationship parent child))
      cmd(~s(connect "Naruto Uzumaki" as child of "Minato Namikaze"))
      assert capture_io(fn -> cmd(~s(parent of "Naruto Uzumaki")) end) == ~s(parent of "Naruto Uzumaki": "Minato Namikaze"\n)
      assert capture_io(fn -> cmd(~s(count children of "Minato Namikaze")) end) == ~s(No. of children of "Minato Namikaze": 1\n)
      clear_db(nil)
    end
  end

  defp clear_db(_) do
    ~w(persons relationship_alias_vocabulary relationship_complements_vocabulary relationships)
    |> Enum.each(&File.rm_rf!/1)
  end

  defp cmd(str) do
    Regex.split(~r/("[^"]*")|(\S+)/, str, include_captures: true)
    |> Enum.filter(fn x -> x != "" and x != " " end)
    |> FamilyTree.Cli.main()
  end
end
