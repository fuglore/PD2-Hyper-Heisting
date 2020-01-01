Hooks:PostHook(TipsTweakData, "init", "hh_tips", function(self)
	table.insert(self.tips, 
		{
			cat_index = 1,
			image = "enemy_zeal",
			consoles = true,
			category = "hh"
		}
	)
    table.insert(self.tips, 
		{
			cat_index = 2,
			image = "ninjas",
			consoles = true,
			category = "hh"
		}
	)
	table.insert(self.tips, 
		{
			cat_index = 3,
			image = "heister_dragan",
			consoles = true,
			category = "hh"
		}
	)
	table.insert(self.tips, 
		{
			cat_index = 4,
			image = "tactics_helping_up",
			consoles = true,
			category = "hh"
		}
	)
	table.insert(self.tips, 
		{
			cat_index = 5,
			image = "enemy_cloaker",
			consoles = true,
			category = "hh"
		}
	)
	table.insert(self.tips, 
		{
			cat_index = 6,
			image = "crimenet_difficulty",
			consoles = true,
			category = "hh"
		}
	)
	table.insert(self.tips, 
		{
			cat_index = 7,
			image = "crimenet_fbifiles",
			consoles = true,
			category = "hh"
		}
	)
	
    for _, tip in ipairs(self.tips) do
		if not self.category_totals[tip.category] or self.category_totals[tip.category] < tip.cat_index then
			self.category_totals[tip.category] = tip.cat_index
		end
	end
end)