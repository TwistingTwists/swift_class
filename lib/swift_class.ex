defmodule SwiftClass do
  @moduledoc false
  import NimbleParsec
  import Words
  # import Attribute
  import BracketAttributes

  classnames =
    repeat(
      ignore(whitespace(min: 0))
      |> concat(word())
      # |> concat(attribute())
      |> parsec(:attribute)
      |> concat(content_name())
      |> wrap()
    )

  defparsec(:parse, classnames)
end
