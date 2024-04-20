# Star Gazer

Star Gazer is a bash script that fetches and stores the data of the repositories
starred by a GitHub user. It then selects a random repository from the stored 
data. That's it (for now). :-]

This is a low effort script I wrote to play around with the GitHub API, bash,
docker, and some GitHub actions.

It's rather limited in functionality. I might add more features later.

## How it works
- The script first checks if the JSON file containing the starred repositories 
data already exists. If it does, it proceeds to the selection step. If it 
doesn't, it collects the data first.  
- The data collection step involves sending requests to the GitHub API to fetch 
the data of the repositories starred by the user. The data is then stored in a 
JSON file.  
- The selection step involves picking a random repository from the stored data 
and printing its details.

The output is in a JSON format and includes the following details:

```json
{
  "statusCode": 200,
  "random_repo": {
    "repo_name": "swc",
    "data": {
      "url": "https://github.com/swc-project/swc",
      "description": "Rust-based platform for the Web",
      "language": "Rust",
      "full_url": "https://github.com/swc-project/swc",
      "stars": 29940,
      "name": "swc",
      "homepage": "https://swc.rs",
      "ssh_url": "git@github.com:swc-project/swc.git"
    }
  }
}
```
The reason it's a JSON and not a simple string is because I used this script
in an AWS Lambda function, and it was easier to parse the output.

I'll add a flag to output the data in a simple string format later.

```
## Usage

To run the script, use the following command:

```bash
./star_gazer.sh
```

Or use Docker with a volume mount.

First, build the Docker image:

```bash
docker build -t star_gazer .
```

Then run the Docker container with `data` as the volume mount point:

```bash
docker run -it \
  --name star-gazer \
  --mount source=data,target=/data \
  star-gazer -u <username>
```

To restart it and reuse the volume mount point:

```bash
docker start -i star-gazer
```
