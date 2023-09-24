defmodule SwiftClassTest do
  use ExUnit.Case
  doctest SwiftClass

  def parse(input) do
    {:ok, output, _, _, _, _} = SwiftClass.parse(input)

    output
  end

  def parse_class_block(input) do
    {:ok, output, _, _, _, _} = SwiftClass.parse_class_block(input)

    output
  end

  describe "parse/1" do
    test "parses modifier function definition" do
      input = "bold(true)"
      output = [["bold", [true], nil]]

      assert parse(input) == output
    end

    test "parses modifier function with content syntax" do
      input = "background(){:content}"
      output = [["background", [], :content]]

      assert parse(input) == output
    end

    test "parses modifier with multiple arguments" do
      input = "background(\"foo\", \"bar\")"
      output = [["background", ["foo", "bar"], nil]]

      assert parse(input) == output

      # space at start and end
      input = "background( \"foo\", \"bar\" )"
      assert parse(input) == output

      # space at start only
      input = "background( \"foo\", \"bar\")"
      assert parse(input) == output

      # space at end only
      input = "background(\"foo\", \"bar\" )"
      assert parse(input) == output
    end

    test "parses single modifier with atom" do
      input = "font(:largeTitle)"

      output = [
        ["font", [["IME", "largeTitle"]], nil]
      ]

      assert parse(input) == output
    end

    test "parses multiple modifiers" do
      input = "font(:largeTitle) bold(true) italic(true)"

      output = [
        ["font", [["IME", "largeTitle"]], nil],
        ["bold", [true], nil],
        ["italic", [true], nil]
      ]

      assert parse(input) == output
    end

    test "parses multiline" do
      input = """
      font(:largeTitle)
      bold(true)
      italic(true)
      """

      output = [
        ["font", [["IME", "largeTitle"]], nil],
        ["bold", [true], nil],
        ["italic", [true], nil]
      ]

      assert parse(input) == output
    end

    test "parses string literal value type" do
      input = "foo(\"bar\")"
      output = [["foo", ["bar"], nil]]

      assert parse(input) == output
    end

    test "parses numerical types" do
      input = "foo(1, -1, 1.1)"
      output = [["foo", [1, -1, 1.1], nil]]

      assert parse(input) == output
    end

    test "parses key/value pairs" do
      input = ~s|foo(bar: "baz", qux: "quux")|
      output = [["foo", [["bar", "baz"], ["qux", "quux"]], nil]]

      assert parse(input) == output
    end

    test "parses bool and nil values" do
      input = "foo(true, false, nil)"
      output = [["foo", [true, false, nil], nil]]

      assert parse(input) == output
    end

    test "parses Implicit Member Expressions" do
      input = "color(:red)"
      output = [["color", [["IME", "red"]], nil]]

      assert parse(input) == output
    end

    test "parses nested function calls" do
      input = ~s|foo(bar("baz"))|
      output = [["foo", [["bar", ["baz"], nil]], nil]]

      assert parse(input) == output
    end

    test "parses attr value references" do
      input = ~s|foo(attr("bar"))|
      output = [["foo", [["Attr", "bar"]], nil]]

      assert parse(input) == output
    end
  end

  describe "class block parser" do
    test "parses a simple block" do
      input = """
      "red-header" do
        color(:red)
        font(:largeTitle)
      end
      """

      output = [
        {
          "red-header",
          [
            ["color", [["IME", "red"]], nil],
            ["font", [["IME", "largeTitle"]], nil]
          ]
        }
      ]

      assert parse_class_block(input) == output
    end

    test "parses a complex block" do
      input = """
      "color-" <> color_name do
        foo(true)
        color(color_name)
        bar(false)
      end
      """

      output = [
        {{:<>, [context: Elixir, imports: [{2, Kernel}]], ["color-", {:color_name, [], Elixir}]},
         [
           ["foo", [true], nil],
           ["color", [{:color_name, [], Elixir}], nil],
           ["bar", [false], nil]
         ]}
      ]

      assert parse_class_block(input) == output
    end

    test "parses a complex block (2)" do
      input = """
      "color-" <> color do
        color(color)
      end
      """

      output = [
        {{:<>, [context: Elixir, imports: [{2, Kernel}]], ["color-", {:color, [], Elixir}]},
         [
           ["color", [{:color, [], Elixir}], nil]
         ]}
      ]

      assert parse_class_block(input) == output
    end

    test "parses multiple blocks" do
      input = """
      "color-" <> color_name do
        foo(true)
        color(color_name)
        bar(false)
      end

      "color-red" do
        color(:red)
      end
      """

      output = [
        {{:<>, [context: Elixir, imports: [{2, Kernel}]], ["color-", {:color_name, [], Elixir}]},
         [
           ["foo", [true], nil],
           ["color", [{:color_name, [], Elixir}], nil],
           ["bar", [false], nil]
         ]},
        {
          "color-red",
          [
            ["color", [["IME", "red"]], nil]
          ]
        }
      ]

      assert parse_class_block(input) == output
    end
  end

  describe "helper functions" do
    test "to_atom" do
      input = "buttonStyle(style: to_atom(style))"

      output = [["buttonStyle", [["style", {:to_atom, [], [{:style, [], Elixir}]}]], nil]]

      assert parse(input) == output
    end

    test "to_integer" do
      input = "frame(height: to_integer(height))"

      output = [["frame", [["height", {:to_integer, [], [{:height, [], Elixir}]}]], nil]]

      assert parse(input) == output
    end

    test "to_float" do
      input = "kerning(kerning: to_float(kerning))"

      output = [["kerning", [["kerning", {:to_float, [], [{:kerning, [], Elixir}]}]], nil]]

      assert parse(input) == output
    end

    test "to_boolean" do
      input = "hidden(to_boolean(is_hidden))"

      output = [["hidden", [{:to_boolean, [], [{:is_hidden, [], Elixir}]}], nil]]

      assert parse(input) == output
    end

    test "camelize" do
      input = "font(family: camelize(family))"

      output = [["font", [["family", {:camelize, [], [{:family, [], Elixir}]}]], nil]]

      assert parse(input) == output
    end

    test "snake_case" do
      input = "font(family: snake_case(family))"

      output = [["font", [["family", {:snake_case, [], [{:family, [], Elixir}]}]], nil]]

      assert parse(input) == output
    end
  end
end
