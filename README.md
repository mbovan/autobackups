# Autobackups
Store database dumps of all your Drupal websites on Box.com.

# Requirements

Installed on your server:
- `curl`, `python`, `drush`

# Setup

1. Create a new [application](https://app.box.com/developers/console) on Box.com
2. Enable OAuth authentication on Configuration > OAuth 2.0 Credentials  tab and get client ID and client secret
3. Create a group in the [admin console](https://app.box.com/master/groups), set shared folders and allow "Uploader" permissions
3. Copy `example.env` to `.env`
4. Set-up Box.com variables. Follow the [official documentation](https://developer.box.com/reference/post-files-content/) for more information.
5. Make the script file executable `chmod +x autobackups.sh`
6. (Optional) Run autobackups regulary (every day at 03:00AM) `0 3 * * * /home/autobackups.sh`
