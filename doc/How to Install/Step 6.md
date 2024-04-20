<!--
SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2021–2024)
-->

# 6. Do any manual set up

While it would be nice if this config automatically set up everything
for you, there are some things that need to be set up manually at the
moment.

## Instructions specific to systems that import `auto-upgrade.nix`

These post-installation steps should only be done on
`jasonyundt.website.home.arpa`.

1. If one doesn’t already exist, create a new email address on
`jasonyundt.email`. The address should be `<fqdn>@jasonyundt.email` where
`<fqdn>` is the domain name of the machine you’re currently setting up
(don’t include the trailing `.` that represents the root DNS zone).
2. On the machine that you’re setting up, create a `~root/mail-password` file
that contains the password for that email address.
3. Make sure that only root has access to that file:

		sudo chmod 400 ~root/mail-password

## Instructions specific to graphical installs

These post-installation steps should only be done on graphical systems.

1. Log in via SDDM.
2. Use KGpg to create a new GPG key to use for a KDE Wallet.
	1. Start KGpg if it’s not already running.
	2. Right click on the KGpg tray icon.
	3. Click “Key Manager”.
	4. In the menu bar, open Keys > Generate Key Pair…
	5. Click “Expert Mode”.
	6. Answer the prompts in the terminal window.
3. Back up the revocation key in the KeePass database. The other parts of the
key aren’t really needed since this key is only going to be used locally on
one machine.
4. Use KWalletManager to create a new wallet named “default” that uses the
GPG key. If there was an existing wallet before you created this one, delete
that wallet.
5. In KDE Wallet settings, make sure that the new wallet is the default wallet
and that the wallet is closed automatically after 10 minutes.
6. In KWalletManager, add a password entry named <jason@jasonyundt.email>.
7. Import Keyboard shortcuts.kksrc. Go to System
Settings>Workspace>Shortcuts>Shortcuts>Import Scheme…
8. Add Transmission and Yakuake to the list of autostart applications.
9. Customize the rest of the system settings.
10. In Firefox, install the following extensions:
	- Plasma Browser integration
	- uBlock Origin
11. In Firefox, enable HTTPS only mode.
12. Set up any additional email accounts in Thunderbird.
13. In Kalendar, set up a reminder on the first of every month to review
installed packages.

## Victory!

Congratulations, you’re finally finished installing NixOS using Jason’s NixOS
Configuration. Hopefully, this instructions will get shorter in the future.

---

[Previous step](./Step%205.md)
