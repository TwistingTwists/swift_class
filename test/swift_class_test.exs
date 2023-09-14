defmodule SwiftClassTest do
  use ExUnit.Case
  doctest SwiftClass

  describe "parse/1" do
    test "basic parser" do
      input = "font(.largeTitle) bold italic"
      output = [["font", [".largeTitle"]], ["bold", [true]], ["italic", [true]]]
      # output = [["font", [".largeTitle"], nil], ["bold", [true], nil], ["italic", [true], nil]]
      assert {:ok, ^output, _, _, _, _} = SwiftClass.parse(input)
    end
  end
end
