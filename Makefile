.PHONY: log weekly help

help:
	@echo "make log     - 今日の学習ログを作る"
	@echo "make weekly  - 今週の振り返りを作る"

log:
	@./scripts/new-log.sh

weekly:
	@./scripts/new-weekly.sh
