import os
import bzip2
import streams
export streams

## This module implements a bzip2file stream for reading.

type
  Bz2FileStream* = ref object of Stream
    mode: FileMode
    f: Bz2File

proc fsClose(s: Stream) =
  if not Bz2FileStream(s).f.isNil:
    discard bz2close(Bz2FileStream(s).f)
    Bz2FileStream(s).f = nil

proc fsReadData(s: Stream, buffer: pointer, bufLen: int): int =
  result = bz2read(Bz2FileStream(s).f, buffer, bufLen).int
  if result == -1:
    raise newException(IOError, "cannot read from stream!")

proc newBz2FileStream*(filename: string, mode=fmRead): Bz2FileStream =
  ## Opens a Bz2file as a file stream. `mode` can only be ``fmRead``.
  new(result)
  case mode
  of fmRead: result.f = bz2open(filename, "rb")
  else: raise newException(IOError, "unsupported file mode '" & $mode &
                          "' for Bz2FileStream!")
  if result.f.isNil:
    let err = osLastError()
    if err != OSErrorCode(0'i32):
      raiseOSError(err)

  result.mode = mode
  result.closeImpl = fsClose
  result.readDataImpl = fsReadData
