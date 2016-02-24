# ShortNatra
ShortNatra is a simple URL Shortener API built with Sinatra and using Redis for storage.

# Dependencies

* Ruby 2.2.4
* [Redis](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-redis)
* Rubygems
* Bundler

# Development

If you have all dependencies, you can set your development environment by following commands.

```
git clone git@github.com:beydogan/shortnatra.git
cd shortnatra
bundle install
```

## Starting up the server

```
rackup
```

# Running Tests
ShortNatra uses **Rspec** for testing. You can run tests with following command.

```
bundle exec rspec spec
```

# Deployment

ShortNatra uses **Docker** for deployment. Dockerfile and docker-compose.yml is included in the repo. You can run docker instance by following commands.

```
docker-compose build
docker-compose up
```
