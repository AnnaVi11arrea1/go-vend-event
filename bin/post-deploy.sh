#!/usr/bin/env bash
# Shared post-deploy hooks for any host (Render, self-hosted Linux, etc.).
set -o errexit

bundle exec rake scraper:deploy
./bin/nano-ai-bootstrap.sh
