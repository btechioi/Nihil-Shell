# packages.nix by poligle

{ config, lib, pkgs, freesmlauncher, system, ... }:
let
    freesm = freesmlauncher.packages.${system}.freesmlauncher;

    # Prebuilt hyprkvm from GitHub releases (no compilation on the machine).
    hyprkvmPkg = pkgs.stdenv.mkDerivation {
        pname = "hyprkvm";
        version = "0.6.14";
        src = pkgs.fetchurl {
            url = "https://github.com/btechioi/hyprKVM/releases/download/v0.6.14/hyprkvm-x86_64-unknown-linux-gnu.tar.gz";
            sha256 = "101a71f7466c2e7f6ca043b75fe0fd4671a7b7aad1487efbe09d21fae7c96715";
        };
        sourceRoot = ".";
        nativeBuildInputs = [ pkgs.makeWrapper ];
        buildInputs = with pkgs; [ wayland libxkbcommon openssl vulkan-loader libGL ];
        installPhase = ''
            mkdir -p $out/bin
            cp hyprkvm $out/bin/
            cp hyprkvm-ctl $out/bin/
            chmod +x $out/bin/hyprkvm $out/bin/hyprkvm-ctl
            wrapProgram $out/bin/hyprkvm \
                --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath (with pkgs; [ wayland libxkbcommon openssl vulkan-loader libGL ])}
        '';
        meta = with pkgs.lib; {
            description = "Hyprland-native software KVM switch";
            homepage = "https://github.com/btechioi/hyprKVM";
            license = licenses.mit;
            platforms = platforms.linux;
            mainProgram = "hyprkvm";
        };
    };
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
        hyprkvmPkg
        wl-clipboard

        # Dev tooling
        uv
        fnm
        nodejs
        rustup
        fvm
        go
        python3
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
