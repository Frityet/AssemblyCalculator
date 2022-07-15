add_rules("mode.debug", "mode.release")

target("AsmCalculator")
do
	set_kind("binary")
	add_files("src/**.asm")
	add_ldflags("-static", "-nostdlib", "-e START", { force = true })
	add_includedirs("src")
end
target_end()
