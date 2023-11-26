#!/usr/bin/env ruby
require 'io/console'
require 'pp'
require 'optparse'

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"

  opts.on("-nREFS", "# refs to return (def 16)") { |n| options[:num_refs] = n.to_i }
  opts.on("-b", "omit non-branch refs") { |b| options[:branches] = !!b }
  opts.on("-h", "--help", "Prints this help") { puts opts exit }
end.parse!

options[:num_refs] ||= 16

branches = `git branch --list`.split("\n").map{|line| line[2..-1]} if options[:branches]

# Here is the original `git lately`, for posterity. It is an alias definition for a
# .gitconfig file
# [alias]
#   lately = !git reflog show --pretty=format:'%gs ~ %gd' --date=relative -n 1000 |\
#     grep 'checkout:' |\
#     grep -oE '[^ ]+ ~ .*' |\
#     awk -F~ '!seen[$1]++' |\
#     head -n 14 |\
#     awk -F' ~ HEAD@{' ' {printf(\"  \\033[33m%s: \\033[37m %s\\033[0m\\n\", substr($2, 1, length($2)-1), $1)}'

recents = {}
index = {}
labels = ('0'..'9').to_a + ('a'..'f').to_a
max_ts_len = 0

reflog = `git reflog show --pretty=format:'%gs ~ %gd' --date=relative -n 1000`
  .split("\n")
  .each{ |line|
    line.match(/checkout:.*?([^ ]+) ~ HEAD@{(.*)}$/) do |match| 
      ref, timestamp = match[1..2]

      next if options[:branches] && !branches.include?(ref)

      label = labels[recents.size]
      if ! recents[ref]
        index[label] = ref 
        max_ts_len = timestamp.length if timestamp.length > max_ts_len
        recents[ref] = timestamp
      end
    end
    break if recents.size >= options[:num_refs]
  }

recents.each.with_index{|(ref, timestamp), i| printf("(%-#{max_ts_len}s) #{labels[i]}:%s\n", timestamp, ref) }
print "Checkout above ref (0-9a-f)? "
char = STDIN.getch
ref = index[char]

if ref 
  puts 
  exec "git checkout #{ref}"
end
