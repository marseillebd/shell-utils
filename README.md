Some utilities for writing shell scripts.
FIXME Actually, it looks like I have way too much stuff in here; I'll need to split a bunch out into another repo full of my gadgets

- [x] [shld](./shld/README.md):
    Allows linking shell libraries together, and has some very limited compilation ability.
    - [ ] TODO extract documentation from a shld library
- [ ] TODO terminal color library
- [ ] TODO pull in exectime, or a better timeout program
- [ ] TODO pull in gitstat
- [ ] TODO organize function in `todo.sh`

## Gadgets
FIXME These should be moved into a separate repository, I think.
Though, the line is blurry, so maybe they can stay if I'm primarily using them from the cli.

- [ ] TODO linters
    - [x] search for spdx license tags
    - [ ] add spdx license tags
    - [x] search for todo items
    - [ ] parse priorities from todo items and generate a md checklist
    - [ ] search system for git repos that have:
        - [ ] uncommitted/unpushed changes
        - [ ] unexpected author configs
    - [ ] haskell import lists
- [ ] TODO scan for the tools I want in my development environment 
- [ ] TODO literate (md) to un-literate (and perhaps backwards, too
- [ ] TODO user programs install
    - takes a file of `(bin|config|data) <source path>( as <target base name>)?`
    - makes appropriate links, according to [[XDG Base Directories]]

- [ ] FIXME lint-todo should be case-insensitive