require './parser'
require './lexer'
require './variable'

parser = Parser.new(Lexer.new($stdin), Variable.new)
code = parser.parse()

File.open("code.output", "w") do |output|
  output.write(code)
end
