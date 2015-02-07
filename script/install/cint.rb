#!/usr/bin/ruby
scriptname = ARGV[0]
lines = IO.readlines(scriptname)

lines.shift 1

File.open("#{scriptname}.cc","w") do |f|
        f.write(lines.join("\n"))
        f.write("\n")
end

system("g++ #{scriptname}.cc -o #{scriptname}.exe")
ARGV.shift 1
args = ARGV.join(" ")

exec "./#{scriptname}.exe " +  args, close_others: false

