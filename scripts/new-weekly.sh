#!/usr/bin/env bash
# 今週（または指定日を含む週）の週次振り返りを templates/weekly.md から作成する
#   使い方: ./scripts/new-weekly.sh [YYYY-MM-DD]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$ROOT/templates/weekly.md"

if [ ! -f "$TEMPLATE" ]; then
  echo "テンプレートが見つかりません: $TEMPLATE" >&2
  exit 1
fi

if [ $# -ge 1 ]; then
  BASE="$1"
else
  BASE="$(date +%Y-%m-%d)"
fi

case "$BASE" in
  [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) ;;
  *) echo "日付は YYYY-MM-DD の形式で指定してください: $BASE" >&2; exit 1 ;;
esac

# GNU date か BSD date かを判定して、日付計算用の関数を定義する
if date -d "$BASE" '+%Y' >/dev/null 2>&1; then
  fmt()   { date -d "$BASE" "+$1"; }                       # BASE を書式化
  shift_d() { date -d "$BASE $1 days" "+%Y-%m-%d"; }        # BASE から n 日ずらす
elif date -j -f '%Y-%m-%d' "$BASE" '+%Y' >/dev/null 2>&1; then
  fmt()   { date -j -f '%Y-%m-%d' "$BASE" "+$1"; }
  shift_d() { date -j -v"$1"d -f '%Y-%m-%d' "$BASE" '+%Y-%m-%d'; }
else
  echo "この環境の date コマンドでは日付計算ができませんでした。" >&2
  echo "templates/weekly.md を手でコピーして weekly/ に置いてください。" >&2
  exit 1
fi

# ISO 8601 の週番号（月曜始まり）
ISO_YEAR="$(fmt '%G')"
ISO_WEEK="$(fmt '%V')"
WEEK="${ISO_YEAR}-W${ISO_WEEK}"

# ISO の曜日番号（月=1 … 日=7）から週の開始日・終了日を求める
DOW_NUM="$(fmt '%u')"
START="$(shift_d "-$((DOW_NUM - 1))")"
END="$(shift_d "+$((7 - DOW_NUM))")"

FILE="$ROOT/weekly/$WEEK.md"
mkdir -p "$ROOT/weekly"

if [ -e "$FILE" ]; then
  echo "すでに存在します: ${FILE#"$ROOT"/}"
else
  sed -e "s/{{WEEK}}/$WEEK/g" \
      -e "s/{{START}}/$START/g" \
      -e "s/{{END}}/$END/g" \
      "$TEMPLATE" > "$FILE"
  echo "作成しました: ${FILE#"$ROOT"/}  ($START 〜 $END)"
fi

if [ -n "${EDITOR:-}" ]; then
  "$EDITOR" "$FILE"
fi
