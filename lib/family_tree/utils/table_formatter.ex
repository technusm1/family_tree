defmodule FamilyTree.Utils.TableFormatter do
  @doc ~S"""
  Takes a list of rows (themselves a list of columns) and returns
  iodata containing an aligned ASCII table with `padding` spaces
  between each column.
  Strategy:
  - convert all values to strings
  - compute max width of each column
  - map each value to [value, padding] except last column
  - pad amount = (column width - value width) + padding
  - append \n to each row

    ## Examples
        iex> FamilyTree.Utils.TableFormatter.format([[1, 2, 3], [4000, 6000, 9000]])
        [[[["1", "    "], ["2", "    "], "3"], 10], [[["4000", " "], ["6000", " "], "9000"], 10]]
  """
  def format(rows, opts \\ []) do
    padding = Keyword.get(opts, :padding, 1)
    rows    = stringify(rows)
    widths  = rows |> transpose |> column_widths
    rows
    |> pad_cells(widths, padding)
    |> Enum.map(&[&1, ?\n])
  end

  defp pad_cells(rows, widths, padding) do
    Enum.map(rows, fn row ->
      map_special(
        Enum.zip(row, widths),
        # pad all values...
        fn {val, width} ->
          pad_amount = width - (val |> byte_size) + padding
          [val, "" |> String.pad_leading(pad_amount)]
        end,
        # ...except the one in the last column
        fn {val, _width} -> val end
      )
    end)
  end

  defp stringify(rows) do
    Enum.map(rows, fn row ->
      Enum.map(row, &to_string/1)
    end)
  end

  defp column_widths(columns) do
    Enum.map(columns, fn column ->
      column |> Enum.map(&String.length/1) |> Enum.max
    end)
  end

  defp transpose(rows) do
    rows
    |> List.zip
    |> Enum.map(&Tuple.to_list(&1))
  end

  # Map elements in `enumerable` with `fun1` except for the last element
  # which is mapped with `fun2`.
  defp map_special(enumerable, fun1, fun2) do
    do_map_special(enumerable, [], fun1, fun2) |> :lists.reverse
  end

  defp do_map_special([], _acc, _fun1, _fun2) do
    []
  end
  defp do_map_special([t], acc, _fun1, fun2) do
    [fun2.(t) | acc]
  end
  defp do_map_special([h|t], acc, fun1, fun2) do
    do_map_special(t, [fun1.(h) | acc], fun1, fun2)
  end
end
