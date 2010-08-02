require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "growl_notifier"
    gem.description = %Q{A ruby library which allows you to send Growl notifications.}
    gem.email = ["psychs@limechat.net", "e.duran@superalloy.nl","jphastings@gmail.com"]
    gem.homepage = "http://github.com/jphastings/growl_notifier"
    gem.summary = "Growl::Notifier is a OSX RubyCocoa class that allows your application to post notifications to the Growl daemon."
    gem.authors = ["Satoshi Nakagawa", "Eloy Duran","JP Hastings-Spital"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

task :default => :build