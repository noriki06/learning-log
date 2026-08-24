#!/usr/bin/env bash
# 今日（または指定日）の学習ログを templates/daily.md から作成する
#   使い方: ./scripts/new-log.sh [YYYY-MM-DD]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$ROOT/templates/daily.md"

if [ ! -f "$TEMPLATE" ]; then
  echo "テンプレートが見つかりません: $TEMPLATE" >&2
  exit 1
fi

if [ $# -ge 1 ]; then
  DATE="$1"
else
  DATE="$(date +%Y-%m-%d)"
fi

# YYYY-MM-DD の形式チェック
case "$DATE" in
  [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) ;;
  *) echo "日付は YYYY-MM-DD の形式で指定してください: $DATE" >&2; exit 1 ;;
esac

YEAR="${DATE%%-*}"
MONTH="$(echo "$DATE" | cut -d- -f2)"

# 曜日を英語で取得（GNU date / BSD date の両対応）
if DOW_EN="$(date -d "$DATE" '+%a' 2>/dev/null)"; then
  :
elif DOW_EN="$(date -j -f '%Y-%m-%d' "$DATE" '+%a' 2>/dev/null)"; then
  :
else
  DOW_EN=""
fi

# 日本語の曜日に変換
case "$DOW_EN" in
  Mon) DOW="月" ;;
  Tue) DOW="火" ;;
  Wed) DOW="水" ;;
  Thu) DOW="木" ;;
  Fri) DOW="金" ;;
  Sat) DOW="土" ;;
  Sun) DOW="日" ;;
  *)   DOW="?" ;;
esac

DIR="$ROOT/logs/$YEAR/$MONTH"
FILE="$DIR/$DATE.md"

mkdir -p "$DIR"

if [ -e "$FILE" ]; then
  echo "すでに存在します: ${FILE#"$ROOT"/}"
else
  sed -e "s/{{DATE}}/$DATE/g" -e "s/{{DOW}}/$DOW/g" "$TEMPLATE" > "$FILE"
  echo "作成しました: ${FILE#"$ROOT"/}"
fi

# EDITOR が設定されていれば開く
if [ -n "${EDITOR:-}" ]; then
  "$EDITOR" "$FILE"
fi
