# Copiloting Rails

[![Website status](https://img.shields.io/website?down_color=red&down_message=offline&style=for-the-badge&up_color=green&up_message=online&url=http%3A%2F%2Fcopil-publi-15f0mgpt6v3bv-814748119.us-east-1.elb.amazonaws.com)](http://copil-publi-15f0mgpt6v3bv-814748119.us-east-1.elb.amazonaws.com)

Example [Ruby on Rails](http://rubyonrails.org) application deployed to AWS with [copilot-cli](https://aws.github.io/copilot-cli/).

## How to

### Create a Rails application

```sh
rails new copiloting_rails --database=postgresql
cd copiloting_rails
```

### Initialize Copilot application and environments

```sh
copilot app init copiloting-rails
copilot env init -n production
```

You'll want to add more than one environment, but here I'll just create one for
simplicity.

### Generate secret

```sh
secret=$(docker compose run --rm --no-deps web rails secret)
copilot secret init -n SECRET_KEY_BASE --values "production=$secret"
```

### Create the web service

Make sure to create the `SECRET_KEY_BASE` secret before continuing as the
application won't start without it.

```sh
copilot svc init -n web -t "Load Balanced Web Service" --dockerfile ./Dockerfile
```

Then edit `copilot/web/manifest.yml` and add the following:

```yaml
secrets:
  SECRET_KEY_BASE: /copilot/${COPILOT_APPLICATION_NAME}/${COPILOT_ENVIRONMENT_NAME}/secrets/SECRET_KEY_BASE
```

Finally deploy the service
```sh
copilot svc deploy -n web -e production
```

## To do

- [ ] Connect ActiveRecord to AWS RDS
- [ ] Upload to AWS S3 with ActiveStorage
- [ ] ActiveJob worker service using SQS queues
