# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, ... }:
{
	services.syncthing = {
		enable = true;

		user = "jayman";

		dataDir = "/home/jayman/Documents/Home/Syncthing";
		extraOptions.gui.tls = true;
		overrideDevices = true;
		overrideFolders = true;

		devices = let
			desktop-device = {
				"Jason-Desktop-Linux" = { id = "7A735CO-FSRRF2I-FN5WRGV-OHGRWHR-TF4Z47H-OJBHRBA-G7CP7BN-FTLXGAX"; };
			};
			laptop-device = {
				"Jason-Laptop-Linux" = { id = "HIUQOJU-CNAGZCU-BHAFKP7-2T4WAO3-XUMWZKC-N2ZXQWD-XSGWNZH-WRGEWAP"; };
			};
		in
		{
			"Server" = { id = "QZBHFNE-XJWGGY4-6JXYMD3-D3HVGR2-C64BVH2-6M644XU-RSVRGAS-QZ752Q7"; };
			"Jason-Lemur-Pro" = { id = "THEABSO-67CCBNW-OCJ6RXK-F6FK54L-2MCDW43-OT7OJNB-MT4OZFM-Z7OCNA4"; };
			"Jason-Desktop-Windows" = { id = "DAW6JNR-DHBHAVL-42UVJDB-SENEDDQ-OVLHNH3-XOVKDE4-JXVIQ23-GJBG6QZ"; };
		# In other words, only add each device to the devices list if this config isn’t being deployed on that device.
		} // (if config.networking.hostName != "Jason-Desktop-Linux" then desktop-device else { })
		// (if config.networking.hostName != "Jason-Laptop-Linux" then laptop-device else { });

		folders = let
			all-others-except-vm = [
				"Server"
				"Jason-Lemur-Pro"
				"Jason-Desktop-Windows"
			] ++ (if config.networking.hostName != "Jason-Desktop-Linux" then [ "Jason-Desktop-Linux" ] else [ ])
			++ (if config.networking.hostName != "Jason-Laptop-Linux" then [ "Jason-Laptop-Linux" ] else [ ]);
		in
		{
			"Keep Across Linux Distros!" = {
				id = "syrpl-vpqnk";
				# TODO: Uncomment that last part once Graphical-Test-VM has a Syncthing ID.
				devices = all-others-except-vm; #++ [ "Graphical-Test-VM" ];
			};
		# In other words, only add the Projects and Game Data folders if we’re not deploying on Graphical-Test-VM.
		} // (if config.networking.hostName != "Graphical-Test-VM" then {
			"Projects" = {
				id = "mjwge-zeznc";
				devices = all-others-except-vm;
			};
			"Game Data" = {
				id = "eheef-uq5hv";
				devices = all-others-except-vm;
			};
		} else { });
	};
}
