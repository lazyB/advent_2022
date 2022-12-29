require('set')

class Item
  attr_accessor :value, :denominators

  def initialize(value)
    @value = value
    @denominators = Set.new
  end
end

class Monkey
  attr_accessor :name, :items, :op_v1, :op, :op_v2, :test_div, :true_monkey, :false_monkey, :inspect_count

  def initialize(name, items, op_v1, op_v2, op, test_div, true_monkey, false_monkey)
    @name = name
    @items = items
    @op_v1 = op_v1
    @op_v2 = op_v2
    @op = op
    @test_div = test_div
    @true_monkey = true_monkey
    @false_monkey = false_monkey
    @inspect_count = 0
  end

  def apply_op(item)
    @inspect_count += 1
    # return item if (@op_v1 == :old && @op_v2 == :old)
    v1 = @op_v1 == :old ? item.value : @op_v1
    v2 = @op_v2 == :old ? item.value : @op_v2
    if @op == "*"
      # item.denominators.add([@op_v1, @op_v2].select { |op| op != :old }.first)
      item.value = v1 * v2
    else
      # item.denominators.clear
      item.value = v1 + v2
    end
    item
  end

  def throw_item(item)
    throw = item.value % @test_div == 0
    if throw
      @true_monkey
    else
      @false_monkey
    end
  end
end

monkeys = []
monkey_map = {}
File.open("day_11.input").each_slice(7) do |lines|
  name_line, items_line, ops_line, test_line, test_result_1, test_result_2 = lines
  monkey_name = name_line.split.last.delete(":")
  items = items_line.split(":").last.split(",").map {|s| Item.new(s.to_i)}
  _, _, v1, op, v2 = ops_line.split(":").last.split
  v1 = v1 == "old" ? :old : v1.to_i
  v2 = v2 == "old" ? :old : v2.to_i
  op = op.to_s
  test_var = test_line.split.last.to_i
  val, res = test_result_1.split(':')
  condition_1 = val.split.last == "true"
  monkey_1 = res.split.last
  val, res = test_result_2.split(':')
  condition_2 = val.split.last == "true"
  monkey_2 = res.split.last

  monkey = Monkey.new(monkey_name, items, v1, v2, op, test_var, monkey_1, monkey_2)
  monkeys << monkey
  monkey_map[monkey_name] = monkey
end

inspection_points = [0, 19, 20, 999, 1999, 2999, 3999, 4999, 5999, 6999, 9999]

10_000.times {|i|
  max_divisor = monkeys.reduce(1){|div, monkey| div * monkey.test_div}
  monkeys.each do |monkey|
    new_items = monkey.items.map {|itm| monkey.apply_op(itm)}
    new_targets = new_items.map{|itm| monkey.throw_item(itm)}
    new_targets.zip(new_items).each{|item |
      target, itm = item
      itm.value = itm.value % max_divisor
      monkey_map[target].items << itm
    }
    monkey.items = []
  end
  if inspection_points.include?(i)
    puts i
  end
}
puts monkeys.sort_by(&:inspect_count).map(&:inspect_count)