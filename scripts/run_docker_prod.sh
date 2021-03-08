#! /bin/bash
docker run -it --mount type=bind,source="$(pwd)",target=/root/home jayjah/ansible-prod
