set_default :ruby_version, "1.9.3-p327"
#set_default :rbenv_bootstrap, "bootstrap-ubuntu-12-04"
# Switch between dirrent RUBY environments cd into the folder.... then run RBENV local(or global) version#
namespace :rbenv do
  desc "Install rbenv, Ruby, and the Bundler gem"
  task :install, roles: :app do
    run "#{sudo} apt-get -y install curl vim git-core libcurl4-openssl-dev"
    run "curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash"
    bashrc = <<-BASHRC
if [ -d $HOME/.rbenv ]; then 
  export PATH="$HOME/.rbenv/bin:$PATH" 
  eval "$(rbenv init -)" 
fi
BASHRC
    put bashrc, "/tmp/rbenvrc"
    run "cat /tmp/rbenvrc ~/.bashrc > ~/.bashrc.tmp"
    run "mv ~/.bashrc.tmp ~/.bashrc"
    run %q{export PATH="$HOME/.rbenv/bin:$PATH"}
    run %q{eval "$(rbenv init -)"}
    #run "rbenv #{rbenv_bootstrap}"
    run "#{sudo} apt-get -y install build-essential zlib1g-dev libssl-dev libreadline-dev libxslt-dev libxml2-dev"
    run "yes | rbenv install #{ruby_version}"
    run "rbenv global #{ruby_version}"
    run "rbenv rehash"
  end
  after "deploy:install", "rbenv:install"
end
