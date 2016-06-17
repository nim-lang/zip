import os, osproc, unittest, ../zip/zipfiles

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

