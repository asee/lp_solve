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
  extend Fiddle::Importer
  base = File.expand_path(File.join( File.dirname(__FILE__), "binaries") )
  err = nil
  ["liblpsolve55.so", "liblpsolve55.so-ux64", "liblpsolve55.dylib", "liblpsolve55.dylib.x86-64", "liblpsolve55.dylib-ppc", "lpsolve55.dll"].each do |lib|
    begin 
      err = nil
      dlload File.join(base, lib) 
      break
    rescue
      err = $!  
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

  # used where we pass a pointer to a long which gets modified in the call
  # and where we need to actually read the modified value within Ruby
  IntArg = struct [
      "int val"
  ]

  #Hold the C pointer to the lprec
  typealias("lprec*", "long")
  
  #The lp_solve API also defines this alias
  typealias("REAL", "double")


  # All of the function signatures here come from 
  # http://lpsolve.sourceforge.net/5.5/lp_solveAPIreference.htm

  # void lp_solve_version(int *majorversion, int *minorversion, int *release, int *build)
  extern "void lp_solve_version(int *, int *, int *, int *)"
  # lprec *read_LP(char *filename, int verbose, char *lp_name)
  extern "lprec *read_LP(char *, int , char *)"
  # int solve(lprec *lp)
  extern "int solve(lprec *)"
  # unsigned char get_variables(lprec *lp, REAL *var);
  extern "unsigned char get_variables(lprec *, REAL *)"
  # int get_Ncolumns(lprec *lp);
  extern "int get_Ncolumns(lprec *)"
  # char *get_col_name(lprec *lp, int column);
  extern "char *get_col_name(lprec *, int )"
  # char *get_origcol_name(lprec *lp, int column);
  extern "char *get_origcol_name(lprec *, int )"
  # lprec *copy_lp(lprec *lp);
  extern "lprec *copy_lp(lprec *)"
  # void print_lp(lprec *lp);
  extern "void print_lp(lprec *)"
  # lprec *make_lp(int rows, int columns);
  extern "lprec *make_lp(int, int)"
  # void delete_lp(lprec *lp);
  extern "void delete_lp(lprec *)"
  # unsigned char set_binary(lprec *lp, int column, unsigned char must_be_bin);
  extern "unsigned char set_binary(lprec *, int, unsigned char)"
  # unsigned char set_col_name(lprec *lp, int column, char *new_name);
  extern "unsigned char set_col_name(lprec *, int , char *)"
  # unsigned char set_obj_fn(lprec *lp, REAL *row);
  extern "unsigned char set_obj_fn(lprec *, REAL *)"
  # unsigned char add_constraint(lprec *lp, REAL *row, int constr_type, REAL rh);
  extern "unsigned char add_constraint(lprec *, REAL *, int, REAL)"
  # unsigned char set_row_name(lprec *lp, int row, char *new_name);
  extern "unsigned char set_row_name(lprec *, int , char *)"
  # REAL get_objective(lprec *lp);
  extern "REAL get_objective(lprec *)"
  # void set_verbose(lprec *lp, int verbose);
  extern "void set_verbose(lprec *, int )"
  # unsigned char set_lp_name(lprec *lp, char *lpname);
  extern "unsigned char set_lp_name(lprec *, char *)"
  # unsigned char write_lp(lprec *lp, char *filename);
  extern "unsigned char write_lp(lprec *, char *)"
  # void set_maxim(lprec *lp);
  extern "void set_maxim(lprec *)"
  # void set_minim(lprec *lp);
  extern "void set_minim(lprec *)"
  
  def version
    maj = IntArg.malloc
    min = IntArg.malloc
    rel = IntArg.malloc
    bld = IntArg.malloc
          
    LPSolve::lp_solve_version(maj, min, rel, bld)
    version = "#{maj.val}.#{min.val}.#{rel.val} build #{bld.val}"
    version
  end
  
end