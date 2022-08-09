<!--
SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
-->

# Upload content

On a machine other than `jasonyundt.website`,

1. If you haven’t already, clone [Jason’s Web Site’s repo](https://jasonyundt.website/gitweb?p=jasons-web-site;a=summary).
2. If you haven’t already, follow the instructions in that repo to build Jason’s
Web Site.
3. In the site’s repo, run
	```sh
	pipenv run python -m build_tool \
		--minify \
		--scheme ftp \
		--scheme https
	```
4. Change to the build directory:
	```sh
	cd build
	```
5. Sync the local `jasons-web-site` directory with the one on
`jasonyundt.website`.
	```sh
	rsync --exclude='*/git' --recursive --perms --chmod=D755,F644 \
		jasons-web-site \
		www-content@jasonyundt.website:~
	```
	```sh
	echo \
		open 'sftp://www-content@jasonyundt.website/~' '&&' \
		mirror -R --exclude-glob='*/git' jasons-web-site \
	| lftp
	```
6. On `jasonyundt.website`,
	1. create mount points for the Git repos:
		```bash
		$ sudo -u www-content mkdir \
			~www-content/jasons-web-site/ftp/git \
			~www-content/jasons-web-site/https/git
		```
	2. add the following to `/etc/fstab`:
		```fstab
		/home/git/repos /home/www-content/jasons-web-site/ftp/git   bind bind,ro 0 0
		/home/git/repos /home/www-content/jasons-web-site/https/git bind bind,ro 0 0
		```
	3. mount the newly created binds:
		```bash
		# mount ~www-content/jasons-web-site/ftp/git
		# mount ~www-content/jasons-web-site/https/git
		```
