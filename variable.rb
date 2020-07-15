class Variable
  def initialize()
    @table = Hash.new
    @offset = 3
  end

  def declare(id)
    if is_declared?(id)
      puts "syntax error #{id} is already declared"
      exit(1)
    else
      @table[id] = @offset
      @offset += 1
    end
  end

  def get(id)
    if is_declared?(id)
      @table[id]
    else
      puts "syntax error #{id} is not declared"
      exit(1)
    end
  end

  def size
    @table.length
  end

private

  def is_declared?(id)
    @table.has_key?(id)
  end
end
