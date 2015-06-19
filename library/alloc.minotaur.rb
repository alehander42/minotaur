def m_realloc(ptr: :t!, size: Size) :t!
  Cast[:t!](realloc ptr, size * Sizeof[:t])
end

a = A.new
f = [Int].new(22)

def init
  @values = Cast[:t!](malloc size * Sizeof[:t])
end

self->values = (*int)malloc(size * sizeof(int));

def m_malloc()
  (t*)malloc(ptr, size * sizeof(t))
end
