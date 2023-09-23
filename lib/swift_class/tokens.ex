defmodule SwiftClass.Tokens do
  import NimbleParsec

  def whitespace(opts) do
    utf8_string([?\s, ?\n, ?\r, ?\t], opts)
  end

  def minus, do: string("-")

  def plus, do: string("+")

  def int do
    optional(minus())
    |> concat(integer(min: 1))
    |> reduce({Enum, :join, [""]})
    |> map({String, :to_integer, []})
  end

  def atom do
    string(":")
    |> replace("IME")
    |> concat(word())
    |> wrap()
  end

  def word do
    ascii_string([?a..?z, ?A..?Z, ?0..?9, ?_], min: 1)
  end

  def variable do
    word()
    |> post_traverse({:inject_variables, []})
  end

  def dotted_word do
    string(".")
    |> concat(word())
    |> reduce({Enum, :join, []})
    |> post_traverse({:prepend_value, [:IME]})
    |> wrap()
  end

  def single_quoted_string do
    ignore(string(~s(')))
    |> repeat(
      lookahead_not(ascii_char([?']))
      |> choice([string(~s(\')), utf8_char([])])
    )
    |> ignore(string(~s(')))
    |> reduce({List, :to_string, []})
  end

  def double_quoted_string do
    ignore(string(~s(")))
    |> repeat(
      lookahead_not(ascii_char([?"]))
      |> choice([string(~s(\")), utf8_char([])])
    )
    |> ignore(string(~s(")))
    |> reduce({List, :to_string, []})
  end

  def ignore_whitespace(combinator \\ empty()) do
    combinator |> ignore(optional(whitespace(min: 1)))
  end

  def comma_separated_list(combinator, elem_combinator) do
    delimiter_separated_list(combinator, elem_combinator, ",", true)
  end

  def delimiter_separated_list(combinator, elem_combinator, delimiter, allow_empty \\ true) do
    combinator
    |> choice(
      [
        #  1+ elems
        elem_combinator
        |> ignore_whitespace()
        |> repeat(
          ignore(string(delimiter))
          |> ignore_whitespace()
          |> concat(elem_combinator)
          |> ignore_whitespace()
        ),
      ] ++
        if allow_empty do
          [
            # 0 elems
            empty()
            |> ignore_whitespace()
          ]
        else
          []
        end
    )
  end
end
