import unittest
import ../zip/zlib

test "test stream compression":
    let text = "The quick brown fox jumps over the lazy dog"
    check( uncompress(compress(text)) == text)
