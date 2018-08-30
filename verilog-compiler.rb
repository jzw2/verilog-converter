


def generate_var_set(vars)
	(0...2 **vars.length).map do |x|
		
		bool_vals = x.to_s(2).chars.map {|c| c == '1' ? "true" : "false"}
		bool_vals =   ["false"] * (vars.length - bool_vals.length)+ bool_vals
		vars.zip(bool_vals)
	end
end

def eval_var_set(var_set, func) 
	var_declares = var_set.map do |vars|
		vars.map {|var, bool| "#{var} = #{bool}"}.join "\n"
	end
#	p var_declares

	var_declares.map {|declares| eval(declares + "\n" + func)}
end
loop do
	equation = gets.gsub("+", "|").gsub("*", "&")

	variables = equation.scan /\w/
	variables = variables.uniq
	puts variables.join(" | ")

	gen = generate_var_set(variables)
	evalued = eval_var_set(gen, equation)
	gen.zip(evalued).each do |gen_val, ans|
		puts (gen_val.map {|x| x.last == "true" ? 1 : 0} + [ans ? 1 : 0]).join(" | ") 
	end

end
