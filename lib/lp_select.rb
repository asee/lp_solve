require "lp_select/version"

# Fiddle is preferred, but newer versions of DL use the same interface.
# Try to load fiddle, and fall back to DL.
begin
  require 'fiddle'
  require 'fiddle/import'
  ExtFfnLib = Fiddle
rescue LoadError
  require 'dl'
  require 'dl/import'
  ExtFfnLib = DL
end

require 'yaml'

module LpSelect
  require 'lp_select/lp_solve.rb'
  require 'lp_select/lp_select.rb'
end