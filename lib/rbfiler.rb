module Rbfiler
  def self.start
    Dir[File.expand_path('../rbfiler', __FILE__) << '/*.rb'].each do |file|
      require file
    end

    require 'fileutils'
    require 'pathname'
    require 'shellwords'
    require 'io/console'
    require 'open3'

    @file_window = Rbfiler::FileWindowController.new
    @file_window.main
  end
end
