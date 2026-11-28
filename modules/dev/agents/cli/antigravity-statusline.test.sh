#!/usr/bin/env bash
set -eu

render() {
  jq -r -f "$(dirname "$0")/antigravity-statusline.jq"
}

[[ "$(render <<'JSON'
{"cwd":"/tmp/repo","model":{"display_name":"Hydrogen","id":"gemini-4-hydrogen"},"context_window":{"context_window_size":1048576,"current_usage":{},"used_percentage":12.1},"quota":{"gemini-weekly":{"remaining_fraction":0.91},"3p-5h":{"remaining_fraction":1,"reset_time":"1970-01-01T00:00:00Z"}}}
JSON
)" == "repo · Hydrogen · ctx 12% used · week 91% left" ]]

[[ "$(render <<'JSON'
{"model":{"display_name":"Claude Sonnet"},"quota":{"3p-5h":{"remaining_fraction":0},"3p-weekly":{"remaining_fraction":0.75},"gemini-weekly":{"remaining_fraction":0.9}},"sandbox":{"enabled":true}}
JSON
)" == "Claude Sonnet · 5h 0% left · week 75% left · sandbox" ]]

[[ "$(render <<< '{}')" == "" ]]
