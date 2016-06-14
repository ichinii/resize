lib = {
	path = PathDir(ModuleFilename()),
	use_installed = false,
}

function lib:configure()
	if ExecuteSilent("ldconfig -p | grep 'GLEW'") then
		use_installed = true
	else
		use_installed = false
	end
end

function lib:apply(settings)
	if self.use_installed then
		settings.cc.includes:Add("/usr/include")
	else
		settings.cc.includes:Add(self.path .. "/include")
		settings.link.libpath:Add(self.path .. "/lib")
	end
	settings.link.libs:Add("GL")
	settings.link.libs:Add("GLU")
	settings.link.libs:Add("GLEW")
end
