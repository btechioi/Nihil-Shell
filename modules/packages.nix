# packages.nix by poligle

{ config, lib, pkgs, ... }:
{
    environment.systemPackages = with pkgs; 
    [
        wev
        wget
        git
        unzip
        lxqt.lxqt-policykit
        fastfetch
        btop
        brightnessctl
        playerctl
        trash-cli
        sound-theme-freedesktop
    ];
    
    programs.nix-ld.enable = true;
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
