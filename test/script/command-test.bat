@echo on
call tailcheck --version || exit /b 1

@echo on
call tailcheck --help || exit /b 1

@echo on
call tailcheck test/data/pos_normal || exit /b 1

@echo on
call tailcheck test/data/pos_normal test/data/pos_duplicate_unwatched_path && exit /b 1

@echo on
call tailcheck --follow-inodes test/data/pos_follow_inodes_normal || exit /b 1
