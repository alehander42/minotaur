module Minotaur
  class MinotaurError < ::StandardError
  end

  class CTypeError < MinotaurError
  end

  class TypeError < MinotaurError
  end

  class NotImplementedError < MinotaurError
  end
end
