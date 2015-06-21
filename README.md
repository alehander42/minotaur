# minotaur

[![Build Status](https://travis-ci.org/alehander42/minotaur.svg)](https://travis-ci.org/alehander42/minotaur)

unfinished(yet)

```ruby
XValue = XClass | XObject

def get_labels(elements: [XValue]) [String]
  map(elements) { |e| e.label }
end
```

```c
enum _XValueType { _XClass, _XObject };

typedef struct XValue {
    _XValueType _type;
    union {
        XClass _v0;
        XValue _v1;
    };
}

List_String get_labels(List_XValue elements) {
    int i;
    List_String labels = List_String_new(elements.length);
    for(i = 0;i < elements.length;i ++) {
        switch(elements->values[i]._type) {
            case _XClass: 
                labels->values[i] = elements->values[i]._v0.label;
        	break;
            case _XValue:
            	labels->values[i] = elements->values[i]._v1.name;
        	break;
        }
    }
    return elements;
}
```

features

* sum types
* generic types
* function overloading
* default args(sometimes)
* local type inference

```ruby
def has_value?(dict!: {:k => :v}, value: :v) Bool
    for k in dict
        return true if dict[k] == v
    end
    false
end

has_value?({'s' => 2}, 2)
has_value?({2=>4}, 3)
```

```c
// impl of dict for String, Int
// impl of dict for Int, Int

bool has_value_string_int(Dict_String_Int* dict, String value) {
    int i = 0;
    String* keys = keys(dict);
    for(i = 0;i < dict->length;i++) {
        if (get_dict_value_string_int(dict, keys[i]) == value) {
            return true;
        }
    }
    return false;
}

bool has_value_int_int(Dict_Int_Int* dict, int value) {
    int i = 0;
    int* keys = keys(dict);
    for(i = 0;i < dict->length;i++) {
        if (get_dict_value_string_int(dict, keys[i]) == value) {
            return true;
        }
    }
    return false;
}

has_value_string_int(_dict0, 2);
has_value_int_int(_dict1, 3);
```


```ruby
class XClass
    id      UInt16
    parent  XClass!
    methods HashMap[UInt16, XMethod!]

    def init(id: UInt16, methods: HashMap[Int16, XMethod!], parent: XClass! or nil)
        @id = id
        @methods = methods
        @parent = parent
    end

    def dispatch(method_id: UInt16) XMethod!
        current = self
        until current.parent.nil? || current.methods.have_key?(method_id)
            current = current.parent
        end
        if current.parent.nil?
            raise Exception.new("missing method")
        else
            return current.methods[method_id]
        end
    end
end
```

```c
typedef struct XClass {
	uint_16t 				  id;
	XClass*     			  parent;
	HashMap_UInt16_XMethodRef methods;
} XClass;

XClass XClass_new_0(uint_16t id, HashMap_UInt16_XMethodRef methods) {
	return XClass { .id = id, .methods = methods, .parent = NULL };
}

XClass XClass_new_1(uint_16t id, HashMap_UInt16_XMethodRef methods, XClass* parent) {
	return XClass { .id = id, .methods = methods, .parent = parent };
}

XMethod* dispatch(XClass* self, uint_16t id) {
	XClass* current = self;
	while(!(current->parent == NULL || have_key(current->methods, id))) {
		current = current->parent;
	}
	if (current->parent == NULL) {
		raise(EXCEPTION, "missing_method");
	}
	else {
		return get(current->methods, id);
	}
}


```
