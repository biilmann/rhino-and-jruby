# Exposing Ruby methods
require 'java'
require 'vendor/rhino'
require 'net/http'

module JS
  include_package 'org.mozilla.javascript'

  class HttpFunction < JS::NativeFunction
    def call(context, scope, scriptable, args)
      Net::HTTP.get URI.parse(args[0])
    end
  end
end

context = JS::Context.enter

scope = context.initStandardObjects

JS::ScriptableObject.putProperty(scope, "http", JS::HttpFunction.new)

code = %[
  http("http://www.webpop.com")
]

puts context.evaluateString(scope, code, "example-3.js", 1, nil)