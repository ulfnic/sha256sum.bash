# sha256sum.bash

Credit to Josh Junon (josh@junon.me) <github.com/qix-> for the [original](https://gist.github.com/Qix-/eaa6b90f4f50a9aefc66c4f871e8f1e0) implementation of producing SHA256 checksums with BASH.

Produce a SHA256 checksum with `od` and pure BASH as an executable or sourced script.

Supported by and tested against all release versions of BASH 3.0+ (2004 onward)

```bash
printf '%s' 'test of a SHA256 checksum' | sha256sum.bash
# stdout: 70b65f3c616222691d9898573377eec90cc03f1e4768f0fffd4c93d4c194821c
```

## Examples of Use

```bash
cat /path/to/file | sha256sum.bash
```
```bash
source /path/to/sha256sum.bash
# sha256sum.bash becomes a function
cat /path/to/file | sha256sum.bash
```

## Dependencies

```
od    # Commonly pre-installed on unix-like systems
```

## Improvements

Multiple iterations of performance enhancements achieving a ~20x improvement in speed primarily through the elimination of subshells and without sacrificing version support.

## License

Licensed under Creative Commons, CC0 1.0 Universal. See LICENSE for details.



