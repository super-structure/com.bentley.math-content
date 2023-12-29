# Using MathJax Node

Usage would ideally just be: `mathjax:mml2svg(`*`mml node`*`)`

Prefer to do this _without_ write/read operations; just passing strings in memory. Unfortunately, this presents the following issues:

- Java expects strings as UTF-16, where as most DITA content is going to be in UTF-8
- Command line arguments using unicode characters are problematic at best and would be unreliable on different platforms. And math content is goign to have _a lot_ of such characters
- Stripping out whitespace and having to swap out single & double quotes are additional hassles that will trade off at least _some_ of the RW operations.

Need to strip out line breaks and extra whitespace in MML; replace double quotes in attributes with single quotes.

MathJax-Node does not seem to care if there is a namespace used for MML or not.

Possible approach:
1) write out mathml to local file in temp
2) pass filename to jar file (can we pass as string?)
3) return unparsed SVG text
4) parse as XML
5) post-process SVG for FO (won't hurt to do this for all transtypes); convert 'ex' dims to 'em' dims.

Ref: [https://stackoverflow.com/questions/53741778/cannot-generate-svg-using-mathjax-node-on-sample](https://stackoverflow.com/questions/53741778/cannot-generate-svg-using-mathjax-node-on-sample)

Command line:
```
node mj-test.js > mj-test.svg
```

## Compiling Java into Jar file
* [Java Jar 'Hello World' example](https://github.com/macagua/example.java.helloworld)

Command line compile Java:
```
javac MathJaxNode/CmdTest.java
java -cp . MathJaxNode.CmdTest
jar cfm CmdTest.jar MathJaxNode.CmdTest MathJaxNode/CmdTest.class
java -jar CmdTest.jar simple.mml
```

## Node.js
* [Command line arguments for Node](https://www.digitalocean.com/community/tutorials/nodejs-command-line-arguments-node-scripts)

* [read in a file in Node.js](https://stackoverflow.com/questions/9168737/read-a-text-file-using-node-js)

* [MathJax Node data output](https://github.com/mathjax/MathJax-node#promiseresolveresultoptions--promiserejecterrors--callbackresult-options)

## Java

* [Java Process Builder Tutorials](https://www.baeldung.com/java-lang-processbuilder-api)

* [Java pass command line arguments](https://stackoverflow.com/questions/8123058/passing-on-command-line-arguments-to-runnable-jar/8123262#8123262)

* [Writing Extension Functions in Java](http://cafeconleche.org/books/xmljava/chapters/ch17s03.html)

* [Saxon: Integrated Extension Functions](https://www.saxonica.com/html/documentation10/extensibility/integratedfunctions/index.html)

* [Microsoft: Java for Beginners](https://learn.microsoft.com/en-us/shows/java-for-beginners/)