#!/usr/bin/env bash
set -e
rm -f Gemfile.lock
bundle config gem.fury.io $GEMFURY_DEPLOY_TOKEN
bundle install
bundle exec srb tc
METRICS=1 bundle exec rspec spec
