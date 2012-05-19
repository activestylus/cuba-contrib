require 'htmlentities'
require "handlebars"

class Cuba
  module Handlebars

    def self.setup(app)
      app.settings[:views]  ||= File.expand_path("views", Dir.pwd)
      app.settings[:layout] ||= "layout"
    end

    def coder
    	HTMLEntities.new
    end

    def unescape(html)
    	coder.decode(html)
    end

    def escape(html)
    	coder.code(html)
    end

    def context
    	::Handlebars::Context.new
    end

    def safe_string(string)
    	::Handlebars::SafeString.new(string)
    end

    def read_file(template)
    	File.open(handle_path(template)).read
    end

    def partial(template, locals = {})
      source = read_file(template)
      html   = context.compile(source).call(locals)
      coder.decode(html)
    end

    def register_partial(name,path)
    	context.register_partial(name, read_file(path))
    end

    def view(template, locals = {}, layout = settings[:layout])
      raise NoLayout.new(self) unless layout
      partial(layout, locals.merge(handle_vars(partial(template, locals))))
    end

    def handle_path(template)
      return template if template.end_with?(".hbs")
      File.join(settings[:views], "#{template}.hbs")
    end

    def handle_vars(content)
      { content: content, session: session }
    end

    class NoLayout < StandardError
      attr :instance

      def initialize(instance)
        @instance = instance
      end

      def message
        "Missing Layout: Try doing #{instance.class}.settings[:layout] = 'layout'"
      end
    end
  end
end
