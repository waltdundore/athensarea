#!/bin/bash
git pull
ansible-vault decrypt ansible/group_vars/all/vault.yml
