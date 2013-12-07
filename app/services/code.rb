module Code

  def self.limitlines string, linelimit: 10000, charlimit: linelimit*51
    truncated = false
    lines = string.slice(0..charlimit).split("\n", linelimit+1)
    lines = lines.take(linelimit) and truncated = true if lines.size > linelimit
    lines.pop and truncated = true if string.length > charlimit
    lines.push(nil) if truncated
    lines
  end

  def self.limitstring string, linelimit: 10000, charlimit: linelimit*51
    limitlines(string, linelimit: linelimit, charlimit: charlimit).join("\n")
  end
end
