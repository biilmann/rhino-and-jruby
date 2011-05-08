require 'java'
require 'vendor/rhino'

module JS
  include_package 'org.mozilla.javascript'
end

context = JS::Context.enter

scope = context.initStandardObjects

code = %[
  
  var javascriptInMyJavaInMyRuby = function() {
    return "Can you say polyglot programming?!";
  };
  
  javascriptInMyJavaInMyRuby();
]

puts context.evaluateString(scope, code, "example-1.js", 1, nil)