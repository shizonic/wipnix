{ pkgs, ... }:

{
	time.timeZone = "Europe/Zurich";
	systemd.extraConfig = "DefaultLimitNOFILE=1048576";
	sound.enable = true;
	location.provider = "geoclue2";

	security.pam.loginLimits = [{
		domain = "*";
		type = "hard";
		item = "nofile";
		value = "1048576";
	}];

	virtualisation = {
		docker.enable = true;

		libvirtd = {
			enable = true;

			qemuVerbatimConfig = ''
				namespaces = []
				user = "okina"
				group = "kvm"
				nographics_allow_host_audio = 1
				max_files = 2048

				cgroup_device_acl = [
					"/dev/kvm",
					"/dev/input/by-path/pci-0000:02:00.0-usb-0:6:1.0-event-kbd",
					"/dev/input/by-path/pci-0000:02:00.0-usb-0:7:1.0-event-mouse",
					"/dev/null", "/dev/full", "/dev/zero",
					"/dev/random", "/dev/urandom",
					"/dev/ptmx", "/dev/kvm", "/dev/kqemu",
					"/dev/rtc","/dev/hpet", "/dev/sev"
				]
			'';
		};
	};

	hardware = {
		bluetooth.enable = true;
		cpu.intel.updateMicrocode = true;

		opengl = {
			driSupport32Bit = true;
			s3tcSupport = true;
		};

		pulseaudio = {
			enable = true;
			support32Bit = true;
			package = pkgs.pulseaudioFull;
			extraConfig = "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1";

			daemon.config = {
				default-sample-format = "s24le";
				default-sample-rate = "192000";
				resample-method = "speex-float-7";
			};
		};
	};

	fonts = {
		fontconfig.cache32Bit = true;
		fonts = with pkgs; [ ipafont ];
	};
}
