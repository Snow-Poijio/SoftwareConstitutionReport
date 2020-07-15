require './node'

class Parser
  def initialize(lexer, variable)
    @lexer = lexer
    @variable = variable
    @depth = 0
    @max_depth = 0
    @loop_cnt = 0
  end

  def parse()
    @token = @lexer.lex() { |l|
      @lexime = l
    }
    mProgram()
  end

private

  def checktoken(f, expected)
    if @token == expected
      @token = @lexer.lex() { |l|
        @lexime = l
      }
    else
      puts "syntax error (#{f}): #{expected} is expected"
      exit(1)
    end
  end

  def mProgram()
    code = ""
    while @token == :var do
      code += mDecl()
    end
    code += mStmts()
    code = "( INT, 0, #{@variable.size + 3 + @max_depth} )\n" + code
    code += "( OPR, 0, 0 )\n"
    code
  end

  def mDecl()
    code = ""
    checktoken("mDecl", :var)
    mIds()
    checktoken("mDecl", :semi)
    code
  end

  def mIds()
    code = ""
    id = @lexime if @token == :id
    checktoken("mIds", :id)
    @variable.declare(id)
    while @token == :comma do
      checktoken("mIds", :comma)
      id = @lexime if @token == :id
      checktoken("mIds", :id)
      @variable.declare(id)
    end
    code
  end

  def mStmts()
    code = ""
    code += mStmt()
    while @token == :semi do
      checktoken("mStmts", :semi)
      code += mStmt()
    end
    code
  end

  def mStmt()
    code = ""
    case @token
    when :id
      code += mAssign()
    when :print
      code += mPrints()
    when :for
      code += mForst()
    else
    end
    code
  end

  def mAssign()
    code = ""
    id = @lexime
    checktoken("mAssign", :id)
    checktoken("mAssign", :coleq)
    node = mSexp()
    code += node.code
    code += "( STO, 0, #{@variable.get(id)} )\n"
    code
  end

  def mPrints()
    code = ""
    checktoken("mPrints", :print)
    node = mSexp()
    code += node.code
    code += "( CSP, 0, 1 )\n"
    code += "( CSP, 0, 2 )\n"
    code
  end

  def mSexp()
    case @token
    when :num
      num = @lexime
      node = Num.new(num)
      checktoken("mSexp", :num)
    when :id
      id = @lexime
      node = Var.new(@variable.get(id))
      checktoken("mSexp", :id)
    when :lpar
      children = []
      checktoken("mSexp", :lpar)
      op = @lexime
      checktoken("mSexp", :op)
      while @token == :num || @token == :id || @token == :lpar 
        children.append(mSexp())
      end

      node = case op
      when '+'
        Plus.new(children)
      when '-'
        Minus.new(children)
      when '*'
        Mult.new(children)
      when '/'
        Div.new(children)
      end

      checktoken("mSexp", :rpar)
    else
      puts "syntax error (mSexp): :num or :id or :lpar is expected"
    end
    node
  end

  def mForst()
    @depth += 1
    @loop_cnt += 1
    loop_cnt = @loop_cnt
    @max_depth = [@max_depth, @depth].max
    code = ""
    checktoken("mForst", :for)
    id = @lexime
    checktoken("mForst", :id)
    checktoken("mForst", :coleq)
    node = mSexp()
    code += node.code
    code += "( STO, 0, #{@variable.get(id)} )\n"
    direct = @lexime
    code += mDirect()
    node = mSexp()
    code += node.code
    code += "( STO, 0, #{@variable.size + 2 + @depth} )\n"
    code += "( LAB, 0, #{2 * loop_cnt - 1} )\n"
    code += "( LOD, 0, #{@variable.get(id)} )\n"
    code += "( LOD, 0, #{@variable.size + 2 + @depth} )\n"
    code += direct == 'to' ? "( OPR, 0, 13 )\n" : "( OPR, 0, 11 )\n"
    code += "( JPC, 0, #{2 * loop_cnt} )\n"
    checktoken("mForst", :do)
    code += mStmts()
    code += "( LOD, 0, #{@variable.get(id)} )\n"
    code += "( LIT, 0, 1 )\n"
    code += direct == 'to' ? "( OPR, 0, 2 )\n" : "( OPR, 0, 3 )\n"
    code += "( STO, 0, #{@variable.get(id)} )\n"
    code += "( JMP, 0, #{2 * loop_cnt - 1} )\n"
    code += "( LAB, 0, #{2 * loop_cnt} )\n"
    checktoken("mForst", :end)
    @depth -= 1
    code
  end

  def mDirect()
    code = ""
    case @token
    when :to
      checktoken("mDirect", :to)
    when :downto
      checktoken("mDirect", :downto)
    else
      puts "syntax error (mDirect): :to or :downto is expected"
      exit(1)
    end
    code
  end
end
