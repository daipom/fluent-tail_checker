#!/bin/bash

set -exu

sudo sed -i -e 's/^mirrorlist/#mirrorlist/g' \
            -e 's/^#baseurl/baseurl/g' \
            -e 's,mirror.centos.org/centos/$releasever,vault.centos.org/7.9.2009,g' \
            /etc/yum.repos.d/CentOS-Base.repo

curl -OL "https://s3.amazonaws.com/packages.treasuredata.com/3/redhat/7/x86_64/td-agent-3.1.1-0.el7.x86_64.rpm"
sudo yum install -y ./td-agent-3.1.1-0.el7.x86_64.rpm

sudo td-agent-gem install /vagrant/pkg/*

tailcheck=/opt/td-agent/embedded/lib/ruby/gems/2.4.0/bin/fluent-tailcheck

$tailcheck --version
$tailcheck --help
$tailcheck /vagrant/test/data/pos_normal
(! $tailcheck /vagrant/test/data/pos_normal /vagrant/test/data/pos_duplicate_unwatched_path)
