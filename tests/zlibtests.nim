import unittest
import ../zip/zlib

test "test stream compression":
    let text = "The quick brown fox jumps over the lazy dog"
    # generated from text with python3.6 zlib module
    # import zlib                       #         GZIP   | ZLIB | RAW
    # z = zlib.compressobj(wbits=WBITS) # WBITS = (16+15 | 15   | -15 )
    # print repr(z.compress(t)+z.flush())
    let raw_deflate = "\x0b\xc9HU(,\xcdL\xceVH*\xca/\xcfSH\xcb\xafP\xc8*\xcd-(V\xc8/K-R(\x01J\xe7$VU*\xa4\xe4\xa7\x03\x00"
    let gzip_deflate = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\x03\x0b\xc9HU(,\xcdL\xceVH*\xca/\xcfSH\xcb\xafP\xc8*\xcd-(V\xc8/K-R(\x01J\xe7$VU*\xa4\xe4\xa7\x03\x009\xa3OA+\x00\x00\x00"
    let zlib_deflate = "x\x9c\x0b\xc9HU(,\xcdL\xceVH*\xca/\xcfSH\xcb\xafP\xc8*\xcd-(V\xc8/K-R(\x01J\xe7$VU*\xa4\xe4\xa7\x03\x00[\xdc\x0f\xda"

    check uncompress(compress(text)) == text
    check uncompress(compress(text, stream=RAW_DEFLATE), stream=RAW_DEFLATE) == text
    check uncompress(compress(text, stream=ZLIB_STREAM), stream=ZLIB_STREAM) == text
    check uncompress(compress(text, stream=GZIP_STREAM), stream=GZIP_STREAM) == text
    check uncompress(compress(text, stream=ZLIB_STREAM), stream=DETECT_STREAM) == text
    check uncompress(compress(text, stream=GZIP_STREAM), stream=DETECT_STREAM) == text
    check compress(text, stream=RAW_DEFLATE) == raw_deflate
    check compress(text, stream=GZIP_STREAM) == gzip_deflate
    check compress(text, stream=ZLIB_STREAM) == zlib_deflate
