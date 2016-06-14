lib = {
	path = PathDir(ModuleFilename()),
	use_ftconfig = false,
	use_installed = false,
}

function lib:configure()
	if ExecuteSilent("freetype-config --cflags") == 0 then
		self.use_ftconfig = true
	elseif ExecuteSilent("ldconfig -p | grep 'freetype'") then
		use_installed = true
	else
		print("FreeType: Couldn't find binaries on system. Trying to link local binaries in " .. self.path .. "/lib")
	end
end

function lib:apply(settings)
	if self.use_ftconfig then
		settings.cc.flags:Add("`freetype-config --cflags`")
		settings.link.flags:Add("`freetype-config --libs`")
	elseif self.use_installed then
		settings.cc.includes:Add("/usr/include")
	else
		settings.cc.includes:Add(self.path .. "/include")
		settings.link.libpath:Add(self.path .. "/lib")
		settings.link.libs:Add("freetype")
	end
end
