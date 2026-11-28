def esc($code; $text): "\u001b[\($code)m\($text)\u001b[0m";
def clean: gsub("[[:cntrl:]]"; "");
def vislen: gsub("\u001b\\[[0-9;]*m"; "") | length;
def sep: esc("90"; "│");

def bar($pct):
  (($pct / 10) | round | if . < 0 then 0 elif . > 10 then 10 else . end) as $filled
  | ("█" * $filled) + ("░" * (10 - $filled));

def fmt_reset:
  if (. == null) or (. <= 0) then ""
  elif . >= 86400 then " \(. / 86400 | floor)d\((. % 86400) / 3600 | floor)h"
  elif . >= 3600 then " \(. / 3600 | floor)h\((. % 3600) / 60 | floor)m"
  else " \(. / 60 | ceil)m" end;

def quota($bucket; $label; $color):
  .quota[$bucket]
  | select(.disabled != true and (.remaining_fraction | type) == "number")
  # Unavailable buckets can report 100% with a zero Unix timestamp.
  | select((.reset_time // "") | startswith("1970-01-01") | not)
  | (.remaining_fraction * 100 | round) as $pct
  | (if $pct < 100 then (.reset_in_seconds | fmt_reset) else "" end) as $rst
  | esc($color; "\($label) \($pct)%") + (if $rst != "" then esc("90"; $rst) else "" end);

def align($left; $right; $width):
  if $left == "" then $right
  elif $right == "" then $left
  elif ($width // 0) <= 0 then "\($left)  \($right)"
  else
    ($width - ($left | vislen) - ($right | vislen)) as $gap
    | if $gap >= 2 then "\($left)\(" " * $gap)\($right)"
      else "\($left)  \($right)" end
  end;

(.terminal_width // 0) as $width
| ($width > 0 and $width < 85) as $narrow
| (.model.display_name // .model.id // "" | clean) as $raw_model
| (if $narrow then ($raw_model | sub("^Gemini [0-9.]+ "; "")) else $raw_model end) as $model
| ([$raw_model, (.model.id // "")] | join(" ")) as $model_key
| (if $model_key | test("gemini|hydrogen|neon|carbon|argon|orchestrator"; "i") then "gemini"
   elif $model_key | test("claude|gpt"; "i") then "3p"
   else null end) as $group
| (if .tool_confirmation_pending == true then esc("93"; "◈")
   elif .agent_state == "working" or .agent_state == "tool_use" then esc("96"; "◐")
   elif .agent_state == "reviewing" then esc("93"; "◈")
   elif .agent_state == "error" then esc("91"; "✖")
   elif .agent_state != null then esc("92"; "●")
   else "" end) as $dot
| ((.workspace.current_dir // .cwd // "") | split("/") | last // "" | clean) as $dir
| (($branch // "") | clean) as $br
| (($ins // "") | clean) as $added
| (($del // "") | clean) as $removed
| ([
    (if $dot != "" and $model != "" then "\($dot) \(esc("1;97"; $model))"
     elif $model != "" then esc("1;97"; $model)
     else empty end),
    (.context_window
     | select(.current_usage != null and (.context_window_size // 0) > 0)
     | select((.used_percentage | type) == "number")
     | (.used_percentage | round) as $pct
     | (if $pct >= 80 then "91" elif $pct >= 60 then "93" else "94" end) as $c
     | if $narrow then esc($c; "\($pct)%") else esc($c; "\(bar($pct)) \($pct)%") end)
  ] | join(" \(sep) ")) as $l1_left
| ([
    (if $br != "" then esc("93"; $br)
     elif $dir != "" then esc("90"; $dir)
     else empty end),
    ([
      (if ($added != "" and $added != "0") then esc("92"; "+\($added)") else empty end),
      (if ($removed != "" and $removed != "0") then esc("91"; "-\($removed)") else empty end)
    ] | join(" ") | select(. != ""))
  ] | join(" \(sep) ")) as $l1_right
| ([
    (select($group != null) | quota($group + "-5h"; "5h"; "96")),
    (select($group != null) | quota($group + "-weekly"; "week"; "95"))
  ] | join(" \(sep) ")) as $l2_left
| (((.subagents // []) | map(select(.status == "running")) | length)) as $subs
| (.task_count // 0) as $tasks
| ([
    (if .cycle_mode == "auto" then esc("92"; "auto")
     elif .cycle_mode == "plan" then esc("95"; "plan")
     elif .cycle_mode == "accept-edits" then esc("93"; "accept-edits")
     else empty end),
    (select(.sandbox.enabled == true) | esc("36"; "sandbox")),
    (if $subs > 0 then esc("96"; "\($subs) sub") else empty end),
    (if $tasks > 0 then esc("96"; "\($tasks) bg") else empty end)
  ] | join(" \(esc("90"; "·")) ")) as $l2_right
| [
    (align($l1_left; $l1_right; $width) | select(. != "")),
    (align($l2_left; $l2_right; $width) | select(. != ""))
  ]
| join("\n")
