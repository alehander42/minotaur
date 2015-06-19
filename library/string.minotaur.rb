include string

class String
  values    Char!
  length    Size
  capacity  Size

  def init(v: Char!)
    @values = v
    @length = string::strlen(v)
    @capacity = @length + 1
  end

  def add(other: String)
    if @capacity < @length + other.length + 1
      @capacity = @capacity * 2
      @values = m_realloc(@values, @capacity)
    end
    for i in @length..(@length + other.length - 1)
      @values[@length + i] = other[i]
    end
    @values[@length + other.length] = ?\0
    self
  end
end

