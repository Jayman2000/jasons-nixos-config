# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
with import <nixpkgs> { };

resholve.writeScriptBin "cmark-html" {
	inputs = [ cmark dos2unix ];
	interpreter = "${bash}/bin/bash";
} ''
	filename="$1.html"
	bom=$'\uFEFF'
	beginning="<!DOCTYPE html>
	<html>
		<head>
			<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\">
			<title>$filename</title>
		</head>
		<body>
	"
	end='  </body>
	</html>
	'

	{
		echo "$bom$beginning"
		cmark --unsafe "$1"
		echo "$end"
	} > "$filename"

	unix2dos "$filename"
''
