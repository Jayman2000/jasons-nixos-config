# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
{
	# I chose to use AdGuard DNS based on this table [1]. It seems
	# to support the most stuff. I’m specifically using the
	# unfiltered version since I don’t really see how this server
	# would benefit from ad blocking.
	#
	# [1]: <https://en.wikipedia.org/w/index.php?title=Public_recursive_name_server&oldid=1119798953#Notable_public_DNS_service_operators>
	domain = "dns-unfiltered.adguard.com";
	# These two lists should be sorted so that the tests in
	# jasons-self-test-script work properly.
	expectedARecords = [
		"94.140.14.140"
		"94.140.14.141"
	];
	expectedAAAARecords = [
		"2a10:50c0::1:ff"
		"2a10:50c0::2:ff"
	];
}
