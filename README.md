# llvm-cookbook

This cookbox contains a collection of snippets that I commonly use in my projects.  I am sharing not only because I think others might find this helpful but also:

- To record these snippets somewhere so I don't have to relearn what instructions I need in order to do something that I know I had done previously somewhere, and
- Hopefully allow others to spot naieve or ignorant snippets where there are far better ways to achieve the same outcome

Each of these snippets have a set of characteristics:

- They are focused,
- They are isolated,
- They are runnable, and
- They are trivial

As far as possible there is not clutter surrounding the snippet which might distract from the concept that is being illustrated.


## Building and Running

I have created a number of scripts contained within `./bin`.

| Name | Purpose |
|------|---------|
| `build-all.sh` | Runs all of the scripts in the correct sequence to populate `./build`. |
| `build-docs.sh` | Iterates through all of the `md` files in `./doc`, running embedded macros and places the result into `./build`. |
| `build-lib.sh` | This directory stores the boilerplate library code that allows the snippets to remain simple.  This script runs make in `./lib`.|
| `build-snippets.sh` | Iterates through all of the `.ll` snippets in `./snippets`, runs `llvm-as` against each file, links using `clang` and then runs the binary placing the output into a `.out` file.  These snippets and output results are embedded into the `md` content deposited into `./build` when `build-docs.sh` is run.
| `clean-all.sh` | Removes all of the temporary files except those that are contained in `./build`. |
