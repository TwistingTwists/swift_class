defmodule SwiftClass.PostProcessors do
  def append_value(rest, args, context, _line, _offset, value) do
    {rest, args ++ [value], context}
  end

  def prepend_value(rest, args, context, _line, _offset, value) do
    {rest, [value | args], context}
  end

  def flip_attr(rest, [[attr], "attr"], context, _line, _offset) when is_binary(attr) do
    {rest, [attr, "Attr"], context}
  end

  def wrap_in_tuple(rest, args, context, _line, _offset) do
    {rest, [List.to_tuple(Enum.reverse(args))], context}
  end

  def block_open_with_variable_to_ast(rest, [variable, string], context, _line, _offset) do
    context =
      Map.update(context, :variables, [variable], fn variables -> [variable | variables] end)

    {rest,
     [
       {:<>, [context: Elixir, imports: [{2, Kernel}]],
        [string, {String.to_atom(variable), [], Elixir}]}
     ], context}
  end

  def inject_variables(rest, [possible_variable], context, _line, _offset)
      when is_binary(possible_variable) do
    {rest, [{String.to_atom(possible_variable), [], Elixir}], context}
  end
end
