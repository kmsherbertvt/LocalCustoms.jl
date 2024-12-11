# LocalCustoms

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://kmsherbertvt.github.io/LocalCustoms.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://kmsherbertvt.github.io/LocalCustoms.jl/dev/)
[![Build Status](https://github.com/kmsherbertvt/LocalCustoms.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/kmsherbertvt/LocalCustoms.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/kmsherbertvt/LocalCustoms.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/kmsherbertvt/LocalCustoms.jl)

This package makes it just a little easier and aesthetically pleasing
    to share names between namespaces in a robust and easily-traceable way.

For example,
```
module AnExamplePackage
    module AnExampleModule
        const AN_EXAMPLE_NAME
    end

    using LocalCustoms
    @local_ export AnExampleModule: AN_EXAMPLE_NAME
end
```

In order for this to be worthy of the Julia registry:
- Add support for the `as` keyword.
- Add support for . nodes amongst the names.