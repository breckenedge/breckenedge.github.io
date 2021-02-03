---
layout: post
title: "My Github Actions Docker-and-VPS-Based CI/CD Pipeline"
date: 2021-01-29 16:06:21 -0600
categories: ops
---

I dislike ops, but oddly I enjoy running my own Linux server. Last year I got interested in deploying a container-based application using an automated Github CI/CD workflow to a $5/mo Linode VPS server.

This workflow builds the project for every branch and PR. The build is based on a `docker-compose.test.yml` file with an `sut` task.

If the tests pass and it's on the `main` branch, this workflow compiles a production-ready image (this could use further optimization), pushes it to the Github Docker Repo, and redeploys it via SSH.

My biggest issues with this process is that Github Actions takes around 12 minutes to complete the workflow for a production deploy.

```yml
# .github/workflows/cicd.yml

name: CICD

# Kick off this pipeline on either a pull request or push to a branch
on:
  push:
  pull_request:

jobs:
  # Run this application's tests or simply build the image.
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: |
          if [ -f docker-compose.test.yml ]; then
            docker-compose --file docker-compose.test.yml build
            docker-compose --file docker-compose.test.yml run sut
          else
            docker build . --file Dockerfile
          fi

  # Build a production image and push to GitHub Packages.
  push:
    # Ensure test job passes before pushing image.
    needs: test

    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v2
      - name: Build image
        run: docker build . --file Dockerfile --tag docker.pkg.github.com/my-profile/my-repo/my-image:latest
      - name: Log into registry
        run: echo "${{ secrets.GITHUB_TOKEN }}" | docker login docker.pkg.github.com -u ${{ github.actor }} --password-stdin
      - name: Push image
        run: docker push docker.pkg.github.com/my-profile/my-repo/my-image:latest

  # Run the deploy.sh script on a server
  deploy:
    needs: push
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v2
      - name: Deploy
        run: |
          echo "${{secrets.HOST_SSH_KEY}}" > ssh_key
          chmod 700 ssh_key
          ssh -o StrictHostKeyChecking=no -i ssh_key ${{ secrets.HOST_USERNAME }}@${{ secrets.HOST_HOSTNAME }} "sh -s" < deploy.sh
          rm ssh_key
```

In the final step of the CICD pipeline above, Github SSHs onto my Linux server and redeploys the application using a custom `deploy.sh` script. This is a generic example of what that script does. Things could definitely be easier with a `docker-compose.prod.yml` file, but Compose can also be too helpful by abstracting so much complexity.

```sh
#!/bin/sh

# This script runs on the docker server to deploy the application. It can be kicked off locally via:
#
# ```
# ssh my-server < deploy.sh
# ```

set -e

echo 'Pulling latest'
docker pull docker.pkg.github.com/my-profile/my-repo/my-image:latest

echo 'Stopping the container'
docker container stop my-app || true

until [ "`docker ps --filter 'name=my-app' --format '{{.ID}}'`" == "" ]; do
	sleep 0.1;
done;

echo 'Starting the container'
docker run --rm --name my-app -d -p 3000:3000 docker.pkg.github.com/my-profile/my-repo/my-image:latest startup.sh
```
