# Development

## Quick start

```console
$ bundle
$ bundle exec exe/fluent-tailcheck --version
$ bundle exec exe/fluent-tailcheck --help
$ bundle exec exe/fluent-tailcheck test/data/pos_duplicate_unwatched_path
```

## Unit test

```console
$ bundle exec rake test
```

## Package test

Need `Vagrant`.

```console
$ vagrant status
$ vagrant up {id}
$ vagrant snapshot save {id} init
$ vagrant ssh {id} -- /vagrant/test/script/{test-script}
$ vagrant snapshot restore {id} init
```

Example:

```console
$ vagrant up centos-7
$ vagrant snapshot save centos-7 init
$ vagrant ssh centos-7 -- /vagrant/test/script/td-agent-v3.1.1.el7-test.bash
$ vagrant snapshot restore centos-7 init
```

## Install and release

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).
