# Swift file type plugin for Vim

This is a [Vim][] file type plugin for the [Swift][] programming language.

[Vim]: http://www.vim.org
[Swift]: https://developer.apple.com/swift/

## Features

* Full syntax coloring for Swift (including support for folding).
* Helper commands for running Swift scripts and printing various compilation
  stages, including LLVM IR and assembly.
* Full support for compiling/running iOS scripts using the iOS Simulator.
* Supports multiple installations of Xcode.

See [`:help ft-swift`][swift.txt] for more details.

[swift.txt]: https://github.com/kballard/vim-swift/blob/master/doc/swift.txt

## Installation

Install this plugin with your Vim plugin manager of choice.

### [NeoBundle][]

[NeoBundle]: https://github.com/Shougo/neobundle.vim

Add the following to your `.vimrc`:

```vim
NeoBundle 'kballard/vim-swift', {
        \ 'filetypes': 'swift',
        \ 'unite_sources': ['swift/device', 'swift/developer_dir']
        \}
```

### [Pathogen][]

[Pathogen]: https://github.com/tpope/vim-pathogen

Run the following commands in your terminal:

```sh
cd ~/.vim/bundle
git clone https://github.com/kballard/vim-swift.git
```
