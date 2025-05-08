tailcheck --version || exit /b 1
tailcheck --help || exit /b 1
tailcheck test/data/pos_normal || exit /b 1
tailcheck test/data/pos_normal test/data/pos_duplicate_unwatched_path  && exit /b 1
tailcheck --follow_inodes test/data/pos_follow_inodes_normal || exit /b 1
