#
#
#            Nim's Runtime Library
#        (c) Copyright 2012 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

## This module implements a zip archive creator/reader/modifier.

import
  streams, libzip, times, os, strutils

const BufSize = 8 * 1024

type
  ZipArchive* = object of RootObj ## represents a zip archive
    mode: FileMode
    w: PZip
{.deprecated: [TZipArchive: ZipArchive].}

proc zipConvPath(path: string): string = 
  return path.replace(r"\", "/")

proc zipError(z: var ZipArchive) =
  var e: ref IOError
  new(e)
  e.msg = $zip_strerror(z.w)
  raise e

proc open*(z: var ZipArchive, filename: string, mode: FileMode = fmRead): bool =
  ## Opens a zip file for reading, writing or appending. All file modes are
  ## supported. Returns true iff successful, false otherwise.
  var err, flags: int32
  case mode
  of fmRead, fmReadWriteExisting, fmAppend: flags = 0
  of fmWrite:
    if existsFile(filename): removeFile(filename)
    flags = ZIP_CREATE or ZIP_EXCL
  of fmReadWrite: flags = ZIP_CREATE
  z.w = zip_open(filename, flags, addr(err))
  z.mode = mode
  result = z.w != nil

proc close*(z: var ZipArchive) =
  ## Closes a zip file.
  zip_close(z.w)

proc createDir*(z: var ZipArchive, dir: string) =
  ## Creates a directory within the `z` archive. This does not fail if the
  ## directory already exists. Note that for adding a file like
  ## ``"path1/path2/filename"`` it is not necessary
  ## to create the ``"path/path2"`` subdirectories - it will be done
  ## automatically by ``addFile``.
  assert(z.mode != fmRead)
  discard zip_add_dir(z.w, dir.zipConvPath)
  zip_error_clear(z.w)

proc removeFile*(z: var ZipArchive, file: string) =
    ## Removes file from zip archive.
    assert(z.mode != fmRead)
    var index = zip_name_locate(z.w, file.zipConvPath, ZIP_FL_NOCASE)
    if index < 0'i32:
      zipError(z)
    else:
      if zip_delete(z.w, index) < 0:
        zipError(z)

proc renameFile*(z: var ZipArchive, src, dest: string) =
    ## Renames or moves file in zip archive.
    assert(z.mode != fmRead)
    var index = zip_name_locate(z.w, src.zipConvPath, ZIP_FL_NOCASE)
    if index < 0'i32:
      zipError(z)
    else:
      if zip_rename(z.w, index, dest.zipConvPath) < 0:
        zipError(z)

proc addFile*(z: var ZipArchive, dest, src: string, deflate: bool = true, replace: bool = false) =
  ## Adds the file `src` to the archive `z` with the name `dest`. `dest`
  ## may contain a path that will be created.
  assert(z.mode != fmRead)
  var index = -1'i32
  if not fileExists(src):
    raise newException(IOError, "File '" & src & "' does not exist")
  let filePath = dest.zipConvPath
  var zipsrc = zip_source_file(z.w, src, 0, -1)
  if zipsrc == nil:
    zipError(z)

  if replace:
    index = zip_name_locate(z.w, filePath, ZIP_FL_NOCASE)
    if index < 0'i32:
      zip_source_free(zipsrc)
      zipError(z)
      return
    else:
      index = zip_replace(z.w, index, zipsrc)
  else:
    index = zip_add(z.w, filePath, zipsrc)
  if index < 0'i32:
    zip_source_free(zipsrc)
    zipError(z)
  if not deflate:
    if zip_set_file_compression(z.w, cast[uint64](index), ZIP_CM_STORE, 6) < 0:
      zip_source_free(zipsrc)
      zipError(z)

proc addFile*(z: var ZipArchive, file: string, deflate: bool = true, replace: bool = false) =
  ## A shortcut for ``addFile(z, file, file)``, i.e. the name of the source is
  ## the name of the destination.
  addFile(z, file, file, deflate, replace)

proc mySourceCallback(state, data: pointer, len: int,
                      cmd: ZipSourceCmd): int {.cdecl.} =
  var src = cast[Stream](state)
  case cmd
  of ZIP_SOURCE_OPEN:
    if src.setPositionImpl != nil: setPosition(src, 0) # reset
  of ZIP_SOURCE_READ:
    result = readData(src, data, len)
  of ZIP_SOURCE_CLOSE: close(src)
  of ZIP_SOURCE_STAT:
    var stat = cast[PZipStat](data)
    zip_stat_init(stat)
    stat.size = high(int32)-1 # we don't know the size
    stat.mtime = getTime()
    result = sizeof(ZipStat)
  of ZIP_SOURCE_ERROR:
    var err = cast[ptr array[0..1, cint]](data)
    err[0] = ZIP_ER_INTERNAL
    err[1] = 0
    result = 2*sizeof(cint)
  of constZIP_SOURCE_FREE: GC_unref(src)
  of ZIP_SOURCE_SUPPORTS:
    # By default a read-only source is supported, which suits us.
    result = -1
  else:
    # An unknown command, failing
    result = -1

proc addFile*(z: var ZipArchive, dest: string, src: Stream, deflate: bool = true, replace: bool = false) =
  ## Adds a file named with `dest` to the archive `z`. `dest`
  ## may contain a path. The file's content is read from the `src` stream.
  assert(z.mode != fmRead)
  GC_ref(src)
  var index = -1'i32
  var zipsrc = zip_source_function(z.w, mySourceCallback, cast[pointer](src))
  if zipsrc == nil: zipError(z)

  if replace:
    index = zip_name_locate(z.w, dest.zipConvPath, ZIP_FL_NOCASE)
    if index < 0'i32:
      zip_source_free(zipsrc)
      zipError(z)
      return
    else:
      index = zip_replace(z.w, index, zipsrc)
  else:
    if zip_add(z.w, dest.zipConvPath, zipsrc) < 0'i32:
      zip_source_free(zipsrc)
      zipError(z)
  if not deflate:
    if zip_set_file_compression(z.w, cast[uint64](index), ZIP_CM_STORE, 6) < 0:
      zip_source_free(zipsrc)
      zipError(z)

proc getArchiveComment*(z: var ZipArchive): string =
  ## Reads the comment from the archive ``z``.
  ## Throws a IOError exception if the comment cannot be read.
  let comm = zip_get_archive_comment(z.w, nil, 0)
  if comm == nil:
    raise newException(IOError, "Could not read the archive comment")
  result = $comm

proc setArchiveComment*(z: var ZipArchive, comm: string) =
  ## Sets the contents of the string ``comm`` as the archive ``z`` comment.
  assert(z.mode != fmRead)
  if comm.len > 65535:
    raise newException(IOError, "The comment string is too long (max 65535 bytes)")
  if zip_set_archive_comment(z.w, comm, int32(comm.len)) != 0:
    zipError(z)

# -------------- zip file stream ---------------------------------------------

type
  TZipFileStream = object of StreamObj
    f: PZipFile
    atEnd: bool

  PZipFileStream* =
    ref TZipFileStream ## a reader stream of a file within a zip archive

proc fsClose(s: Stream) = zip_fclose(PZipFileStream(s).f)
proc fsAtEnd(s: Stream): bool = PZipFileStream(s).atEnd
proc fsReadData(s: Stream, buffer: pointer, bufLen: int): int =
  result = zip_fread(PZipFileStream(s).f, buffer, bufLen)
  if result == 0:
    PZipFileStream(s).atEnd = true

proc newZipFileStream(f: PZipFile): PZipFileStream =
  new(result)
  result.f = f
  result.atEnd = false
  result.closeImpl = fsClose
  result.readDataImpl = fsReadData
  result.atEndImpl = fsAtEnd
  # other methods are nil!

# ----------------------------------------------------------------------------

proc getStream*(z: var ZipArchive, filename: string): PZipFileStream =
  ## returns a stream that can be used to read the file named `filename`
  ## from the archive `z`. Returns nil in case of an error.
  ## The returned stream does not support the `setPosition`, `getPosition`,
  ## `writeData` or `atEnd` methods.
  var x = zip_fopen(z.w, filename.zipConvPath, 0'i32)
  if x != nil: result = newZipFileStream(x)

iterator walkFiles*(z: var ZipArchive): string =
  ## walks over all files in the archive `z` and returns the filename
  ## (including the path).
  var i = 0'i32
  var num = zip_get_num_files(z.w)
  while i < num:
    yield $zip_get_name(z.w, i, 0'i32)
    inc(i)

proc extractFile*(z: var ZipArchive, srcFile: string, dest: Stream) =
  ## extracts a file from the zip archive `z` to the destination stream.
  var buf: array[BufSize, byte]
  var strm = getStream(z, srcFile.zipConvPath)
  while true:
    let bytesRead = strm.readData(addr(buf[0]), buf.len)
    if bytesRead <= 0: break
    dest.writeData(addr(buf[0]), bytesRead)

  dest.flush()
  strm.close()

proc extractFile*(z: var ZipArchive, srcFile: string, dest: string) =
  ## extracts a file from the zip archive `z` to the destination filename or directory.
  var filePath = if dest == "": "." else: dest.zipConvPath

  if filePath.endsWith("/"): 
    createDir(filePath)
    filePath = filePath & srcFile.extractFilename
  # file system will not accept directory and file of the same name
  if os.existsDir(filePath): filePath = filePath / srcFile.extractFilename

  var file = newFileStream(filePath, fmWrite)
  if file.isNil:
    raise newException(IOError, "Failed to create output file: " & filePath)
  extractFile(z, srcFile, file)
  file.close()

proc extractAll*(z: var ZipArchive, dest: string) =
  ## extracts all files from archive `z` to the destination directory.
  createDir(dest)
  let destPath = dest.zipConvPath
  for file in walkFiles(z):
    if file.endsWith("/"):
      createDir(destPath / file[0..file.rfind("/")])
    else:
      var (dir, filename, ext) = file.splitFile()
      createDir(destPath / dir)
      extractFile(z, file, destPath / file)

