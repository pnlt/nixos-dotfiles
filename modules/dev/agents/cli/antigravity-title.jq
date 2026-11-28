((.workspace.current_dir // .cwd // "") | split("/") | last // "") as $dir
| (if .tool_confirmation_pending == true then "permission"
   elif .agent_state == "working" or .agent_state == "tool_use" then "working"
   elif .agent_state == "reviewing" then "reviewing"
   elif .agent_state == "error" then "error"
   elif .agent_state == "idle" then "ready"
   else (.agent_state // "") end) as $state
| [
    "agy",
    ($state | select(. != "")),
    ((if (.conversation_title // "") != "" then .conversation_title else $dir end) | select(. != ""))
  ]
| join(" · ")
| gsub("[[:cntrl:]]"; "")
