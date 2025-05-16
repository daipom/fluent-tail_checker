#!/bin/bash

set -exu

curl -OL "https://s3.amazonaws.com/packages.treasuredata.com/lts/5/redhat/9/x86_64/fluent-package-5.0.1-1.el9.x86_64.rpm"
sudo dnf install -y ./fluent-package-5.0.1-1.el9.x86_64.rpm

sudo fluent-gem install /vagrant/pkg/*

tailcheck=/opt/fluent/bin/fluent-tailcheck

$tailcheck --version
$tailcheck --help
$tailcheck /vagrant/test/data/pos_normal
(! $tailcheck /vagrant/test/data/pos_normal /vagrant/test/data/pos_duplicate_unwatched_path)
