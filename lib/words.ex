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

  def maybe_brackets do
    ignore(string("("))
    |> choice([word(), dotted_word()])
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
    whitespace(min: 0) |> replace(true)
    # ])
  end
end
