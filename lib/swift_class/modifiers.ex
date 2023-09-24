defmodule SwiftClass.Modifiers do
  import SwiftClass.Tokens
  import SwiftClass.PostProcessors
  import SwiftClass.HelperFunctions
  import NimbleParsec

  true_value =
    string("true")
    |> replace(true)

  false_value =
    string("false")
    |> replace(false)

  null =
    string("nil")
    |> replace(nil)

  frac =
    string(".")
    |> concat(integer(min: 1))

  float =
    int()
    |> concat(frac)
    |> reduce({Enum, :join, [""]})
    |> map({String, :to_float, []})

  key_value_pair =
    ignore_whitespace()
    |> concat(choice([word(), double_quoted_string()]))
    |> ignore_whitespace()
    |> concat(ignore(string(":")))
    |> ignore_whitespace()
    |> concat(choice([parsec(:nested_attribute), variable(), double_quoted_string()]))
    |> wrap()

  defparsec(
    :nested_attribute,
    choice([
      string("attr")
      |> wrap(parsec(:maybe_brackets))
      |> post_traverse({:flip_attr, []})
      |> wrap(),
      helper_function()
      |> parsec(:maybe_brackets)
      |> post_traverse({:helper_function_to_ast, []}),
      word()
      |> wrap(parsec(:maybe_brackets))
      |> parsec(:content_name)
      |> wrap()
    ]),
    export_combinator: true
  )

  @bracket_child [
    parsec(:nested_attribute),
    key_value_pair,
    float,
    int(),
    true_value,
    false_value,
    null,
    atom(),
    variable(),
    dotted_word(),
    double_quoted_string()
  ]

  defparsec(
    :maybe_brackets,
    ignore_whitespace()
    |> ignore(string("("))
    |> ignore_whitespace()
    |> comma_separated_list(choice(@bracket_child))
    |> ignore(string(")"))
  )

  defparsec(
    :attribute,
    choice([
      parsec(:maybe_brackets),
      whitespace(min: 1) |> replace(true)
    ])
    |> wrap()
    |> parsec(:content_name)
  )

  defparsec(
    :modifier,
    word()
    |> parsec(:attribute)
    |> wrap(),
    export_combinator: true
  )

  valid_content_name =
    ignore(string("{"))
    |> concat(ignore(string(":")))
    |> concat(word())
    |> ignore(string("}"))
    |> map({String, :to_atom, []})

  # if there is no content_name, append nil
  invalid_content_name = empty() |> post_traverse({:append_value, [nil]})

  defparsec(
    :content_name,
    choice([valid_content_name, invalid_content_name]),
    export_combinator: true
  )
end
