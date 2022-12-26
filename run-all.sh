#!/usr/bin/env bash

# Colors

SUCCESS=$(tput setaf 2)
ERROR=$(tput setaf 1)
INFO=$(tput setaf 6)
RESET=$(tput sgr0)

echo "Killing old session..."
tmux kill-session -t "RustyController plugins" 2>/dev/null && echo "Killed existing tmux session"
tmux new-session -d -s "RustyController plugins" -c "$(pwd)"

BASE_DIR="$PWD"
find . -mindepth 1 -maxdepth 1 -type d -print0 | while IFS= read -r -d '' dir
do
  cd "$dir" || continue

  wkdir="$PWD"
  plugin="${PWD##*/}"

  if [ -f main.py ]; then
    if [ -f .ad-hoc ]; then
      echo "Ignoring $plugin because it's an ad-hoc plugin."
      continue
      cd "$BASE_DIR" || echo "Huh..? Failed to cd to base dir"
    fi

    echo "${INFO}Running $plugin$RESET"
    python_command="pip install -r requirements.txt; python main.py 2>&1 >> log.txt || echo \"Failed running $plugin\""
    tmux new-window -t "RustyController plugins" -n "$plugin" "cd $wkdir && $python_command" && echo "${SUCCESS}Success.$RESET" || echo "${ERROR}Failed!$RESET"
  else
    echo "Ignoring $plugin folder"
  fi

  cd "$BASE_DIR" || echo "Huh..? Failed to cd to base dir"
done

echo "${INFO}Finished RustyController plugins$RESET"