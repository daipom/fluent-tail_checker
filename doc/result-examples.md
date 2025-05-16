# Result examples

## No anomalies found

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

## Pos duplication found

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

## Too low collection ratio file found

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
