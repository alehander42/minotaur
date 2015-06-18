types:

basic
c types:

UInt : UInt64 UInt32 UInt16 UInt8 
Int  : Int64 Int32 Int16 Int8
Float
Bool
Char
Void

struct types:

class A
  a UInt8
  b Float

pointer types:

Int!
A!

generic types:

List[:t]
Dict[:t, :v]
Function[*:args]

enum types:

enum Color do
  Red
  Green
  Blue
end

algebraic data types, called variants

variant XValue do
  XClass
  XObject
  XMethod
  XNil
end

XValue e;

e.id e.id

match e do
  XClass    { e.met }
  XObject   { e.x }
end


e.as(XClass).methods

switch(e._type) {
case _internal_XClass:
    f = e.i0.met;
    break;
case _internal_XObject:
    f = e.i1.x;
    break;
default:
    raise(MatchError, "e has not a match");
}

unit types

implicit variant types

def lala(a: Int | String)
end

automatic headers

def f2(a: Int) Int
  a * 2
end

int f(int a);



class List
  generic :a
  
  def map(f: Function[:a, :b]) List[:b]
    out List[:b]
    for element in self
      out << f(element)
    end
    out
  end
  
  def map_(f: Function[:a, :b]) List![:b]
    for i in 0...@length
      self[i] = f(self[i])
    end
    self
  end
end

[4, 8].map_ { |a| a + 2}

int32_t anon_f0(int32_t a) {
    return a + 2;
}

List_Int32 _a0 = { .values = {4, 8}, .length = 2, .capacity = 3};
map__Int32(&_a0, *anon_f0);

List_Int32* map__Int32_Int32(List_Int32* self, int(*f)(int)) {
    int i;
    for(i = 0;i < self->length;i++) {
        self->values[i] = (&f)(self->values[i]);
    }
    return self;
}
