class Integer
  def prime?
    (2..(Math.sqrt self)).all? do |divisor|
      % divisor != 0
    end
  end

  def prime_divisors
    number = abs
    result = []
    (2..number).step do |divisor|
      if number % divisor == 0 && divisor.prime?
        result << divisor
      end
    end
    result
  end
end

class Range
  def fizzbuzz
    result = to_a
    result.map! do |item|
      if item % 3 == 0
        item = item % 5 == 0 ? :fizzbuzz : :fizz
      else
        item = item % 5 == 0 ? :buzz : item
      end
    end
    result
  end
end

class Hash
  def group_values
    result = Hash.new
    self.each do |key, value|
      if result.has_key? value
        result[value] = result[value] << key
      else
        result.store value, [key]
      end
    end
    result
  end
end

class Array
  def densities
    map { |item| self.count item }
  end
end
