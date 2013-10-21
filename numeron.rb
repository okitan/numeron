#!/usr/bin/env ruby

require "forwardable"

require "bundler/setup"
require_relative "lib/numeron"

class NumeronCLI
  extend Forwardable

  def_delegators :@numeron, *Numeron.instance_methods(false)

  def initialize(numeron = Numeron.new)
    @numeron = numeron
  end

  def status
    @numeron
  end

  def next_game(*excepts)
    @numeron = Numeron.new(*excepts)
  end

  alias t try
  alias n next_game
end

cli = NumeronCLI.new

require "pry"

cli.pry
