defmodule SwiftClass do
  @moduledoc false
  import NimbleParsec
  import Words
  import SwiftBlock
  import BracketAttributes

  classnames =
    repeat(
      ignore(whitespace(min: 0))
      |> concat(word())
      |> parsec(:attribute)
      |> wrap()
    )

  defparsec(:parse, classnames)

  classnames_in_block =
    repeat(
      lookahead_not(ignore_whitespace() |> string("end"))
      |> ignore_whitespace()
      |> concat(word())
      |> parsec(:attribute)
      |> wrap()
    )
    |> ignore_whitespace()
    |> ignore(string("end"))
    |> wrap()

  classblocks =
    repeat(
      ignore_whitespace()
      |> concat(block_first_line())
      |> ignore_whitespace()
      |> concat(classnames_in_block)
      |> ignore_whitespace()
      |> post_traverse({:wrap_in_tuple, []})
    )

  defparsec(:parse_class_block, classblocks)
end
