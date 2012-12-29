class Expr
  def self.build(expr_tree)
    expr_tree_copy = Array.new expr_tree
    if expr_tree_copy.length == 3
      Binary.build expr_tree_copy
    else
      Unary.build expr_tree_copy
    end
  end
end

class Binary < Expr
  attr_reader :left, :right

  def self.build(expr_tree)
    case expr_tree.shift
    when :+ then Addition.new Expr.build(expr_tree.shift), Expr.build(expr_tree.shift)
    when :* then Multiplication.new Expr.build(expr_tree.shift), Expr.build(expr_tree.shift)
    end
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

class Addition < Binary
  def initialize(left, right)
    @left, @right = left, right
  end

  def evaluate(environment = {})
    (@left.evaluate environment) + (@right.evaluate environment)
  end

  def simplify
    return Number.new evaluate if exact?
    return @left.simplify if @right.exact? and @right.evaluate == 0
    return @right.simplify if @left.exact? and @left.evaluate == 0
    left, right = @left.simplify, @right.simplify
    if left == @left and right == @right
      Addition.new(left, right)
    else
      Addition.new(left, right).simplify
    end
  end

  def derive(variable)
    Addition.new(@left.derive(variable), @right.derive(variable)).simplify
  end
end

class Multiplication < Binary
  def initialize(left, right)
    @left, @right = left, right
  end

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
      Multiplication.new(@left.simplify, @right.simplify)
    else
      Multiplication.new(@left.simplify, @right.simplify).simplify
    end
  end

  def derive(variable)
    left = Multiplication.new @left.derive(variable), @right
    right = Multiplication.new @left, @right.derive(variable)
    Addition.new(left, right).simplify
  end
end

class Unary < Expr
  attr_reader :arg

  def self.build(expr_tree)
    case expr_tree.shift
    when :number then Number.new expr_tree.shift
    when :variable then Variable.new expr_tree.shift
    when :- then Negation.new Expr.build expr_tree.shift
    when :sin then Sine.new Expr.build expr_tree.shift
    when :cos then Cosine.new Expr.build expr_tree.shift
    end
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

class Negation < Unary
  def initialize(arg)
    @arg = arg
  end

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
  def initialize(arg)
    @arg = arg
  end

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
  def initialize(arg)
    @arg = arg
  end

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
  def initialize(arg)
    @arg = arg
  end

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
  def initialize(arg)
    @arg = arg
  end

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
