{
	networking = {
		hostName = "xonec";
		nameservers = [ "127.0.0.1" "::1" ];

		networkmanager = {
			enable = true;
			dns = "none";
		};

		# firewall = {
		# 	allowedTCPPorts = [
		# 		13370
		# 	];

		# 	allowedUDPPorts = [
		# 		13370
		# 	];
		# };
	};
}
