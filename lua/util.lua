function RemoveFromTable(t, f)
	local index = 1
	local size = #t
	while index <= size do
		if f(t[index]) then
			t[index] = t[size]
			t[size] = nil
			size = size - 1
		else index = index + 1
		end
	end
end
