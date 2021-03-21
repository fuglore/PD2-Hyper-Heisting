local bad_table = {
	MutatorHydra = true
}

function MutatorsManager:can_enable_mutator(mutator)
	if bad_table[mutator:id()] then
		return false
	end
	
	for _, imutator in ipairs(self:mutators()) do
		if imutator:id() ~= mutator:id() and imutator:is_enabled() and imutator:is_incompatible_with(mutator) then
			return false, imutator
		end
	end

	return true
end