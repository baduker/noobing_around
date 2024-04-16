# Star Gazer

Star Gazer is a bash script that fetches and stores the data of the repositories
starred by a GitHub user. It then selects a random repository from the stored 
data.

## Usage

To run the script, use the following command:

```bash
./star_gazer.sh
```

## How it works
- The script first checks if the JSON file containing the starred repositories 
data already exists. If it does, it proceeds to the selection step. If it 
doesn't, it collects the data first.  
- The data collection step involves sending requests to the GitHub API to fetch 
the data of the repositories starred by the user. The data is then stored in a 
JSON file.  
- The selection step involves picking a random repository from the stored data 
and printing its details.
