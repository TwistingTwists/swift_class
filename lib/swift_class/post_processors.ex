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
    {rest,
     [
       {:<>, [context: Elixir, imports: [{2, Kernel}]],
        [string, {String.to_atom(variable), [], Elixir}]}
     ], context}
  end

  def to_variable_ast(rest, [variable_name], context, _line, _offset) do
    {rest, [{String.to_atom(variable_name), [], Elixir}], context}
  end

  def helper_function_to_ast_name(rest, [_], context, _line, _offset, ast_name) do
    {rest, [ast_name], context}
  end

  def helper_function_to_ast(rest, args, context, _line, _offset) do
    [ast_name | other_args] = Enum.reverse(args)

    {rest, [{String.to_atom(ast_name), [], other_args}], context}
  end
end
