# Documentation

**Note:** Contributions to this plugin should follow established [coding conventions](https://www.dita-ot.org/dev/topics/plugin-coding-conventions) and best practices.

## Feature Roadmap

* [ ] Provide rendering of MathML _and_ LaTeX content in DITA and LwDITA files
    - Integrate oXygen's plugin for rendering LaTeX to SVG using Java (...or just rely on MathJax to also convert LaTeX to SVG?)
    - JEuclid: use this library & functions similar to how dita-latex uses JLaTeXMath? ~~Use Norman Walsh's [MathML-to-SVG Calabash extension](https://github.com/ndw/xmlcalabash1-mathml-to-svg/tree/master) as a guide?~~
    - Saxon HE uses "[Integrated extension functions](https://www.saxonica.com/html/documentation9.8/extensibility/integratedfunctions/index.html)" (as of v9.2). Each class must be added to the `net.sf.saxon.lib.ExtensionFunctionDefinition` (ref. [Implementing Saxon extension functions](https://www.dita-ot.org/dev/topics/implement-saxon-extension-functions). This can also just be added manually to the jar file in the META-INF/services directory.
* [x] Provide templates to handle equation and mathml domains (not part of the DITA-OT standard templates)
* [ ] Provide math content rendering solutions for when Node is installed as well as if not (e.g., using JEuclid as alternative transform to SVG or using MathJax on client side)
    - **Note:** Refer to [Java_Node.md](Java_Node.md) for details on how the custom Saxon extension might be used with Node.js.
    - Use Node.js to provide pre-rendering of math content into SVG
    - MathJax for Node and MathJax as part of this plugin _or_ installed via NPM on the machine?
    - XSLT that copies out MML or LaTeX content to a file with a given ID as the filename; preprocess2.topic
    - Run mathjax-node on that external file to produce external SVG; preprocess2.topic
    - Use XSLT again to copy back in the SVG contents; html5.topic & transform.topic2fo
    - Another possilbe option: [pymathematical](https://github.com/Danmou/pymathematical)?
    - [TexZilla](http://fred-wang.github.io/TeXZilla/) ([on GitHub](https://github.com/fred-wang/TeXZilla)) - TeX 2 MathML 2 SVG
* [ ] Provide fetch mechanism for equation number for links to an equation-block or equation-figure (without title)
* [x] Automatic equation numbering (when `<equation-number>` element is empty)
* [ ] Special transformation & rendering of definition lists as equation symbols
* [ ] Provide anchor links for each equation number
* [ ] Support `<mathref>` to "pull" in external equation content (i.e., .mml files)
* [ ] Links to `<equation-blocks>` and `<equation-figures>` (without titles) reference the `<equation-number>` (sim. to how tables and figures behave).
* [ ] Account for combined empty & filled `<equation-number>` elements.

## To Do

Refer to [TODO.md](TODO.md)

## Third-party Software

Make sure that any 3rd party code used complies with Bentley's copy-left policies!

[Node.js](https://github.com/nodejs/node) is under an MIT license, with external libraries under a variety of licenses

[MathJax](https://github.com/mathjax/MathJax) and [MathJax for Node](https://github.com/mathjax/MathJax-node) are under an Apache 2.0 license.
[dita-latex](https://github.com/oxygenxml/dita-latex/tree/master) is under an Apache 2.0 license.

[JLaTeXMath](https://github.com/opencollab/jlatexmath/tree/master) is under the GNU General Public License v2.0 w/Classpath exception license