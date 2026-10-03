#!/usr/bin/env bash
# 登録済みの声で TTS API から音声を生成する
# 使い方: ./generate_speech.sh --prompt 'おはよう' --voice tobari1 [--path out.wav]
set -euo pipefail

API_BASE="http://localhost:8088/v1"
MODEL="irodori-tts"
PROMPT=""
VOICE_ID=""
OUT=""

usage() {
  echo "使い方: $0 --prompt <テキスト> --voice <voice_id> [--path <出力wav>]" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prompt) PROMPT="${2:?--prompt に値が必要です}"; shift 2 ;;
    --voice)  VOICE_ID="${2:?--voice に値が必要です}"; shift 2 ;;
    --path)   OUT="${2:?--path に値が必要です}"; shift 2 ;;
    *) usage ;;
  esac
done

[[ -n "$PROMPT" && -n "$VOICE_ID" ]] || usage

# 未指定ならカレントディレクトリに日時付きで保存
[[ -n "$OUT" ]] || OUT="./speech_$(date +%Y%m%d_%H%M%S).wav"

payload=$(jq -n --arg model "$MODEL" --arg input "$PROMPT" --arg voice "$VOICE_ID" \
  '{model: $model, input: $input, voice: $voice, response_format: "wav"}')

curl -sS -f -X POST "${API_BASE}/audio/speech" \
  -H "Content-Type: application/json" \
  -d "$payload" \
  -o "$OUT"

echo "保存しました: $OUT"
