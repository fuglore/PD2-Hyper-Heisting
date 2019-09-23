Hooks:PostHook(WeaponTweakData, "init", "wep_init", function(self, tweakdata)
	--local reb = true
	--currently disabled, unfinished code, playable though
	if reb then
		--STK Heavies assuming perkdeck boosts:
		--31(32) = 3 hits
		--40(42) = 2 hits
		--59(60+) = 1 hit
		
		--30-40-SMGs begin here
		
		--CMP, base for all SMGs, note slight recoil pattern difference, generalist single-target weapon.
		
		self.mp9.kick.standing = {
			1.6,
			1.8,
			-0.75,
			0.75
		}
		self.mp9.kick.crouching = {
			1.4,
			1.6,
			-0.75,
			0.75
		}
		self.mp9.kick.steelsight = {
			1.2,
			1.4,
			-0.25,
			0.25
		}
		self.mp9.spread.steelsight = 1
		self.mp9.stats.damage = 31
		self.mp9.stats.spread = 20
		self.mp9.stats.spread_moving = 20
		self.mp9.stats.recoil = 22
		self.mp9.AMMO_PICKUP = {12, 12}
		
		--60-SMGs begin here
		--Krinkov, not particularly close to their other brethren, very powerful ammo-pickup and damage-wise, but lacks in stats.
		self.akmsu.kick.standing = self.mp9.kick.standing
		self.akmsu.kick.crouching = self.mp9.kick.crouching
		self.akmsu.kick.steelsight = self.mp9.kick.steelsight
		self.akmsu.spread.steelsight = 1
		self.akmsu.stats.damage = 59
		self.akmsu.stats.spread = 17
		self.akmsu.stats.spread_moving = 15
		self.akmsu.stats.recoil = 18
		self.akmsu.AMMO_PICKUP = {2.6, 2.6} 
		

		--40-Rifles begin here
		
		--CAR-4, base for all rifles, generalist single-target weapon.
		self.new_m4.kick.standing = {
			1.6,
			1.8,
			-1,
			1
		}
		self.new_m4.kick.crouching = {
			1.4,
			1.8,
			-1,
			1
		}
		self.new_m4.kick.steelsight = {
			1.2,
			1.6,
			-0.25,
			0.25
		}
		self.new_m4.spread.steelsight = 1
		self.new_m4.stats.damage = 40
		self.new_m4.stats.spread = 20
		self.new_m4.stats.spread_moving = 18
		self.new_m4.stats.recoil = 18
		self.new_m4.AMMO_PICKUP = {5, 5} --Ammo pickup is evened and consistent amongst weapons, rather than remain to random chance, all weapoons have...decent ammo economy, outta ammo? Switch! Ammo bags are given value by allowing usage of high damage auto-fire weapons without switching
		
		--AMCAR, player starter weapon, generalist, versatile bullet hose.
		self.amcar.kick.standing = self.new_m4.kick.standing
		self.amcar.kick.crouching = self.new_m4.kick.crouching
		self.amcar.kick.steelsight = self.new_m4.kick.steelsight
		self.amcar.spread.steelsight = 1
		self.amcar.stats.damage = 40
		self.amcar.stats.spread = 18
		self.amcar.stats.spread_moving = 18
		self.amcar.stats.recoil = 20
		self.amcar.AMMO_PICKUP = {6, 6} --never run out of ammo, pretty much
		
		--60-Rifles begin here
		
		--AMR-16, medium risk weapon, good stats, ok ammo pickup, less versatile than AMCAR and CAR-4, but closer to them overall.
		self.m16.kick.standing = self.new_m4.kick.standing
		self.m16.kick.crouching = self.new_m4.kick.standing
		self.m16.kick.steelsight = self.new_m4.kick.standing
		self.m16.spread.steelsight = 1
		self.m16.stats.damage = 59 --Kills heavies in one headshot with perkdeck boosts.
		self.m16.stats.spread = 16
		self.m16.stats.spread_moving = 16
		self.m16.stats.recoil = 17
		self.m16.AMMO_PICKUP = {2.6, 2.6} --Careful switching between auto-fire and non-autofire will result in overall better ammo-consumption, alternatively, spray, and switch to a safer, less risky weapon.
		
		--LMGs begin here
		
		--KSP, death to the LMG meta, high-risk, high-reward, a weapon for people who think they can handle the ride, base for all LMGs.
		self.m249.kick.standing = {
			1.2,
			1.2,
			-1,
			1
		}
		self.m249.kick.crouching = self.m249.kick.standing
		self.m249.kick.steelsight = self.m249.kick.standing
		--Damage unchanged, picks off specials very, very well.
		self.m249.stats.spread = 7
		self.m249.stats.spread_moving = 5
		self.m249.stats.recoil = 8
		self.m249.AMMO_PICKUP = {0, 4} --Extremely random ammo pickup.	
		
		--Shotguns begin here
		
		--Reinfeld, base for all shotguns, generalist horde-control weapon.
		self.r870.damage_near = 2000 
		self.r870.damage_far = 4000 --Overall range increased, compare to Loco's range
		
		self.r870.fire_mode_data = {
			fire_rate = 0.575
		}
		self.r870.single = {
			fire_rate = 0.575
		}
		
		self.r870.spread = {
			standing = 6
		}
		self.r870.spread.crouching = self.r870.spread.standing 
		self.r870.spread.steelsight = 3
		self.r870.spread.moving_standing = self.r870.spread.standing
		self.r870.spread.moving_crouching = self.r870.spread.standing
		self.r870.spread.moving_steelsight = self.r870.spread.steelsight
		
		self.r870.kick = {
			standing = {
				2.3,
				3,
				-0.7,
				0.7
			}
		}
		self.r870.kick.crouching = self.r870.kick.standing
		self.r870.kick.steelsight = {
			1.8,
			1.8,
			-0.5,
			0.5
		}
		self.r870.stats.spread = 12
		--self.r870.stats.spread_moving = 9
		self.r870.stats.recoil = 12
		self.r870.stats.damage = 106
		self.r870.AMMO_PICKUP = {3, 3} --If players are actively getting multi-kills, the net-gain will make up for any loss.
		
		--Locomotive, simple changes to make it comparable to a secondary r870, with less horde-control, but more single-target capabilities for things like slugs.
		self.serbu.spread.standing = self.r870.spread.standing 
		self.serbu.spread.crouching = self.r870.spread.standing
		self.serbu.spread.steelsight = self.r870.spread.steelsight 
		self.serbu.spread.moving_standing = self.r870.spread.standing
		self.serbu.spread.moving_crouching = self.r870.spread.standing 
		self.serbu.spread.moving_steelsight = self.r870.spread.steelsight
		self.serbu.kick.standing = self.r870.kick.standing
		self.serbu.kick.crouching = self.r870.kick.standing
		self.serbu.kick.steelsight = self.r870.kick.steelsight
		self.serbu.stats.spread = 18
		--self.serbu.stats.spread_moving = 17
		self.serbu.stats.recoil = 8
		self.serbu.stats.damage = 106
		self.serbu.AMMO_PICKUP = {2, 2}
		
		--Snipers begin here
		
		--Platypus, base for all sniper rifles, little to no changes needed.
		self.model70.AMMO_PICKUP = {3, 3} --Stabilized ammo pickup, no more randomness, higher than vanilla, snipers struggle aplenty with enemy control in Hyper Heisting, and I want them to at the very least, have stable sustenance.
		
		
		--Pistols begin here
		
		--Chimano 88, base for all pistols, low-risk-low-reward, ok-damage but...it's a pistol.
		self.glock_17.fire_mode_data = {
			fire_rate = 0.08
		}
		self.glock_17.single = {
			fire_rate = 0.08
		}
		self.glock_17.kick.standing = {
			0.8,
			1.2,
			-0.5,
			0.5
		}
		self.glock_17.kick.crouching = {
			0.8,
			1,
			-0.25,
			0.25
		}
		self.glock_17.kick.steelsight = {
			0.8,
			0.8,
			-0.25,
			0.25
		}
		self.glock_17.stats.spread = 21
		self.glock_17.stats.spread_moving = 20
		self.glock_17.stats.recoil = 19
		self.glock_17.stats.damage = 59
		self.glock_17.AMMO_PICKUP = {6, 6} --Compare to vanilla 1-5 chance, self-sustainable.
		
		
		--Specials begin here
	
	end	
	
end)
