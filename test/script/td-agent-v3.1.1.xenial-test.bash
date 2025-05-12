#!/bin/bash

set -exu

curl -OL "https://s3.amazonaws.com/packages.treasuredata.com/3/ubuntu/xenial/pool/contrib/t/td-agent/td-agent_3.1.1-0_amd64.deb"
sudo apt install -y ./td-agent_3.1.1-0_amd64.deb

sudo td-agent-gem install /vagrant/pkg/*

tailcheck=/opt/td-agent/embedded/lib/ruby/gems/2.4.0/bin/tailcheck

$tailcheck --version
$tailcheck --help
$tailcheck /vagrant/test/data/pos_normal
(! $tailcheck /vagrant/test/data/pos_normal /vagrant/test/data/pos_duplicate_unwatched_path)
