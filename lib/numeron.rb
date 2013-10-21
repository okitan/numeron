class Numeron
  class Answer
    def initialize(num)
      @num = validate_num(num)
    end

    def check(num)
      num = "%03d" % num.to_i
      eat = num.chars.zip(@num.chars).map {|a, b| a == b ? true: nil }.compact.count

      return eat, num.chars.size - (num.chars - @num.chars).size - eat
    end

    def inspect
      @num.inspect
    end

    protected
    def validate_num(_num)
      num = _num.to_i
      if (0..987).include?(num) && !num.to_s.chars.uniq!
        "%03d" % num
      else
        raise "invalid number #{_num.inspect}"
      end
    end
  end

  class Try
    def initialize(num, eat, bite)
      @num = Numeron::Answer.new(num)
      @eat, @bite = validate_eat_and_bite(eat, bite)
    end

    def filter(posibilities)
      posibilities.select {|num| @num.check(num) == [ @eat, @bite ] }
    end

    protected
    def validate_eat_and_bite(_eat, _bite)
      eat, bite = _eat.to_i, _bite.to_i

      raise "invalid eat #{_eat.inspect}"   unless (0..3).include?(eat)
      raise "invalid bite #{_bite.inspect}" unless (0..3).include?(bite)

      raise "eat + bite > 3" if eat + bite > 3

      return eat, bite
    end
  end

  def initialize(*excepts)
    @hundreds = num_lists - excepts.flatten
    @tens     = num_lists - excepts.flatten
    @ones     = num_lists - excepts.flatten

    @tried = []
  end

  def try(num, eat, bite)
    try = Try.new(num, eat, bite)

    @posibilities = try.filter(posibilities)
    update_candidates

    @tried << try

    self
  end

  def most_possible_number
    recommend = posibilities.map {|num| num.chars }.transpose.map {|nums| nums.max_by {|num| nums.count(num) } }.join

    posibilities.max_by {|num| Numeron::Answer.new(num).check(recommend).inject(:+) }
  end

  def least_possible_number
    count = posibilities.map(&:chars).flatten.group_by {|num| num }
    least_num = count.to_a.sort_by {|k, v| v }.transpose.first.first(3).join

    posibilities.max_by {|num| Numeron::Answer.new(num).check(least_num).inject(:+) }
  end

  def posibilities
    @posibilities ||= @hundreds.product(@tens, @ones).map {|nums| nums.uniq! ? nil : nums.join }.compact
  end

  def inspect
    <<-_NUMERON_
current posibilities: #{posibilities.size}
  hundreds: #{@hundreds}
  tens    : #{@tens}
  ones    : #{@ones}
  recommend: #{most_possible_number} or #{least_possible_number}
    _NUMERON_
  end

  protected
  def num_lists
    (0..9).to_a
  end

  def update_candidates
    @hundreds, @tens, @ones = posibilities.map {|num| num.chars.map(&:to_i) }.transpose.map(&:uniq).map(&:sort)
  end
end
