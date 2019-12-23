local old_init_risk_assets = AssetsTweakData._init_risk_assets
function AssetsTweakData:_init_risk_assets(tweak_data)
	old_init_risk_assets(self, tweak_data)
	self.risk_sm_wish.texture = "guis/textures/pd2/mission_briefing/assets/assets_risklevel_6_hh"
end