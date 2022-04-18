--dirty, fixes a crash with joining mid-heist

core:module("CoreSequenceManager")

function ObjectElement.load(unit, data)
	if alive(unit) then
		for name, sub_data in pairs(data) do
			for func_name, values in pairs(sub_data) do
				local obj = unit:get_object(values[1])
				
				if obj and alive(obj) then
					obj[func_name](obj, values[2])
				end
			end
		end
	end
end