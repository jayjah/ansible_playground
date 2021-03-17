#! /bin/bash
ansible all -i localhost, -m debug -a "msg={{ '$1' | password_hash('sha512', 'mysecretsalt') }}"
