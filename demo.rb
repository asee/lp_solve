require 'init.rb'

# The idea here is to make a fruit salad that everyone will enjoy, for the lowest cost possible.
# Contrived, but illustrates the use of boolean variables and constraints for making choices.


@fruits = {
  "apple" => 1, 
  "bananna" => 0.3, 
  "pear" => 1.4, 
  "strawberry" => 3, 
  "pineapple" => 5, 
  "watermelon" => 4.3, 
  "grapes" => 2.4, 
  "orange" => 0.89, 
  "kiwi" => 3.49, 
  "mango" => 4.45, 
  "cherry" => 6, 
  "blueberry" => 5.50
}

@lprec = LPSelect.new(:vars => @fruits.keys)
@lprec.set_objective(@fruits, :min) # min is the default

# Alice likes berries, she gets at least one
@lprec.add_constraint({:name => "alice_picks", :vars => ["blueberry", "strawberry"], :op => LPSelect::GE, :target => 1})

# Bob likes tropical fruit, but he shouldn't get any more than two
@lprec.add_constraint({:name => "bob_picks", :vars => ["kiwi", "mango", "pineapple"], :op => LPSelect::LE, :target => 2})

# Carol is a toddler and gets to pick only two things.
@lprec.add_constraint({:name => "carol_picks", :vars => ["apple", "bananna", "grapes"], :op => LPSelect::EQ, :target => 2})

# Dan is an omnivore and we like him enough that he should get at least three.
@lprec.add_constraint({:name => "don_picks", :vars => @fruits.keys, :op => LPSelect::GE, :target => 3})

# etc...

# At this point, you can serialize it to yaml for reading later, 
# or to the native readable format for command line use
print "YAML DEFINITION:\n" + @lprec.to_yaml
print "LP FORMAT DEFINITION:\n" + @lprec.to_lp_format

# Or just right to a file
# @lprec.to_file("fruit_salad_lp.txt")

# Solve it:
print "\nSOLVE STATUS:\n #{@lprec.solve}"

# Get the results:
print "\nLOW COST SOLUTION RESULT:\n" + @lprec.results.inspect
print "\nTOTAL COST: #{@lprec.objective}"
print "\nSELECTED FRUITS: #{@lprec.results.collect{|k,v| v == 1.0 ? k : nil}.flatten.compact.join(", ")}"


# make an expensive one
@lprec.set_objective(@fruits, :max) 
@lprec.solve
print "\nHIGH COST SOLUTION:\n" + @lprec.results.inspect
print "\nTOTAL COST: #{@lprec.objective}"
print "\nSELECTED FRUITS: #{@lprec.results.collect{|k,v| v == 1.0 ? k : nil}.flatten.compact.join(", ")}"