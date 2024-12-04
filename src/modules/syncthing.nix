# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, ... }:
{
	services.syncthing = {
		enable = true;

		user = "jayman";

		dataDir = "/home/jayman/Documents/Home/Syncthing";
		overrideDevices = true;
		overrideFolders = true;
		openDefaultPorts = true;

		settings = {
			extraOptions.gui.tls = true;
			devices = let
				desktop-device = {
					"Jason-Desktop-Linux" = { id = "KADJ4K2-U73CLZH-L6ADY3J-FRFPVUH-HQF3NQZ-472YGQU-K43NZWS-LLDX5AX"; };
				};
				graphical-test-vm-device = {
					"Graphical-Test-VM" = { id = "37WSTYX-LF6LIUJ-EMAA2Z3-FVAS6GI-2BGM2ND-E3FOYCB-I67JIZH-KBCGGA5"; };
				};
			in
			{
				"Server" = { id = "QZBHFNE-XJWGGY4-6JXYMD3-D3HVGR2-C64BVH2-6M644XU-RSVRGAS-QZ752Q7"; };
				"Jason-Lemur-Pro" = { id = "J5UN6OL-YTQM5PO-ARP3I77-EZIHIXS-Y4QNWDS-OSUTZLP-TES6TDP-TCOAKAV"; };
				"Jason-Lemur-Pro-VM-Test" = { id = "DACPZKJ-GMT2UG7-WDYKPBX-KOK3LEF-BLTKCEM-FJGP2L6-7GXB24S-2GPLQQC"; };
				"Jason-Desktop-Windows" = { id = "IJ7DGZZ-HEOL43C-4RCWITD-QCATRWR-HPTWFR3-XTTYEZW-QUV4CBL-5P7AGQF"; };
			# In other words, only add each device to the devices list if this config isn’t being deployed on that device.
			} // (if config.networking.hostName != "Jason-Desktop-Linux" then desktop-device else { })
			// (if config.networking.hostName != "Graphical-Test-VM" then graphical-test-vm-device else { });

			folders = let
				all-others-except-vms = [
					"Server"
					"Jason-Lemur-Pro"
					"Jason-Desktop-Windows"
				] ++ (if config.networking.hostName != "Jason-Desktop-Linux" then [ "Jason-Desktop-Linux" ] else [ ]);
			in
			{
				"Keep Across Linux Distros!" = {
					id = "syrpl-vpqnk";
					devices = all-others-except-vms ++ [ "Jason-Lemur-Pro-VM-Test" ] ++ (if config.networking.hostName != "Graphical-Test-VM" then [ "Graphical-Test-VM" ] else [ ]);
				};
			# In other words, only add the Projects and Game Data folders if we’re not deploying on Graphical-Test-VM.
			} // (if config.networking.hostName != "Graphical-Test-VM" then {
				"Projects" = {
					id = "mjwge-zeznc";
					devices = all-others-except-vms;
				};
				"Game Data" = {
					id = "eheef-uq5hv";
					devices = all-others-except-vms;
				};
			} else { });
		};
	};
}
