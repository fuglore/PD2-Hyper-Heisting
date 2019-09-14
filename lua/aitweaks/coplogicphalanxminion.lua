function CopLogicPhalanxMinion._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local focus_enemy = data.attention_obj
	local in_combat = focus_enemy and focus_enemy.verified and focus_enemy.dis <= 3000
	local delay = in_combat and 0.35 or 1.05
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects)

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)
	data.logic._upd_aim(data, my_data)

	return delay
end