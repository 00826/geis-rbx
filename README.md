# geis-rbx

| <img src="./icon.png" width="161"> | "oh, to optimize things that dont really need to be optimized" <br><br> IPA: /ɡɛʃ/ ...is an idiosyncratic taboo, whether of obligation or prohibition, similar to being under a vow or curse, yet the observance of which can also bring power and blessings. <br><br> *an extremely straightforward open-source function benchmarking project with a simple single-table interface*|
|-|:-|

geis-rbx is a standalone repository used in the open-source Roblox place: https://www.roblox.com/games/17449910945/

---

## about

geis-rbx uses **[Jobs.luau](./src/Jobs/init.luau)**, a single-table interface for simplicity and fast benchmarking, and is outlined by the `JobTable` luau type:

```lua
--- game/StarterGui/Geis/Jobs

export type JobTable = {
	Header: string; -- histogram header
	Work: { [string]: () -> () }; -- table of functions to benchmark {[Name]: fn}
	RefreshRate: number; -- histogram refresh rate
	Cycles: number; -- # of data points to draw the histogram
}
```

the linked game is a sandboxed version of the default Baseplate, stripped of unnecessary instances, default scripts, and settings that might skew benchmark results during runtime

within the Studio place is a `Toolbox` folder `(game/ReplicatedStorage/Toolbox)`, which is meant to house developer-made instances for easy referencing/access should any benchmark require them

- by default, the Toolbox contains a `BasePart` and `R6`/`R15` rigs

---

## benchmarking

- functions are timed using `os.clock()` every `RunService.RenderStep`
- times are stored in a first-in, first-out queue
<br><br>
- results are represented as a histogram, partitioned by percentiles of 10
- histogram intervals are represented in microseconds (μs)
- the x-bounds of the histogram are defined as `[0, max(functionTimes)]`
- the y-bounds of the histogram are defined as `[0, max(functionFrequencies)]`

---

## example usage & result

https://github.com/00826/geis-rbx/assets/61893206/df575758-229c-4002-a0f4-9cb8ecb89cae

> [!WARNING]
> because work functions are bound to `RunService.RenderStep`, benchmarking will only work in Play (F5) mode

```lua
---a JobTable benchmarking different ways to arrive at Vector3 (0, 0, 0)
{
	Header			= "99 ways to Vector3(0, 0, 0)";

	Work			= {
		["Vector3.zero"] = function()
			return Vector3.zero
		end;
		["Vector3.new(0, 0, 0)"] = function()
			return Vector3.new(0, 0, 0)
		end;
		["Vector3.one - Vector3.one"] = function()
			return Vector3.one - Vector3.one
		end;
	};

	RefreshRate		= 1 / 15;
	Cycles			= 5000;
}
```
