#!/usr/bin/env ruby
require 'io/console'
require 'pp'
require 'optparse'

# Here is the original `git lately`, for posterity. It is an alias definition for a
# .gitconfig file
# [alias]
#   lately = !git reflog show --pretty=format:'%gs ~ %gd' --date=relative -n 1000 |
#     grep 'checkout:' |
#     grep -oE '[^ ]+ ~ .*' |
#     awk -F~ '!seen[$1]++' |
#     head -n 14 |
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
      max_ts_len = timestamp.length if timestamp.length > max_ts_len
      label = labels[recents.size]
      index[label] = ref unless recents[ref]
      recents[ref] ||= timestamp
    end
    break if recents.size >= 16
  }

recents.each.with_index{|(ref, timestamp), i| printf("(%-#{max_ts_len}s) #{labels[i]}:%s\n", timestamp, ref) }
print "Checkout above ref (0-9a-f)? "
char = STDIN.getch
ref = index[char]

if ref 
  puts 
  exec "git checkout #{ref}"
end
