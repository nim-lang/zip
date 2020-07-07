# Package

version       = "0.3.1"
author        = "Anonymous"
description   = "Wrapper for the zip library"
license       = "MIT"

skipDirs = @["tests"]

# Dependencies

requires "nim >= 0.10.0"

task tests, "Run lib tests":
  withDir "tests":
    exec "nim c -r ziptests"
    exec "nim c -r zlibtests"
    exec "nim c -r gziptests"

when defined(nimdistros) and not defined(useLibzipSrc):
  import distros
  if detectOs(MacOSX):
    foreignDep "libzip"
  else:
    foreignDep "libzip"
