# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{
	services.syncthing = {
		enable = true;

		user = "jayman";

		dataDir = "/home/jayman/Documents/Home/Syncthing";
		extraOptions.gui.tls = true;
		overrideDevices = true;
		overrideFolders = true;
		devices = {
			"Server" = { id = "QZBHFNE-XJWGGY4-6JXYMD3-D3HVGR2-C64BVH2-6M644XU-RSVRGAS-QZ752Q7"; };
			"Jason-Lemur-Pro" = { id = "XDRFUGH-DWTEVBO-YELO3PG-2QWAFMS-D3H3NKH-CADVPI3-REOFSY5-NZDDXAE"; };
			"Jason-Desktop-Linux" = { id = "VQ3YVQK-FPN6REG-T3BNHX2-LT5YS4O-YFGVXPV-ENJM3AZ-LD7AE5W-FFS5JQI"; };
			"Jason-Desktop-Windows" = { id = "DAW6JNR-DHBHAVL-42UVJDB-SENEDDQ-OVLHNH3-XOVKDE4-JXVIQ23-GJBG6QZ"; };
		};
		folders = {
			"Keep Across Linux Distros!" = {
				id = "syrpl-vpqnk";
				devices = [ "Server" "Jason-Lemur-Pro" "Jason-Desktop-Linux" "Jason-Desktop-Windows" ];
			};
			"Projects" = {
				id = "mjwge-zeznc";
				devices = [ "Server" "Jason-Lemur-Pro" "Jason-Desktop-Linux" "Jason-Desktop-Windows" ];
			};
			"Game Data" = {
				id = "eheef-uq5hv";
				devices = [ "Server" "Jason-Lemur-Pro" "Jason-Desktop-Linux" "Jason-Desktop-Windows" ];
			};
		};
	};
}
