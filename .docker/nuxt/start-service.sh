#!/bin/sh

set -e

if [ -f "${WORK_DIR}/package-lock.json" ]; then
  npm install && npm run dev
else
  echo "not found package file"
  node -v
  echo "You must have nuxt js installed"
  # Keep container running but do nothing
  tail -f /dev/null
fi