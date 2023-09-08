defmodule FamilyTreeCliTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureIO

  doctest FamilyTree
  doctest FamilyTree.Utils.TableFormatter

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

    test "with extra options" do
      cmd(~s(add person "Naruto Uzumaki" --gender=male --age=25))
      cmd(~s(add person "Kushina Uzumaki" --gender=female))
      cmd(~s(add person "Minato Namikaze" --gender=male))

      cmd(~s(add relationship parent child))

      assert capture_io(fn -> cmd(~s(set relationship parent father --gender=male)) end) == ~s(parent will be called father when parent [gender: "male"]\n)
      assert capture_io(fn -> cmd(~s(set relationship parent mother --gender=female)) end) == ~s(parent will be called mother when parent [gender: "female"]\n)
      assert capture_io(fn -> cmd(~s(set relationship child son --gender=male)) end) == ~s(child will be called son when child [gender: "male"]\n)
      assert capture_io(fn -> cmd(~s(set relationship child daughter --gender=female)) end) == ~s(child will be called daughter when child [gender: "female"]\n)

      cmd(~s(connect "Naruto Uzumaki" as child of "Kushina Uzumaki"))
      cmd(~s(connect "Naruto Uzumaki" as child of "Minato Namikaze"))

      assert capture_io(fn -> cmd(~s(mother of "Naruto Uzumaki")) end) == ~s(mother of "Naruto Uzumaki": "Kushina Uzumaki"\n)
      assert capture_io(fn -> cmd(~s(count sons of "Kushina Uzumaki")) end) == ~s(No. of sons of "Kushina Uzumaki": 1\n)
      assert capture_io(fn -> cmd(~s(count children of "Kushina Uzumaki")) end) == ~s(No. of children of "Kushina Uzumaki": 1\n)
      assert capture_io(fn -> cmd(~s(count daughter of "Minato Namikaze")) end) == ~s(No. of daughter of "Minato Namikaze": 0\n)
      clear_db(nil)
    end

    test "for self-complementary relation" do
      cmd(~s(add person "Boruto Uzumaki"))
      cmd(~s(add person "Himawari Uzumaki" --gender=female))

      cmd(~s(add relationship sibling))

      assert capture_io(fn -> cmd(~s(set relationship sibling brother --gender=male)) end) == ~s(sibling will be called brother when sibling [gender: "male"]\n)
      assert capture_io(fn -> cmd(~s(set relationship sibling sister --gender=female)) end) == ~s(sibling will be called sister when sibling [gender: "female"]\n)

      cmd(~s(connect "Boruto Uzumaki" as brother of "Himawari Uzumaki"))

      assert capture_io(fn -> cmd(~s(sister of "Boruto Uzumaki")) end) == ~s(sister of "Boruto Uzumaki": "Himawari Uzumaki"\n)
      assert capture_io(fn -> cmd(~s(count siblings of "Himawari Uzumaki")) end) == ~s(No. of siblings of "Himawari Uzumaki": 1\n)
      assert capture_io(fn -> cmd(~s(count brothers of "Himawari Uzumaki")) end) == ~s(No. of brothers of "Himawari Uzumaki": 1\n)
      assert capture_io(fn -> cmd(~s(count sister of "Himawari Uzumaki")) end) == ~s(No. of sister of "Himawari Uzumaki": 0\n)

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
