#!/usr/bin/env ruby
require 'io/console'
require 'pp'
require 'optparse'

# Here is the original `git lately`, for posterity. It is an alias definition for a
# .gitconfig file
# [alias]
#   lately = !git reflog show --pretty=format:'%gs ~ %gd' --date=relative -n 1000 |\
#     grep 'checkout:' |\
#     grep -oE '[^ ]+ ~ .*' |\
#     awk -F~ '!seen[$1]++' |\
#     head -n 14 |\
#     awk -F' ~ HEAD@{' ' {printf(\"  \\033[33m%s: \\033[37m %s\\033[0m\\n\", substr($2, 1, length($2)-1), $1)}'

opts = {}
OptionParser.new do |options|
  options.banner = "Usage: #{$0} [options]"

  options.on("-nREFS", "--num-refs=REFS", "# refs to return (def 16)") { |n| opts[:num_refs] = n.to_i }
  options.on("-b", "--branches", "omit non-branch refs") { |b| opts[:branches] = !!b }
  options.on("-h", "--help", "Prints this help") { puts options; exit }
end.parse!

opts[:num_refs] ||= 16

recents = {}
index = {}
labels = ('0'..'9').to_a + ('a'..'f').to_a
max_ts_len = 0

# Maybe overkill to use IO here, but we're opening that can of worms next, 
# so might as well.
branches = IO.popen(%w[git branch --list]) do |branch_output|
  branch_output.each_line.map{ |line| line[2..-2] }
end if opts[:branches]

#
# Use IO to open a pipe so output will be buffered. This lets us quit when we have
# what we want, w/out having to consume the rest of a huge reflog
#
cmd = %w[git reflog show --pretty=format:%gs~%gd --date=relative]
IO.popen(cmd) do |reflog|
  reflog.each_line do |line|
    line.chomp.match(/checkout:.*?([^ ]+)~HEAD@{(.*)}$/) do |match| 
      ref, timestamp = match[1..2]
      next if opts[:branches] && !branches.include?(ref)
      label = labels[recents.size]
      if ! recents[ref]
        index[label] = ref
        max_ts_len = timestamp.length if timestamp.length > max_ts_len
        recents[ref] = timestamp
      end
    end
    break if recents.size >= opts[:num_refs]
  end
end

recents.each.with_index do |(ref, timestamp), i| 
  printf("(%-#{max_ts_len}s) #{labels[i]}:%s\n", timestamp, ref)
end
print "Checkout above ref (0-9a-f)? "
ref = index[STDIN.getch]

puts && exec(%w[git checkout ref]) if ref