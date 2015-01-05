require 'test_helper'

class LpSolveTest < Test::Unit::TestCase
  
  # void lp_solve_version(int *majorversion, int *minorversion, int *release, int *build)
  def test_lp_solve_version
    assert LPSolve.version.include?("5.5.0 build ")
  end
  
  # lprec *make_lp(int rows, int columns);
  def test_make_lp
    assert_nothing_raised do
      @lp = LPSolve::make_lp(0, 0) 
    end
    assert_not_nil @lp
  end
  
  # unsigned char set_binary(lprec *lp, int column, unsigned char must_be_bin);
  def test_set_binary
    @lp = LPSolve::make_lp(0, 1)
    assert_nothing_raised do
      LPSolve::set_binary(@lp, 1, 1) #Define the column to be binary
    end
  end
  
  # unsigned char set_col_name(lprec *lp, int column, char *new_name);
  def test_set_col_name
    @lp = LPSolve::make_lp(0, 1)
    assert_nothing_raised do
      LPSolve::set_col_name(@lp, 1, "fred") 
    end
  end
  
  # unsigned char set_lp_name(lprec *lp, char *lpname);
  def test_set_lp_name
    @lp = LPSolve::make_lp(0, 0) 
    assert_nothing_raised do
      LPSolve::set_lp_name(@lp, "Hi mom")
    end
  end
  
  # void set_verbose(lprec *lp, int verbose);
  def test_set_verbose
    @lp = LPSolve::make_lp(0, 0) 
    assert_nothing_raised do
      LPSolve::set_verbose(@lp, LPSolve::SEVERE )
    end
  end
  
  # lprec *copy_lp(lprec *lp);
  def test_copy_lp
    @lp = LPSolve::make_lp(0, 0) 
    assert_nothing_raised do
      LPSolve::copy_lp(@lp)
    end
  end
  
  # lprec *read_LP(char *filename, int verbose, char *lp_name)
  def test_read_lp
    filename = File.expand_path("../lp_format_sample.txt", __FILE__)
    assert_nothing_raised do
      @lp = LPSolve::read_LP(filename, LPSolve::SEVERE, "")
    end
  end
  
  # char *get_origcol_name(lprec *lp, int column);
  def test_get_origcol_name
    @lp = LPSolve::make_lp(0, 1)
    LPSolve::set_col_name(@lp, 1, "fred")
    
    colname = LPSolve::get_origcol_name(@lp, 1)
    assert_equal "fred", colname.to_s
  end

  # void set_maxim(lprec *lp);
  def test_set_maxim
    @lp = LPSolve::make_lp(0, 0) 
    assert_nothing_raised do
      LPSolve::set_maxim(@lp)
    end
  end
  
  # void set_minim(lprec *lp);
  def test_set_minim
    @lp = LPSolve::make_lp(0, 0) 
    assert_nothing_raised do
      LPSolve::set_minim(@lp)
    end
  end
  
  # unsigned char write_lp(lprec *lp, char *filename);
  def test_write_lp
    destination = Tempfile.new("lp_solve_test")
    begin
      @lp = LPSolve::make_lp(0, 1)
      LPSolve::set_col_name(@lp, 1, "fred")
    
      assert_nothing_raised do
        LPSolve::write_lp(@lp, destination.path)
      end
      assert File.size(destination.path) > 0
    ensure
      destination.unlink
    end
  end

	# int get_Ncolumns(lprec *lp);
  def test_get_Ncolumns
    @lp = LPSolve::make_lp(0, 3)
    ncols = LPSolve::get_Ncolumns(@lp)
    assert_equal 3, ncols
  end
  
	# char *get_col_name(lprec *lp, int column);
  def test_get_col_name
    @lp = LPSolve::make_lp(0, 1)
    LPSolve::set_col_name(@lp, 1, "fred")
    
    colname = LPSolve::get_origcol_name(@lp, 1)
    assert_equal "fred", colname.to_s
  end
  
	# unsigned char add_constraint(lprec *lp, REAL *row, int constr_type, REAL rh);
  def test_add_constraint
    @lp = LPSolve::make_lp(0, 2)
    
    #The API expects a 1 indexed array    
    constraint_vars = [0, 0, 1]
    FFI::MemoryPointer.new(:double, constraint_vars.size) do |p|
      p.write_array_of_double(constraint_vars)
      assert_nothing_raised do
        LPSolve::add_constraint(@lp, p, LPSelect::EQ, 1.0.to_f)
      end
    end
  end
  
  # unsigned char set_row_name(lprec *lp, int row, char *new_name);
  def test_set_row_name
    @lp = LPSolve::make_lp(0, 2)
    LPSolve::set_col_name(@lp, 1, "fred")
    LPSolve::set_col_name(@lp, 2, "bob")
    
    #The API expects a 1 indexed array
    constraint_vars = [0, 0, 1]
    FFI::MemoryPointer.new(:double, constraint_vars.size) do |p|
      p.write_array_of_double(constraint_vars)
      LPSolve::add_constraint(@lp, p, LPSelect::EQ, 1.0.to_f)
    end
    
    assert_nothing_raised do
      LPSolve::set_row_name(@lp, 1, "onlyBob")
    end
  end
  
  # unsigned char set_obj_fn(lprec *lp, REAL *row);
  def test_set_obj_fn
    @lp = LPSolve::make_lp(0, 1)
    
    #The API expects a 1 indexed array
    constraint_vars = [1.0, 3.0]
    FFI::MemoryPointer.new(:double, constraint_vars.size) do |p|
      p.write_array_of_double(constraint_vars)
      assert_nothing_raised do
        LPSolve::set_obj_fn(@lp, p)
      end
    end
  end
  
  
	# void delete_lp(lprec *lp);	
  def test_delete_lp
    @lp = LPSolve::make_lp(0, 1)
    assert_nothing_raised do
      LPSolve::delete_lp(@lp)
    end
  end
  
	# int solve(lprec *lp)
  def test_solve
    @lp = LPSolve::make_lp(0, 2)
    LPSolve::set_verbose(@lp, LPSolve::SEVERE )
    LPSolve::set_col_name(@lp, 1, "fred")
    LPSolve::set_col_name(@lp, 2, "bob")
    
    #The API expects a 1 indexed array
    constraint_vars = [0, 0, 1]
    FFI::MemoryPointer.new(:double, constraint_vars.size) do |p|
      p.write_array_of_double(constraint_vars)
      LPSolve::add_constraint(@lp, p, LPSelect::EQ, 1.0.to_f)
    end

    LPSolve::set_minim(@lp)
    
    assert_nothing_raised do
      solution = LPSolve::solve(@lp) 
    end
    
  end
  
  # REAL get_objective(lprec *lp);
  def test_get_objective
    @lp = LPSolve::make_lp(0, 2)
    LPSolve::set_verbose(@lp, LPSolve::SEVERE )
    LPSolve::set_col_name(@lp, 1, "fred")
    LPSolve::set_col_name(@lp, 2, "bob")
    
    #The API expects a 1 indexed array
    constraint_vars = [0, 0, 1]
    FFI::MemoryPointer.new(:double, constraint_vars.size) do |p|
      p.write_array_of_double(constraint_vars)
      LPSolve::add_constraint(@lp, p, LPSelect::EQ, 1.0.to_f)
    end
    
    LPSolve::set_minim(@lp)
    solution = LPSolve::solve(@lp) 
    
    assert_nothing_raised do
      objective = LPSolve::get_objective(@lp)
      assert_not_nil objective
    end
  end
  
	# unsigned char get_variables(lprec *lp, REAL *var);  
  def test_get_variables
    @lp = LPSolve::make_lp(0, 2)
    LPSolve::set_verbose(@lp, LPSolve::SEVERE )
    LPSolve::set_col_name(@lp, 1, "fred")
    LPSolve::set_col_name(@lp, 2, "bob")
    
    #The API expects a 1 indexed array
    constraint_vars = [0, 0, 1]
    FFI::MemoryPointer.new(:double, constraint_vars.size) do |p|
      p.write_array_of_double(constraint_vars)
      LPSolve::add_constraint(@lp, p, LPSelect::EQ, 1.0.to_f)
    end
    
    
    LPSolve::set_minim(@lp)
    solution = LPSolve::solve(@lp) 
    
    retvals = []
    FFI::MemoryPointer.new(:double, 2) do |p|
      assert_nothing_raised do
        err = LPSolve::get_variables(@lp, p)
      end
      retvals = p.get_array_of_double(0,2)
    end
    assert_not_nil retvals[0]
    assert_equal 1.0, retvals[1]
  end
end