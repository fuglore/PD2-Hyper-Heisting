local mvec3_n_equal = mvector3.not_equal
local mvec3_set = mvector3.set
local mvec3_set_st = mvector3.set_static
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_div = mvector3.divide
local mvec3_lerp = mvector3.lerp
local mvec3_cpy = mvector3.copy
local mvec3_set_l = mvector3.set_length
local mvec3_dot = mvector3.dot
local mvec3_cross = mvector3.cross
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_rot = mvector3.rotate_with
local math_abs = math.abs
local math_max = math.max
local math_clamp = math.clamp
local math_ceil = math.ceil
local math_floor = math.floor
local math_up = math.UP
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
NavigationManager = NavigationManager or class()
NavigationManager.nav_states = {
	"allow_access",
	"forbid_access",
	"forbid_custom"
}
NavigationManager.nav_meta_operations = {
	"force_civ_submission",
	"relieve_forced_civ_submission"
}
NavigationManager.COVER_RESERVED = 4
NavigationManager.COVER_RESERVATION = 5
NavigationManager.ACCESS_FLAGS_VERSION = 1
NavigationManager.ACCESS_FLAGS = {
	"civ_male",
	"civ_female",
	"gangster",
	"security",
	"security_patrol",
	"cop",
	"fbi",
	"swat",
	"murky",
	"sniper",
	"spooc",
	"shield",
	"tank",
	"taser",
	"teamAI1",
	"teamAI2",
	"teamAI3",
	"teamAI4",
	"SO_ID1",
	"SO_ID2",
	"SO_ID3",
	"pistol",
	"rifle",
	"ntl",
	"hos",
	"run",
	"fumble",
	"sprint",
	"crawl",
	"climb"
}
NavigationManager.ACCESS_FLAGS_OLD = {}

function NavigationManager:draw_coarse_path(path, alt_color)
	if not path then
		return
	end
	
	local all_nav_segs = self._nav_segments
	
	local line1 = Draw:brush(Color.red:with_alpha(0.5), 5)
	local line2 = Draw:brush(Color.blue:with_alpha(0.5), 5)
	
	if alt_color then
		for path_i = 1, #path do
			local seg_pos = all_nav_segs[path[path_i][1]].pos
			line2:cylinder(seg_pos, seg_pos + math_up * 185, 20)
		end
	else
		for path_i = 1, #path do
			local seg_pos = all_nav_segs[path[path_i][1]].pos
			line1:cylinder(seg_pos, seg_pos + math_up * 185, 20)
		end
	end
end

function NavigationManager:shorten_coarse_through_dis(path)
	do return path end
	
	local i = 1
	local all_nav_segs = self._nav_segments
	local done = nil
	
	--log("indexes before: " .. tostring(#path) .. "")
	--local line1 = Draw:brush(Color.red:with_alpha(0.5), 5)
	
	while not done do 
		if path[i + 1] and i + 1 < #path then
			local i_seg_pos_1 = all_nav_segs[path[i][1]].pos
			local i_seg_pos_2 = all_nav_segs[path[i + 1][1]].pos
			
			if math_abs(i_seg_pos_1.z - i_seg_pos_2.z) < 185 then 
				local travel_dis = mvec3_dis(i_seg_pos_1, i_seg_pos_2)
				
				if travel_dis < 800 then
					local new_path = {}
					
					for path_i = 1, #path do
						if path_i ~= i + 1	then
							new_path[#new_path + 1] = path[path_i]
						end
					end
					path = deep_clone(new_path)			
				elseif math_abs(i_seg_pos_1.z - i_seg_pos_2.z) < 93 then 
					local ray_params = {
						allow_entry = false,
						pos_from = i_seg_pos_1,
						pos_to = i_seg_pos_2
					}

					if not self:raycast(ray_params) then
						local new_path = {}
						--line1:cylinder(i_seg_pos_2, i_seg_pos_2 + math_up * 185, 20)
						for path_i = 1, #path do
							if path_i ~= i + 1	then
								new_path[#new_path + 1] = path[path_i]
							end
						end
						path = deep_clone(new_path)
					end
				end
			end
			
			i = i + 1
		else
			done = true
		end
	end
	
	--log("indexes after: " .. tostring(#path) .. "")
	
	--local line2 = Draw:brush(Color.blue:with_alpha(0.5), 5)
	
	--for path_i = 1, #path do
	--	local seg_pos = all_nav_segs[path[path_i][1]].pos
	--	line2:cylinder(seg_pos, seg_pos + math_up * 185, 20)
	--end
	
	return path
end

function NavigationManager:search_coarse(params)
	local pos_to, start_i_seg, end_i_seg, access_pos, access_neg = nil

	if params.from_seg then
		start_i_seg = params.from_seg
	elseif params.from_tracker then
		start_i_seg = params.from_tracker:nav_segment()
	end

	if params.to_seg then
		end_i_seg = params.to_seg
	elseif params.to_tracker then
		end_i_seg = params.to_tracker:nav_segment()
	end

	pos_to = params.to_pos or self._nav_segments[end_i_seg].pos

	if start_i_seg == end_i_seg then
		if params.results_clbk then
			params.results_clbk({
				{
					start_i_seg
				},
				{
					end_i_seg,
					mvec3_cpy(pos_to)
				}
			})

			return
		else
			return {
				{
					start_i_seg
				},
				{
					end_i_seg,
					mvec3_cpy(pos_to)
				}
			}
		end
	end

	if type_name(params.access_pos) == "table" then
		access_pos = self._quad_field:convert_access_filter_to_number(params.access_pos)
	elseif type_name(params.access_pos) == "string" then
		access_pos = self._quad_field:convert_nav_link_flag_to_bitmask(params.access_pos)
	else
		access_pos = params.access_pos
	end

	if params.access_neg then
		access_neg = self._quad_field:convert_nav_link_flag_to_bitmask(params.access_neg)
	else
		access_neg = 0
	end

	local new_search_data = {
		id = params.id,
		long_path = params.long_path,
		to_pos = mvec3_cpy(pos_to),
		start_i_seg = start_i_seg,
		end_i_seg = end_i_seg,
		seg_searched = {},
		discovered_seg = {
			[start_i_seg] = true
		},
		seg_to_search = {
			{
				i_seg = start_i_seg
			}
		},
		results_callback = params.results_clbk,
		verify_clbk = params.verify_clbk,
		access_pos = access_pos,
		access_neg = access_neg
	}

	if params.results_clbk then
		table.insert(self._coarse_searches, new_search_data)
	else
		local result = self:_execute_coarce_search(new_search_data)

		return result
	end
end

function NavigationManager:_execute_coarce_search(search_data)
	local search_id = search_data.id
	local i = 0

	while true do
		if i == 500 then
			log("endless")

			return false
		else
			i = i + 1
		end

		local next_search_seg = search_data.seg_to_search[#search_data.seg_to_search]
		local next_search_i_seg = next_search_seg.i_seg

		table.remove(search_data.seg_to_search)

		local all_nav_segments = self._nav_segments
		local neighbours = all_nav_segments[next_search_i_seg].neighbours

		if neighbours[search_data.end_i_seg] then
			local entry_found = nil

			for _, i_door in ipairs(neighbours[search_data.end_i_seg]) do
				if type(i_door) == "number" then
					entry_found = true

					break
				elseif i_door:delay_time() < TimerManager:game():time() and i_door:check_access(search_data.access_pos, search_data.access_neg) then
					entry_found = true

					break
				end
			end

			if entry_found then
				local i_seg = next_search_i_seg
				local this_seg = next_search_seg
				local prev_seg = search_data.end_i_seg
				local path = {
					{
						search_data.end_i_seg,
						search_data.to_pos
					}
				}

				table.insert(path, 1, {
					next_search_i_seg,
					next_search_seg.pos
				})

				local searched = search_data.seg_searched

				while this_seg.from do
					i_seg = this_seg.from
					this_seg = searched[i_seg]

					table.insert(path, 1, {
						i_seg,
						this_seg.pos
					})
				end

				return path
			end
		end

		local to_pos = search_data.to_pos
		local new_segments = self:_sort_nav_segs_after_pos(to_pos, next_search_i_seg, search_data.discovered_seg, search_data.verify_clbk, search_data.access_pos, search_data.access_neg, search_data.long_path)

		if new_segments then
			if search_data.access_pos then
				for i_seg, data in pairs(new_segments) do
					if self._quad_field:is_nav_segment_blocked(i_seg, search_data.access_pos) then
						new_segments[i_seg] = nil
					end
				end
			end

			local to_search = search_data.seg_to_search

			for i_seg, seg_data in pairs(new_segments) do
				local new_seg_weight = seg_data.weight
				local search_index = #to_search
				if search_data.long_path then
					local weight_mul = math.lerp(1, 2, math.random())
				
					new_seg_weight = new_seg_weight * weight_mul
					while search_index > 0 and to_search[search_index].weight > new_seg_weight do
						search_index = search_index - 1
					end
				else
					while search_index > 0 and to_search[search_index].weight < new_seg_weight do
						search_index = search_index - 1
					end
				end

				table.insert(to_search, search_index + 1, seg_data)
			end
		end

		local nr_seg_to_search = #search_data.seg_to_search

		if nr_seg_to_search == 0 then
			return false
		else
			search_data.seg_searched[next_search_i_seg] = next_search_seg
		end
	end
end

function NavigationManager:_sort_nav_segs_after_pos(to_pos, i_seg, ignore_seg, verify_clbk, access_pos, access_neg, long_path)
	local all_segs = self._nav_segments
	local all_doors = self._room_doors
	local all_rooms = self._rooms
	local seg = all_segs[i_seg]
	local neighbours = seg.neighbours
	local found_segs = nil

	for neighbour_seg_id, door_list in pairs(neighbours) do
		if not ignore_seg[neighbour_seg_id] and not all_segs[neighbour_seg_id].disabled and (not verify_clbk or verify_clbk(neighbour_seg_id)) then
			for i = 1, #door_list do
				local i_door = door_list[i]
				
				if type(i_door) == "number" then
					local door = all_doors[i_door]
					local door_pos = door.center
					local weight = mvec3_dis_sq(door_pos, to_pos)

					if found_segs then
						if found_segs[neighbour_seg_id] then
							if long_path and weight > found_segs[neighbour_seg_id].weight or weight < found_segs[neighbour_seg_id].weight then
								found_segs[neighbour_seg_id] = {
									weight = weight,
									from = i_seg,
									i_seg = neighbour_seg_id,
									pos = door_pos
								}
							end
						else
							found_segs[neighbour_seg_id] = {
								weight = weight,
								from = i_seg,
								i_seg = neighbour_seg_id,
								pos = door_pos
							}
							ignore_seg[neighbour_seg_id] = true
						end
					else
						found_segs = {
							[neighbour_seg_id] = {
								weight = weight,
								from = i_seg,
								i_seg = neighbour_seg_id,
								pos = door_pos
							}
						}
						ignore_seg[neighbour_seg_id] = true
					end
				elseif not alive(i_door) then
					debug_pause("[NavigationManager:_sort_nav_segs_after_pos] dead nav_link! between NavSegments", i_seg, "-", neighbour_seg_id)
				elseif not i_door:is_obstructed() and i_door:delay_time() < TimerManager:game():time() and i_door:check_access(access_pos, access_neg) then
					local end_pos = i_door:script_data().element:nav_link_end_pos()
					local my_weight = mvec3_dis_sq(end_pos, to_pos)

					if found_segs then
						if found_segs[neighbour_seg_id] then
							if long_path and my_weight > found_segs[neighbour_seg_id].weight or my_weight < found_segs[neighbour_seg_id].weight then
								found_segs[neighbour_seg_id] = {
									weight = my_weight,
									from = i_seg,
									i_seg = neighbour_seg_id,
									pos = end_pos
								}
							end
						else
							found_segs[neighbour_seg_id] = {
								weight = my_weight,
								from = i_seg,
								i_seg = neighbour_seg_id,
								pos = end_pos
							}
							ignore_seg[neighbour_seg_id] = true
						end
					else
						found_segs = {
							[neighbour_seg_id] = {
								weight = my_weight,
								from = i_seg,
								i_seg = neighbour_seg_id,
								pos = end_pos
							}
						}
						ignore_seg[neighbour_seg_id] = true
					end
				end
			end
		end
	end

	return found_segs
end
