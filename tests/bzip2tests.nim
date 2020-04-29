import os, ../zip/bzip2files

proc readAllAndClose(f: Stream): string =
  doAssert(not f.isNil, "error opening stream")
  shallowCopy result, f.readAll()
  f.close()

const path = currentSourcePath().splitPath().head

proc main() =
  # reference text data
  let text = newFileStream(path / "files/gzipfiletest.txt").readAllAndClose()
  # reference BZIP2 archive (made with bzip2: stable 1.0.6 on OSX)
  let arch_bz2 = newBz2FileStream(path / "files/gzipfiletest.txt.bz2").readAllAndClose()

  doAssert(arch_bz2 == text)

main()
