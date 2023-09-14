# defmodule Attribute do
#   import NimbleParsec
#   import Words
#   import BracketAttributes

#   defparsec(
#     :attribute,
#     choice([
#       parsec(:maybe_brackets),
#       # standalone attribute - eg.
#       # bold
#       whitespace(min: 1) |> replace(true)
#     ])
#     |> wrap(),
#     export_combinator: true
#   )
# end
