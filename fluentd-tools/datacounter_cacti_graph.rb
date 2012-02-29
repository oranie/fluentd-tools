#!/usr/local/rvm/rubies/ruby-1.9.3-p125/bin/ruby
#
#example: ./datacounter_cacti_graph.rb -p /var/log/td-agent/ -f counter -s count
#
#datacounterプラグインで出力された値をCacti用に項目ごとに整形・出力します。

#example:Log
#2012-02-29T18:50:44+09:00       result  {"apache.access_unmatched_count":0,"apache.access_unmatched_rate":0.0,"apache.access_2xx_count":0,"apache.access_2xx_rate":0.0,"apache.access_3xx_count":0,"apache.access_3xx_rate":0.0,"apache.access_4xx_count":0,"apache.access_4xx_rate":0.0,"apache.access_5xx_count":0,"apache.access_5xx_rate":0.0}

#example:print out
#apache.access_unmatched_count:0 apache.access_2xx_count:0       apache.access_3xx_count:0       apache.access_4xx_count:0       apache.access_5xx_count:0

require 'optparse'
require 'time'
require 'json'

opt = OptionParser.new
opts = Hash.new

opt.on('-p VAL' " cacti check log file path") {|v| opts["log_path"] = v}
opt.on('-f VAL' " cacti check log file name") {|v| opts["file_name"] = v}
opt.on('-s VAL' " cacti check string")        {|v| opts["string"] = v}

opt.parse!(ARGV)

#column_array = ["count","rate","percentage"]

def get_new_logfile(path,logfile)
    cmd = "find #{path} -name \"#{logfile}*\"| xargs ls -t| head -n 1"
    new_log_file = open("|#{cmd}")do |fp|
        new_log_file = fp.gets
    end
    File.exist?("#{new_log_file.chomp}")
    return new_log_file.chomp
end

def tac_to_hash(opts)
    log_file  = opts["log_file"]
    check_str = opts["str"]

    open("|tac #{log_file}") do |fp|
        while line = fp.gets
            line_ary = log_line_parse(line)
            record_hash = json_to_hash(line_ary[2])
            return record_hash
        end
    end
end


def log_line_parse(log_line)
    line_record = log_line.split(/\t/)
    return line_record
end


def json_to_hash(json)
    hash = JSON.parse(json)
    return hash
end

def get_hash_key_array(data_hash,column_array)
    array = data_hash.keys
    key_array = []
    column_array.each do |col|
        key_array << array.select{|elem| elem =~ /#{col}/}
    end
    return key_array
end

def print_value(hash,key_array)
    key_array.each do |key|
        if key.nil? || key.empty?  
            next
        end
        key.each do |k|
            print "#{k}:#{hash[k]}\t"
        end
        print "\n"
    end
end

begin
    opts["log_file"] = get_new_logfile(opts["log_path"],opts["file_name"])
    data_hash = tac_to_hash(opts)
    column_array = [opts["string"]]
    key_array = get_hash_key_array(data_hash,column_array)
    print_value(data_hash,key_array)
rescue => er
    print "ERROR!!!! #{er}\n"
end
