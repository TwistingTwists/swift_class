defmodule Words do
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

  def word do
    ascii_string([?a..?z, ?A..?Z, ?0..?9, ?_], min: 1)
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

  # def maybe_brackets do
  #   true_value =
  #     string("true")
  #     |> replace(true)

  #   false_value =
  #     string("false")
  #     |> replace(false)

  #   null =
  #     string("nil")
  #     |> replace(nil)

  #   frac =
  #     string(".")
  #     |> concat(integer(min: 1))

  #   float =
  #     int()
  #     |> concat(frac)
  #     |> reduce({Enum, :join, [""]})
  #     |> map({String, :to_float, []})

  #   key_value_pair =
  #     ignore_whitespace()
  #     |> concat(choice([word(), double_quoted_string()]))
  #     |> ignore_whitespace()
  #     |> concat(ignore(string(":")))
  #     |> ignore_whitespace()
  #     |> concat(choice([word(), double_quoted_string()]))
  #     |> wrap()

  #   nested_function_call

  #   ignore(string("("))
  #   |> choice([
  #     # can there be a case like
  #     # input = "foo(1 true false 1.1)"
  #     repeat(
  #       # ignore_whitespace()
  #       choice([
  #         key_value_pair,
  #         float,
  #         int(),
  #         true_value,
  #         false_value,
  #         null,
  #         word(),
  #         dotted_word(),
  #         double_quoted_string()
  #       ])
  #       |> ignore_whitespace()
  #     ),
  #     ignore_whitespace()
  #   ])
  #   |> ignore(string(")"))
  # end

  # def attribute do
  #   choice([
  #     maybe_brackets(),
  #     standalone_attribute()
  #   ])
  #   |> wrap()
  # end

  # def content_name do
  #   # {:content}
  #   valid_content_name =
  #     ignore(string("{"))
  #     |> concat(ignore(string(":")))
  #     |> concat(word())
  #     |> ignore(string("}"))
  #     |> map({String, :to_atom, []})

  #   # if there is no content_name, append nil
  #   invalid_content_name = ignore(string("")) |> post_traverse({:append_value, [nil]})

  #   choice([valid_content_name, invalid_content_name])
  # end
end
