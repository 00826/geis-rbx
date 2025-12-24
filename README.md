# geis-rbxㅤ/ɡɛʃ/

a benchmarking tool that won't run you a wendys biggie bag

## about

|ico.png|lore|
|-|-|
| <img src="./icon.png" width="96"> |"to optimize things that don't really need to be optimized"<br/><br/>*geis* is an idiosyncratic taboo, whether of obligation or prohibition, similar to being under a vow or curse, yet the observance of which can also bring power and blessings.|

## interfacing

the benchmark can be interfaced from [params.luau](./params.luau), typed as:

```lua
type params = {
	functions: {[string]: () -> ()}; --- function table
	runtime: number; --- time that each function is tested
	percentiles: {number}; --- percentiles to include in summary
	printtext: boolean; --- print text in output when calling `receipt()`

	results: {}; --- {[keyof<functions>]: typeof(geis.interpret(...))}
}
```

## usage

results are presented as plain text for portability

```lua
--- workspace:QueryDescendants(), workspace:GetChildren() vs 1000 folders

print(geis.receipt(geis.run( { ... } )))

--- [1] 'querydescendants' (samples: 7168) (runtime: 60s) (units: μs):
--- ---
--- min: 22.90
--- max: 197.20
--- median: 36.20
--- ---
--- P95avg: 134.08
--- P99avg: 156.83
--- ---
--- histogram: [0 4672 1730 128 65 244 212 92 19 6] (interval: 19.72)

--- [2] 'getchildren' (samples: 7291) (runtime: 60s) (units: μs):
--- ---
--- min: 69.50
--- max: 319.20
--- median: 85.00
--- ---
--- P95avg: 206.79
--- P99avg: 242.77
--- ---
--- histogram: [0 0 4176 1833 650 352 231 30 13 6] (interval: 31.92)
```

---

geis-rbx by 00826 / overflowed
