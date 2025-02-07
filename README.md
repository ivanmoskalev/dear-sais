# DearSAIS
> this library is part of [dear](https://github.com/ivanmoskalev/dear) suite

Swift implementation of the SA-IS algorithm for building suffix arrays in `O(n)` (as compared to naive `O(n × log(n)`). The library exposes an API for constructing suffix arrays from either textual (`String`) or binary (`[UInt8]`) data.

Suffix arrays are mostly used in data compression, and especially for calculating binary diff patches in update systems.

The code has been ported into idiomatic Swift from [Chromium's implementation](https://github.com/chromium/chromium/blob/7c222671e7164bd6b726ef1d8d6e73403ad72559/components/zucchini/suffix_array.h#L35).

I wrote this library for my upcoming implementation of the bsdiff-like compression, which will in turn power low-footprint over-the-air dictionary updates in [my electronic dictionary app](https://apps.apple.com/en/app/id1598891664).

## Installation

DearSAIS is distributed via Swift Package Manager.

```swift
.package(url: "https://github.com/ivanmoskalev/DearSAIS.git", from: "1.0.0")
```

## Contributing

Please note that contributions are accepted if they align with the vision for the library. Please open an issue first to discuss proposed changes. 

## License

This project (and the rest of the dear suite) is released into the public domain under [The Unlicense](https://unlicense.org/). Do whatever you want with it however you want.
