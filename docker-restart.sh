#!/usr/bin/env bash

cat << "EOF"
  ________            ______                    ________            _____              _____ 
  ___  __ \______________  /______________      ___  __ \_____________  /______ _________  /_
  __  / / /  __ \  ___/_  //_/  _ \_  ___/________  /_/ /  _ \_  ___/  __/  __ `/_  ___/  __/
  _  /_/ // /_/ / /__ _  ,<  /  __/  /   _/_____/  _, _//  __/(__  )/ /_ / /_/ /_  /   / /_  
  /_____/ \____/\___/ /_/|_| \___//_/           /_/ |_| \___//____/ \__/ \__,_/ /_/    \__/  

  ===========================================================================================

EOF

# Loop through each directory
for dir in $(ls -d */); do
  printf "Entering directory: $dir\n"

  # Check if directory exists
  if [ -d "$dir" ]; then
    cd "$dir" || continue

    if [ -f ".disabled" ] || [ -f ".ignore" ]; then
      printf "Stopping and skipping...\n"
      docker compose down
      cd - > /dev/null

      printf "\n"
      echo "-------------------------------------"
      printf "\n"

      continue
    fi

    printf "Restarting services...\n\n"
    docker compose down && docker compose up -d

    # Go back to previous directory
    cd - > /dev/null
  else
    printf "ERROR: Directory not found: $dir\n"
  fi

  printf "\n"
  echo "-------------------------------------"
  printf "\n"
done

echo "All done!"
