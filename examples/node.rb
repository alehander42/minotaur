class XValue
  proto XValue!
  data  {String => XValue}

  def init(data: {String => XValue}, proto: XValue! or nil)
    @proto = proto
    @data = data
  end

  def dispatch(message: String) XValue!
    result XValue!
    current = self

    while result.nil?
      raise NotFoundError(message) if current.nil?
      result = current.data[message]
    end
    result
  end
end

class Node
  generic :t

  value     :t
  link      Node![:t]

  def init(value: :t)
    @value = value
    @link  = nil
  end

  def push(value: t) Node[:t]
    @link = self
    @value = value
    self
  end

  def find(value: t) Node![:t]
    node = self
    until node.nil?
      return node if node.value == value
      node = node.link
    end
    nil
  end
end

XValue* dispatch(XValue* self, MString message) {
    XValue* result = NULL;
    XValue* current = self;

    while (result == NULL) {
        if (current == NULL) {
            raise_not_found_error(message);
        }
        result = get_key(current->data, message);
    }
    return result;
}

