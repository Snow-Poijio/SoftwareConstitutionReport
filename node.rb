class Num
  def initialize(num)
    @num = num
  end

  def code
    "( LIT, 0, #{@num.to_i} )\n"
  end
end

class Var
  def initialize(offset)
    @offset = offset
  end

  def code
    "( LOD, 0, #{@offset} )\n"
  end
end

class BinOp
  def initialize(children)
    @children = children
  end
end

class Plus < BinOp
  def code
    code = @children[0].code
    @children[1..].each do |node|
      code += node.code
      code += "( OPR, 0, 2 )\n"
    end
    code
  end
end

class Minus < BinOp
  def code
    code = @children[0].code
    @children[1..].each do |node|
      code += node.code
      code += "( OPR, 0, 3 )\n"
    end
    code
  end
end

class Mult < BinOp
  def code
    code = @children[0].code
    @children[1..].each do |node|
      code += node.code
      code += "( OPR, 0, 4 )\n"
    end
    code
  end
end

class Div < BinOp
  def code
    code = @children[0].code
    @children[1..].each do |node|
      code += node.code
      code += "( OPR, 0, 5 )\n"
    end
    code
  end
end
