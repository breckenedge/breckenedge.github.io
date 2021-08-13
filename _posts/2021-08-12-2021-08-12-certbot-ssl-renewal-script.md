---
layout: post
title: Certbot SSL Renewal Script
date: 2021-08-12 21:18 -0500
---
I have a [subdomain](https://todo.breckenridge.dev) for a while that's secured for free via [certbot](https://certbot.eff.org), but I was still manually refreshing the certificate every 45 days because that subdomain also runs an Nginx proxy. I hadn't automated this renewal because the Nginx proxy can't be up during certificate renewal; renewal depends on being able to run on port 80 and 443. (Certbot does this in order to confirm domain ownership.)

I'd been mulling over a complicated setup using Docker and containers until I gave up and just wrote a shell script (ash in this case since the server is running Alpine):

```sh
#!/bin/ash

set -e
service nginx stop
certbot renew --standalone
service nginx start
```

which I trigger once a month from `cron`:

```
# min	hour	day	month	weekday	command
0	2	1	*	*	/root/renew.sh
```

Note that `certbot renew --standalone` requires running certbot manually at least once for every domain that the server hosts.

Is this portable and will it work for multiple servers? No. Do I care? Not at this time. Is this perfect? Nothing ever is.

Just one of those things that I can't believe it took me this long to automate.
