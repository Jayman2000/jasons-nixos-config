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
		in
		{
			"Server" = { id = "QZBHFNE-XJWGGY4-6JXYMD3-D3HVGR2-C64BVH2-6M644XU-RSVRGAS-QZ752Q7"; };
			"Jason-Lemur-Pro" = { id = "XDRFUGH-DWTEVBO-YELO3PG-2QWAFMS-D3H3NKH-CADVPI3-REOFSY5-NZDDXAE"; };
			"Jason-Desktop-Windows" = { id = "DAW6JNR-DHBHAVL-42UVJDB-SENEDDQ-OVLHNH3-XOVKDE4-JXVIQ23-GJBG6QZ"; };
		# In other words, only add Jason-Desktop-Linux to the devices list if this config isn’t being deployed to Jason-Desktop-Linux.
		} // (if config.networking.hostName != "Jason-Desktop-Linux" then desktop-device else { });

		folders = let
			all-others = [
				"Server"
				"Jason-Lemur-Pro"
				"Jason-Desktop-Windows"
			] ++ (if config.networking.hostName != "Jason-Desktop-Linux" then [ "Jason-Desktop-Linux" ] else [ ]);
		in
		{
			"Keep Across Linux Distros!" = {
				id = "syrpl-vpqnk";
				devices = all-others;
			};
			"Projects" = {
				id = "mjwge-zeznc";
				devices = all-others;
			};
			"Game Data" = {
				id = "eheef-uq5hv";
				devices = all-others;
			};
		};
	};
}
