# Capistrano::ConfigProvider

[Capistrano][] tasks for provisioning app configuration from a git repository
or local path, mirroring linked files/dirs structure.

If from a repository, basically this just clones (and keeps updated) a
repository to the `shared_path`. You can use different branches for different
stages and so on.

If from a local path, this uploads the files before [Capistrano][] symlinks them.

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'capistrano-config_provider'
```

And then execute:

``` bash
$ bundle
```

Or install it yourself as:

``` bash
$ gem install capistrano-config_provider
```

Then load it in your `Capfile`:

``` ruby
require 'capistrano/config_provider'
```

## Usage

If you are using [capistrano][]'s feature of linking config files to each release,
like this

``` ruby
set :linked_files, %w{
  config/database.yml
  config/secrets.yml
  config/environments/production.rb
}
```

you have to somehow get those files in the remote server, before even trying to
deploy. This makes a "cold" deploy really cumbersome. With this gem you just
configure the repository's url and you're good to go.

Of course, you have to manage your configuration in a repository first, and if
this repository is of private access you have to configure your server so it
can clone it through your ssh session.

### Configuration and defaults

``` ruby
# The name of the task that updates the configuration. This gems provides
# `'config:git'` and `'config:dir'`, but you could define a custom task.
set :config_strategy, 'config:git'

# Your configuration repository url.
set :config_repo_url, nil

# In which roles deploy this repo.
set :config_roles, :all

# Which branch to use from `:config_repo_url`. You could deploy from
# different branches in different stages.
set :config_repo_branch, :master

# The name of the cloned repo in capistrano's shared path and should match
# your linked files' structure. It works out of the box with capistrano and
# rails.
set :config_release_path, 'config'

# The directory from where the configuration will be uploaded to the
# server, if you're using `'config:dir'` strategy.
set :config_local_path`, "tmp/#{fetch(:stage)}-config"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can
also run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/mauriciopasquier/capistrano-config_provider. This project is
intended to be a safe, welcoming space for collaboration, and contributors are
expected to adhere to the [Contributor Covenant](http://contributor-covenant.org)
code of conduct.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

[capistrano]: http://capistranorb.com
