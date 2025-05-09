#!/bin/bash

set -exu

tailcheck --version
tailcheck --help
tailcheck test/data/pos_normal
(! tailcheck test/data/pos_normal test/data/pos_duplicate_unwatched_path)
tailcheck --follow_inodes test/data/pos_follow_inodes_normal
