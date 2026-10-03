#!/usr/bin/env bash
# リファレンス音声を TTS API に登録する
# 使い方: ./register_voice.sh --id tobari --path ./hoge.wav
set -euo pipefail

API_BASE="http://localhost:8088/v1"
VOICE_ID=""
FILE=""

usage() {
  echo "使い方: $0 --id <voice_id> --path <音声ファイル>" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --id)   VOICE_ID="${2:?--id に値が必要です}"; shift 2 ;;
    --path) FILE="${2:?--path に値が必要です}"; shift 2 ;;
    *) usage ;;
  esac
done

[[ -n "$VOICE_ID" && -n "$FILE" ]] || usage

if [[ ! -f "$FILE" ]]; then
  echo "ファイルが見つかりません: $FILE" >&2
  exit 1
fi

curl -sS -f -X POST "${API_BASE}/audio/voices" \
  -F "file=@${FILE}" \
  -F "voice_id=${VOICE_ID}"
echo
