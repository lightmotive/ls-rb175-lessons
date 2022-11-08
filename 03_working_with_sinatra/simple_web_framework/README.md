# Simple Web Framework

## Commands

- Start server in a [standard LS Ruby Dev Container](https://github.com/lightmotive/ls-ruby-project-template): `bundle exec rackup config.ru -p 49152 -o ls-ruby-container`
  - Change the `-o` value to your main Ruby dev container's name, which is specified in `docker-compose.yml` under `services`.
    - Docker creates a default network with the container name as an alias.
    - The name should also match what's specified in `./.devcontainer/devcontainer.json`'s `service` value
  - Change the `-p` value to the same container's internal port, which specified in `docker-compose.yml` under `ports` under the main container's service entry).
