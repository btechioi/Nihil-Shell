# editors.nix by poligle

{ config, lib, pkgs, ... }:
let
	# Zed preview and the OpenCode installer ship and update their own
	# binaries; Nix is only here for the files they read. Home Manager's
	# OpenCode module reads the package version while it assembles its
	# warnings, and a null package breaks that, so the module is given an
	# empty stand-in that installs nothing and reports the installed
	# version.
	opencodeVersion = "2.3.0";

	opencodeStub = pkgs.runCommand "opencode-external" { version = opencodeVersion; } ''
		mkdir -p $out/bin
	'';

	opencodeCli = "${config.xdg.configHome}/opencode/cli.json";
in
{
	programs.zed-editor =
	{
		enable = true;
		package = null;
	};

	programs.opencode =
	{
		enable = true;
		package = opencodeStub;
	};

	# Stylix generates the theme for OpenCode 1, which keeps its choice in
	# tui.json; version 2 reads cli.json instead, and wants the name there.
	# The file stays the user's: only the theme keys are set.
	home.activation.nihilOpencodeTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
		cli=${lib.escapeShellArg opencodeCli}

		mkdir -p "$(dirname "$cli")"
		[ -e "$cli" ] || echo '{"$schema":"https://opencode.ai/v2/cli.json"}' > "$cli"

		tmp="$(mktemp "$cli".XXXXXX)"
		${pkgs.jq}/bin/jq '.theme = ((.theme // {}) + { name: "stylix", mode: "dark" })' "$cli" > "$tmp"
		chmod 600 "$tmp"
		mv "$tmp" "$cli"
	'';
}
