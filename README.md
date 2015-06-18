# minotaur

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
