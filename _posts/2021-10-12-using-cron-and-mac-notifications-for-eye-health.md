---
layout: post
title: Using cron and Mac notifications for eye health
date: 2021-10-12 13:25 -0500
---

Last week was another trip to the optometrist as my eyes continue their slow march towards bifocals. I've gone to the same optometrist for a few years, but since I moved, I decided to try another one nearer to my house. I'm glad that I did. This doctor explained a few more ways in how sitting in front of a screen can cause eye problems. She said that we blink less often when we're staring at a screen and that this can lead to drier eyes. Thankfully she also had a solution in the form of a habit that I could practice to help relieve my eyes, called it the "20-20-20" routine:

> Every 20 minutes, blink (hard) 20 times, and look at something at least 20 feet away for 20 seconds.

Knowing that I'd never remember to do this, I wanted to see if there was a way I could get notifications on my work machine every 20 minutes during the hours of the day that I'm typically in front of the screen. `cron` to the rescue. Adding this line to my crontab pops up a notification every 20 minutes from 9am to 5pm on workdays, casually nudging me to perform the routine:

```crontab
* 20 9-17 * * 1-5 osascript -e 'display notification "20/20/20" with title "Eyeguard"'
```

So far it's worked great and my eyes feel much less strained at the end of the day.
