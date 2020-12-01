local world_g = World

function TeamAIMovement:on_SPOOCed(enemy_unit)
	local push_vec = Vector3()
	local distance = mvector3.direction(push_vec, enemy_unit:movement():m_head_pos(), self._unit:movement():m_pos())
	mvector3.normalize(push_vec)
	mvector3.set_z(push_vec, 200)
	local attack_data = {
		attacker_unit = enemy_unit,
		is_cloaker_kick = true,
		melee_armor_piercing = true,
		damage = 400, --die
		pos = self._unit:movement():m_pos(),
		push_vel = push_vec * 2000
	}
	self._unit:character_damage():damage_melee(attack_data)
	
	return true
end

function TeamAIMovement:play_taser_boom()
	world_g:effect_manager():spawn({
		effect = Idstring("effects/pd2_mod_hh/particles/weapons/explosion/electric_explosion"),
		position = self._unit:movement():m_pos(),
		normal = math.UP
	})
	
	self._unit:sound():play("c4_explode_metal")
end

function TeamAIMovement:pre_destroy()
	--execute copmovement pre_destroy to ensure any changes to it also apply here
	--this is how it should've been done from the start
	TeamAIMovement.super.pre_destroy(self)

	if self._heat_listener_clbk then
		managers.groupai:state():remove_listener(self._heat_listener_clbk)

		self._heat_listener_clbk = nil
	end

	if self._switch_to_not_cool_clbk_id then
		managers.enemy:remove_delayed_clbk(self._switch_to_not_cool_clbk_id)

		self._switch_to_not_cool_clbk_id = nil
	end
end
