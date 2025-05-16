# fluent-tailcheck

`fluent-tailcheck` is a command for [Fluentd](https://www.fluentd.org/).

This command checks whether [in_tail](https://docs.fluentd.org/input/tail) plugin is collecting logs properly.
For example, this command verifies whether a known critical log missing issue is occurring.

Known critical log missing issues:

* https://github.com/fluent/fluentd/issues/3614
  * In case `follow_inodes false` (default setting), collection of a file may stop and continue to stop after log rotation.
  * Fixed since Fluentd v1.16.3 (fluent-package v5.0.2, td-agent v4.5.2).
* https://github.com/fluent/fluentd/issues/4190
  * In case `follow_inodes true`, collection of a file may stop and continue to stop after log rotation.
  * Fixed since Fluentd v1.16.2 (fluent-package v5.0.0, td-agent v4.5.1).

This command allows you to check whether these issues are occurring on your Fluentd.

## Requirements

| fluent-tailcheck | fluentd | td-agent | fluent-package |
|------------------|---------|----------|----------------|
| all versions     | >= v1.0 | >= 3.1.1 | >= 5.0.0       |

## Installation

### fluent-package

#### RPM/DEB (Linux)

```console
$ sudo fluent-gem install fluent-tail_checker
```

Then, you can use the command as follows.

```console
$ /opt/fluent/bin/fluent-tailcheck --help
```

#### .msi (Windows)

`Fluent Package Command Prompt` with Administrator privilege:

```console
$ fluent-gem install fluent-tail_checker
```

Then, you can use the command as follows.

```console
$ fluent-tailcheck --help
```

### For td-agent v4

#### RPM/DEB (Linux)

```console
$ sudo td-agent-gem install fluent-tail_checker
```

Then, you can use the command as follows.

```console
$ /opt/td-agent/bin/fluent-tailcheck --help
```

#### .msi (Windows)

`Td-agent Command Prompt` with Administrator privilege:

```console
$ td-agent-gem install fluent-tail_checker
```

Then, you can use the command as follows.

```console
$ fluent-tailcheck --help
```

### For td-agent v3

#### RPM/DEB (Linux)

```console
$ sudo td-agent-gem install fluent-tail_checker
```

Then, you can use the command as follows.

```console
$ /opt/td-agent/embedded/lib/ruby/gems/2.4.0/bin/fluent-tailcheck --help
```

#### .msi (Windows)

`Td-agent Command Prompt` with Administrator privilege:

```console
$ fluent-gem install fluent-tail_checker
```

Then, you can use the command as follows.

```console
$ fluent-tailcheck --help
```

### For your Ruby environment

```console
$ gem install fluent-tail_checker
```

Then, you can use the command as follows.

```console
$ fluent-tailcheck --help
```

## Usage

### Help

```console
$ fluent-tailcheck --help
```

### Version

```console
$ fluent-tailcheck --version
```

### Check pos files

You can specify a path of a pos file to check:

```console
$ fluent-tailcheck /var/log/td-agent/pos/secure
```

You can specify multiple paths:

```console
$ fluent-tailcheck /var/log/td-agent/pos/secure /var/log/td-agent/pos/message
```

You can use wildcards:

```console
$ fluent-tailcheck /var/log/td-agent/pos/*
```

If you use [follow_inodes](https://docs.fluentd.org/input/tail#follow_inodes), then you must specify `--follow-inodes` option.
(If you have both settings that use `follow_inodes` and those that do not, please run the command separately.)

```console
$ fluent-tailcheck --follow-inodes /var/log/td-agent/pos/secure
```

You can change the minimum ratio of collection of each target log file by specify `--ratio DECIMAL`.
By default (`0.5`), the command detects log files that have not been collected up to 50% of the filesize.

```
$ fluent-tailcheck --ratio 0.7 /var/log/td-agent/pos/secure
```

### Result example

#### No anomalies found

```
Check /path/to/pos.
Done duplication check for 2 PosEntries.
Done collection ratio check for 2 files.

All check completed. (Fluentd v1.15.0)
There is no anomalies.
```

This means:

* The command has checked `/path/to/pos`.
* The command has checked 2 pos entries for duplication check.
* The command has checked 2 files for collection ratio check.
* It is detected that the version of your Fluentd is v1.15.0.
* There is no anomalies.

#### Pos duplication found

```
Check /path/to/pos.
Done duplication check for 3 PosEntries.
Duplicated PosEntries are found. This is a known log missing issue that was fixed in Fluentd v1.16.3 (fluent-package v5.0.2, td-agent v4.5.2). If you are using any version older than these, updating Fluentd will resolve the issue.
Duplicated paths:
  /test/foo.log
Done collection ratio check for 0 files.

All check completed. (Fluentd v1.15.0)
Some anomalies are found. Please check the logs for details.
If you have any questions or issues, please report them to the following:
  Fluentd Q&A: https://github.com/fluent/fluentd/discussions/categories/q-a
  Fluentd Q&A (日本語用): https://github.com/fluent/fluentd/discussions/categories/q-a-japanese
  About this command (日本語可): https://github.com/clear-code/fluent-tail_checker/issues
```

In this case, some the pos entries are duplicated.
It is a known log missing issue that was fixed in Fluentd v1.16.3.

> * https://github.com/fluent/fluentd/issues/3614
>   * In case `follow_inodes false` (default setting), collection of a file may stop and continue to stop after log rotation.
>   * Fixed since Fluentd v1.16.3 (fluent-package v5.0.2, td-agent v4.5.2).

So, you should check whether there is any log missing, and consider updating Fluentd, especially, if you are using any version older than Fluentd v1.16.3 (fluent-package v5.0.2, td-agent v4.5.2).

#### Too low collection ratio file found

```
Check /path/to/pos.
Done duplication check for 2 PosEntries.
Done collection ratio check for 2 files.
Collection ratio of some files are too low. Collection of those files may not be keeping up. Or it may have stopped with some anomalies. This can be a known log missing issue of the follow_inodes feature that was fixed in Fluentd v1.16.2 (fluent-package v5.0.0, td-agent v4.5.1). If you are using any version older than these, updating Fluentd will resolve the issue.
Filepaths with too low collection ratio (threshold: 0.5):
  /test/bar.log (ratio: 0.2)
  /test/foo.log (ratio: 0.1)

All check completed. (Fluentd v1.15.0)
Some anomalies are found. Please check the logs for details.
If you have any questions or issues, please report them to the following:
  Fluentd Q&A: https://github.com/fluent/fluentd/discussions/categories/q-a
  Fluentd Q&A (日本語用): https://github.com/fluent/fluentd/discussions/categories/q-a-japanese
  About this command (日本語可): https://github.com/clear-code/fluent-tail_checker/issues
```

In this case, collection ratio of some target files are too low.
Collection of those files may have stopped or may not be keeping up.

> /test/bar.log (ratio: 0.2)

This means that only 20% of the data of the file is collected for the filesize.
If it is not keeping up temporarily, then it is no problem.
If this is always the case, or if collection has stopped completely, then log missing may occur.

Especially, if the `in_tail` uses [follow_inodes](https://docs.fluentd.org/input/tail#follow_inodes), there is a known log missing issue that was fixed in Fluentd v1.16.2.

> * https://github.com/fluent/fluentd/issues/4190
>   * In case `follow_inodes true`, collection of a file may stop and continue to stop after log rotation.
>   * Fixed since Fluentd v1.16.2 (fluent-package v5.0.0, td-agent v4.5.1).

Please consider updating Fluentd if you are using any version older than Fluentd v1.16.2 (td-agent v4.5.1).

## Feature

`fluent-tailcheck` performs the following checks on the specified pos file.

* duplication check
* collection ratio check

### Duplication check

`fluent-tailcheck` checks whether there is any dulication in the specified pos files.

The keys of watching pos entries in one pos file must be unique.

By default, the key is the path of the target log file.
When using [follow_inodes](https://docs.fluentd.org/input/tail#follow_inodes), the key is the inode.

If duplication occurs, it means some anomalies occurs in that `in_tail`.
Especially, the following log missing issue causes this duplication.

> * https://github.com/fluent/fluentd/issues/3614
>   * In case `follow_inodes false` (default setting), collection of a file may stop and continue to stop after log rotation.
>   * Fixed since Fluentd v1.16.3 (fluent-package v5.0.2, td-agent v4.5.2).

### Collection ratio check

`fluent-tailcheck` checks collection ratio of each watching pos entry.

By default, `fluent-tailcheck` detects log files that have not been collected up to 50% of the filesize.
You can change this threshold by `--ratio` option.
Please see `Usage` section for details.

If this it too low, collection of those files may not be keeping up.
Or it may have stopped with some anomalies.

Especially, if the `in_tail` uses [follow_inodes](https://docs.fluentd.org/input/tail#follow_inodes), there is a known log missing issue that was fixed in Fluentd v1.16.2.

> * https://github.com/fluent/fluentd/issues/4190
>   * In case `follow_inodes true`, collection of a file may stop and continue to stop after log rotation.
>   * Fixed since Fluentd v1.16.2 (fluent-package v5.0.0, td-agent v4.5.1).

#### Limitation

`fluent-tailcheck` checks the sizes of logfiles based on the paths recorded in the pos files (except already unwatched pos entries).

However, if using `--follow-inodes`, there is a restriction on which files can be checked.
If using `--follow-inodes`, it is possible that `fluent-tailcheck` can not check the already rotated logfiles even if they are recorded in the pos files and are not unwatched yet.
Since the path recorded in the pos file is not updated after log rotation, the current path and inode may differ.
`fluent-tailcheck` checks only log files whose path and inode in the pos file match.
At least, it can check the current log files.

If not using `--follow-inodes`, this limitation does not exist.

## Development

### Quick start

```console
$ bundle
$ bundle exec exe/fluent-tailcheck --version
$ bundle exec exe/fluent-tailcheck --help
$ bundle exec exe/fluent-tailcheck test/data/pos_duplicate_unwatched_path
```

### Unit test

```console
$ bundle exec rake test
```

### Package test

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

### Install and release

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/clear-code/fluent-tail_checker.

## Copyright

* Copyright 2025 Daijiro Fukuda
* License
  * Apache License, Version 2.0
