defmodule SwiftClass do
  @moduledoc false
  import NimbleParsec
  import Words

  classnames =
    repeat(
      ignore(whitespace(min: 0))
      |> concat(word())
      |> concat(attribute())
      |> concat(content_name())
      |> wrap()
    )


  defp append_nil(rest, args, context, _line, _offset) do
    {rest, args ++ [nil], context}
  end
  defparsec(:parse, classnames)
end
