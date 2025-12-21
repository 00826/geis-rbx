--!strict

--- ### geis.luauㅤ/ɡɛʃ/
---
--- benchmarking tool
local geis = {}

--- runs benchmark against `params`
--- returns `params`, with results 
function geis.run(params: {
	functions: {[string]: () -> ()}; --- function table
	percentiles: {number}; --- percentiles to include in summary
	runtime: number; --- time that each function is tested
	printtext: boolean; --- print text in output when calling `receipt()`

	results: {}; --- {[keyof<functions>]: typeof(geis.interpret(...))}
})
	local timetables = {}
	local runtime = params.runtime
	
	--- run test
	for key, f in params.functions do
		timetables[key] = {}
		local times = timetables[key]
		local elapsed = 0
		local function frame()
			local start = os.clock()

			f()

			local finish = os.clock()
			table.insert(times, (finish - start) * 1000000) --- s to μs
		end

		print(string.format("[geis-run]: benchmarking '%s' (runtime: %ds)", key, runtime))

		repeat
			elapsed += task.wait()
			frame()
		until elapsed > runtime

		print(string.format("[geis-run]: benchmarked '%s' (time: %.2fs) (samples: %d)", key, elapsed, #times), times)
	end

	--- sort tables
	table.clear(params.results) --- in case same table gets re-used
	for key, times in timetables do
		table.sort(times)

		params.results[key] = geis.interpret(times, params.percentiles, 10)
	end

	return params
end

--- returns: \
--- `{stats stats}` a table of stats from array of sorted-by-ascending times `t`
function geis.interpret(t: {number}, percentiles: {number}, histogramslices: number)
	--- min max
	local min = t[1]
	local max = t[#t]

	--- median
	local len = #t
	local midpoint = len // 2
	local median = 0
	if len > 1 then
		if len % 2 == 0 then
			median = 0.5 * (t[midpoint] + t[midpoint + 1])
		else
			median = t[midpoint]
		end
	else
		median = t[1]
	end

	--- histogram
	local histogram = table.create(histogramslices, 0)

	local interval = t[len] / histogramslices
	local minoffset = 1

	for slice = 1, histogramslices do
		local ceil = slice * interval

		for j = minoffset, #t, 1 do
			local time = t[j]
			if time > ceil then
				minoffset = j

				break
			else
				histogram[slice] += 1
			end
		end
	end

	--- percentiles
	local pcts = table.create(#percentiles)
	for i, percentile in ipairs(percentiles) do
		--- ```
		--- [0          ...          1]
		--- [  | <- floor             ] (100 - 90)
		---    ^  table.move() range  ^
		--- ```
		--- find % to cut
		local floor = math.floor(len * (percentile / 100)) --- {95, 99}

		local p = table.create(len - floor)
		table.move(t, floor, #t, 1, p)
		local sum = 0
		for j, time in ipairs(p) do
			sum += time
		end

		local percentileaverage = sum / #p

		table.insert(pcts, string.format("P%davg: %.2f", percentile, percentileaverage))
	end
	
	return {
		samples = len;
		min = min;
		max = max;
		median = median;
		percentiles = pcts;
		histogram = histogram;
		histograminterval = interval;
	}
end

--- returns \
--- `{[string]: {text: string; value: typeof(geis.interpret(...)}} receipt` table describing benchmark results
function geis.receipt(params: typeof(geis.run(...)))
	local receipt = {}
	local i = 0
	for k, v: typeof(geis.interpret({}, {}, 0)) in params.results::any do
		i += 1

		local istring = string.format(
			"\n[%d] '%s' (samples: %d) (runtime: %ds) (units: μs):\n---\nmin: %.2f\nmax: %.2f\nmedian: %.2f\n---\n%s\n---\nhistogram: [%s] (interval: %.2f)",
			i,
			k,
			v.samples,
			params.runtime,
			v.min,
			v.max,
			v.median,
			table.concat(v.percentiles, "\n"),
			table.concat(v.histogram, " "),
			v.histograminterval
		)

		if params.printtext == true then
			print(istring)
		end

		receipt[k] = {
			text = istring;
			value = v;
		}
	end

	return receipt
end

return geis