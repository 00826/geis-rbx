---returns a histogram, partitioned by percentiles of (P or 10)
return function(SortedTimes: {number}, MaxTime: number?, P: number?): {number}
	local Len = #SortedTimes
	local Partitions = (P or 10)
	local Hist = table.create(Partitions, 0)

	if Len == 0 then
		return Hist
	end

	local Interval = (MaxTime or SortedTimes[#SortedTimes]) / Partitions

	for i = 1, Partitions do
		local IntervalMax = i * Interval
		
		local ThisTime = nil

		repeat
			ThisTime = table.remove(SortedTimes, 1)
			if not ThisTime then break end

			if ThisTime > IntervalMax then
				table.insert(SortedTimes, 1, ThisTime)
			else
				Hist[i] += 1
			end
		until (ThisTime >= IntervalMax)
	end

	return Hist, Interval
end