# Dev Notes

## Java 

Use [ProcessBuilder](https://stackoverflow.com/a/25735681)

## Node.js

Simple JavaScript program to call MathJax & pass the name of the temp .mml file.

## MathJax

SVG Config options: https://docs.mathjax.org/en/latest/options/output/svg.html

Post-processing resulting SVG:

- swap 'ex' for 'pt' (2x)
- remove root @role, @focusable
- change g/@data-mml-node to @class?
- remove use/@data-c
