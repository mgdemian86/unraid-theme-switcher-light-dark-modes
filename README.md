# Unraid Theme Switcher

Automatically switches Unraid's Dynamix theme between light and dark modes based on the server's local time.

## Requirements

- An Unraid server with the **User Scripts** plugin installed.
- The configured theme identifiers must be available in Unraid. Use the theme names Unraid recognizes (typically the theme stylesheet filename without `.css`).

## Install

1. In Unraid, open **Settings → User Scripts** and add a script.
2. Copy the contents of [`theme-switcher.sh`](./theme-switcher.sh) into the script editor and save it.
3. Set the script schedule to run hourly. For a custom cron schedule, use:

   ```cron
   0 * * * *
   ```

The script checks the active mode each time it runs and only edits Unraid's theme setting when a change is needed. It reads and updates `/boot/config/plugins/dynamix/dynamix.cfg`.

## Configure

Edit these four values near the top of the script:

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

Use different whole-number start hours from `0` to `23`. The script uses the Unraid server's local time. If the light start hour is later than the dark start hour, the light period spans midnight. For example, light at `20` and dark at `7` means light mode from 20:00 until 07:00.

The hourly User Scripts schedule is intentional: it lets these four values determine the transition times without requiring a second schedule setting to be kept in sync.

## Logs

Run the script or view its log in the User Scripts plugin to see the current time, selected theme, and whether a change was made.