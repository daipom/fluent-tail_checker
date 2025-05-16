#!/bin/bash

set -exu

fluent-tailcheck --version
fluent-tailcheck --help
fluent-tailcheck test/data/pos_normal
(! fluent-tailcheck test/data/pos_normal test/data/pos_duplicate_unwatched_path)
fluent-tailcheck --follow-inodes test/data/pos_follow_inodes_normal
