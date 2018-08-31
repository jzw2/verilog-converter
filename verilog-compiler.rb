
class Circuit
  attr_reader :func
  # func is string representation for the function
  def initialize(func)
    @func = func.gsub("+", "|").gsub("*", "&")
  end


  def vars
    @vars ||= func.scan(/\w/).uniq.sort
  end

  #matrix of all combinations of the boolean inputs
  def input_matrix
    (0...2 **vars.length).map do |x|
      
      bool_vals = x.to_s(2).chars.map {|c| c == '1' }
      bool_vals =   [false] * (vars.length - bool_vals.length)+ bool_vals #need to pad the beginning
      bool_vals
    end
  end

  # array of the out puts corresponding to the input matrix
  def outputs
    var_declares = input_matrix.map do |row|
      vars.zip(row).map {|var, bool| "#{var} = #{bool}"}.join "\n"
    end
  #	p var_declares

    var_declares.map {|declares| eval(declares + "\n" + func)}
  end

  def boolean_matrix
    input_matrix.zip(outputs).map {|row, ans| row + [ans]}
  end

  def to_verilog
    positive = input_matrix.select {|x| x.last }
    id_count = 0
    ands = positive.map do |row|
      id_count += 1
      args = row.zip(vars).map {|bool, var| bool ? var : "not#{var}"} 
      "and o#{id_count}(w#{id_count}, #{args.join ", "});"
    end

    wires = (1..id_count).map {|id| "w#{id}"} + vars.map {|x| "not#{x}"}

    big_or = "or o1(out, #{wires.join ", "});"

    nots = vars.map {|x| "not n#{x}(not#{x}, #{x});" }

    "module test(output, #{vars.join ", "});
  output out;
  input #{vars.join ", "};

  wire #{wires.join ", "};

  #{nots.join "\n  "} 

  #{ands.join "\n  "}

  #{big_or}
endmodule"
  end



end

  circ = Circuit.new "a * b + !c"
  p circ.boolean_matrix
  puts circ.vars.join(" | ")
  circ.boolean_matrix.each do |row|
    puts row.map {|x| x ? 1 : 0}.join " | "
  end

  puts circ.to_verilog
