require 'ruby-prof'

class Profiler
  def initialize(app)
    @app = app
  end

  def call(env)
    res = nil

    return @app.call(env) if env["ORIGINAL_FULLPATH"] !~ /\/t\/oh/

    # warm up
    10.times do
      @app.call(env)
    end

    result = RubyProf.profile do
      100.times do
        res = @app.call(env)
      end
    end

    printer = RubyProf::GraphHtmlPrinter.new(result)
    File.open("/tmp/master.html", 'w') { |file| printer.print(file) }

    res
  end
end

Rails.configuration.middleware.use Profiler
