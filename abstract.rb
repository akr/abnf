=begin
= abstract.rb implements abstract methods for Ruby.

In general, abstract methods are not required for dynamically typed
object oriented languages such as Ruby.
It is because existence of a method is checked at run time.

This library makes it possible to check existence of a method with unit test
before run time.

== Example
  require 'abstract'

  class A
    define_abstract_method :m
  end

  class B < A
    def m
      p :B
    end
  end

  class C < A
  end

  if __FILE__ == $0
    require 'runit/testcase'
    require 'runit/cui/testrunner'

    class AbstractTest < RUNIT::TestCase
      def test_abstract
	assert_equal([], B.abstract_methods) #=> success
	assert_equal([], C.abstract_methods) #=> fail
      end
    end

    RUNIT::CUI::TestRunner.run(AbstractTest.suite)
  end

== Methods
--- Module#define_abstract_method(name)
    defines an abstract method named as ((|name|)).

    If the defined method is called, AbstractMethodCallError is raised.

--- Module#abstract_methods
    returns an array which contains list of non-redefined abstract method names.
    The method names are represented as symbols.

--- Module#abstract?
    returns true iff there is a non-redefined abstract method.
=end

class AbstractMethodCallError < NotImplementedError
end

class Module
  AbstractMethods = {}

  def define_abstract_method(name)
    name = name.intern if String === name
    AbstractMethods[self] ||= []
    AbstractMethods[self] << name
    self.class_eval {
      define_method(name) {raise AbstractMethodCallError.new(name.to_s)}
    }
  end

  def abstract_methods
    methods = []
    ancestors.reverse_each {|mod|
      methods -= mod.instance_methods.map {|name| name.intern}
      methods |= AbstractMethods[mod] if AbstractMethods.include? mod
    }
    methods
  end

  def abstract?
    !abstract_methods.empty?
  end
end

if __FILE__ == $0
  require 'runit/testcase'
  require 'runit/cui/testrunner'

  class AbstractTest < RUNIT::TestCase
    def test_class
      eval <<-End
        class A
	  define_abstract_method :m
	end
	assert_equal([:m], A.abstract_methods)

	class B < A
	end
	assert_equal([:m], B.abstract_methods)

	class C < B
	  def m
	  end
	end
	assert_equal([], C.abstract_methods)
      End
    end

    def test_module
      eval <<-End
        module M
	  define_abstract_method :m
	end
	assert_equal([:m], M.abstract_methods)

	module N
	  include M
	end
	assert_equal([:m], N.abstract_methods)

	module O
	  include N
	  def m
	  end
	end
	assert_equal([], O.abstract_methods)

	class X
	  include N
	end
	assert_equal([:m], X.abstract_methods)

	class Y
	  include O
	end
	assert_equal([], Y.abstract_methods)
      End
    end
  end

  RUNIT::CUI::TestRunner.run(AbstractTest.suite)
end