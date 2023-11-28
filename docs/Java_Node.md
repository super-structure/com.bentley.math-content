# Using Custom Java Extension Class with Node.js

Ideally, the process of converting a `<m:math>` element to `<svg:svg>` would simply implemented a function within the XSL transform templates. Fortunately, this should be something accomplished using [Saxon extension functions](https://www.dita-ot.org/dev/topics/implement-saxon-extension-functions).

For example, using a function like: 
    `mathjax:mml2svg(`*`mml node`*`)`

**Note:** Saxon HE is the open-source (and free licensed) version of Saxon, which is the XSL / XPath parser included with the DITA Open Toolkit. [Saxon HE  v12.3](https://www.saxonica.com/html/documentation12/about/index.html) is included with DITA OT v4.1.1 and newer.

The basic principle here is as follows:

* Use the [Integrated extension function](https://www.saxonica.com/html/documentation9.8/extensibility/integratedfunctions/index.html) capability in Saxon HE to create a custom class which uses the `net.sf.saxon.lib.ExtensionFunctionDefinition` API.
* This Java class simply runs MathJax-Node via the command line and passes on the "input" MathML and returns the "output" SVG
* The Java class must be compiled into a JAR file and then [added to the DITA-OT class path](https://www.dita-ot.org/dev/topics/plugin-javalib) (via the `dita.conductor.lib.import` extension point).
* Java class calls MathJax-Node.js via the java.lang.ProcessBuilder API.
* May need to write to a temporary .mml file and then read this back in (write out to a temporary .svg file as well?). _Or_ is there some dom / xml  handling that can do a better job than just trying to pass MathML as a string?
* Prefer to do this _without_ write/read operations; just passing strings in memory. Unfortunately, this presents the following issues:
    - Java expects strings as UTF-16, where as most DITA content is going to be in UTF-8
    - Command line arguments using unicode characters are problematic at best and would be unreliable on different platforms. And math content is goign to have _a lot_ of such characters
    - Stripping out whitespace and having to swap out single & double quotes are additional hassles that will trade off at least _some_ of the RW operations.

## Structure

```

```

## Java Class

1. Compile the class for the package ( Reference:: [Java Compiler](https://docs.oracle.com/javase/8/docs/technotes/tools/windows/javac.html) )
    ````
    javac -cp "D:\DITA\DITA-OT_4.1.1_Dev\lib\Saxon-HE-12.3.jar"; TestPackage/TestClass.java
    javac -cp "D:\DITA\DITA-OT_4.1.1_Dev\lib\Saxon-HE-12.3.jar";"D:\DITA\DITA-OT_4.1.1_Dev\plugins\com.bentley.math-content\lib\jlatexmath-1.0.7.jar";"D:\DITA\DITA-OT_4.1.1_Dev\plugins\org.dita.pdf2.fop\lib\batik-all-1.16.jar"; com/oxygenxml/latex/svg/LatexToSVG.java
    ````    

   **Notes:**
    - Saxon-HE 11.4 (in Oxygen 25.1) can only use up to class file 61.0, which requires using [JDK version 17](https://javaalmanac.io/bytecode/versions/).
    - I am using [Microsoft OpenJDK v 17.0.9 LTS](https://learn.microsoft.com/en-us/java/openjdk/download#openjdk-17)
    - Can compile for older releases using [`--release 17`](https://docs.oracle.com/en/java/javase/17/docs/specs/man/javac.html#option-release)
    - In Windows, the resource jar are separated by ';', other OSes use ':' (Reference: [Including jars in classpath on commandline]( https://stackoverflow.com/a/43666499) )
    - Need to include the .class and any $n.class files in the compiled Jar file (along with services list

2. Create the jar file ( Reference: [Java Archive Tool](https://docs.oracle.com/javase/7/docs/technotes/tools/windows/jar.html) )
    ```
    jar cfe MyTest.jar TestPackage.TestClass TestPackage/TestClass.class TestPackage/TestClass$1.class
    jar cfe LatexToSVG.jar com.oxygenxml.latex.svg.LatexToSVG com/oxygenxml/latex/svg/LatexToSVG.class com/oxygenxml/latex/svg/LatexToSVG$1.class
    jar cfe MyTest.jar TestPackage.TestClass TestPackage/TestClass.class TestPackage/TestClass$1.class META-INF/services/net.sf.saxon.lib.ExtensionFunctionDefinition    
    ```    

3. Update with extension definition ( References: https://stackoverflow.com/questions/4079675/how-to-add-files-to-jars-meta-inf; https://stackoverflow.com/questions/64046027/oxygen-xml-editor-and-saxon-extension-functions)
    ```
    jar uf MyTest.jar META-INF/services/net.sf.saxon.lib.ExtensionFunctionDefinition
    jar uf LatexToSVG.jar META-INF/services/net.sf.saxon.lib.ExtensionFunctionDefinition
    ```

### Reference

- [example.java.helloworld](https://github.com/macagua/example.java.helloworld#compile-class)


## Saxon Java Extension Functions

The `StructuredQName()` method includes the following: the namespace prefix, the namespace URI, and the function name. These _must_ match the values used in the stylesheet. See the following examples:


### Example Java Class file

```
package TestPackage;

/* Saxon-HE-12.3.jar must be on the classpath */
import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

public class TestClass extends ExtensionFunctionDefinition {
    @Override
    public StructuredQName getFunctionQName() {
        return new StructuredQName("ex-ns", "http://www.example.com/test-class", "function");
    }
    
    @Override
    public SequenceType[] getArgumentTypes() {
        return new SequenceType[] { SequenceType.SINGLE_STRING, SequenceType.SINGLE_STRING };
    }
    
    @Override
    public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
        return SequenceType.SINGLE_STRING;
    }
    
    @Override
    public ExtensionFunctionCall makeCallExpression() {
        return new ExtensionFunctionCall() {
            @Override
            public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
                String str1 = "Hello ";
                String str2 = "!";
                String first = arguments[0].head().getStringValue();
                String last = arguments[1].head().getStringValue();
                String result = str1.concat(first).concat(" ").concat(last).concat(str2);
                return StringValue.makeStringValue(result);
            }
        };
    }
}
```

### Example Stylesheet using this class

```
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:ex-ns="http://www.example.com/test-class"
    exclude-result-prefixes="saxon ex-ns">
    
    <xsl:template match="/doc">
        <doc>
            <xsl:apply-templates/>
        </doc>
    </xsl:template>
    
    <xsl:template match="//name">
        <xsl:variable name="first-name" as="xs:string" select="@first"/>
        <xsl:variable name="last-name" as="xs:string" select="@last"/>
        <name>
            <xsl:copy-of select="ex-ns:function($first-name, $last-name)"/>
        </name>
    </xsl:template>
</xsl:stylesheet>
```

### References:

- [Class StructuredQName](https://www.saxonica.com/html/documentation12/javadoc/net/sf/saxon/om/StructuredQName.html)
- [Class ExtensionFunctionDefinition](https://www.saxonica.com/html/documentation12/javadoc/net/sf/saxon/lib/ExtensionFunctionDefinition.html)
- [Package net.sf.saxon.value](https://www.saxonica.com/html/documentation12/javadoc/net/sf/saxon/value/package-summary.html)

The Java class itself must be registered for Saxon to find. There are [several different methods](https://www.saxonica.com/html/documentation9.8/extensibility/integratedfunctions/ext-full-J.html):

1) [add the following file to the .jar](https://stackoverflow.com/questions/4079675/how-to-add-files-to-jars-meta-inf) along with the class(es): `\META-INF\services\net.sf.saxon.lib.ExtensionFunctionDefinition`
   this file contains one `PackageName.ClassName` per line (e.g., `TestPackage.TestClass`). 
   This is probably the best method for DITA-OT plugins.
2) use [a configuration file](https://www.saxonica.com/html/documentation12/configuration/configuration-file/index.html) and declaring them in a `<resources><extensionFunction>` section.
    **Example:** 
    ```
    <?xml version="1.0" encoding="UTF-8"?>
    <configuration edition="HE" xmlns="http://saxon.sf.net/ns/configuration">
       <!--<global traceExternalFunctions="true"/>-->
          <resources>
              <extensionFunction>TestPackage.TestClass</extensionFunction>
         </resources>
    </configuration>
    ```
3) call the `config.registerExtensionFunction()` (probably not useful for DITA OT plugins)
4) a user-defined class that implements the `net.sf.saxon.Initializer` and is called via the `-init` option on the command line (probably not useful for DITA OT plugins)
5) Create the file using the `<service>` elements in the Ant `<jar>` task. This is described in [the DITA OT docs](https://www.dita-ot.org/dev/topics/implement-saxon-extension-functions) and may be another good alternative for use with a DITA-OT plugin.

### Reference

- [Saxonica - Java extension functions: full interface](https://www.saxonica.com/html/documentation12/extensibility/extension-functions-J/ext-full-J.html)
- [Init error with Saxon HE Java Extension function in Oxygen XML](https://stackoverflow.com/questions/77406836/init-error-with-saxon-he-java-extension-function-in-oxygen-xml)
- [java.lang.ProcessBuilder API Guide](https://www.baeldung.com/java-lang-processbuilder-api)

## References

- [Extending XSLT with Java](http://cafeconleche.org/books/xmljava/chapters/ch17s03.html); [_Processing XML with Java_](http://cafeconleche.org/books/xmljava/) by Elliotte Rusty Harold, 2002
- [dita-latex OxygenXML plugin for DITA-OT](https://github.com/oxygenxml/dita-latex/tree/master/com.oxygenxml.latex.svg)
- [How to support returning ArrayList in ExtensionFunction in Saxon HE 9.7](https://stackoverflow.com/questions/57474503/how-to-support-returning-arraylist-in-extensionfunction-saxon-he-9-7)


### Node.js
* [Command line arguments for Node](https://www.digitalocean.com/community/tutorials/nodejs-command-line-arguments-node-scripts)

* [read in a file in Node.js](https://stackoverflow.com/questions/9168737/read-a-text-file-using-node-js)

* [MathJax Node data output](https://github.com/mathjax/MathJax-node#promiseresolveresultoptions--promiserejecterrors--callbackresult-options)

### Java

* [Java Process Builder Tutorials](https://www.baeldung.com/java-lang-processbuilder-api)

* [Java pass command line arguments](https://stackoverflow.com/questions/8123058/passing-on-command-line-arguments-to-runnable-jar/8123262#8123262)

* [Writing Extension Functions in Java](http://cafeconleche.org/books/xmljava/chapters/ch17s03.html)

* [Saxon: Integrated Extension Functions](https://www.saxonica.com/html/documentation10/extensibility/integratedfunctions/index.html)

* [Microsoft: Java for Beginners](https://learn.microsoft.com/en-us/shows/java-for-beginners/)