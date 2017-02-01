# Converted from Pascal

## Interface to the zlib http://www.zlib.net/ compression library.

when defined(windows):
  const libz = "zlib1.dll"
elif defined(macosx):
  const libz = "libz.dylib"
else:
  const libz = "libz.so.1"

type
  Uint* = cuint
  Ulong* = culong
  Ulongf* = culong
  Pulongf* = ptr Ulongf
  ZOffT* = clong
  Pbyte* = cstring
  Pbytef* = cstring
  Allocfunc* = proc (p: pointer, items: Uint, size: Uint): pointer{.cdecl.}
  FreeFunc* = proc (p: pointer, address: pointer){.cdecl.}
  InternalState*{.final, pure.} = object 
  PInternalState* = ptr InternalState
  ZStream*{.final, pure.} = object 
    nextIn*: Pbytef
    availIn*: Uint
    totalIn*: Ulong
    nextOut*: Pbytef
    availOut*: Uint
    totalOut*: Ulong
    msg*: Pbytef
    state*: PInternalState
    zalloc*: Allocfunc
    zfree*: FreeFunc
    opaque*: pointer
    dataType*: cint
    adler*: Ulong
    reserved*: Ulong

  ZStreamRec* = ZStream
  PZstream* = ptr ZStream
  GzFile* = pointer
  ZStreamHeader* = enum
    DETECT_STREAM,
    RAW_DEFLATE,
    ZLIB_STREAM,
    GZIP_STREAM
{.deprecated: [TInternalState: InternalState, TAllocfunc: Allocfunc,
              TFreeFunc: FreeFunc, TZStream: ZStream, TZStreamRec: ZStreamRec].}

const 
  Z_NO_FLUSH* = 0
  Z_PARTIAL_FLUSH* = 1
  Z_SYNC_FLUSH* = 2
  Z_FULL_FLUSH* = 3
  Z_FINISH* = 4
  Z_OK* = 0
  Z_STREAM_END* = 1
  Z_NEED_DICT* = 2
  Z_ERRNO* = -1
  Z_STREAM_ERROR* = -2
  Z_DATA_ERROR* = -3
  Z_MEM_ERROR* = -4
  Z_BUF_ERROR* = -5
  Z_VERSION_ERROR* = -6
  Z_NO_COMPRESSION* = 0
  Z_BEST_SPEED* = 1
  Z_BEST_COMPRESSION* = 9
  Z_DEFAULT_COMPRESSION* = -1
  Z_FILTERED* = 1
  Z_HUFFMAN_ONLY* = 2
  Z_DEFAULT_STRATEGY* = 0
  Z_BINARY* = 0
  Z_ASCII* = 1
  Z_UNKNOWN* = 2
  Z_DEFLATED* = 8
  Z_NULL* = 0
  Z_MEM_LEVEL* = 8
  MAX_WBITS* = 15

proc zlibVersion*(): cstring{.cdecl, dynlib: libz, importc: "zlibVersion".}
proc deflate*(strm: var ZStream, flush: int32): int32{.cdecl, dynlib: libz, 
    importc: "deflate".}
proc deflateEnd*(strm: var ZStream): int32{.cdecl, dynlib: libz, 
    importc: "deflateEnd".}
proc inflate*(strm: var ZStream, flush: int32): int32{.cdecl, dynlib: libz, 
    importc: "inflate".}
proc inflateEnd*(strm: var ZStream): int32{.cdecl, dynlib: libz, 
    importc: "inflateEnd".}
proc deflateSetDictionary*(strm: var ZStream, dictionary: Pbytef, 
                           dictLength: Uint): int32{.cdecl, dynlib: libz, 
    importc: "deflateSetDictionary".}
proc deflateCopy*(dest, source: var ZStream): int32{.cdecl, dynlib: libz, 
    importc: "deflateCopy".}
proc deflateReset*(strm: var ZStream): int32{.cdecl, dynlib: libz, 
    importc: "deflateReset".}
proc deflateParams*(strm: var ZStream, level: int32, strategy: int32): int32{.
    cdecl, dynlib: libz, importc: "deflateParams".}
proc inflateSetDictionary*(strm: var ZStream, dictionary: Pbytef, 
                           dictLength: Uint): int32{.cdecl, dynlib: libz, 
    importc: "inflateSetDictionary".}
proc inflateSync*(strm: var ZStream): int32{.cdecl, dynlib: libz, 
    importc: "inflateSync".}
proc inflateReset*(strm: var ZStream): int32{.cdecl, dynlib: libz, 
    importc: "inflateReset".}
proc compress*(dest: Pbytef, destLen: Pulongf, source: Pbytef, sourceLen: Ulong): cint{.
    cdecl, dynlib: libz, importc: "compress".}
proc compress2*(dest: Pbytef, destLen: Pulongf, source: Pbytef, 
                sourceLen: Ulong, level: cint): cint{.cdecl, dynlib: libz, 
    importc: "compress2".}
proc uncompress*(dest: Pbytef, destLen: Pulongf, source: Pbytef, 
                 sourceLen: Ulong): cint{.cdecl, dynlib: libz, 
    importc: "uncompress".}
proc compressBound*(sourceLen: Ulong): Ulong {.cdecl, dynlib: libz, importc.}
proc gzopen*(path: cstring, mode: cstring): GzFile{.cdecl, dynlib: libz, 
    importc: "gzopen".}
proc gzdopen*(fd: int32, mode: cstring): GzFile{.cdecl, dynlib: libz, 
    importc: "gzdopen".}
proc gzsetparams*(thefile: GzFile, level: int32, strategy: int32): int32{.cdecl, 
    dynlib: libz, importc: "gzsetparams".}
proc gzread*(thefile: GzFile, buf: pointer, length: int): int32{.cdecl, 
    dynlib: libz, importc: "gzread".}
proc gzwrite*(thefile: GzFile, buf: pointer, length: int): int32{.cdecl, 
    dynlib: libz, importc: "gzwrite".}
proc gzprintf*(thefile: GzFile, format: Pbytef): int32{.varargs, cdecl, 
    dynlib: libz, importc: "gzprintf".}
proc gzputs*(thefile: GzFile, s: Pbytef): int32{.cdecl, dynlib: libz, 
    importc: "gzputs".}
proc gzgets*(thefile: GzFile, buf: Pbytef, length: int32): Pbytef{.cdecl, 
    dynlib: libz, importc: "gzgets".}
proc gzputc*(thefile: GzFile, c: char): char{.cdecl, dynlib: libz, 
    importc: "gzputc".}
proc gzgetc*(thefile: GzFile): char{.cdecl, dynlib: libz, importc: "gzgetc".}
proc gzflush*(thefile: GzFile, flush: int32): int32{.cdecl, dynlib: libz, 
    importc: "gzflush".}
proc gzseek*(thefile: GzFile, offset: ZOffT, whence: int32): ZOffT{.cdecl, 
    dynlib: libz, importc: "gzseek".}
proc gzrewind*(thefile: GzFile): int32{.cdecl, dynlib: libz, importc: "gzrewind".}
proc gztell*(thefile: GzFile): ZOffT{.cdecl, dynlib: libz, importc: "gztell".}
proc gzeof*(thefile: GzFile): int {.cdecl, dynlib: libz, importc: "gzeof".}
proc gzclose*(thefile: GzFile): int32{.cdecl, dynlib: libz, importc: "gzclose".}
proc gzerror*(thefile: GzFile, errnum: var int32): Pbytef{.cdecl, dynlib: libz, 
    importc: "gzerror".}
proc adler32*(adler: Ulong, buf: Pbytef, length: Uint): Ulong{.cdecl, 
    dynlib: libz, importc: "adler32".}
  ## **Warning**: Adler-32 requires at least a few hundred bytes to get rolling.
proc crc32*(crc: Ulong, buf: Pbytef, length: Uint): Ulong{.cdecl, dynlib: libz, 
    importc: "crc32".}
proc deflateInitu*(strm: var ZStream, level: int32, version: cstring, 
                   streamSize: int32): int32{.cdecl, dynlib: libz, 
    importc: "deflateInit_".}
proc inflateInitu*(strm: var ZStream, version: cstring,
                   streamSize: int32): int32 {.
    cdecl, dynlib: libz, importc: "inflateInit_".}
proc deflateInit*(strm: var ZStream, level: int32): int32
proc inflateInit*(strm: var ZStream): int32
proc deflateInit2u*(strm: var ZStream, level: int32, `method`: int32, 
                    windowBits: int32, memLevel: int32, strategy: int32, 
                    version: cstring, streamSize: int32): int32 {.cdecl, 
                    dynlib: libz, importc: "deflateInit2_".}
proc inflateInit2u*(strm: var ZStream, windowBits: int32, version: cstring, 
                    streamSize: int32): int32{.cdecl, dynlib: libz, 
    importc: "inflateInit2_".}
proc deflateInit2*(strm: var ZStream, 
                   level, `method`, windowBits, memLevel,
                   strategy: int32): int32
proc inflateInit2*(strm: var ZStream, windowBits: int32): int32
proc zError*(err: int32): cstring{.cdecl, dynlib: libz, importc: "zError".}
proc inflateSyncPoint*(z: PZstream): int32{.cdecl, dynlib: libz, 
    importc: "inflateSyncPoint".}
proc getCrcTable*(): pointer{.cdecl, dynlib: libz, importc: "get_crc_table".}

proc deflateBound*(strm: var ZStream, sourceLen: ULong): ULong {.cdecl,
        dynlib: libz, importc: "deflateBound".}

proc deflateInit(strm: var ZStream, level: int32): int32 = 
  result = deflateInitu(strm, level, zlibVersion(), sizeof(ZStream).cint)

proc inflateInit(strm: var ZStream): int32 = 
  result = inflateInitu(strm, zlibVersion(), sizeof(ZStream).cint)

proc deflateInit2(strm: var ZStream, 
                  level, `method`, windowBits, memLevel,
                  strategy: int32): int32 = 
  result = deflateInit2u(strm, level, `method`, windowBits, memLevel, 
                         strategy, zlibVersion(), sizeof(ZStream).cint)

proc inflateInit2(strm: var ZStream, windowBits: int32): int32 = 
  result = inflateInit2u(strm, windowBits, zlibVersion(), 
                         sizeof(ZStream).cint)

proc zlibAllocMem*(appData: pointer, items, size: int): pointer {.cdecl.} = 
  result = alloc(items * size)

proc zlibFreeMem*(appData, `block`: pointer) {.cdecl.} = 
  dealloc(`block`)


proc compress*(sourceBuf: cstring; sourceLen: int; level=Z_DEFAULT_COMPRESSION; stream=GZIP_STREAM): string =
  ## Given a cstring, returns its deflated version with an optional header.
  ## Valid argument for ``stream`` are:
  ##  ZLIB_STREAM - add a zlib header and footer.
  ##  GZIP_STREAM - add a basic gzip header and footer.
  ##  RAW_DEFLATE - no header is generated.
  ##
  ## Passing a nil cstring will crash this proc in release mode and assert in
  ## debug mode.
  ##
  ## Compression level can be set with ``level`` argument. Currently
  ## ``Z_DEFAULT_COMPRESSION`` is 6.
  ##
  ## Returns nil on failure.
  var z: ZStream

  var windowBits = MAX_WBITS
  case (stream)
  of RAW_DEFLATE: windowBits = -MAX_WBITS
  of GZIP_STREAM: windowBits = MAX_WBITS + 16
  of ZLIB_STREAM, DETECT_STREAM:
    discard # DETECT_STREAM defaults to ZLIB_STREAM

  var status = deflateInit2(z, level.int32, Z_DEFLATED.int32,
                               windowBits.int32, Z_MEM_LEVEL.int32,
                               Z_DEFAULT_STRATEGY.int32)

  if status != Z_OK:
    # Out of memory.
    return

  let space = deflateBound(z, sourceLen.Uint)

  var compressed = newStringOfCap(space)
  z.next_in = sourceBuf
  z.avail_in = sourceLen.Uint
  z.next_out = addr(compressed[0])
  z.avail_out = space.Uint

  defer: discard deflateEnd(z)

  status = deflate(z, Z_FINISH)

  if status != Z_STREAM_END:
    # Incomplete stream.
    return

  compressed.setLen(z.total_out)
  swap(result, compressed)

proc compress*(sourceBuf: string; level=Z_DEFAULT_COMPRESSION; stream=GZIP_STREAM): string =
  ## Given a string, returns its deflated version with an optional header.
  ## Valid argument for ``stream`` are:
  ##  ZLIB_STREAM - add a zlib header and footer.
  ##  GZIP_STREAM - add a basic gzip header and footer.
  ##  RAW_DEFLATE - no header is generated.
  ##
  ## Passing a nil string will crash this proc in release mode and assert in
  ## debug mode.
  ##
  ## Compression level can be set with ``level`` argument. Currently
  ## ``Z_DEFAULT_COMPRESSION`` is 6.
  ##
  ## Returns nil on failure.
  result = compress(sourceBuf, sourceBuf.len, level, stream)

proc uncompress*(sourceBuf: cstring, sourceLen: int; stream=DETECT_STREAM): string =
  ## Given a deflated buffer returns its inflated content as a string.
  ##
  ## Passing a nil cstring will crash this proc in release mode and assert in
  ## debug mode.
  ##
  ## Returns nil on problems. Failure is a very loose concept, it could be you
  ## passing a non deflated string, or it could mean not having enough memory
  ## for the inflated version.
  ##
  ## The uncompression algorithm is based on
  ## http://stackoverflow.com/questions/17820664 but does ignore some of the
  ## original signed/unsigned checks, so may fail with big chunks of data
  ## exceeding the positive size of an int32. The algorithm can deal with
  ## concatenated deflated values properly.
  assert (not sourceBuf.isNil)

  var z: ZStream
  # Initialize input.
  z.nextIn = sourceBuf

  # Input left to decompress.
  var left = zlib.Uint(sourceLen)
  if left < 1:
    # Incomplete gzip stream, or overflow?
    return

  # Create starting space for output (guess double the input size, will grow if
  # needed -- in an extreme case, could end up needing more than 1000 times the
  # input size)
  var space = zlib.Uint(left shl 1)
  if space < left:
    space = left

  var decompressed = newStringOfCap(space)

  # Initialize output.
  z.nextOut = addr(decompressed[0])
  # Output generated so far.
  var have = 0


  var windowBits = MAX_WBITS
  case (stream)
  of RAW_DEFLATE: windowBits = -MAX_WBITS
  of ZLIB_STREAM: windowBits = MAX_WBITS
  of GZIP_STREAM: windowBits = MAX_WBITS + 16
  of DETECT_STREAM: windowBits = MAX_WBITS + 32

  z.availIn = 0;
  var status = inflateInit2(z, windowBits.int32)
  if status != Z_OK:
    # Out of memory.
    return

  # Make sure memory allocated by inflateInit2() is freed eventually.
  defer: discard inflateEnd(z)

  # Decompress all of self.
  while true:
    # Allow for concatenated gzip streams (per RFC 1952).
    if status == Z_STREAM_END:
      discard inflateReset(z)

    # Provide input for inflate.
    if z.availIn == 0:
      # This only makes sense in the C version using unsigned values.
      z.availIn = left
      left -= z.availIn

    # Decompress the available input.
    while true:
      # Allocate more output space if none left.
      if int(space) == have:
        decompressed.setLen(space)
        # Double space, handle overflow.
        space = space shl 1
        if int(space) < have:
          # Space was likely already maxed out.
          discard inflateEnd(z)
          return

        # Increase space.
        decompressed.setLen(space)
        # Update output pointer (might have moved).
        z.nextOut = addr(decompressed[have])

      # Provide output space for inflate.
      z.availOut = zlib.Uint(int(space) - have)
      have += int(z.availOut)

      # Inflate and update the decompressed size.
      status = inflate(z, Z_SYNC_FLUSH)
      have -= int(z.availOut)

      # Bail out if any errors.
      if status != Z_OK and status != Z_BUF_ERROR and status != Z_STREAM_END:
        # Invalid gzip stream.
        discard inflateEnd(z)
        return

      # Repeat until all output is generated from provided input (note
      # that even if z.avail_in is zero, there may still be pending
      # output -- we're not done until the output buffer isn't filled)
      if z.availOut != 0:
        break
    # Continue until all input consumed.
    if left == 0 and z.availIn == 0:
      break

  # Verify that the input is a valid gzip stream.
  if status != Z_STREAM_END:
    # Incomplete stream.
    return

  decompressed.setLen(have)
  swap(result, decompressed)


proc uncompress*(sourceBuf: string; stream=DETECT_STREAM): string =
  ## Given a GZIP-ed string return its inflated content.
  ## Passing a nil string will crash this proc in release mode and assert in
  ## debug mode.
  ##
  ## Returns nil on failure.
  result = uncompress(sourceBuf, sourceBuf.len, stream)



proc deflate*(buffer: var string; level=Z_DEFAULT_COMPRESSION; stream=GZIP_STREAM): bool {.discardable.} =
  ## Convenience proc which deflates a string and insert an optional header/footer.
  ## Valid argument for ``stream`` are:
  ##   - ZLIB_STREAM - add a zlib header and footer.
  ##   - GZIP_STREAM - add a basic gzip header and footer.
  ##   - RAW_DEFLATE - no header is generated.
  ##
  ## Passing a nil string will crash this proc in release mode and assert in
  ## debug mode.
  ##
  ## Compression level can be set with ``level`` argument. Currently
  ## ``Z_DEFAULT_COMPRESSION`` is 6.
  ##
  ## Returns true if `buffer` was successfully deflated otherwise the buffer is untouched.
  assert(not buffer.isNil)
  if buffer.len < 1: return
  var temp = compress(addr(buffer[0]), buffer.len, level, stream)
  if not temp.isNil:
    swap(buffer, temp)
    result = true

proc inflate*(buffer: var string; stream=DETECT_STREAM): bool {.discardable.} =
  ## Convenience proc which inflates a string containing compressed data
  ## with an optional header.
  ##  Valid argument for ``stream`` are:
  ##   - DETECT_STREAM - detect if zlib or gzip header is present
  ##                      and decompress stream. Fail on raw deflate stream.
  ##   - ZLIB_STREAM - decompress a zlib stream.
  ##   - GZIP_STREAM - decompress a gzip stream.
  ##   - RAW_DEFLATE - decompress a raw deflate stream.
  ##
  ## Passing a nil string will crash this proc in release mode and assert in
  ## debug mode. It is ok to pass a buffer which doesn't contain deflated data,
  ## in this case the proc won't modify the buffer.
  ##
  ## Returns true if `buffer` was successfully inflated.
  assert (not buffer.isNil)
  if buffer.len < 1: return
  var temp = uncompress(addr(buffer[0]), buffer.len, stream)
  if not temp.isNil:
    swap(buffer, temp)
    result = true
