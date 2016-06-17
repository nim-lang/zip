# Package

version       = "0.1.1"
author        = "Anonymous"
description   = "Wrapper for the zip library"
license       = "MIT"

# Dependencies

requires "nim >= 0.10.0"

task tests, "Run lib tests":
  withDir "tests":
    exec "nim c -r ziptests"