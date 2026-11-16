# packages.nix by poligle

{ config, lib, pkgs, freesmlauncher, system, ... }:
let
    freesm = freesmlauncher.packages.${system}.freesmlauncher;
in
{
    environment.systemPackages = with pkgs; 
    [
        wev
        wget
        git
        unzip
        fastfetch
        btop
        brightnessctl
        playerctl
        trash-cli
        sound-theme-freedesktop
        android-tools
        libva-utils
        intel-gpu-tools
        freesm
    ];
    
    programs.nix-ld.enable = true;

    # Android Debug Bridge + platform tools (adb, fastboot, ...). systemd 258
    # grants device access via uaccess rules, so no adbusers group is needed.

    # Libraries for programs that arrive as ordinary Linux binaries, the
    # way their makers ship them: Zed from zed.dev wants GLib and ALSA to
    # load, and the Vulkan loader (with Mesa) to draw.
    programs.nix-ld.libraries = with pkgs;
    [
        glib
        alsa-lib
        vulkan-loader
        libGL
        wayland
        libxkbcommon
        libx11
        libxcb
        fontconfig
        freetype
        dbus
    ];

    nixpkgs.config.allowUnfree = true;

    # AppImages, run like any other binary: registered with binfmt, and
    # nix-ld gives the libraries their bundled helpers expect.
    programs.appimage =
    {
        enable = true;
        binfmt = true;
    };

    # Flatpak, with its portals and Flathub as a remote
    services.flatpak.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    systemd.services.flatpak-flathub =
    {
        description = "Add Flathub as a Flatpak remote";
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" "flatpak-system-helper.service" ];
        serviceConfig.Type = "oneshot";
        script = "${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo";
    };

    fonts.packages = with pkgs; 
    [
        nerd-fonts.jetbrains-mono
        nerd-fonts.hack
    ];
}
