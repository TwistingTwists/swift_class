defmodule SwiftBlock do
  @moduledoc false
  import NimbleParsec
  import Words

  def block_first_line do
    choice([
      double_quoted_string()
      |> ignore_whitespace()
      |> ignore(string("<>"))
      |> ignore_whitespace()
      |> concat(word())
      |> post_traverse({:block_first_line_ast, []}),
      double_quoted_string()
    ])
    |> ignore_whitespace()
    |> ignore(string("do"))
  end
end
