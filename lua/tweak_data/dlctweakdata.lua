Hooks:PostHook(dlctweakdata, "init", "dlctweakshit", function(self, tweak_data)		
		self.hyperheist = {
			content = {},
			free = true
		}
		self.hyperheist.content.loot_drops = {}
		self.hyperheist.content.upgrades = {}	
		self.hyperheist.content.loot_drops = {
			{
				type_items = "textures",
				item_entry = "truthrunes",
				amount = 1
			}			
		}
end)