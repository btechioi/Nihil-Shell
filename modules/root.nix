# root.nix by poligle

# Root's own home, kept to the things a person reaches for while editing
# the machine: `sudo nvim /etc/nixos/local.nix` is then the same editor the
# shell offers, with the same plugins and the same colours, and GTK apps
# started as root wear the same theme.
{ ... }:
{
    home-manager.users.root =
    {
        imports =
        [
            ../home/nvim.nix
            ../home/gtk.nix
        ];

        home.username = "root";
        home.homeDirectory = "/root";
        home.stateVersion = "26.05";

        programs.home-manager.enable = true;
    };
}
