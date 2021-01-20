---
layout: post
title:  "Linux, Docker and Rails with a Github Actions-based CI/CD Pipeline"
date:   2021-01-19 21:19:14 -0600
categories: programming operations devops
---

In this post, I'd like to share the approach I took to automate deployment of a Docker-based Ruby on Rails application to an Alpine Linux server using a Github Actions-based CI/CD pipeline. This approach is not perfect. It's not even as good as a well-written Capistrano or Mina based deployment, but it was an interesting learning experience and I'd do it again. It was one of those things that I'd been wanting to play around with for quite some time but hadn't had the chance until the right opportunity came along.

# Background

Last spring, my wife and I purchased our first home. Buying a home came a few hundred TODOs that either of us needed to address. Being a programmer and having used tons of other people's todo apps, I knew immediately that I didn't want to use anyone else's app to track these TODOs. Custom software to the rescue!

(In all seriousness, I do try to use off-the-shelf software whenever I can, but for fucks sake I should be allowed to write a TODO app every once in a while.)

# The Ruby-on-Rails application

This Rails application starts like any other. To simplify deployment, I did use the Rails default `sqlite3` database. Even in 2021, Rails still has perfectly good defaults, and I'm using webpacker with support for typescript and React.

```sh
rails new
```

# The Dockerfile

I've played around with Docker for about a year before settling on this `Dockerfile` for my Rails application. What I like about this Dockerfile is that it's both production ready and I can use it if I need to drop down into the console, which, to be honest, I still end up doing pretty often because the Rails console is just that good. By the way, I learned a lot of this from reading the "Rails on Docker" book (recommended by Shawn Scott) and I suggest that you pick up a copy to learn more. This Dockerfile works with both webpacker and the legacy Rails asset pipeline.

```Dockerfile
FROM ruby:2.7.1-alpine

ENV RUBYOPT -W:no-deprecated
ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true
ENV BUILD_PACKAGES yarn nodejs npm build-base sqlite-dev tzdata
ENV BUNDLE_WITHOUT development:test
ENV BUNDLE_JOBS 5

RUN apk update --quiet && \
    apk upgrade --quiet && \
    apk add $BUILD_PACKAGES --quiet && \
    rm -rf /var/cache/apk

WORKDIR /code
COPY . /code/

RUN bin/bundle install --quiet
RUN SECRET_KEY_BASE=`bin/rails secret` bin/rails assets:precompile

EXPOSE 3000

CMD ["bin/rails", "server"]
```

# The Alpine Linux Server

Provisioning an Apline Linux server to run Docker images is easy. Step 1: buy a $5/mo virtual server from Linode or Digital Ocean. Step 2: Install Docker. Step 3: Install Nginx and provision free SSL certificates for your domain.

ASIDE: I've used Heroku and it's awesome, but I keep coming back to running my own service on my own servers. That's pretty old fashioned these days, but I grew up with the LAMP stack. Is Kubernetes the way of the future? Honestly I doubt it. My bet is PAAS and FAAS will return and take over in the 2020s and people will stop worrying about most of what goes into ops again. That said, there are a lot of highly paid Kubernetes experts out there these days. (There were also a lot of XSLT experts out there way back in 2006 and it still failed, thank the Lord. Before that, there was a DIGITAL expert, Thomas Rhea, that I used to go drinking with back when a Bush was in the White House, and he could tell some wild stories about consulting fees.)

ASIDE 2: Yes I still install packages in a terminal via SSH. I know about and have used chef, ansible, puppet and plain-ole bash scripts. They're all good, and also overkill for small projects. If you're reading this, your project is probably small.

```sh
apk add docker nginx
```

# The Github Actions CI/CD Pipeline


