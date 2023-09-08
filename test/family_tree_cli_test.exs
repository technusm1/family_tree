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

    test "with details option" do
      cmd(~s(add person "Naruto Uzumaki" "gender:male"))
      cmd(~s(add person "Minato Namikaze" "gender:male;occupation:4th Hokage"))
      cmd(~s(add person "Kushina Uzumaki" "gender:female"))
      cmd(~s(add relationship parent child))

      assert capture_io(fn -> cmd(~s(set relationship parent father "gender:male")) end) == ~s(parent will be called father when parent [gender: "male"]\n)
      assert capture_io(fn -> cmd(~s(set relationship parent mother "gender:female")) end) == ~s(parent will be called mother when parent [gender: "female"]\n)
      assert capture_io(fn -> cmd(~s(set relationship child son "gender:male")) end) == ~s(child will be called son when child [gender: "male"]\n)
      assert capture_io(fn -> cmd(~s(set relationship child daughter "gender:female")) end) == ~s(child will be called daughter when child [gender: "female"]\n)

      cmd(~s(connect "Naruto Uzumaki" as son of "Minato Namikaze"))
      cmd(~s(connect "Naruto Uzumaki" as son of "Kushina Uzumaki"))
      assert capture_io(fn -> cmd(~s(--detail parents of "Naruto Uzumaki")) end) == ~s(parents of "Naruto Uzumaki": "Kushina Uzumaki" [gender: "female"]\n"Minato Namikaze" [gender: "male", occupation: "4th Hokage"]\n)
      clear_db(nil)
    end

    test "with extra options" do
      cmd(~s(add person "Naruto Uzumaki" "gender:male;age:25"))
      cmd(~s(add person "Kushina Uzumaki" gender:female))
      cmd(~s(add person "Minato Namikaze" gender:male))

      cmd(~s(add relationship parent child))

      assert capture_io(fn -> cmd(~s(set relationship parent father gender:male)) end) == ~s(parent will be called father when parent [gender: "male"]\n)
      assert capture_io(fn -> cmd(~s(set relationship parent mother "gender:female")) end) == ~s(parent will be called mother when parent [gender: "female"]\n)
      assert capture_io(fn -> cmd(~s(set relationship child son gender:male)) end) == ~s(child will be called son when child [gender: "male"]\n)
      assert capture_io(fn -> cmd(~s(set relationship child daughter gender:female)) end) == ~s(child will be called daughter when child [gender: "female"]\n)

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
      cmd(~s(add person "Himawari Uzumaki" gender:female))

      cmd(~s(add relationship sibling))

      assert capture_io(fn -> cmd(~s(set relationship sibling brother gender:male)) end) == ~s(sibling will be called brother when sibling [gender: "male"]\n)
      assert capture_io(fn -> cmd(~s(set relationship sibling sister gender:female)) end) == ~s(sibling will be called sister when sibling [gender: "female"]\n)

      cmd(~s(connect "Boruto Uzumaki" as brother of "Himawari Uzumaki"))

      assert capture_io(fn -> cmd(~s(sister of "Boruto Uzumaki")) end) == ~s(sister of "Boruto Uzumaki": "Himawari Uzumaki"\n)
      assert capture_io(fn -> cmd(~s(count siblings of "Himawari Uzumaki")) end) == ~s(No. of siblings of "Himawari Uzumaki": 1\n)
      assert capture_io(fn -> cmd(~s(count brothers of "Himawari Uzumaki")) end) == ~s(No. of brothers of "Himawari Uzumaki": 1\n)
      assert capture_io(fn -> cmd(~s(count sister of "Himawari Uzumaki")) end) == ~s(No. of sister of "Himawari Uzumaki": 0\n)

      clear_db(nil)
    end

    test "a family tree by billy shakespeare" do
      # First generation
      cmd(~s(add person "John Shakespeare" died:1602))
      cmd(~s(add person "Mary Arden" died:1602;gender:female))

      # Second generation
      cmd(~s(add person "Joan" born:1558;died:1559;gender:female))
      cmd(~s(add person "Margaret" born:1562;died:1563;gender:female))

      cmd(~s(add person "William Shakespeare" born:1564;died:1616))
      cmd(~s(add person "Anne Hathaway" born:1556;died:1623;gender:female))

      cmd(~s(add person "Gilbert" born:1566;died:1612))
      cmd(~s(add person "Anne" born:1571;died:1579;gender:female))
      cmd(~s(add person "Richard" born:1574;died:1613))
      cmd(~s(add person "Edmund" born:1580;died:1607))

      # Shakespeare's brats
      cmd(~s(add person "Susanna" born:1583;died:1649;gender:female))
      cmd(~s(add person "Hamnet" born:1585;died:1596))
      cmd(~s(add person "Judith" born:1585;died:1662;gender:female))

      # Shakespeare's sons-in-law
      cmd(~s(add person "Thomas Quiney" born:1589;died:1655))
      cmd(~s(add person "John Hall" born:1575;died:1635))

      # Shakespeare's grandkids
      cmd(~s(add person "Elizabeth" born:1608;died:1670;gender:female))
      cmd(~s(add person "Shakespeare" born:1616;died:1617;gender:male))
      cmd(~s(add person "Richard II" born:1618;died:1639;gender:male)) # <-- We're naming this one Richard II, since we already have a Richard in the family tree
      cmd(~s(add person "Thomas" born:1620;died:1639;gender:male))

      cmd(~s(add relationship spouse))
      cmd(~s(add relationship sibling))
      cmd(~s(add relationship parent child))

      assert capture_io(fn -> cmd(~s(set relationship parent father gender:male)) end) == ~s(parent will be called father when parent [gender: "male"]\n)
      assert capture_io(fn -> cmd(~s(set relationship parent mother gender:female)) end) == ~s(parent will be called mother when parent [gender: "female"]\n)
      assert capture_io(fn -> cmd(~s(set relationship child son gender:male)) end) == ~s(child will be called son when child [gender: "male"]\n)
      assert capture_io(fn -> cmd(~s(set relationship child daughter gender:female)) end) == ~s(child will be called daughter when child [gender: "female"]\n)
      assert capture_io(fn -> cmd(~s(set relationship spouse husband gender:male)) end) == ~s(spouse will be called husband when spouse [gender: "male"]\n)
      assert capture_io(fn -> cmd(~s(set relationship spouse wife gender:female)) end) == ~s(spouse will be called wife when spouse [gender: "female"]\n)
      assert capture_io(fn -> cmd(~s(set relationship sibling brother gender:male)) end) == ~s(sibling will be called brother when sibling [gender: "male"]\n)
      assert capture_io(fn -> cmd(~s(set relationship sibling sister gender:female)) end) == ~s(sibling will be called sister when sibling [gender: "female"]\n)

      # Connecting first generation and second
      cmd(~s(connect "John Shakespeare" as husband of "Mary Arden"))
      assert capture_io(fn -> cmd(~s(husband of "Mary Arden")) end) == ~s(husband of "Mary Arden": "John Shakespeare"\n)

      for i <- ["Joan", "Margaret", "William Shakespeare", "Gilbert", "Anne", "Richard", "Edmund"] do
        cmd(~s(connect "John Shakespeare" as father of "#{i}"))
        cmd(~s(connect "Mary Arden" as mother of "#{i}"))
      end

      assert capture_io(fn -> cmd(~s(children of "Mary Arden")) end) == ~s(children of "Mary Arden": "Anne", "Edmund", "Gilbert", "Joan", "Margaret", "Richard", "William Shakespeare"\n)
      assert capture_io(fn -> cmd(~s(daughters of "John Shakespeare")) end) == ~s(daughters of "John Shakespeare": "Anne", "Joan", "Margaret"\n)

      cmd(~s(connect "William Shakespeare" as husband of "Anne Hathaway"))

      for i <- ["Joan", "Margaret", "William Shakespeare", "Gilbert", "Anne", "Richard", "Edmund"],
          j <- ["Joan", "Margaret", "William Shakespeare", "Gilbert", "Anne", "Richard", "Edmund"],
          i != j do
        cmd(~s(connect "#{i}" as sibling of "#{j}"))
      end
      assert capture_io(fn -> cmd(~s(siblings of "Margaret")) end) == ~s(siblings of "Margaret": "Anne", "Edmund", "Gilbert", "Joan", "Richard", "William Shakespeare"\n)
      assert capture_io(fn -> cmd(~s(sisters of "Margaret")) end) == ~s(sisters of "Margaret": "Anne", "Joan"\n)

      # Connecting Shakespeare and his brats
      for i <- ["Susanna", "Hamnet", "Judith"] do
        cmd(~s(connect "William Shakespeare" as father of "#{i}"))
        cmd(~s(connect "Anne Hathaway" as mother of "#{i}"))
      end

      assert capture_io(fn -> cmd(~s(children of "Anne Hathaway")) end) == ~s(children of "Anne Hathaway": "Hamnet", "Judith", "Susanna"\n)
      assert capture_io(fn -> cmd(~s(daughters of "William Shakespeare")) end) == ~s(daughters of "William Shakespeare": "Judith", "Susanna"\n)

      for i <- ["Susanna", "Hamnet", "Judith"],
          j <- ["Susanna", "Hamnet", "Judith"],
          i != j do
        cmd(~s(connect "#{i}" as sibling of "#{j}"))
      end

      cmd(~s(connect "John Hall" as husband of "Susanna"))
      cmd(~s(connect "Thomas Quiney" as husband of "Judith"))

      # Connecting the last generation
      cmd(~s(connect "John Hall" as father of "Elizabeth"))
      cmd(~s(connect "Susanna" as mother of "Elizabeth"))

      assert capture_io(fn -> cmd(~s(child of "Susanna")) end) == ~s(child of "Susanna": "Elizabeth"\n)
      assert capture_io(fn -> cmd(~s(daughter of "John Hall")) end) == ~s(daughter of "John Hall": "Elizabeth"\n)
      assert capture_io(fn -> cmd(~s(son of "Susanna")) end) == ~s(son of "Susanna": \n)


      for i <- ["Shakespeare", "Richard II", "Thomas"] do
        cmd(~s(connect "Thomas Quiney" as father of "#{i}"))
        cmd(~s(connect "Judith" as mother of "#{i}"))
      end

      assert capture_io(fn -> cmd(~s(children of "Thomas Quiney")) end) == ~s(children of "Thomas Quiney": "Richard II", "Shakespeare", "Thomas"\n)
      assert capture_io(fn -> cmd(~s(daughters of "Judith")) end) == ~s(daughters of "Judith": \n)
      assert capture_io(fn -> cmd(~s(sons of "Judith")) end) == ~s(sons of "Judith": "Richard II", "Shakespeare", "Thomas"\n)

      for i <- ["Shakespeare", "Richard II", "Thomas"],
          j <- ["Shakespeare", "Richard II", "Thomas"],
          i != j do
        cmd(~s(connect "#{i}" as sibling of "#{j}"))
      end

      assert capture_io(fn -> cmd(~s(brothers of "Shakespeare")) end) == ~s(brothers of "Shakespeare": "Richard II", "Thomas"\n)
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
