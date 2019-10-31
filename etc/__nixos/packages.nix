{ pkgs, ... }:

{
	# List packages installed in system profile. To search by name, run:
	# $ nix-env -qaP | grep wget
	environment.systemPackages = with pkgs; [
		# Utilities.
		lm_sensors
		gnupg
		neofetch
		tewisay
		catfish
		ebtables
		dnsmasq
		bridge-utils
		netcat-openbsd
		virtmanager
		openssl
		docker-compose
		qt5.qttools

		# Development
		git
		gcc
		go
		vscode-with-extensions

		# Compression.
		p7zip
		unzip
		unrar
		unar
		zstd

		# Internet
		telnet
		keybase-gui
		chromium
		google-chrome
		firefox
		brave
		midori
		elinks
		shadowfox
		mumble

		# Media.
		ncmpcpp
		mpv
		youtube-dl
		gimp
		mcomix
		timidity
		soundfont-fluid

		# Emulation.
		dolphinEmu
		snes9x-gtk
		mgba
		wine

		# KDE.
		akonadi
		ark
		ffmpegthumbs
		kate
		kcalc
		kgpg
		kmail
		konversation
		krename
		okular
		spectacle
		gwenview
	];
}
