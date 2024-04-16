#!/usr/bin/env bash

set -e -o pipefail

readonly USER="baduker"
readonly STARRED="${USER}_stars.json"
readonly API_URL="https://api.github.com/users/$USER/starred?per_page=100"

# Get the last page number from the "Link" header
function get_last_page_number() {
  local url
  local status
  local total_pages

  while IFS=':' read -r key value; do
    # trim whitespace in "value"
    value=${value##+([[:space:]])}; value=${value%%+([[:space:]])}

    case "$key" in
        link) url="$value"
                ;;
        HTTP*) read -r _ status _ <<< "$key{$value:+:$value}"
                ;;
     esac
  done < <(curl -sI "$API_URL")

  total_pages=$(
    echo "$url" \
      | cut -d ' ' -f 3 \
      | sed -n 's/.*page=\([0-9]*\).*/\1/p'
      )
  echo "$total_pages"
}

# Collect user's starred repos data
function collect_user_data() {
  local total_pages
  total_pages=$(get_last_page_number)
  echo "Collecting starred repos data for ${USER}..."

  # Adapt the script to use it with docker volumes
  mkdir ./data && cd ./data
  for page_number in $(seq 1 "$total_pages"); do
      echo "Fetching page $page_number/$total_pages..."
      curl -s "$API_URL"\&page="$page_number" | \
        jq -r '
        . | .[]
          |
            {
              repo_name: .name,
              data: {
                  url: .html_url,
                  description: .description,
                  language: .language,
                  full_url: .html_url,
                  stars: .stargazers_count,
                  name: .name,
                  homepage: .homepage,
                  ssh_url: .ssh_url,
                }
            }'  \
        >> "${0%.sh}_$page_number.json"
  done

  # We need to merge all the JSON files into one and remove the individual files
  # We also need to persist the data for docker container restarts
  jq --slurp 'map(.)' ./*.json > "$STARRED"

  # Remove the individual JSON files
  rm "${0%.sh}"_*.json

  echo "Data collection completed!"

  # Let's see where we are and return to the script directory
  pwd
  cd "$SCRIPT_DIR"
}

# Select a random repo from the user's starred repos from the JSON file
function selector() {
  local selected
  selected=$(
    jq -r --arg repo \
    $(shuf -n1 -e $(jq -r '.[].repo_name' < "./data/$STARRED")) \
    '.[] |
    {
      statusCode: 200,
      random_repo: select(.repo_name == $repo)
    }' < "./data/$STARRED")
  echo "$selected"
}

# Main function
function main() {

  # Enable extended pattern matching
  shopt -s extglob
  local total_pages

  # Check if the JSON file is already present
  if [ -f "./data/$STARRED" ]; then
    echo "Found existing starred repos data for user: $USER."
    selector
  else
    collect_user_data
    selector
  fi
}

main
