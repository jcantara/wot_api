module WotApi

  class Error < StandardError
  end

  class ResponseError < Error
  end

  class InvalidRegionError < Error
  end

  class InvalidConfigError < Error
  end

end
