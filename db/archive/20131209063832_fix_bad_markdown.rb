class FixBadMarkdown < ActiveRecord::Migration
  def fix_titles(string)
    toplevel = 10
    pos = 0
    while inc = (string.slice(pos, string.length) =~ /^((#+)[^#].*)$/)
      toplevel = [toplevel, $~[2].length].min
      pos += inc + $~[0].length
    end
    toplevel = 2 if toplevel<2
    string = string.gsub(/^#{Array.new(toplevel-2,"#").join}/,'').gsub(/^(#+)([^# ])/, '\1 \2')
    return string
  end

  def up
    Problem.all.each do |problem|
      problem.statement = fix_titles(problem.statement)
      problem.save
    end
  end

  def down
  end
end
