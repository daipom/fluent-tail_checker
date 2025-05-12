#!/bin/bash

set -exu

curl -OL "https://s3.amazonaws.com/packages.treasuredata.com/lts/5/ubuntu/jammy/pool/contrib/f/fluent-package/fluent-package_5.0.1-1_amd64.deb"
sudo apt install -y ./fluent-package_5.0.1-1_amd64.deb

sudo fluent-gem install /vagrant/pkg/*

tailcheck=/opt/fluent/bin/tailcheck

$tailcheck --version
$tailcheck --help
$tailcheck /vagrant/test/data/pos_normal
(! $tailcheck /vagrant/test/data/pos_normal /vagrant/test/data/pos_duplicate_unwatched_path)
