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
      output = {:bold, [], [true]}

      assert parse(input) == output
    end

    test "parses modifier function with content syntax" do
      input = "background(){:content}"
      output = {:background, [], [[content: :content]]}

      assert parse(input) == output

      # permits whitespace surrounds
      input = "background() { :content }"

      assert parse(input) == output

      # permits array of content references

      input = "background() { [:content1, :content2] }"

      output = {:background, [], [[content: [:content1, :content2]]]}

      assert parse(input) == output

      # permits multiline
      input = """
      background() {
        :content1
        :content2
      }
      """

      assert parse(input) == output
    end

    test "parses modifier with multiple arguments" do
      input = "background(\"foo\", \"bar\")"
      output = {:background, [], ["foo", "bar"]}

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

    test "parses single modifier with atom as IME" do
      input = "font(.largeTitle)"

      output = {:font, [], [{:., [], [nil, :largeTitle]}]}

      assert parse(input) == output
    end

    test "parses chained IMEs" do
      input = "font(color: Color.red)"

      output = {:font, [], [[color: {:., [], [:Color, :red]}]]}

      assert parse(input) == output

      input = "font(color: Color.red.shadow(.thick))"

      output =
        {:font, [],
         [[color: {:., [], [:Color, {:., [], [:red, {:shadow, [], [{:., [], [nil, :thick]}]}]}]}]]}

      assert parse(input) == output
    end

    test "parses chained IMEs within the content block" do
      input = "background() { Color.red }"

      output = {:background, [], [[content: {:., [], [:Color, :red]}]]}

      assert parse(input) == output
    end

    test "parses multiple modifiers" do
      input = "font(.largeTitle) bold(true) italic(true)"

      output = [
        {:font, [], [{:., [], [nil, :largeTitle]}]},
        {:bold, [], [true]},
        {:italic, [], [true]}
      ]

      assert parse(input) == output
    end

    test "parses complex modifier chains" do
      input = "color(color: .foo.bar.baz(1, 2).qux)"

      output =
        {:color, [],
         [
           [
             color:
               {:., [],
                [nil, {:., [], [:foo, {:., [], [:bar, {:., [], [{:baz, [], [1, 2]}, :qux]}]}]}]}
           ]
         ]}

      assert parse(input) == output
    end

    test "parses multiline" do
      input = """
      font(.largeTitle)
      bold(true)
      italic(true)
      """

      output = [
        {:font, [], [{:., [], [nil, :largeTitle]}]},
        {:bold, [], [true]},
        {:italic, [], [true]}
      ]

      assert parse(input) == output
    end

    test "parses string literal value type" do
      input = "foo(\"bar\")"
      output = {:foo, [], ["bar"]}

      assert parse(input) == output
    end

    test "parses numerical types" do
      input = "foo(1, -1, 1.1)"
      output = {:foo, [], [1, -1, 1.1]}

      assert parse(input) == output
    end

    test "parses key/value pairs" do
      input = ~s|foo(bar: "baz", qux: .quux)|
      output = {:foo, [], [[bar: "baz", qux: {:., [], [nil, :quux]}]]}

      assert parse(input) == output
    end

    test "parses bool and nil values" do
      input = "foo(true, false, nil)"
      output = {:foo, [], [true, false, nil]}

      assert parse(input) == output
    end

    test "parses Implicit Member Expressions" do
      input = "color(.red)"
      output = {:color, [], [{:., [], [nil, :red]}]}

      assert parse(input) == output
    end

    test "parses nested function calls" do
      input = ~s|foo(bar("baz"))|
      output = {:foo, [], [{:bar, [], ["baz"]}]}

      assert parse(input) == output
    end

    test "parses attr value references" do
      input = ~s|foo(attr("bar"))|
      output = {:foo, [], [{:__attr__, [], "bar"}]}

      assert parse(input) == output
    end
  end

  describe "class block parser" do
    test "parses a simple block" do
      input = """
      "red-header" do
        color(.red)
        font(.largeTitle)
      end
      """

      output = [
        {
          "red-header",
          [
            {:color, [], [{:., [], [nil, :red]}]},
            {:font, [], [{:., [], [nil, :largeTitle]}]}
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
           {:foo, [], [true]},
           {:color, [], [{Elixir, [], {:color_name, [], Elixir}}]},
           {:bar, [], [false]}
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
           {:color, [], [{Elixir, [], {:color, [], Elixir}}]}
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
        color(.red)
      end
      """

      output = [
        {{:<>, [context: Elixir, imports: [{2, Kernel}]], ["color-", {:color_name, [], Elixir}]},
         [
           {:foo, [], [true]},
           {:color, [], [{Elixir, [], {:color_name, [], Elixir}}]},
           {:bar, [], [false]}
         ]},
        {
          "color-red",
          [
            {:color, [], [{:., [], [nil, :red]}]}
          ]
        }
      ]

      assert parse_class_block(input) == output
    end
  end

  describe "helper functions" do
    test "to_atom" do
      input = "buttonStyle(style: to_atom(style))"

      output = {:buttonStyle, [], [[style: {Elixir, [], {:to_atom, [], [{:style, [], Elixir}]}}]]}

      assert parse(input) == output
    end

    test "to_integer" do
      input = "frame(height: to_integer(height))"

      output = {:frame, [], [[height: {Elixir, [], {:to_integer, [], [{:height, [], Elixir}]}}]]}

      assert parse(input) == output
    end

    test "to_float" do
      input = "kerning(kerning: to_float(kerning))"

      output =
        {:kerning, [], [[kerning: {Elixir, [], {:to_float, [], [{:kerning, [], Elixir}]}}]]}

      assert parse(input) == output
    end

    test "to_boolean" do
      input = "hidden(to_boolean(is_hidden))"

      output = {:hidden, [], [{Elixir, [], {:to_boolean, [], [{:is_hidden, [], Elixir}]}}]}

      assert parse(input) == output
    end

    test "camelize" do
      input = "font(family: camelize(family))"

      output = {:font, [], [[family: {Elixir, [], {:camelize, [], [{:family, [], Elixir}]}}]]}

      assert parse(input) == output
    end

    test "snake_case" do
      input = "font(family: snake_case(family))"

      output = {:font, [], [[family: {Elixir, [], {:snake_case, [], [{:family, [], Elixir}]}}]]}

      assert parse(input) == output
    end
  end
end
