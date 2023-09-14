defmodule SwiftClassTest do
  use ExUnit.Case
  doctest SwiftClass

  def parse(input) do
    {:ok, output, _, _, _, _} = SwiftClass.parse(input)

    output
  end

  describe "parse/1" do
    test "parses modifier function definition" do
      input = "bold(true)"
      output = [["bold", [true], nil]]

      assert output == parse(input)
    end

    test "parses modifier function with content syntax" do
      input = "background(){:content}"
      output = [["background", [], :content]]

      assert output == parse(input)
    end

    test "parses modifier with multiple arguments" do
      input = "background(\"foo\" \"bar\")"
      output = [["background", ["foo", "bar"], nil]]

      assert output == parse(input)
    end

    test "parses multiple modifiers" do
      input = "font(.largeTitle) bold(true) italic(true)"
      output = [["font", [".largeTitle"], nil], ["bold", [true], nil], ["italic", [true], nil]]

      assert output == parse(input)
    end

    test "parses multiline" do
      input = """
      font(.largeTitle)
      bold(true)
      italic(true)
      """
      output = [["font", [".largeTitle"], nil], ["bold", [true], nil], ["italic", [true], nil]]

      assert output == parse(input)
    end

    test "parses string literal value type" do
      input = "foo(\"bar\")"
      output = [["foo", ["bar"], nil]]

      assert output == parse(input)
    end

    test "parses numerical types" do
      input = "foo(1 -1 1.1)"
      output = [["foo", [1, -1, 1.1], nil]]

      assert output == parse(input)
    end

    test "parses key/value pairs" do
      input = "foo(bar: \"baz\")"
      output = [["foo", [["bar", "baz"]], nil]]

      assert output == parse(input)
    end

    test "parses bool and nil values" do
      input = "foo(true false nil)"
      output = [["foo", [true, false, nil], nil]]

      assert output == parse(input)
    end

    test "parses Implicit Member Expressions" do
      input = "color(.red)"
      output = [["color", [[".red", :IME]]]]

      assert output == parse(input)
    end

    test "parses nested function calls" do
      input = "foo(bar(\"baz\"))"
      output = [["foo", [["bar", ["baz"], nil]], nil]]

      assert output == parse(input)
    end
  end
end
