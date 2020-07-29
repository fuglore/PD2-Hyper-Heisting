local plastic_init = AssetsTweakData.init
function AssetsTweakData:init(tweak_data)
	plastic_init(self, tweak_data)
	self.no_mercy_c4 = {}
	self.no_mercy_c4.name_id = "menu_asset_no_mercy_c4"
	self.no_mercy_c4.texture = "guis/dlcs/dlc1/textures/pd2/mission_briefing/assets/train_03"
	self.no_mercy_c4.stages = {"no_mercy_c4"}
	self.no_mercy_c4.visible_if_locked = true
	self.no_mercy_c4.unlock_desc_id = "menu_asset_no_mercy_c4_desc"
	self.no_mercy_c4.no_mystery = true
	self.no_mercy_c4.money_lock = tweak_data:get_value("money_manager", "mission_asset_cost_small", 3)
	self.no_mercy_c4.stages = {
			"nmh_hyper",
		}
end