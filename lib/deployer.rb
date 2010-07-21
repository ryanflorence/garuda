#!/usr/bin/env ruby
require 'lib/git_extractor'
class Deployer < GitExtractor

  attr_accessor :ref_data

  def initialize(params={})
    super
    error 'No ref_data hash specified in params' if params[:ref_data].nil?
    @ref_data = params[:ref_data]
  end

end