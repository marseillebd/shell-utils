# shld
Tools for "linking" shell scripts.
- [ ] a "file format" for shell libraries (really just some code style)
- [x] a "static shell linker" tool
- [ ] a "dynamic shell linker" (as a static library)

What I like about shell scripts is:
- shell (even bash) is fairly ubiquitous
- shell scripts are (preferrably) single-file:
  - just pop a single file on your `$PATH`, and you're ready to go
  - no runtime dependency resolution problems

There are some things I miss from more general-purpose languages, though:
- utility/helper libraries
- static analysis to check for errors
- literate code

This script plans to:
- [x] bundle libraries into your script
  - must keep line numbers intact for debugging purposes
  - [x] libraries are specified in a separate file
    - requirements file can be:
      - [x] custom text file
      - [ ] toml
      - [ ] yaml
      - [ ] json
    - libraries can be from:
      - [x] filepath
      - [ ] git
      - [ ] `SHLD_PATH`
      - [ ] url
  - your code should only define functions
  - [x] `cat` libraries into the bundled script
  - [x] call your `main` function
- [ ] preprocess markdown files into script files
  - [ ] tick-fenced code blocks
- [ ] run shellcheck on your script
- [ ] tries to statically analyze what commands the script depends on
- [ ] tries to check if your libraries match the library format
