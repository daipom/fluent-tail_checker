#!/bin/bash

set -exu

curl -OL "https://s3.amazonaws.com/packages.treasuredata.com/4/redhat/8/x86_64/td-agent-4.0.0-1.el8.x86_64.rpm"
sudo dnf install -y ./td-agent-4.0.0-1.el8.x86_64.rpm

sudo td-agent-gem install /vagrant/pkg/*

tailcheck=/opt/td-agent/bin/tailcheck

$tailcheck --version
$tailcheck --help
$tailcheck /vagrant/test/data/pos_normal
(! $tailcheck /vagrant/test/data/pos_normal /vagrant/test/data/pos_duplicate_unwatched_path)
