# Capistrano tasks for provisioning app configuration from a git repository,
# mirroring linked files/dirs structure. Basically this just clones (and keeps
# updated) a repository to the shared_path. You can use different branches for
# different stages and so on.
namespace :config do
  desc 'Clones configuration to shared path'
  task :clone do
    next unless fetch(:config_repo_url)

    on release_roles fetch(:config_roles) do
      within shared_path do
        execute :git, 'clone',
          '--branch', fetch(:config_repo_branch),
          fetch(:config_repo_url), fetch(:config_release_path)
      end
    end
  end

  desc 'Updates app configuration from cloned repo'
  task :update do
    next unless fetch(:config_release_path)

    on release_roles fetch(:config_roles) do
      within shared_path.join(fetch(:config_release_path)) do
        execute :git, 'fetch', 'origin'
        execute :git, 'checkout', fetch(:config_repo_branch)
        execute :git, 'pull'
      end
    end
  end

  desc 'Fetches or updates configuration in server'
  task :provision do
    invoke fetch(:config_strategy)
  end

  desc 'Fetches or updates configuration in server through git'
  task :git do
    on release_roles fetch(:config_roles) do
      config_path = shared_path.join(fetch(:config_release_path))

      # If config already exists, update it, If it doesn't, clone it
      if test "[ -d #{config_path} ]"
        invoke 'config:update'
      else
        invoke 'config:clone'
      end
    end
  end

  desc 'Syncs a local dir with the server'
  task :dir do
    local_dir = ENV['config_dir'] || fetch(:config_local_path)
    remote_dir = shared_path.join(fetch(:config_release_path))

    on roles(:app) do
      Dir.glob("#{local_dir}/*").each do |file|
        upload! file, remote_dir, recursive: true
      end
    end
  end
end

after 'deploy:check:directories', 'config:provision'

namespace :load do
  task :defaults do
    set :config_strategy, fetch(:config_strategy, 'config:git')
    set :config_roles, fetch(:config_roles, :all)
    set :config_repo_url, fetch(:config_repo_url, nil)
    set :config_repo_branch, fetch(:config_repo_branch, :master)
    set :config_release_path, fetch(:config_release_path, 'config')
    set :config_local_path, fetch(:config_local_path, "tmp/#{fetch(:stage)}-config")
  end
end
