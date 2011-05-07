# Limiting resource use
require 'java'
require 'vendor/rhino'

module JS
  include_package 'org.mozilla.javascript'
  
  class RestrictedContext < JS::Context
    attr_accessor :start_time, :instruction_count
  end
  
  class RestrictedContextFactory < JS::ContextFactory
    INSTRUCTION_LIMIT = 1000
    TIME_LIMIT = 1
    
    def self.restrict(context)
      context.language_version = JS::Context::VERSION_1_8
      context.instruction_observer_threshold = 100
      context.optimization_level = -1
    end
    
    def restrict(context)
      self.class.restrict(context)
    end
    
    def makeContext
      RestrictedContext.new.tap do |context|
        restrict(context)
      end
    end

    def observeInstructionCount(context, instruction_count)
      context.instruction_count += instruction_count

      if context.instruction_count > INSTRUCTION_LIMIT || (Time.now - context.start_time).to_i > TIME_LIMIT
        raise "Yikes! Wayyyy too many instructions for me!"
      end
    end

    def doTopCall(callable, context, scope, this_obj, args)
      context.start_time = Time.now
      context.instruction_count = 0
      super
    end    
  end  
end

JS::ContextFactory.initGlobal(JS::RestrictedContextFactory.new)
context = JS::Context.enter

scope = context.initStandardObjects

code = %[
  
  var javascriptInMyJavaInMyRuby = function() {
    return "Can you say polyglot programming?!";
  };
  
  while (true) {
    // HAHA
  }
  
  javascriptInMyJavaInMyRuby();
]

puts context.evaluateString(scope, code, "example-2.js", 1, nil)