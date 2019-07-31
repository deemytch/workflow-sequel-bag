#!/usr/bin/bash

bundle install --path=vendor --jobs=4 --binstubs
cat createdb.sql | psql -U postgres
ruby sequelbag.rb
