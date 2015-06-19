class List
  generic   :t

  values    :t!
  length    Size
  capacity  Size

  def init(v: :t!, s: Size)
    @values = v
    @length = s
    @capacity = s
  end

  def add(other: List[:t])
    if @capacity < @length + other.length + 1
      @capacity = @capacity * 2
      @values = mrealloc(@values, @capacity)
    end
    for i in @length..(@length + other.length - 1)
      @values[@length + i] = other[i]
    end
    @values[@length + other.length] = ?\0
    self
  end
end

# e = [4, 7]

# int _a0[2] = {4, 7};
# MList e = MList_new(_a0, 2)
