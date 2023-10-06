defmodule SwiftClass.Modifiers do
  import SwiftClass.Tokens
  import SwiftClass.PostProcessors
  import SwiftClass.HelperFunctions
  import NimbleParsec

  key_value_pair =
    ignore_whitespace()
    |> concat(word())
    |> concat(ignore(string(":")))
    |> ignore_whitespace()
    |> concat(
      choice([
        literal(),
        parsec(:ime),
        parsec(:nested_attribute),
        parsec(:key_value_list),
        variable()
      ])
    )
    |> post_traverse({:to_keyword_tuple_ast, []})

  defparsec(
    :key_value_pairs,
    ignore_whitespace()
    |> non_empty_comma_separated_list(key_value_pair)
    |> ignore_whitespace()
    |> wrap()
  )

  defparsec(
    :key_value_list,
    enclosed("[", parsec(:key_value_pairs), "]")
  )

  # .baz
  # .baz(0.1)
  implicit_ime = fn is_initial ->
    ignore(string("."))
    |> concat(word())
    |> wrap(optional(parsec(:brackets)))
    |> post_traverse({:to_implicit_ime_ast, [is_initial]})
  end

  # Foo.bar
  # Foo.baz(0.1)
  scoped_ime =
    module_name()
    |> ignore(string("."))
    |> concat(word())
    |> wrap(optional(parsec(:brackets)))
    |> post_traverse({:to_scoped_ime_ast, []})

  defparsec(
    :ime,
    choice([
      # Scoped
      # Color.red
      scoped_ime,
      # Implicit
      # .red
      implicit_ime.(true)
    ])
    |> repeat(
      # <other_ime>.red
      implicit_ime.(false)
    )
    |> post_traverse({:chain_ast, []})
  )

  defparsec(
    :nested_attribute,
    choice([
      #
      string("attr")
      |> wrap(parsec(:brackets))
      |> post_traverse({:to_attr_ast, []}),
      #
      helper_function()
      |> enclosed("(", quoted_variable(), ")")
      |> post_traverse({:to_function_call_ast, []})
      |> post_traverse({:tag_as_elixir_code, []}),
      #
      word()
      |> parsec(:brackets)
      |> post_traverse({:to_function_call_ast, []})
    ])
  )

  @bracket_child [
    literal(),
    parsec(:key_value_pairs),
    parsec(:nested_attribute),
    parsec(:ime),
    variable()
  ]

  defparsec(
    :brackets,
    enclosed("(", comma_separated_list(choice(@bracket_child)), ")")
  )

  defparsec(
    :modifier,
    ignore_whitespace()
    |> concat(word())
    |> parsec(:brackets)
    |> parsec(:maybe_content)
    |> post_traverse({:to_function_call_ast, []}),
    export_combinator: true
  )

  defparsec(
    :modifiers,
    repeat(parsec(:modifier)),
    export_combinator: true
  )

  content =
    choice([
      enclosed("[", comma_separated_list(choice(@bracket_child)), "]"),
      #
      newline_separated_list(choice(@bracket_child)),
      #
      choice(@bracket_child)
    ])
    |> post_traverse({:tag_as_content, []})
    |> wrap()

  defparsec(
    :maybe_content,
    choice([
      enclosed("{", content, "}"),
      empty()
    ])
  )
end
