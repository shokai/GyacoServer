#!/usr/bin/env ruby
require 'rubygems'
require 'wav-file'
require 'ArgsParser'

parser = ArgsParser.parser
parser.bind(:path, :p, 'watch path (required)')
parser.bind(:out, :o, 'out file name (required)')
parser.bind(:loop, :l, 'do loop')
parser.bind(:help, :h, 'show help')
parser.bind(:interval, :i, 'directory watch interval')
first, params = parser.parse(ARGV)

if !parser.has_params([:path, :out]) or parser.has_param(:help)
  puts parser.help
  exit 1
end

params[:path] += '/' unless params[:path] =~ /\/$/
interval = 3
interval = params[:interval] if params[:interval]

tmp_dir = '/tmp/gyaco'
Dir::mkdir(tmp_dir) unless File::exists?(tmp_dir)

files = nil
files_old = nil
loop do
  files = Dir.glob(params[:path]+'*').delete_if{|i| !(i =~ /\.(wav|mp3)/i)}.sort.reverse
  if files != files_old and files.size > 0
    sources = Array.new
    files.each{|i|
      out = "#{tmp_dir}/#{i.split(/\//).last.gsub(/\..+/,'.wav')}"
      puts `ffmpeg -i #{i} #{out}` unless File::exists?(out)
      sources << out
    }
    p sources
    format = WavFile::readFormat open(sources.first)
    dataChunk = WavFile::readDataChunk open(sources.first)
    if sources.size > 1
      for i in 1...sources.size do
        data = WavFile::readDataChunk open(sources[i])
        dataChunk.data += data.data
      end
    end
    WavFile::write(open("#{tmp_dir}/tmp.wav", 'w'), format, [dataChunk])
    puts `ffmpeg -y -i #{tmp_dir}/tmp.wav #{params[:out]}`
  end
  files_old = files
  break unless params[:loop]
  sleep interval
end


