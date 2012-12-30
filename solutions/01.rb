class Integer
  def prime?
    (2..(Math.sqrt self)).all? do |divisor|
      self % divisor != 0
    end
  end

  def prime_divisors
    number = abs
    result = []
    (2..number).step do |divisor|
      result << divisor if number % divisor == 0 and divisor.prime?
    end
    result
  end
end

class Range
  def fizzbuzz
    map do |item|
      if item % 15 == 0 then :fizzbuzz
      elsif item % 3 == 0 then :fizz
      elsif item % 5 == 0 then :buzz
      else item
      end
    end
  end
end

class Hash
  def group_values
    result = Hash.new
    each do |key, value|
      result[value] ||= []
      result[value] << key
    end
    result
  end
end

class Array
  def densities
    map { |item| count item }
  end
end
