defmodule SwiftClass.HelperFunctions do
  @moduledoc false
  import NimbleParsec

  @functions %{
    "to_atom" => "to_atom",
    "to_integer" => "to_integer",
    "to_float" => "to_float",
    "to_boolean" => "to_boolean",
    "camelize" => "camelize",
    "snake_case" => "snake_case"
  }

  def helper_function do
    choice(
      Enum.map(@functions, fn {k, v} ->
        string(k)
        |> post_traverse({:helper_function_to_ast_name, [v]})
      end)
    )
  end
end
