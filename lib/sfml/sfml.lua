lib = {
	path = PathDir(ModuleFilename()),
	use_installed = true,
	--find_installed_cmd = "ldconfig -p | grep 'sfml-system.so$' | sed 's/[^\\/]*\\(\\/.*\\)\\/libsfml-system\\.so/\\1/'",
	find_installed_cmd = "ldconfig -p | grep 'sfml-system.so$' | sed 's/[^\\/]*\\(.*\\)libsfml-system\\.so/\\1/'",
}

function lib:configure()
	if ExecuteSilent(self.find_installed_cmd) == 0 then
		self.use_installed = true
	else
		print("SFML: Couldn't find binaries on system. Trying to link local binaries in " .. self.path .. "/lib")
		self.use_installed = false
	end
end

function lib:apply(settings)
	if self.use_installed then
		settings.cc.includes:Add("/usr/include")
		settings.link.libpath:Add("`" .. self.find_installed_cmd .. "`")
	else
		settings.cc.includes:Add(self.path .. "/include")
		settings.link.libpath:Add(self.path .. "/lib")
	end
	settings.link.libs:Add("sfml-system")
	settings.link.libs:Add("sfml-window")
end
