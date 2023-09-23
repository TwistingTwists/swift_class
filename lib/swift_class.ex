defmodule SwiftClass do
  @moduledoc false
  import NimbleParsec
  import SwiftClass.Modifiers
  import SwiftClass.Blocks
  import SwiftClass.PostProcessors
  import SwiftClass.Tokens

  classnames =
    repeat(
      ignore(whitespace(min: 0))
      |> parsec(:modifier)
    )

  defparsec(:parse, classnames)

  classblocks =
    repeat(
      ignore_whitespace()
      |> concat(block_open())
      |> concat(block_contents())
      |> concat(block_close())
      |> post_traverse({:wrap_in_tuple, []})
    )

  defparsec(:parse_class_block, classblocks)
end
