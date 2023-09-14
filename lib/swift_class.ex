defmodule SwiftClass do
  @moduledoc false
  import NimbleParsec
  import Words
  import BracketAttributes

  classnames =
    repeat(
      ignore(whitespace(min: 0))
      |> concat(word())
      |> parsec(:attribute)
      |> wrap()
    )

  defparsec(:parse, classnames)
end
