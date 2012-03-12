class String
  def shorten
    if self.size > SHORTEN_LIMIT
      return self[0,SHORTEN_LIMIT] + "..."
    end
    
    return self
  end

  def get_date(zone)
    #chunks = self.split("/");
    #chunks[0], chunks[1] = chunks[1], chunks[0]
    return Time.parse(self)
  end
end
