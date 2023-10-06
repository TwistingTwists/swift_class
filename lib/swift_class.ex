defmodule SwiftClass do
  @moduledoc false
  import NimbleParsec
  import SwiftClass.Modifiers
  import SwiftClass.Blocks
  import SwiftClass.PostProcessors
  import SwiftClass.Tokens

  def parse(input) do
    case SwiftClass.Modifiers.modifiers(input) do
      {:ok, [output], a, b, c, d} ->
        {:ok, output, a, b, c, d}

      other ->
        other
    end
  end

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
