
Import("lua/print_r.lua")
Import("lua/util.lua")

plattform = "linux";

function ValidiateArg(arg, value)
	if arg == "conf" then
		if conf ~= "debug" and conf ~= "release" then
			error("Invalid value for argument 'conf': '"..value.."'. Valid values are 'debug' and 'release'")
		end
	elseif arg == "dir" then
		
	end
	-- arch
end

function GenerateLibSettings(settings, name)
	Import("lib/" .. name .. "/" .. name .. ".lua")
	lib:configure()
	lib:apply(settings)
end

function GenerateGenerelSettings(settings)
	if conf == "debug" then
		settings.debug = 1
		settings.optimize = 0
	elseif conf == "release" then
		settings.debug = 0
		settings.optimize = 1
	end

	settings.cc.flags:Add("-Wall")
	settings.cc.flags_cxx:Add("--std=c++14")
	settings.cc.includes:Add("src")
	settings.cc.Output = function(settings, input)
		input = input:gsub("^src/", "")
		return PathJoin(PathJoin(build_dir, "obj"), PathBase(input))
	end
	settings.link.Output = function(settings, input)
		return PathJoin(build_dir, PathBase(input))
	end
end

function GenerateClientSettings(settings)
	GenerateLibSettings(settings, "freetype")
	GenerateLibSettings(settings, "sfml")
end

function GenerateTestSettings(settings, dir)
	settings.cc.includes:Add(dir)
	settings.cc.Output = function(settings, input)
		return PathJoin(PathJoin(build_dir, "obj"), PathBase(input))
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
datadst_dir = "data"

settings = NewSettings()
GenerateGenerelSettings(settings)

srcs = CollectRecursive(src_dir .. "/*.cpp")
shared_srcs = TableDeepCopy(srcs)
RemoveFromTableContaining(shared_srcs, {"/server/", "/client/"})
client_srcs = TableDeepCopy(srcs)
RemoveFromTableMissing(client_srcs, "/client/")
server_srcs = TableDeepCopy(srcs)
RemoveFromTableMissing(server_srcs, "/server/")

shared_objs = Compile(settings, shared_srcs)

PseudoTarget("server")
server_objs = Compile(settings, server_srcs)
server_exe = Link(settings, "resize_srv", TableFlatten({shared_objs, server_objs}))
AddDependency("server", server_exe)

GenerateClientSettings(settings)

PseudoTarget("client")
client_objs = Compile(settings, client_srcs)
client_exe = Link(settings, "resize", TableFlatten({shared_objs, client_objs}))
AddDependency("client", client_exe)

objs = TableFlatten({shared_objs, server_objs, client_objs})

PseudoTarget("data")
do
	local data_files = CollectRecursive(datasrc_dir .. "/")
	for i, file in pairs(data_files) do
		local target = file:gsub("^" .. datasrc_dir .. "/", "")
		target = PathJoin(PathJoin(build_dir, datadst_dir), target)
		AddJob(target, file .. " > " .. target , "cp " .. file .. " " .. target)
		AddDependency(target, file)
		AddDependency("data", target)
	end
end

PseudoTarget("test")
do
	local test_objs = TableDeepCopy(objs)
	RemoveFromTableContaining(test_objs, "/main.o$")
	local test_dirs = CollectDirs("test/*")
	for i, dir in pairs(test_dirs) do
		local settings = TableDeepCopy(settings)
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
