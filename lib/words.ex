defmodule Words do
  import NimbleParsec

  def whitespace(opts) do
    utf8_string([?\s, ?\n, ?\r, ?\t], opts)
  end

  def word do
    ascii_string([?a..?z, ?A..?Z, ?0..?9, ?_], min: 1)
  end

  def dotted_word do
    string(".")
    |> concat(word())
    |> reduce({Enum, :join, []})
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

  def maybe_brackets do
    true_value =
      string("true")
      |> replace(true)

    false_value =
      string("false")
      |> replace(false)

    ignore(string("("))
    |> choice([
      true_value,
      false_value,
      word(),
      dotted_word(),
      repeat(
        ignore(optional(whitespace(min: 1)))
        |> concat(double_quoted_string())
        |> ignore(optional(whitespace(min: 1)))
      ),
      ignore(whitespace(min: 0))
    ])
    |> ignore(string(")"))
  end

  def attribute do
    choice([
      maybe_brackets(),
      standalone_attribute()
    ])
    |> wrap()
  end

  def standalone_attribute do
    # choice([
    # default value to be true.
    whitespace(min: 1) |> replace(true)
    # ])
  end

  def content_name do
    # {:content}
    valid_content_name =
      ignore(string("{"))
      |> concat(ignore(string(":")))
      |> concat(word())
      |> ignore(string("}"))
      |> map({String, :to_atom, []})

    invalid_content_name = ignore(string("")) |> post_traverse({:append_nil, []})

    choice([valid_content_name, invalid_content_name])
  end
end
