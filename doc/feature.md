# Feature

`fluent-tailcheck` performs the following checks on the specified pos file.

* [Duplication check](#duplication-check)
* [Collection ratio check](#collection-ratio-check)

## Duplication check

`fluent-tailcheck` checks whether there is any dulication in the specified pos files.

The keys of watching pos entries in one pos file must be unique.

By default, the key is the path of the target log file.
When using [follow_inodes](https://docs.fluentd.org/input/tail#follow_inodes), the key is the inode.

If duplication occurs, it means some anomalies occurs in that `in_tail`.
Especially, the following log missing issue causes this duplication.

> * https://github.com/fluent/fluentd/issues/3614
>   * In case `follow_inodes false` (default setting), collection of a file may stop and continue to stop after log rotation.
>   * Fixed since Fluentd v1.16.3 (fluent-package v5.0.2, td-agent v4.5.2).

## Collection ratio check

`fluent-tailcheck` checks collection ratio of each watching pos entry.

By default, `fluent-tailcheck` detects log files that have not been collected up to 50% of the filesize.
You can change this threshold by `--ratio` option.

If this it too low, collection of those files may not be keeping up.
Or it may have stopped with some anomalies.

Especially, if the `in_tail` uses [follow_inodes](https://docs.fluentd.org/input/tail#follow_inodes), there is a known log missing issue that was fixed in Fluentd v1.16.2.

> * https://github.com/fluent/fluentd/issues/4190
>   * In case `follow_inodes true`, collection of a file may stop and continue to stop after log rotation.
>   * Fixed since Fluentd v1.16.2 (fluent-package v5.0.0, td-agent v4.5.1).

### Limitation

`fluent-tailcheck` checks the sizes of logfiles based on the paths recorded in the pos files (except already unwatched pos entries).

However, if using `--follow-inodes`, there is a restriction on which files can be checked.
If using `--follow-inodes`, it is possible that `fluent-tailcheck` can not check the already rotated logfiles even if they are recorded in the pos files and are not unwatched yet.
Since the path recorded in the pos file is not updated after log rotation, the current path and inode may differ.
`fluent-tailcheck` checks only log files whose path and inode in the pos file match.
At least, it can check the current log files.

If not using `--follow-inodes`, this limitation does not exist.
