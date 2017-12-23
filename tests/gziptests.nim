import ../zip/gzipfiles

proc readAllAndClose(f: Stream): string =
    shallowCopy result, f.readAll()
    f.close()

proc main() =
    # reference text data
    let text = newFileStream("files/gzipfiletest.txt").readAllAndClose()
    # reference GZIP archive (made with GNU gzip on linux x64)
    let arch_gz = newGzFileStream("files/gzipfiletest.txt.gz").readAllAndClose()

    doAssert(arch_gz == text)

    # write data to a new archive.
    block:
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

    # readall from new archive & check that data is corrupted.
    let new_data = newGzFileStream("files/gzipfiletest.data.gz").readAllAndClose()
    doAssert(new_data == text)

    # read from archive and write to new archive.
    block:
        let s = newGzFileStream("files/gzipfiletest.data.gz")
        let w = newGzFileStream("files/gzipfiletest.data2.gz", fmWrite)
        var buffer: array[32, uint8] # chunk_size
        while true:
            let bytes = s.readData(buffer[0].addr, buffer.len)
            # do something
            w.writeData(buffer[0].addr, bytes)
            if bytes < buffer.len:
                break
        s.close()
        w.close()
main()
