{
	description = "A machine running NIHIL";

	inputs.nihil.url = "github:btechioi/Nihil-Shell";

	outputs = { nihil, ... }:
	let
		settings = builtins.fromJSON (builtins.readFile ./settings.json);
	in
	{
		nixosConfigurations.${settings.host.name} = nihil.lib.mkSystem
		{
			inherit settings;
			modules = [ ./hardware-configuration.nix ./local.nix ];
			home = [ ./home.nix ];
		};
	};
}
