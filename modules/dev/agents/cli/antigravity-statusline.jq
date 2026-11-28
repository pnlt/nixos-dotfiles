def quota($bucket; $label):
  .quota[$bucket]
  | select(.disabled != true and (.remaining_fraction | type) == "number")
  # Unavailable buckets can report 100% with a zero Unix timestamp.
  | select((.reset_time // "") | startswith("1970-01-01") | not)
  | "\($label) \(.remaining_fraction * 100 | round)% left";

(.model.display_name // .model.id // "") as $model
| ([$model, (.model.id // "")] | join(" ")) as $model_key
| (if $model_key | test("gemini|hydrogen|neon|carbon|argon|orchestrator"; "i") then "gemini"
   elif $model_key | test("claude|gpt"; "i") then "3p"
   else null end) as $group
| [
    ((.workspace.current_dir // .cwd // "") | split("/") | last | strings | select(. != "")),
    ($model | select(. != "")),
    (.context_window
     | select(.current_usage != null and (.context_window_size // 0) > 0)
     | select((.used_percentage | type) == "number")
     | "ctx \(.used_percentage | round)% used"),
    (select($group != null) | quota($group + "-5h"; "5h")),
    (select($group != null) | quota($group + "-weekly"; "week")),
    (select(.sandbox.enabled == true) | "sandbox")
  ]
| join(" · ")
| gsub("[[:cntrl:]]"; "")
