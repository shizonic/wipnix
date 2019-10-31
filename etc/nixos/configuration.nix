{ config, pkgs, ... }:

{
    system.stateVersion = "19.09";

    swapDevices = [{ device = "/dev/mapper/cryptswap"; }];

    fileSystems = {
        "/" = {
            device = "/dev/mapper/cryptroot";
            fsType = "btrfs";
            options = [ "defaults" "noatime" "compress=lzo" "ssd" "discard" "subvol=subvols/@" ];
        };

        "/boot" = {
            device = "/dev/mapper/cryptroot";
            fsType = "btrfs";
            options = [ "defaults" "noatime" "compress=lzo" "ssd" "discard" "subvol=subvols/@boot" ];
        };

        "/home" = {
            device = "/dev/mapper/cryptroot";
            fsType = "btrfs";
            options = [ "defaults" "noatime" "compress=lzo" "ssd" "discard" "subvol=subvols/@home" ];
        };

        "/boot/efi" = {
            label = "uefi";
            device = disk.efi;
            fsType = "vfat";
            options = [ "discard" ];
        };
    };

    boot = {
        # plymouth.enable = true;
        kernelPackages = pkgs.linuxPackages_latest;

        # kernelParams = [
        #     "iommu=pt"
        #     "zswap.enabled=1"
        #     "kvm.ignore_msrs=1"
        # ];

        loader = {
            efi = {
                canTouchEfiVariables = true;
                efiSysMountPoint = "/boot/efi";
            };

            grub = {
                efiSupport = true;
                enableCryptodisk = true;
                device = "nodev";
                # splashImage = "/mnt/hdd1/home/okina/Pictures/grub.png";
            };
        };

        initrd = {
            secrets."/boot/.crypt.key" = /boot/.crypt.key
            preDeviceCommands = "mkdir -pm0700 /run/cryptsetup";

            supportedFilesystems = [ "btrfs" ];
            luks.devices = {
                "cryptroot" = {
                    allowDiscards = true;
                    keyFile = "/boot/.crypt.key";
                };

                "cryptswap" = {
                    allowDiscards = true;
                    keyFile = "/boot/.crypt.key";
                };
            };
        };
    };

    resumeDevice = "/dev/cryptswap";

	networking = {
		hostName = "xonec";
		nameservers = [ "127.0.0.1" "::1" ];

		networkmanager = {
			enable = true;
			dns = "none";
		};
    };


}
