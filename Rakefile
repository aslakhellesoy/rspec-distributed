require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/contrib/rubyforgepublisher'
require 'fileutils'
require 'hoe'
require 'spec/rake/spectask'

include FileUtils
require File.join(File.dirname(__FILE__), 'lib', 'spec', 'distributed', 'version')

AUTHOR = 'Aslak Hellesoy, Bob Cotton'
EMAIL = 'aslak.hellesoy@gmail.com', 'bob.cotton@gmail.com'
DESCRIPTION = "Run RSpec distributed with DRb or Rinda"
GEM_NAME = 'spec_distributed' # what ppl will type to install your gem

@config_file = "~/.rubyforge/user-config.yml"
@config = nil
def rubyforge_username
  unless @config
    begin
      @config = YAML.load(File.read(File.expand_path(@config_file)))
    rescue
      puts <<-EOS
ERROR: No rubyforge config file found: #{@config_file}
Run 'rubyforge setup' to prepare your env for access to Rubyforge
 - See http://newgem.rubyforge.org/rubyforge.html for more details
      EOS
      exit
    end
  end
  @rubyforge_username ||= @config["username"]
end

RUBYFORGE_PROJECT = 'rspec-ext' # The unix name for your project
HOMEPATH = "http://#{RUBYFORGE_PROJECT}.rubyforge.org"


#REV = YAML.load(`svn info`)['Revision'] rescue nil
REV=nil
VERS = Spec::Distributed::VERSION::STRING + (REV ? ".#{REV}" : "")
CLEAN.include ['**/.*.sw?', '*.gem', '.config', '**/.DS_Store']
RDOC_OPTS = ['--quiet', '--title', 'Spec::Distributed documentation',
    "--opname", "index.html",
    "--line-numbers", 
    "--main", "README",
    "--inline-source"]

class Hoe
  def extra_deps 
    @extra_deps.reject { |x| Array(x).first == 'hoe' } 
  end 
end

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
hoe = Hoe.new(GEM_NAME, VERS) do |p|
  p.author = AUTHOR 
  p.description = DESCRIPTION
  p.email = EMAIL
  p.summary = DESCRIPTION
  p.url = HOMEPATH
  p.rubyforge_name = RUBYFORGE_PROJECT if RUBYFORGE_PROJECT
  p.test_globs = ["test/**/test_*.rb"]
  p.clean_globs |= CLEAN  #An array of file patterns to delete on clean.
  
  # == Optional
  p.changes = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.extra_deps = [['rspec', '>= 1.1.1'], ['systemu', '>= 1.2.0']]     # An array of rubygem dependencies [name, version], e.g. [ ['active_support', '>= 1.3.1'] ]
  #p.spec_extras = {}    # A hash of extra values to set in the gemspec.
end

CHANGES = hoe.paragraphs_of('History.txt', 0..1).join("\n\n")
PATH    = (RUBYFORGE_PROJECT == GEM_NAME) ? RUBYFORGE_PROJECT : "#{RUBYFORGE_PROJECT}/#{GEM_NAME}"
hoe.remote_rdoc_dir = File.join(PATH.gsub(/^#{RUBYFORGE_PROJECT}\/?/,''), 'rdoc')

desc 'Generate website files'
task :website_generate do
  Dir['website/**/*.txt'].each do |txt|
    sh %{ ruby scripts/txt2html #{txt} > #{txt.gsub(/txt$/,'html')} }
  end
end

desc 'Upload website files to rubyforge'
task :website_upload do
  host = "#{rubyforge_username}@rubyforge.org"
  remote_dir = "/var/www/gforge-projects/#{PATH}/"
  local_dir = 'website'
  sh %{rsync -aCv #{local_dir}/ #{host}:#{remote_dir}}
end

desc 'Generate and upload website files'
task :website => [:website_generate, :website_upload, :publish_docs]

desc 'Release the website and new gem version'
task :deploy => [:check_version, :website, :release] do
  puts "Remember to create SVN tag:"
  puts "svn copy svn+ssh://#{rubyforge_username}@rubyforge.org/var/svn/#{PATH}/trunk " +
    "svn+ssh://#{rubyforge_username}@rubyforge.org/var/svn/#{PATH}/tags/REL-#{VERS} "
  puts "Suggested comment:"
  puts "Tagging release #{CHANGES}"
end

desc 'Runs tasks website_generate and install_gem as a local deployment of the gem'
task :local_deploy => [:website_generate, :install_gem]

task :check_version do
  unless ENV['VERSION']
    puts 'Must pass a VERSION=x.y.z release version'
    exit
  end
  unless ENV['VERSION'] == VERS
    puts "Please update your version.rb to match the release version, currently #{VERS}"
    exit
  end
end

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec\/spec,\/var\/lib\/gems,\/Library\/Ruby,\.autotest']
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

# Hoe insists on setting task :default => :test
# !@#$ no easy way to empty the default list of prerequisites
Rake::Task['default'].send :instance_variable_set, "@prerequisites", FileList[]
desc "Default task is to run specs"
task :default => :spec

namespace :example do
  desc "Run examples the plain way"
  Spec::Rake::SpecTask.new('plain') do |t|
    t.spec_files = FileList['examples/**/*.rb']
    t.spec_opts = [
      '--color', '--diff'
    ]
  end

  desc "Run a slave for examples"
  Spec::Rake::SpecTask.new('slave') do |t|
    t.spec_files = FileList['examples/**/*.rb']
    t.spec_opts = [
      '--color', '--diff',
      '--require', 'rubygems,spec/distributed,spec/distributed/hooks/slave_update_svn', 
      '--runner', 'Spec::Distributed::RindaSlaveRunner'
    ]
    t.libs = ['lib'] # This line is not necessary if you have Spec::Distributes installed as a gem
  end

  desc "Run a master for examples"
  Spec::Rake::SpecTask.new('master') do |t|
    t.spec_files = FileList['examples/**/*.rb']
    t.spec_opts = [
      '--color', '--diff',
      '--require', 'rubygems,spec/distributed,spec/distributed/hooks/master_detect_svn_rev', 
      '--runner', 'Spec::Distributed::RindaMasterRunner'
    ]
    t.libs = ['lib'] # This line is not necessary if you have Spec::Distributes installed as a gem
  end
end
