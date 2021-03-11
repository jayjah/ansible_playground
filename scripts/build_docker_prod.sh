#! /bin/bash
docker build --tag jayjah/ansible-prod --ssh default --no-cache --build-arg APP_ENV=prod .
