#!/usr/bin/env bash
# Stop hook: one line at a pause in a substantial session, asking whether anything is
# worth a garden note. Writes systemMessage (display-only) rather than additionalContext,
# which the harness delivers to the model and which would keep the turn alive instead of
# ending it.
#
# Triggers on tokens, not prompt count. Prompt count is a bad proxy for how much prose was
# fired at the user: one session produced 96k output tokens across 9 prompts, another 36k
# across 13.

set -uo pipefail

payload=$(cat)

# Fired because an earlier Stop hook continued the turn; nudging again would loop.
[[ $(jq -r '.stop_hook_active // false' <<<"$payload") == true ]] && exit 0

fleeting="${GARDEN:-}/garden/05 - Fleeting"
[[ -n ${GARDEN:-} && -d $fleeting ]] || exit 0

transcript=$(jq -r '.transcript_path // empty' <<<"$payload")
[[ -r $transcript ]] || exit 0

session=$(jq -r '.session_id // empty' <<<"$payload")
[[ -n $session ]] || exit 0

# One nudge per session. A session is the unit the material belongs to.
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/claude-garden"
marker="$state_dir/nudged-$session"
[[ -e $marker ]] && exit 0

output_limit=${GARDEN_NUDGE_OUTPUT_TOKENS:-30000}
context_limit=${GARDEN_NUDGE_CONTEXT_TOKENS:-160000}

# usage repeats across every content-block entry of one request, so dedupe by requestId
# before summing or the total runs 2-3x high.
read -r produced occupancy <<<"$(jq -sr '
  [ .[] | select(.isSidechain != true and .message.usage != null) ]
  | (reduce .[] as $m ({}; .[$m.requestId // $m.uuid] = $m.message.usage)) as $by_request
  | ([ $by_request[].output_tokens // 0 ] | add // 0) as $produced
  | ([ .[] | .message.usage
       | (.input_tokens // 0)
         + (.cache_read_input_tokens // 0)
         + (.cache_creation_input_tokens // 0) ] | max // 0) as $occupancy
  | "\($produced) \($occupancy)"
' "$transcript" 2>/dev/null)"

[[ $produced =~ ^[0-9]+$ && $occupancy =~ ^[0-9]+$ ]] || exit 0

if (( occupancy >= context_limit )); then
  reason=compaction
elif (( produced >= output_limit )); then
  reason=volume
else
  exit 0
fi

# Anchored, or any transcript already invoking /garden suppresses the nudge.
jq -r '
  select(.type == "user" and .toolUseResult == null and (.isSidechain | not))
  | (.message.content // "")
  | (if type == "array" then (map(select(.type == "text") | .text // "") | join(" ")) else . end)
' "$transcript" 2>/dev/null | grep -qE '^[[:space:]]*/garden\b' && exit 0

title=$(jq -r 'select(.type == "ai-title") | .aiTitle // empty' "$transcript" 2>/dev/null | tail -1)

# The harness writes this title as prose in some sessions and as a kebab slug in others;
# the nudge is read by a human, so flatten the slug form back to words.
[[ $title == *-* && $title != *" "* ]] && title=${title//-/ }

subject=${title:-this session}
if [[ $reason == compaction ]]; then
  message="garden: \"$subject\" is close to compaction - the detail goes soon. run /garden"
else
  message="garden: \"$subject\" - worth a note? run /garden"
fi

mkdir -p "$state_dir" || exit 0
: >"$marker"

jq -nc --arg msg "$message" '{systemMessage: $msg}'
exit 0
