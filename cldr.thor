$:.unshift(File.dirname(__FILE__) + '/lib')

# This is a copy of the "cldr" gem's cldr.thor file in order to run it locally
# in this project.

require "rubygems"
require "thor"
require "cldr/thor"
