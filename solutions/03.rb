class Expr
  def self.build(expr_tree)
    tree = Array.new expr_tree
    case tree.shift
    when :+ then Addition.new Expr.build(tree.shift), Expr.build(tree.shift)
    when :* then Multiplication.new Expr.build(tree.shift), Expr.build(tree.shift)
    when :number then Number.new tree.shift
    when :variable then Variable.new tree.shift
    when :- then Negation.new Expr.build tree.shift
    when :sin then Sine.new Expr.build tree.shift
    when :cos then Cosine.new Expr.build tree.shift
    end
  end

  def +(other)
    Addition.new self, other
  end

  def *(other)
    Multiplication.new self, other
  end
end

class Binary < Expr
  attr_reader :left, :right

  def initialize(left, right)
    @left, @right = left, right
  end

  def exact?
    @left.exact? and @right.exact?
  end

  def ==(other)
    self.class == other.class and left == other.left and right == other.right
  end

  def !=(other)
    not self == other
  end
end

class Unary < Expr
  attr_reader :arg

  def initialize(arg)
    @arg = arg
  end

  def exact?
    @arg.exact?
  end

  def ==(other)
    self.class == other.class and arg == other.arg
  end

  def !=(other)
    not self == other
  end
end

class Addition < Binary
  def evaluate(environment = {})
    (@left.evaluate environment) + (@right.evaluate environment)
  end

  def simplify
    return Number.new evaluate if exact?
    return @right.simplify if @left.exact? and @left.evaluate == 0
    return @left.simplify if @right.exact? and @right.evaluate == 0
    if @left == @left.simplify and  @right == @right.simplify
      @left + @right
    else
      (@left.simplify + @right.simplify).simplify
    end
  end

  def derive(variable)
    (@left.derive(variable) + @right.derive(variable)).simplify
  end
end

class Multiplication < Binary
  def evaluate(environment = {})
    (@left.evaluate environment) * (@right.evaluate environment)
  end

  def simplify
    return Number.new evaluate if exact?
    if @left.exact?
      return Number.new 0 if @left.evaluate == 0
      return @right.simplify if @left.evaluate == 1
    end
    if @right.exact?
      return Number.new 0 if @right.evaluate == 0
      return @left.simplify if @right.evaluate == 1
    end
    if @left == @left.simplify and @right == @right.simplify
      @left * @right
    else
      (@left.simplify * @right.simplify).simplify
    end
  end

  def derive(variable)
    ((@left.derive(variable) * @right) + (@left * @right.derive(variable))).simplify
  end
end

class Negation < Unary
  def evaluate(environment = {})
    -(@arg.evaluate environment)
  end

  def simplify
    return Number.new evaluate if exact?
    Negation.new @arg.simplify
  end

  def derive(variable)
    Negation.new(@arg.derive(variable)).simplify
  end
end

class Sine < Unary
  def evaluate(environment = {})
    Math.sin @arg.evaluate environment
  end

  def simplify
    return Number.new evaluate if exact?
    Sine.new @arg.simplify
  end

  def derive(variable)
    Multiplication.new(@arg.derive(variable), Cosine.new(@arg)).simplify
  end
end

class Cosine < Unary
  def evaluate(environment = {})
    Math.cos @arg.evaluate environment
  end

  def simplify
    return Number.new evaluate if exact?
    Cosine.new @arg.simplify
  end

  def derive(variable)
    Multiplication.new(@arg.derive(variable), Negation.new(Sine.new(@arg))).simplify
  end
end

class Variable < Unary
  def evaluate(environment = {})
    raise "uninitialized variable" if not environment.has_key? @arg
    environment.fetch @arg
  end

  def simplify
    self
  end

  def derive(variable)
    return Number.new 1 if variable == @arg
    return Number.new 0
  end

  def exact?
    false
  end
end

class Number < Unary
  def evaluate(environment = {})
    @arg
  end

  def simplify
    self
  end

  def derive(variable)
    Number.new 0
  end

  def exact?
    true
  end
end
