# Capistrano tasks for provisioning app configuration from a git repository,
# mirroring linked files/dirs structure. Basically this just clones (and keeps
# updated) a repository to the shared_path. You can use different branches for
# different stages and so on.
namespace :config do
  desc 'Clones configuration to shared path'
  task :clone do
    repo_url = fetch(:config_repo_url)

    next unless repo_url

    on release_roles fetch(:config_roles) do
      within shared_path do
        execute :git, 'clone',
          '--branch', fetch(:config_repo_branch), repo_url, fetch(:config_release_path)
      end
    end
  end

  desc 'Updates app configuration from cloned repo'
  task :update do
    release_path = fetch(:config_release_path)

    next unless release_path && fetch(:config_repo_url)

    on release_roles fetch(:config_roles) do
      within shared_path.join(release_path) do
        execute :git, 'fetch', 'origin'
        execute :git, 'checkout', fetch(:config_repo_branch)
        execute :git, 'pull'
      end
    end
  end

  desc 'Fetches or updates configuration in server'
  task provision: :validate do
    invoke fetch(:config_strategy)
  end

  desc 'Fetches or updates configuration in server through git'
  task :git do
    next unless fetch(:config_repo_url)

    on release_roles fetch(:config_roles) do
      release_path = shared_path.join(fetch(:config_release_path))

      # If config already exists, update it, If it doesn't, clone it
      if test("[ -d #{release_path} ]") && test("[ $(ls -A #{release_path}) ]")
        invoke 'config:update'
      else
        invoke 'config:clone'
      end
    end
  end

  desc 'Syncs a local dir with the server'
  task :dir do
    local_dir = fetch(:config_local_path)
    remote_dir = shared_path.join(fetch(:config_release_path))

    next unless test("[ -d #{local_dir} ]")

    on roles(:app) do
      # Make sure remote_dir exists
      execute :mkdir, '-pv', remote_dir

      Dir.glob("#{local_dir}/*").each do |file|
        upload! file, remote_dir, recursive: true
      end
    end
  end

  desc 'Validates configuration values'
  task :validate do
    on release_roles fetch(:config_roles) do
      case fetch(:config_strategy)
      when 'config:git'
        if fetch(:config_repo_url).nil?
          warn 'config: :config_repo_url is not set'
        end
      when 'config:dir'
        local_path = fetch(:config_local_path)

        unless test("[ -d #{local_path} ]")
          warn "config: 'config_local_path: #{local_path}' doesn't exist"
        end
      else
        warn "config: unknown :config_strategy, couldn't validate it"
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
