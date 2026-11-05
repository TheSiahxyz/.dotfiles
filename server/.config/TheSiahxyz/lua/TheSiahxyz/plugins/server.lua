-- Server (no display): turn off plugins that need images, a GUI or Jupyter.
-- lazy.nvim merges specs by name, so `enabled = false` here wins everywhere.
return {
	{ "3rd/image.nvim", enabled = false },
	{ "3rd/diagram.nvim", enabled = false },
	{ "HakonHarnes/img-clip.nvim", enabled = false },
	{ "benlubas/image-save.nvim", enabled = false },
	{ "benlubas/molten-nvim", enabled = false },
	{ "vhyrro/luarocks.nvim", enabled = false },
	{ "leafo/magick", enabled = false },
}
