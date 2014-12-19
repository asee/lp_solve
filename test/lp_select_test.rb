require 'test_helper'

class LpSelectTest < Test::Unit::TestCase
  def setup
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
  end
  
  def test_set_objective
    objective_row = {}
    assert_nothing_raised do
      @lprec.set_objective(@fruits, :min) # min is the default
      objective_row = @lprec.objective_row
    end
    assert_equal :min, objective_row[:direction]
    assert_equal @fruits.length, objective_row[:weights].length
  end
  
  def test_add_constraints
    # Alice likes berries, she gets at least one
    @lprec.add_constraint({:name => "alice_picks", :vars => ["blueberry", "strawberry"], :op => LPSelect::GE, :target => 1})
    assert_not_nil @lprec.constraints.detect{|x| x[:name] == 'alice_picks'}

    # Bob likes tropical fruit, but he shouldn't get any more than two
    @lprec.add_constraint({:name => "bob_picks", :vars => ["kiwi", "mango", "pineapple"], :op => LPSelect::LE, :target => 2})
    assert_not_nil @lprec.constraints.detect{|x| x[:name] == 'bob_picks'}

    # Carol is a toddler and gets to pick only two things.
    @lprec.add_constraint({:name => "carol_picks", :vars => ["apple", "bananna", "grapes"], :op => LPSelect::EQ, :target => 2})
    assert_not_nil @lprec.constraints.detect{|x| x[:name] == 'carol_picks'}

    # Dan is an omnivore and we like him enough that he should get at least three.
    @lprec.add_constraint({:name => "don_picks", :vars => @fruits.keys, :op => LPSelect::GE, :target => 3})    
    assert_not_nil @lprec.constraints.detect{|x| x[:name] == 'don_picks'}
    
    assert_equal 4, @lprec.constraints.count
  end
  
  def test_yaml_serialize
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
    
    yaml_source = nil
    assert_nothing_raised do
      yaml_source = @lprec.to_yaml
    end
    assert_not_nil yaml_source
    
    alt = LPSelect.new(:yaml => yaml_source)
    assert_equal alt.objective_row, @lprec.objective_row
    assert_equal alt.vars, @lprec.vars
    assert_equal alt.constraints, @lprec.constraints
  end
  
  def test_lp_format_serialize
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
    begin
      destination = Tempfile.new("lp_select_test")
      lp_source = nil
      assert_nothing_raised do
        lp_source = @lprec.to_lp_format
        @lprec.to_file(destination.path)
      end
      
      assert_not_nil lp_source
      
      @lprec.constraints.each do |c|
        assert lp_source.include?(c[:name]), "Expected the source to include #{c[:name]}"
      end
      
      @fruits.keys.each do |name|
        assert lp_source.include?(name), "Expected the source to include #{name}"
      end
      
      assert File.size(destination.path) > 0
      
      alt = LPSelect.new(:filename => destination.path)
      assert_equal alt.vars, @lprec.vars
      
    ensure
      destination.unlink
    end
  end
  
  def test_should_solve_with_min_price
    @lprec.set_objective(@fruits, :min) # min is the default

    # Alice likes berries, she gets at least one
    @lprec.add_constraint({:name => "alice_picks", :vars => ["blueberry", "strawberry"], :op => LPSelect::GE, :target => 1})

    # Bob likes tropical fruit, but he shouldn't get any more than two
    @lprec.add_constraint({:name => "bob_picks", :vars => ["kiwi", "mango", "pineapple"], :op => LPSelect::LE, :target => 2})

    # Carol is a toddler and gets to pick only two things.
    @lprec.add_constraint({:name => "carol_picks", :vars => ["apple", "bananna", "grapes"], :op => LPSelect::EQ, :target => 2})

    # Dan is an omnivore and we like him enough that he should get at least three.
    @lprec.add_constraint({:name => "don_picks", :vars => @fruits.keys, :op => LPSelect::GE, :target => 3})

    status = nil
    assert_nothing_raised do
      status = @lprec.solve
    end
    
    assert_not_nil status
    assert_equal LPSolve::OPTIMAL, status
    
    assert_not_nil @lprec.results
    selected_fruits = @lprec.results.collect{|k,v| v == 1.0 ? k : nil}.flatten.compact
    assert_equal 4.3, @lprec.objective  
    assert_equal [:apple, :pear], selected_fruits
  end
  
  def test_should_solve_with_max_price
    @lprec.set_objective(@fruits, :max) 

    # Alice likes berries, she gets at least one
    @lprec.add_constraint({:name => "alice_picks", :vars => ["blueberry", "strawberry"], :op => LPSelect::GE, :target => 1})

    # Bob likes tropical fruit, but he shouldn't get any more than two
    @lprec.add_constraint({:name => "bob_picks", :vars => ["kiwi", "mango", "pineapple"], :op => LPSelect::LE, :target => 2})

    # Carol is a toddler and gets to pick only two things.
    @lprec.add_constraint({:name => "carol_picks", :vars => ["apple", "bananna", "grapes"], :op => LPSelect::EQ, :target => 2})

    # Dan is an omnivore and we like him enough that he should get at least three.
    @lprec.add_constraint({:name => "don_picks", :vars => @fruits.keys, :op => LPSelect::GE, :target => 3})

    status = nil
    assert_nothing_raised do
      status = @lprec.solve
    end
    
    assert_not_nil status
    assert_equal LPSolve::OPTIMAL, status
    
    assert_not_nil @lprec.results
    selected_fruits = @lprec.results.collect{|k,v| v == 1.0 ? k : nil}.flatten.compact
    assert_equal 33.94, @lprec.objective  
    assert_equal [:bananna, :pear, :strawberry, :pineapple, :watermelon, :grapes, :kiwi, :mango, :cherry], selected_fruits
  end
  
end
