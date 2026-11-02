# vpn

A small wrapper around the `sing-box` systemd service. It starts the VPN, waits for the
tunnel, checks that the internet works, and rolls back with logs if it doesn't.

## Install

```bash
git clone https://github.com/slashdekomori/vpn && cd vpn
./install.sh              # symlinks bin/vpn -> ~/.local/bin/vpn
./install.sh --nopasswd   # same + no sudo password for start/stop/restart
```

You need `sing-box`, `curl`, `iproute2` and `systemd`, and `~/.local/bin` must be in your `PATH`.

Uninstall: `./install.sh --uninstall`

## Usage

```
vpn            toggle on/off
vpn on         check config -> start -> wait for tunnel -> test (auto rollback on failure)
vpn off        stop and test the direct connection
vpn restart    restart and test
vpn status     service state + current IP / country
vpn check      connection test only
vpn log        follow logs (journalctl -fu sing-box)
vpn edit       edit /etc/sing-box/config.json, then validate it
vpn help       show help
```

DNS often fails for a few seconds after start. `vpn on` keeps retrying for up to
`VPN_WARMUP` seconds (30 by default) before it decides the VPN is broken.

Environment overrides: `VPN_SERVICE`, `VPN_CONF_DIR`, `VPN_IFACE`, `VPN_TIMEOUT`, `VPN_WARMUP`.

## Removing the password prompt (manual)

`./install.sh --nopasswd` does this for you. To do it by hand:

```bash
echo "$USER ALL=(root) NOPASSWD: /usr/bin/systemctl start sing-box, /usr/bin/systemctl stop sing-box, /usr/bin/systemctl restart sing-box" \
  | sudo tee /etc/sudoers.d/sing-box
sudo chmod 440 /etc/sudoers.d/sing-box
sudo visudo -c                 # validate. If it fails: sudo rm /etc/sudoers.d/sing-box
```

Check it: `sudo -n systemctl restart sing-box` should run without asking for a password.

Undo it: `sudo rm /etc/sudoers.d/sing-box`

The rule only covers those three exact commands, so it doesn't give out broader root access.
