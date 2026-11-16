# zen.nix by poligle

{ config, lib, pkgs, inputs, ... }:
let
    colors = config.lib.stylix.colors.withHashtag;
in
{
    imports = [ inputs.zen-browser.homeModules.beta ];

    programs.zen-browser =
    {
        enable = true;
        setAsDefaultBrowser = true;
        profiles =
        {
            default =
            {
                settings =
                {
                    "ui.highlight" = colors.base03;
                    "ui.highlighttext" = colors.base06;

                    # Hardware video decode via VA-API (Intel iHD).
                    "media.ffmpeg.vaapi.enabled" = true;
                    "media.hardware-video-decoding.force-enabled" = true;
                    "gfx.webrender.all" = true;
                    "widget.dmabuf.force-enabled" = true;
                };
            };
        };
    };

    stylix.targets.zen-browser.profileNames = [ "default" ];
}
