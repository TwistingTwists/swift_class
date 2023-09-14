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

  defp append_value(rest, args, context, _line, _offset, value) do
    {rest, args ++ [value], context}
  end

  defp prepend_value(rest, args, context, _line, _offset, value) do
    {rest, [value | args], context}
  end

  defparsec(:parse, classnames)
end
