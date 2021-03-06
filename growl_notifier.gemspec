# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{growl_notifier}
  s.version = "1.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Satoshi Nakagawa", "Eloy Duran", "JP Hastings-Spital"]
  s.date = %q{2010-08-03}
  s.description = %q{A ruby library which allows you to send Growl notifications.}
  s.email = ["psychs@limechat.net", "e.duran@superalloy.nl", "jphastings@gmail.com"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc",
     "TODO"
  ]
  s.files = [
    ".gitignore",
     "History.txt",
     "LICENSE",
     "Manifest.txt",
     "README.rdoc",
     "Rakefile",
     "TODO",
     "VERSION",
     "growl_notifier.gemspec",
     "lib/growl_notifier.rb"
  ]
  s.homepage = %q{http://github.com/jphastings/growl_notifier}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Growl::Notifier is a OSX RubyCocoa class that allows your application to post notifications to the Growl daemon.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

