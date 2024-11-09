# CryptoKit<!-- omit in toc -->

- [1. HMAC](#1-hmac)
- [2. Generate hex string from `SHA256Digest`](#2-generate-hex-string-from-sha256digest)

## 1. HMAC

A hash-based message authentication algorithm.

Use hash-based message authentication to create a code with a value that’s dependent on both a block of data and a symmetric cryptographic key. Another party with access to the data and the same secret key can compute the code again and compare it to the original to detect whether the data changed.

This serves a purpose similar to digital signing and verification, but depends on a **shared symmetric key** instead of public-key cryptography.

**As with digital signing, the data isn’t hidden by this process.** When you need to encrypt the data as well as authenticate it, use a cipher like ``AES`` or ``ChaChaPoly`` to put the data into a sealed box (an instance of ``AES/GCM/SealedBox`` or ``ChaChaPoly/SealedBox``).

## 2. Generate hex string from `SHA256Digest`

Use `withUnsafeBytes()`:

```swift
public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R
```

- `R`: This is a generic type parameter that represents the return type of the closure `body`. It can be any type, allowing you to perform various operations on the raw bytes and return a result of any desired type.
- `UnsafeRawBufferPointer`: The body closure takes an `UnsafeRawBufferPointer` as input. This pointer provides direct access to the raw bytes of the underlying data.
- `Rethrows`: The `rethrows` keyword indicates that the function can rethrow any errors that might be thrown by the `body` closure.

**Example**:

```swift
let message = "Hello, world!"
let sha256Digest = SHA256.hash(data: Data(message.utf8))

let hexString = sha256Digest.withUnsafeBytes { bytes in
    bytes.map { byte in
        String(format: "%02x", byte)
    }
    .joined()
}

print(hexString) 
// Output: 315f5bdb76d078c43b8ac0064e4a0164612b1fce77c869345bfc94c75894edd3
```

This code snippet utilizes closures and functional programming techniques to convert a `SHA256.Digest` object into a *hexadecimal string* representation.

- `bytes` inside the closure: This represents an `UnsafeRawBufferPointer`. It provides temporary access to a contiguous block of memory containing the raw bytes of the digest data.
- `.map { byte in ... }`: This uses the map function on the bytes (`UnsafeRawBufferPointer`).
- `map` iterates over each `byte`(it's `UInt8` type) in the raw buffer and applies the provided closure to each byte individually.
- `%02x` formats the `byte` into a two-digit *hexadecimal string*, prepending a leading `0` if necessary.
- `joined` combines all the individual hexadecimal strings generated from each byte into a single, concatenated string.
