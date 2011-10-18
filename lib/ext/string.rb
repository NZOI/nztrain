class String
  def shorten
    if self.size > SHORTEN_LIMIT
      return self[0,SHORTEN_LIMIT] + "..."
    end
    
    return self
  end

  def get_date
    return DateTime.strptime(self, "%m/%d/%Y %H:%M")
  end
end
