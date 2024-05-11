# geis-rbx

| <img src="./icon.png" width="161"> | "oh, to optimize things that dont really need to be optimized" <br><br> IPA: /ɡɛʃ/ ...is an idiosyncratic taboo, whether of obligation or prohibition, similar to being under a vow or curse, yet the observance of which can also bring power and blessings. <br><br> *an extremely straightforward open-source function benchmarking project with a simple single-table interface*|
|-|:-|

geis-rbx is a standalone repository used in the open-source Roblox place: https://www.roblox.com/games/17449910945/

the linked game is a sandboxed version of the default "Baseplate" place, stripped of unnecessary instances and settings that might skew benchmark results during runtime.

---

## about geis:

the **[Jobs.luau](./src/Jobs/init.luau)** file is the table-interface which serves as a blank slate to interact with the benchmarking timer, and uses the `JobTable` luau type:

```lua
export type JobTable = {
	Header: string; -- display header of job
	SortBy: ("Server"|"ServerP"|"Client"|"ClientP")?; -- sort by speed in ascending order (default: "Server")
	Size: number; -- size of times to sample from
	P: number; -- latency-time constant, usually 90, 95, or 99
	Work: { { Name: string, F: () -> () } }; -- array of work-tables to benchmark
}
```

... within the Roblox place there is a `Toolbox` folder, which by default contains a `BasePart`, an `R6` rig and an `R15` rig for convenience, and is meant to house developer-made instances for easy referencing/access should any benchmark require them

benchmark results are timed using `os.clock()` and are represented as microseconds (μs)

---

## using geis:

commented-out of the `.Work` array is a work-table template with fields `Name` and `F`. `Name` is a string that describes the name of field `F` which is the function `() -> ()` that you want to benchmark. for example, the below `Jobs` table, which benchmarks the various ways to represent a zero-magnitude `Vector3`:
```lua
{
	Header = "zero vector3 benchmarking!";
	SortBy = "Server";
	Size = 10000;
	P = 95;

	Work = {
		{
			Name = "Vector3.zero";
			F = function()
				return Vector3.zero
			end;
		};
		{
			Name = "Vector3.new(0, 0, 0)";
			F = function()
				return Vector3.new(0, 0, 0)
			end;
		};
		{
			Name = "Vector3.one - Vector3.one";
			F = function()
				return Vector3.one - Vector3.one
			end;
		};
	};
}
```
> [ ! ] work-table names that contain capture pattern `"%d"` may not work nicely with the :gsub() call used to display benchmark results

... will yield the following result:

https://github.com/00826/geis-rbx/assets/61893206/4eabee45-1a5e-420c-9113-c9c2152e5b27
