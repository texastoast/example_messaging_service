#!/bin/bash

set -e

echo "Starting the application..."
echo "Environment: ${ENV:-development}"

# Add your application startup commands here
echo "Checking Deps"
mix deps.get
echo "Running Migrations"
mix ecto.migrate
echo "Seeding Database"
mix run priv/repo/seeds.exs
echo "Starting server"
iex -S mix phx.server
