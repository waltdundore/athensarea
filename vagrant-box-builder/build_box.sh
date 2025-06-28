#!/bin/bash
vagrant up --provider=parallels
vagrant halt
vagrant package --output debian12-arm64.parallels.box
vagrant box add custom/debian12-arm64 ./debian12-arm64.parallels.box
