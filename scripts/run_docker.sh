#! /bin/bash
docker run -it --mount type=bind,source="$(pwd)",target=/root/home,readonly jayjah/ansible
