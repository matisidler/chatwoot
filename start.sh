#!/bin/sh

set -e

echo Waiting for database...

while ! pg_isready -h ${PGHOST} -p ${PGPORT}; do sleep 0.25; done; 

echo Database is now available

# Remove auto_annotate_models.rake if it exists, without throwing an error
rm -f /app/lib/tasks/auto_annotate_models.rake

bundle exec rails db:chatwoot_prepare

bundle exec rails db:migrate

# Set a default port if $PORT is not set
PORT=${PORT:-3000}

multirun \
    "bundle exec sidekiq -C config/sidekiq.yml" \
    "bundle exec rails s -b 0.0.0.0 -p $PORT"

false