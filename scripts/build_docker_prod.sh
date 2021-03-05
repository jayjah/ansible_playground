#! /bin/bash
docker build --tag jayjah/ansible-prod --ssh default --build-arg APP_ENV=prod .
