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

* [fluent-package](doc/installation.md#fluent-package)
* [td-agent v4](doc/installation.md#td-agent-v4)
* [td-agent v3](doc/installation.md#td-agent-v3)
* [Your Ruby environment](doc/installation.md#your-ruby-environment)

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
Please see [Collection ratio check](doc/feature.md#collection-ratio-check) for details.

```
$ fluent-tailcheck --ratio 0.7 /var/log/td-agent/pos/secure
```

### Permission

`fluent-tailcheck` requires read permission to the specified pos files and the target log files.

Please use `sudo` (on Linux-like) or a terminal with administrative privileges (on Windows).

```console
$ sudo fluent-tailcheck /var/log/td-agent/pos/secure
```

### Automation

It would be a good idea to run this command periodically to make sure `in_tail` works properly.

If any anomaly is detected, the command exits with an error (with a non-zero status).
You can use the exit code for the automation.

### Result examples

* [Result examples](doc/result-examples.md)

## Feature

* [Feature](doc/feature.md)

## Development

* [Development](doc/development.md)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/clear-code/fluent-tail_checker.

## Copyright

* Copyright 2025 Daijiro Fukuda
* License
  * Apache License, Version 2.0
