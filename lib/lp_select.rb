require "lp_select/version"

# Fiddle is preferred, but newer versions of DL use the same interface.
# Try to load fiddle, and fall back to DL.  Except, for our sanity call it Fiddle.
begin
  require 'fiddle'
  require 'fiddle/import'
rescue LoadError
  require 'dl'
  require 'dl/import'
  Fiddle = DL
end

require 'yaml'

module LpSelect
  require 'lp_select/lp_solve.rb'
  require 'lp_select/lp_select.rb'
end