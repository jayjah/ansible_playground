#! /bin/bash
docker run --platform linux/arm64 -it --network="host" --mount type=bind,source="$(pwd)",target=/root/home jayjah/ansible-prod
