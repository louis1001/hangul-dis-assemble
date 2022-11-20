# HangulDisAssemble

A port of e-'s `hangul.js` library.
This is supposed to be a direct port. All the documentation can be found at the original repo: https://github.com/e-/Hangul.js

The differences in api will be described below.

- `Hangul.disassemble` was separated into `disassemble` and `disassembleGrouped`. The grouped version is the one that returns a list of lists of `String`, grouped by syllable. 
