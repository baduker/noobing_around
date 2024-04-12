#!/usr/bin/env bash

set -e -o pipefail

readonly USER="baduker"
readonly STARRED="${USER}_stars.json"
readonly API_URL="https://api.github.com/users/$USER/starred?per_page=100"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Get the last page number from the "Link" header
function get_last_page_number() {
  local link
  local status
  local total_pages

  while IFS=':' read -r key value; do
    # trim whitespace in "value"
    value=${value##+([[:space:]])}; value=${value%%+([[:space:]])}

    case "$key" in
        link) link="$value"
                ;;
        HTTP*) read -r _ status _ <<< "$key{$value:+:$value}"
                ;;
     esac
  done < <(curl -sI "$API_URL")
echo "API response status: $status!"

total_pages=$(
  echo "$link" \
    | cut -d ' ' -f 3 \
    | sed -n 's/.*page=\([0-9]*\).*/\1/p'
    )
echo "Found $total_pages pages of starred repos for user: $USER."
}

# Collect user's starred repos data
function collect_user_data() {
  local page_number
  echo "Collecting starred repos data..."
  for page_number in $(seq 1 "$1"); do
      echo "Fetching page $page_number/$1..."
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
  jq --slurp 'map(.)' "$SCRIPT_DIR"/*.json > "$STARRED"
  rm "$SCRIPT_DIR"/"${0%.sh}"_*.json

   echo "Data collection completed!"
}

# Select a random repo from the user's starred repos from the JSON file
function selector() {
  local selected
  selected=$(jq -r --arg repo $(shuf -n1 -e $(jq -r '.[].repo_name' < "$STARRED")) \
  '.[] |
  {
    statusCode: 200,
    random_repo: select(.repo_name == $repo)
  }' < "$STARRED")
  echo "$selected"
}

# Main function
function main() {
  # Enable extended pattern matching
  shopt -s extglob
  local total_pages

  # Check if the JSON file is already present
  if [ -f "$STARRED" ]; then
    echo "Found existing starred repos data for user: $USER."
    selector
    exit 0
  fi

  total_pages=$(get_last_page_number)
  collect_user_data "$total_pages"

  selector

}

main
