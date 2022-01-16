#! /bin/bash
docker buildx build --platform linux/arm64 --tag jayjah/ansible-prod --ssh default --no-cache --build-arg APP_ENV=prod .
