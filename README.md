# zip
Wrapper for the zip library

## Usage
zip

``` Nim
import zip/zipfiles
# Opens a zip file for reading, writing or appending.
var z: ZipArchive
  if not z.open(filename):
    echo "Opening zip failed"
    quit(1)

# extracts all files from archive z to the destination directory.
z.extractAll("files/td")
```
read and write using Stream

``` Nim
import zip/zipfiles
import streams
var z: ZipArchive
# add new file
z.open(filename, fmWrite)
z.addFile("foo.bar", newStringStream("content"))

# read file to string stream
z.open(filename, fmRead)
let outStream = newStringStream("")
z.extractFile("foo.bar", outStream)
```
load archive from memory

``` Nim
var z: ZipArchive
z.fromBuffer(archiveData)
```

zlib
``` Nim
import zip/zlib
uncompress(compress(text, stream=RAW_DEFLATE), stream=RAW_DEFLATE)
uncompress(compress(text, stream=ZLIB_STREAM), stream=ZLIB_STREAM)
uncompress(compress(text, stream=GZIP_STREAM), stream=GZIP_STREAM)
uncompress(compress(text, stream=ZLIB_STREAM), stream=DETECT_STREAM)
uncompress(compress(text, stream=GZIP_STREAM), stream=DETECT_STREAM)
compress(text, stream=RAW_DEFLATE)
compress(text, stream=GZIP_STREAM)
compress(text, stream=ZLIB_STREAM)
```

gzip
``` Nim
import zip/gzipfiles
# read text data
let arch_gz = newGzFileStream("files/gzipfiletest.txt.gz").readAllAndClose()

```

read from archive and write to new archive.

``` Nim
let w = newGzFileStream("files/gzipfiletest.data.gz", fmWrite)
let chunk_size = 32
var num_bytes = text.len
var idx = 0
while true:
  w.writeData(text[idx].unsafeAddr, min(num_bytes, chunk_size))
  if num_bytes < chunk_size:
    break
  dec(num_bytes, chunk_size)
  inc(idx, chunk_size)
w.close()
```

read line by line confirming that behavior of atEnd is consistent with standard FileStream

``` Nim
let gzfs = newGzFileStream("files/gzipfiletest.txt.gz")
  while not gzfs.atEnd():
    discard gzfs.readLine()
```
