#!/usr/bin/env bash
set -eu

strip_ansi() {
  sed -E 's/\x1b\[[0-9;]*m//g'
}

render() {
  local branch="${1:-}" ins="${2:-}" del="${3:-}"
  jq -r --arg branch "$branch" --arg ins "$ins" --arg del "$del" \
    -f "$(dirname "$0")/antigravity-statusline.jq"
}

out=$(render "main" "12" "3" <<'JSON' | strip_ansi
{"cwd":"/tmp/repo","agent_state":"idle","model":{"display_name":"Gemini 4 Neon (Medium)","id":"gemini-4-neon-medium"},"context_window":{"context_window_size":524288,"current_usage":{},"used_percentage":38.2},"quota":{"gemini-5h":{"remaining_fraction":0.94,"reset_in_seconds":11520},"gemini-weekly":{"remaining_fraction":0.88,"reset_in_seconds":345600},"3p-5h":{"remaining_fraction":1,"reset_time":"1970-01-01T00:00:00Z"}},"cycle_mode":"auto","sandbox":{"enabled":true}}
JSON
)
[[ "$out" == $'● Gemini 4 Neon (Medium) │ ████░░░░░░ 38%  main │ +12 -3\n5h 94% 3h12m │ week 88% 4d0h  auto · sandbox' ]]

narrow=$(render "main" "" "" <<'JSON' | strip_ansi
{"terminal_width":72,"model":{"display_name":"Gemini 4 Neon (Medium)","id":"gemini-4-neon-medium"},"context_window":{"context_window_size":524288,"current_usage":{},"used_percentage":65},"quota":{"gemini-weekly":{"remaining_fraction":0.91}}}
JSON
)
[[ "$narrow" == *"Neon (Medium) │ 65%"*"main"* ]]
[[ "$narrow" != *"█"* ]]

[[ "$(render <<< '{}')" == "" ]]

render_title() {
  jq -r -f "$(dirname "$0")/antigravity-title.jq"
}

[[ "$(render_title <<< '{"cwd":"/tmp/repo","agent_state":"working"}')" == "agy · working · repo" ]]
[[ "$(render_title <<< '{"cwd":"/tmp/repo","agent_state":"idle","conversation_title":"Audit config"}')" == "agy · ready · Audit config" ]]
[[ "$(render_title <<< '{"cwd":"/tmp/repo","agent_state":"tool_use","tool_confirmation_pending":true}')" == "agy · permission · repo" ]]
[[ "$(render_title <<< '{"cwd":"/","agent_state":"error"}')" == "agy · error" ]]
[[ "$(render_title <<< '{}')" == "agy" ]]
