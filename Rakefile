task :default => :spec
require 'spec/rake/spectask'
Spec::Rake::SpecTask.new {|t| t.spec_opts = ['--color']}

begin
  require 'jeweler'
  project_name = 'scopify'

  Jeweler::Tasks.new do |gem|
    gem.name = project_name
    gem.summary = "Add named scopes and scoped to any Object / Model."
    gem.email = "grosser.michael@gmail.com"
    gem.homepage = "http://github.com/grosser/#{project_name}"
    gem.authors = ["Michael Grosser"]
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install jeweler"
end