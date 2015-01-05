# -----------------------------------------------
#  
#  This module uses Ruby's DL library to dynamically load
#  the liblpsolve library, which is a linear equation solver.
#
#  This module mostly serves to load the file and attach to the 
#  API functions
#
# -----------------------------------------------

module LPSolve
  extend FFI::Library
  base = File.expand_path(File.join( File.dirname(__FILE__), "binaries") )
  err = nil
  ["liblpsolve55.so", "liblpsolve55.so-ux64", "liblpsolve55.dylib", "liblpsolve55.dylib.x86-64", "liblpsolve55.dylib-ppc", "lpsolve55.dll"].each do |lib|
    begin 
      err = nil
      ffi_lib File.join(base, lib) 
      break
    rescue LoadError => e
      err = e
    end
  end
  raise "Could not find suitable liblpsolve55 library #{err}" unless err.nil?
  
  #Constants used when assigning constraints
  LE = 1 # <=
  EQ = 3 # ==
  GE = 2 # >=
  
  def op_to_s(op_int)
    case op_int
      when LPSelect::GE then ">="
      when LPSelect::LE then "<=" 
      when LPSelect::EQ then "=="
    end
  end
  
  #Constants used for verbosity
  CRITICAL = 1
  SEVERE = 2
  IMPORTANT = 3
  NORMAL = 4
  DETAILED = 5
  FULL = 6
  
  #Constants used for solve results
  NOMEMORY = -2
  OPTIMAL = 0
  SUBOPTIMAL = 1
  INFEASIBLE = 2
  UNBOUNDED = 3
  DEGENERATE = 4
  NUMFAILURE = 5
  USERABORT = 6
  TIMEOUT = 7
  PRESOLVED = 9
  PROCFAIL = 10
  PROCBREAK = 11
  FEASFOUND = 12
  NOFEASFOUND = 13

  typedef :double, :REAL
  typedef :long, :lprec


  # All of the function signatures here come from 
  # http://lpsolve.sourceforge.net/5.5/lp_solveAPIreference.htm

  # void lp_solve_version(int *majorversion, int *minorversion, int *release, int *build)
  attach_function :lp_solve_version, [:pointer, :pointer, :pointer, :pointer], :void
  
  # lprec *read_LP(char *filename, int verbose, char *lp_name)
  attach_function :read_LP, [:string, :int, :string], :pointer
  
  # int solve(lprec *lp)
  attach_function :solve, [:pointer], :int
  
  # unsigned char get_variables(lprec *lp, REAL *var);
  attach_function :get_variables, [:pointer, :pointer], :char
  
  # int get_Ncolumns(lprec *lp);
  attach_function :get_Ncolumns, [:pointer], :int
  
  # char *get_col_name(lprec *lp, int column);
  attach_function :get_col_name, [:pointer, :int], :string
  
  # char *get_origcol_name(lprec *lp, int column);
  attach_function :get_origcol_name, [:pointer, :int], :string
    
  # lprec *copy_lp(lprec *lp);
  attach_function :copy_lp, [:pointer], :pointer
  
  # void print_lp(lprec *lp);
  attach_function :print_lp, [:pointer], :void
  
  # lprec *make_lp(int rows, int columns);
  attach_function :make_lp, [:int, :int], :pointer
  
  # void delete_lp(lprec *lp);
  attach_function :delete_lp, [:pointer], :void
  
  # unsigned char set_binary(lprec *lp, int column, unsigned char must_be_bin);
  attach_function :set_binary, [:pointer, :int, :char], :char
  
  # unsigned char set_col_name(lprec *lp, int column, char *new_name);
  attach_function :set_col_name, [:pointer, :int, :string], :char
  
  # unsigned char set_obj_fn(lprec *lp, REAL *row);
  attach_function :set_obj_fn, [:pointer, :pointer], :char
  
  # unsigned char add_constraint(lprec *lp, REAL *row, int constr_type, REAL rh);
  attach_function :add_constraint, [:pointer, :pointer, :int, :REAL], :char
  
  # unsigned char set_row_name(lprec *lp, int row, char *new_name);
  attach_function :set_row_name, [:pointer, :int, :string], :char
  
  # REAL get_objective(lprec *lp);
  attach_function :get_objective, [:pointer], :REAL
  
  # void set_verbose(lprec *lp, int verbose);
  attach_function :set_verbose, [:pointer, :int], :void
  
  # unsigned char set_lp_name(lprec *lp, char *lpname);
  attach_function :set_lp_name, [:pointer, :string], :char
  
  # unsigned char write_lp(lprec *lp, char *filename);
  attach_function :write_lp, [:pointer, :string], :char
  
  # void set_maxim(lprec *lp);
  attach_function :set_maxim, [:pointer], :void
  
  # void set_minim(lprec *lp);
  attach_function :set_minim, [:pointer], :void
  
  def self.version
    maj_ptr = FFI::MemoryPointer.new(:pointer, 1)
    min_ptr = FFI::MemoryPointer.new(:pointer, 1)
    rel_ptr = FFI::MemoryPointer.new(:pointer, 1)
    bld_ptr = FFI::MemoryPointer.new(:pointer, 1)
    LPSolve::lp_solve_version(maj_ptr, min_ptr, rel_ptr, bld_ptr)
    
    "#{maj_ptr.read_int}.#{min_ptr.read_int}.#{rel_ptr.read_int} build #{bld_ptr.read_int}"
  end
  
end