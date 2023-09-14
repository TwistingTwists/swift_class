defmodule SwiftClass do
  @moduledoc false
  import NimbleParsec
  import Words

  # input = "font(.largeTitle) bold italic "
  # output = [["font", [".largeTitle"], nil], ["bold", [true], nil], ["italic", [true], nil]]

  classnames =
    repeat(
      ignore(whitespace(min: 0))
      |> concat(word())
      |> concat(attribute())
      |> wrap()
    )

  defparsec(:parse, classnames)
end
