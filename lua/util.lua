function RemoveFromTable(t, f)
	local index = 1
	local size = #t
	while index <= size do
		if f(t[index]) then
			t[index] = t[size]
			t[size] = nil
			size = size - 1
		else
			index = index + 1
		end
	end
end

function RemoveFromTableContaining(t, re)
	re = TableFlatten({re})
	RemoveFromTable(t, function(element)
		for k, v in pairs(re) do
			if element:match(v) then
				return true
			end
		end

		return false
	end)
end

function RemoveFromTableMissing(t, re)
	re = TableFlatten({re})
	RemoveFromTable(t, function(element)
		for k, v in pairs(re) do
			if not element:match(v) then
				return true
			end
		end

		return false
	end)
end
