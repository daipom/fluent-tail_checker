#!/bin/bash

set -exu

curl -OL "https://s3.amazonaws.com/packages.treasuredata.com/4/ubuntu/focal/pool/contrib/t/td-agent/td-agent_4.0.0-1_amd64.deb"
sudo apt install -y ./td-agent_4.0.0-1_amd64.deb

sudo td-agent-gem install /vagrant/pkg/*

tailcheck=/opt/td-agent/bin/fluent-tailcheck

$tailcheck --version
$tailcheck --help
$tailcheck /vagrant/test/data/pos_normal
(! $tailcheck /vagrant/test/data/pos_normal /vagrant/test/data/pos_duplicate_unwatched_path)
