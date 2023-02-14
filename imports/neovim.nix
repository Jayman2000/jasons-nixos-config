# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{
	home-manager.users.jayman = { pkgs, ... }: {
		programs.neovim = {
			enable = true;
			extraConfig = ''
				set spell
				let g:better_whitespace_enabled=0
				let g:strip_whitespace_confirm=0
				let g:strip_only_modified_lines=1
				let g:strip_whitespace_on_save=1
			'';
			plugins = with pkgs.vimPlugins; [ vim-better-whitespace vim-nix ];
		};
	};
}
