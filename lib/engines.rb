# frozen_string_literal: true

# We need engines for the custom verification flows within an application as
# they are handled by Rails engines. The engines are separated to their own
# directory in order to keep them separated from the actual application root.
#
# Make sure the following conditions are met for each engine:
# - The engine needs to have its own directory under the "engines" directory
# - The engine class file needs to be at the root of the engine directory
# - The engine directory needs to have a "lib" directory at its root at the
#   same level of the engine class file
# - Make sure also the "lib" directory has a ".keep" file in it in order to keep
#   it in the version control

require_relative "engines/helsinki/budgeting_verification"
