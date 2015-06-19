# include stdio(printf)
# import library
include stdio

def print(value: Int)
	stdio::printf("%d", value)
end

def add4(a: Int) Int
  a + 4
end

print(add4(4))
