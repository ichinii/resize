
Import("lua/print_r.lua")
Import("lua/util.lua")

function ValidiateArg(arg, value)
	if arg == "conf" then
		if conf ~= "debug" and conf ~= "release" then
			error("Invalid value for argument 'conf': '"..value.."'. Valid values are 'debug' and 'release'")
		end
	elseif arg == "dir" then
		
	end
end

function GenerateGlobalSettings(settings)
	if conf == "debug" then
		settings.debug = 1
	elseif conf == "release" then
		settings.debug = 0
		settings.optimize = 1
	end
end

function GenerateBuildSettings(settings)
	GenerateGlobalSettings(settings)
	settings.cc.includes:Add("src")
	settings.cc.Output = function(settings, input)
		input = input:gsub("^src/", "")
		return PathJoin(PathJoin(build_dir, "obj"), PathBase(input))
	end
	settings.link.Output = function(settings, input)
		return PathJoin(build_dir, PathBase(input))
	end
end

function GenerateTestSettings(settings, dir)
	GenerateGlobalSettings(settings)
	settings.cc.includes:Add("src")
	settings.cc.includes:Add(dir)
	settings.cc.Output = function(settings, input)
		return PathJoin(PathJoin(build_dir, "objs"), PathBase(input))
	end
	settings.link.Output = function(settings, input)
		return PathJoin(build_dir, "test_" .. PathBase(input))
	end
end

if ScriptArgs["conf"] then
	conf = ScriptArgs["conf"]
else
	conf = "debug"
end
ValidiateArg("conf", conf)

if ScriptArgs["dir"] then
	build_dir = ScriptArgs["dir"]
else
	build_dir = "build"
end
ValidiateArg("dir", build_dir)
build_dir = PathJoin(build_dir, conf)

src_dir = "src"
datasrc_dir = "datasrc"


settings = NewSettings()
GenerateBuildSettings(settings)

srcs = CollectRecursive(src_dir .. "/*.cpp")
objs = Compile(settings, srcs)

PseudoTarget("client")
do
	local client_objs = TableDeepCopy(objs)
	for k, v in pairs(client_objs) do
		if(v:match("server/")) then
			table.remove(client_objs, k)
		end
	end
	local exe = Link(settings, "resize", client_objs)
	AddDependency("client", exe)
end

PseudoTarget("server")
do
	local server_objs = TableDeepCopy(objs)
	for k, v in pairs(server_objs) do
		if(v:match("client/")) then
			table.remove(server_objs, k)
		end
	end
	local exe = Link(settings, "resize_srv", server_objs)
	AddDependency("server", exe)
end

PseudoTarget("data")
do
	local data_files = CollectRecursive(datasrc_dir .. "/")
	for i, file in pairs(data_files) do
		local target = PathJoin(PathJoin(build_dir, "data"), file)
		AddJob(target, file .. " > " .. target , "cp " .. file .. " " .. target)
		AddDependency(target, file)
		AddDependency("data", target)
	end
end

PseudoTarget("test")
do
	local test_objs = TableDeepCopy(objs)
	RemoveFromTable(test_objs, function(v)
		return v:match("main.o")
	end)
	local test_dirs = CollectDirs("test/*")
	for i, dir in pairs(test_dirs) do
		GenerateTestSettings(settings, dir)
		local this_test_srcs = CollectRecursive(dir .. "/*.cpp")
		local this_test_objs = Compile(settings, this_test_srcs)
		local this_test_exe = Link(settings, PathFilename(dir), TableFlatten({test_objs, this_test_objs}))

		PseudoTarget(dir, this_test_exe)
		AddDependency("test", dir)
	end
end

PseudoTarget("all", "client", "data", "test")
PseudoTarget("game", "client", "data")
DefaultTarget("game")
