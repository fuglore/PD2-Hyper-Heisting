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
			image = "hh_ninjas",
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
			image = "crimenet_difficulty",
			consoles = true,
			category = "hh"
		}
	)
	table.insert(self.tips, 
		{
			cat_index = 8,
			image = "enemy_flashbang",
			consoles = true,
			category = "hh"
		}
	)
	table.insert(self.tips, 
		{
			cat_index = 9,
			image = "hh_shotgunners",
			consoles = true,
			category = "hh"
		}
	)
	table.insert(self.tips, 
		{
			cat_index = 10,
			image = "hh_shotgunners",
			consoles = true,
			category = "hh"
		}
	)
	table.insert(self.tips, --remember fuglore, this is the hyper heisting discord tip, remember that
		{
			cat_index = 11,
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

function TipsTweakData:get_a_tip()
	local tip = self.tips[math.random(#self.tips)]
	
	if tip and tip.category and tip.category == "trivia" and math.random() < 0.6 then
		tip = self.tips[math.random(#self.tips)]
		--log("itrerolledmaybe")
		if tip.category and tip.category == "trivia" and math.random() < 0.4 then
			tip = self.tips[math.random(#self.tips)]
			--log("itrerolledmaybe")
			if tip.category and tip.category == "trivia" and math.random() < 0.2 then
				tip = self.tips[math.random(#self.tips)]
				--log("thisisthelastreroll")
				if tip.category and tip.category == "trivia" then
					--log("how")
				end
			end		
		end
	end
	
	local image_exists = DB:has(Idstring("texture"), "guis/textures/loading/hints/" .. tip.image)
	
	if not image_exists then
		Application:error("Warning: missing loading hint image: " .. tip.image)

		return nil
	end

	local title_id = "loading_" .. tip.category .. "_title"
	local text_id = "loading_" .. tip.category .. "_" .. tip.cat_index

	return {
		image = tip.image,
		index = tip.cat_index,
		total = self.category_totals[tip.category],
		title = managers.localization:to_upper_text(title_id),
		text = managers.localization:text(text_id)
	}
end