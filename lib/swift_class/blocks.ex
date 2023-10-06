defmodule SwiftClass.Blocks do
  @moduledoc false
  import NimbleParsec
  import SwiftClass.Tokens

  def string_with_variable do
    string()
    |> ignore_whitespace()
    |> ignore(string("<>"))
    |> ignore_whitespace()
    |> concat(quoted_variable())
    |> post_traverse({:block_open_with_variable_to_ast, []})
  end

  def block_open do
    choice([
      string_with_variable(),
      string()
    ])
    |> ignore_whitespace()
    |> ignore(string("do"))
  end

  def block_contents do
    repeat(
      lookahead_not(block_close())
      |> ignore_whitespace()
      |> parsec(:modifier)
    )
    |> ignore_whitespace()
    |> wrap()
  end

  def block_close do
    ignore_whitespace()
    |> ignore(string("end"))
  end
end
