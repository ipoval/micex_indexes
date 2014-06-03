# encoding: utf-8

require 'rspec'
require 'stringio'
require 'tempfile'
require_relative 'micex'

describe 'parses the information from the MICEX page' do
  context 'TGK1' do
    specify 'prints out some information' do
      std = $stdout.dup
      tmp_file = Tempfile.new('stdout_fake').tap { |fakestdout| $stdout.reopen(fakestdout.path) }
      micex_run
      $stdout.reopen(std)
      expect(tmp_file.read).to include 'MICEX'
    end
  end
end

__END__
