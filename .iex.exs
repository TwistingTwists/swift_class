# input = "font(.largeTitle) bold italic"
# # output = [["font", [".largeTitle"], nil], ["bold", [true], nil], ["italic", [true], nil]]

input = "font(.largeTitle) bold italic margin-4"
# output = [["font", [".largeTitle"], nil], ["bold", [true], nil], ["italic", [true], nil]]

SwiftClass.parse(input)
