#! /bin/bash
openssl passwd -salt "$1" "$1"
