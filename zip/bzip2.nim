when defined(windows):
  const libbz2 = "bzip2.dll"
elif defined(macosx):
  const libbz2 = "libbz2.dylib"
else:
  const libbz2 = "libbz2.so.1"

type
  Pbytef* = cstring
  Bz2File* = pointer

proc bz2libVersion*(): cstring {.cdecl, dynlib: libbz2,
  importc: "BZ2_bzlibVersion".}

proc bz2open*(path: cstring, mode: cstring): Bz2File {.cdecl, dynlib: libbz2,
  importc: "BZ2_bzopen".}

proc bz2read*(thefile: Bz2File, buf: pointer, length: int): int32 {.cdecl,
  dynlib: libbz2, importc: "BZ2_bzread".}

proc bz2close*(thefile: Bz2File): int32 {.cdecl, dynlib: libbz2,
  importc: "BZ2_bzclose".}

proc bz2error*(thefile: Bz2File, errnum: var int32): Pbytef {.cdecl,
  dynlib: libbz2, importc: "BZ2_bzerror".}
