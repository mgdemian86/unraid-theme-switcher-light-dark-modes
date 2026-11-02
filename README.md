# Unraid Theme Switcher

Automatically switches Unraid's Dynamix theme between light and dark modes based on the server's local time.

## Why I made this

I tried other plugins that offered automatic theme switching, but the options I found required geolocation, which I was not comfortable enabling. I wanted a simple alternative that switches themes on a schedule without relying on location data, so I wrote this script. I have been using it for about a year without any issues.

## Requirements

- An Unraid server with the **User Scripts** plugin installed.
- Both configured theme identifiers must be available in Unraid. Use the names Unraid recognizes (typically the theme stylesheet filename without `.css`).

## Install and schedule

1. Install **User Scripts** from the **Community Apps** store.
2. Open **User Scripts**, create a script, paste the contents of [`theme-switcher.sh`](./theme-switcher.sh), and save it.
3. Configure the script's schedule as a custom cron expression:

   ```cron
   0 8,17 * * *
   ```

   In plain English, this runs the script every day at 08:00 and 17:00 (the start of the 8 AM and 5 PM hours).

   A cron expression has five fields, in order: **minute, hour, day of month, month, day of week**. In this example, `0` means minute zero, `8,17` means both the 8th and 17th hours (08:00 and 17:00), and each `*` means every day, month, or weekday. The comma separates the two run hours.

   **Important:** these two cron run hours must match the two start hours configured in the script: `LIGHT_MODE_STARTS_AT` and `DARK_MODE_STARTS_AT`. If you change either start hour, update the cron expression too. For example, light at 09:00 and dark at 18:00 needs `0 9,18 * * *`. Use 24-hour hours from `0` to `23` in both places.

   **If the server is off when a scheduled run is due, that run will be missed.** The script does not catch up automatically when the server starts again. Run it manually from User Scripts after the server is back online to apply the theme for the current time without waiting for the next scheduled run.

The script reads and updates Unraid's saved theme in `/boot/config/plugins/dynamix/dynamix.cfg`. It only edits that setting when the selected theme differs from the mode active at the time it runs.

## Find installed themes from the Unraid console

Unraid includes the `white` and `black` themes by default. If you already have other themes installed and want to switch between them, you can use those too.

1. Open Unraid's built-in console/terminal from the Unraid web interface.
2. Run this command to list the installed Dynamix theme names:

   ```bash
   for f in /usr/local/emhttp/webGui/styles/themes/*.css; do [ -f "$f" ] && basename "$f" .css; done
   ```

3. Use the exact name printed for a theme in the script settings below. The command removes the directory path and `.css` extension for you.

## Configure the themes and start times

Edit these four values near the top of the script. Replace the theme names inside the quotes with installed names from the console command above; keep the quotation marks. `white` and `black` are Unraid's default themes, and you can use any other installed themes instead.

```bash
LIGHT_THEME="white"
DARK_THEME="black"
LIGHT_MODE_STARTS_AT=8
DARK_MODE_STARTS_AT=17
```

| Setting | Meaning |
| --- | --- |
| `LIGHT_THEME` | Unraid theme identifier to use for light mode. |
| `DARK_THEME` | Unraid theme identifier to use for dark mode. |
| `LIGHT_MODE_STARTS_AT` | Local server hour when light mode begins (0–23). |
| `DARK_MODE_STARTS_AT` | Local server hour when dark mode begins (0–23). |

Use different whole-number start hours from `0` to `23`. The script uses the Unraid server's local time. If the light start hour is later than the dark start hour, the light period spans midnight. For example, light at `20` and dark at `7` means light mode from 20:00 until 07:00. The cron expression should then include both hours, for example `0 7,20 * * *`.

## Logs

Run the script or view its log in the User Scripts plugin to see the current time, selected theme, and whether a change was made.