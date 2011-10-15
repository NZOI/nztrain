class String
  def shorten
    if self.size > SHORTEN_LIMIT
      return self[0,SHORTEN_LIMIT] + "..."
    end
    
    return self
  end
end
