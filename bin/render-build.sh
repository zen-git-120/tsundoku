#!/usr/bin/env bash
set -o errexit

bundle install
yarn install --frozen-lockfile
bin/rails assets:precompile
bin/rails db:migrate