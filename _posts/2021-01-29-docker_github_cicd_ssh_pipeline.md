---
layout: post
title: "My Github Actions Docker-and-VPS-Based CI/CD Pipeline"
date: 2021-01-29 16:06:21 -0600
categories: ops
---

Last updated August 18, 2021.

Oddly, I still enjoy running my own Linux server. A few years ago, I became interested in deploying a container-based application using an automated Github-Actions-based CI/CD workflow to a $5/mo Linode VPS server. These workflows run the test suite against PRs and build and deploy docker images via SSH.

I recently split up this workflow into separate files and stopped using the Docker-based `docker-compose.test.yml`/`sut` workflow. I've replaced it with the native Github Ruby pipeline, which is substantially faster than building a Docker image just to run tests.

Here's my test workflow pipeline that runs the Ruby-based test suite on every new PR.

```yml
# in .github/workflows/test.yml
name: Tests

on: [pull_request]

jobs:
  # Run tests.
  # See also https://docs.docker.com/docker-hub/builds/automated-testing/
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
      - name: Install ruby dependencies
        run: bundle install
      - name: Install javascript dependencies
        run: yarn install
      - name: Run tests
        run: bundle exec rake
```

Once PRs are merged to `main`, a follow-up `Deploy` workflow builds a Docker image and deploys it to my Linode server via SSH:

```yml
# in .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches:
      - main

jobs:
  # Push image to GitHub Packages.
  # See also https://docs.docker.com/docker-hub/builds/
  build:
    runs-on: ubuntu-latest
    if: github.event_name == 'push'

    steps:
      - uses: actions/checkout@v2

      - name: Build image
        run: docker build . --file Dockerfile --tag docker.pkg.github.com/my-profile/my-repo/my-image:latest

      - name: Log into registry
        run: echo "${{ secrets.GITHUB_TOKEN }}" | docker login docker.pkg.github.com -u ${{ github.actor }} --password-stdin

      - name: Push image
        run: docker push docker.pkg.github.com/my-profile/my-repo/my-image:latest

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    steps:
      - uses: actions/checkout@v2
      - name: Deploy
        run: |
          echo "${{secrets.HOST_SSH_KEY}}" > ssh_key
          chmod 700 ssh_key
          ssh -o StrictHostKeyChecking=no -i ssh_key ${{ secrets.HOST_USERNAME }}@${{ secrets.HOST_HOSTNAME }} "sh -s" < deploy.sh
          rm ssh_key
```

The above Deploy workflow references a custom `deploy.sh` script. Here's a generic example of what that script does:

```sh
#!/bin/sh

# This script runs on the docker server to deploy the application. It can be kicked off locally via:
#
# ```
# ssh my-server < deploy.sh
# ```

set -e

echo 'Removing dangling images'
yes | docker image prune

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
