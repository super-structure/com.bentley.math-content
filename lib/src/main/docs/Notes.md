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

## Saxonica Extensions

The following occurs when the entry in `net.sf.saxon.lib.ExtensionFunctionDefinition` cannot be located.

```
Initializing project
Error: Build failed with an exception: /Users/jason.coleman/DITA/DITA-OT/dita-ot-4.3.1/plugins/org.dita.base/build.xml:28: The following error occurred while executing this line:
/Users/jason.coleman/DITA/DITA-OT/dita-ot-4.3.1/plugins/org.dita.base/build_init.xml:95: java.util.ServiceConfigurationError: net.sf.saxon.lib.ExtensionFunctionDefinition: Provider com.bentely.mathml.svg.MathMLToSVGJEuclid not found
```