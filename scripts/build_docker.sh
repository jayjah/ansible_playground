#! /bin/bash
docker buildx build --platform linux/arm64 --tag jayjah/ansible-prod --no-cache .
