require 'yaml'

%w[lp_solve lp_select].each { |file| 
  require File.join( File.dirname(__FILE__), "lib",file) 
}
