# hardware.nix by poligle

{ config, lib, pkgs, ... }:
let
    greeter = config.services.greetd.settings.default_session.user;
    skipReader = pkgs.writeShellScript "skip-fingerprint" ''
        for state in /proc/acpi/button/lid/*/state; do
            [ -r "$state" ] || continue
            ${pkgs.gnugrep}/bin/grep -q closed "$state" && exit 0
        done
        if [ "''${PAM_SERVICE:-}" = sudo ] && uid=$(${pkgs.coreutils}/bin/id -u -- "''${PAM_USER:-}" 2> /dev/null) \
            && [ "$(${pkgs.coreutils}/bin/cat "/run/user/$uid/nihil-sudo-password" 2> /dev/null)" = "$PPID" ]; then
            exit 0
        fi
        if [ "''${PAM_SERVICE:-}" = greetd ] && uid=$(${pkgs.coreutils}/bin/id -u -- ${greeter} 2> /dev/null) \
            && [ -e "/run/user/$uid/nihil-greeter-password" ]; then
            exit 0
        fi
        exit 1
    '';

    skipFingerprint = service:
    {
        rules.auth.skipFingerprint =
        {
            enable = config.security.pam.services.${service}.fprintAuth;
            order = config.security.pam.services.${service}.rules.auth.fprintd.order - 1;
            control = "[success=1 default=ignore]";
            modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
            args = [ "quiet" "${skipReader}" ];
        };
    };
in
{
    services.libinput.enable = true;

    services.logind.settings.Login =
    {
        HandleLidSwitch = lib.mkDefault "suspend";
        HandleLidSwitchExternalPower = lib.mkDefault "suspend";
        HandleLidSwitchDocked = lib.mkDefault "ignore";
    };
    services.fprintd.enable = config.nihil.fingerprint;

    # Secret Service provider for apps that store credentials (Zed's GitHub
    # login, browsers, ...). Without it they cannot persist tokens and ask
    # to sign in again on every launch.
    services.gnome.gnome-keyring.enable = true;

    hardware.enableRedistributableFirmware = lib.mkDefault true;
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    security.pam.services = lib.genAttrs [ "sudo" "su" "login" "polkit-1" "greetd" ] skipFingerprint //
    {
        hyprlock.fprintAuth = false;
        greetd.enableGnomeKeyring = true;
    };
    zramSwap.enable = true;

    # Preserve the Wayland session env so `sudo nvim` (and other GUI/TUI tools
    # run as root) can reach the user's clipboard and Wayland socket.
    security.sudo.extraConfig = ''
        Defaults env_keep += "WAYLAND_DISPLAY XDG_RUNTIME_DIR"
    '';
    hardware.graphics = {
        enable = true;
        # VA-API / VDPAU drivers for the Intel HD 630 (Kaby Lake, gen9).
        # iHD (intel-media-driver) is the modern driver; i965 is the legacy
        # fallback. Both ship so whichever libva picks works.
        extraPackages = with pkgs; [
            intel-media-driver
            intel-vaapi-driver
            libva-vdpau-driver
            vpl-gpu-rt
        ];
        extraPackages32 = with pkgs; [
            intel-media-driver
            intel-vaapi-driver
        ];
    };
    
    services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="leds", KERNEL=="platform::micmute", RUN+="${pkgs.coreutils}/bin/chgrp nihil-leds /sys/class/leds/%k/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/leds/%k/brightness"
    '';
}
