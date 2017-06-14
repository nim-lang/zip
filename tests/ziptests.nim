import os, osproc, streams, unittest, ../zip/zipfiles

const path = splitPath(currentSourcePath()).head & "/../zip/zipfiles"

test "can compile zipfiles":
  check execCmdEx("nim -o:./nimcache/zipfiles --nimcache:./nimcache c " &
    path).exitCode == QuitSuccess

test "zipfiles extractAll":
  var filename = "files/тест.xlsx"
  var z: ZipArchive
  if not z.open(filename):
    echo "Opening zip failed"
    quit(1)
  z.extractAll("files/td")
  z.close()
  check existsDir("files/td/xl/worksheets")
  check existsFile("files/td/xl/worksheets/sheet1.xml")

test "zipfiles read and write using Stream":
  let filename = getTempDir() / "zipfiles_test_archive.zip"
  defer: filename.removeFile

  var z: ZipArchive
  require z.open(filename, fmWrite)
  z.addFile("foo.bar", newStringStream("content"))
  z.close

  require filename.existsFile

  require z.open(filename, fmRead)
  let outStream = newStringStream("")
  z.extractFile("foo.bar", outStream)
  z.close()

  check: outStream.data == "content"
