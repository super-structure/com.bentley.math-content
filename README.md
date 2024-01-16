![Bentley logo](image/Bentley_logo.svg)
# MathML Transformations for DITA v1.3

DITA Open Toolkit plugin for math content (MathML ~~and LaTeX~~) integration with DITA v1.3.

2023-06-22

This plugin includes stylesheets for HTML5/XHTML and PDF/FO transformations by means of DITA Open Toolkit extensions.

While browsers have included some support for MathML in recent years, rendering of anything but very basic math content is severaly limited even as of late 2023. However, SVG support is well established in all modern browsers. Therefore, in addition to general stylesheets to support MathML content, this plugin also "pre-renders" the `<mathml>` elements into SVG using MathJax 3.x.

**In Development**: Refer to [docs](docs/index.md) for roadmap and To Do list.

## Prerequisites

Node.js - for pre-rendering of equation content into SVG
MathJax 3 - included here
    [Hosting your own copy of the MathJax Components](https://www.npmjs.com/package/mathjax#hosting-your-own-copy-of-the-mathjax-components)

[![Powered by MathJax](https://www.mathjax.org/badge/badge.gif)](https://www.mathjax.org)

## Installation

1. Download or clone this repository to your DITA OT `plugins` directory.
2. Run the `dita --install` command.

## Usage

(Coming soon…)

## Roadmap

Refer to [TODO.md](docs/TODO.md) for details.

## Reference
* [&lt;math&gt; on MDN](https://developer.mozilla.org/en-US/docs/Web/MathML/Element/math)
* [MathML Core W3C Spec.](https://w3c.github.io/mathml-core/)

## Copyright

Copyright © Bentley Systems, Incorporated. All rights reserved.

## License

**MathJax 3.x** distribution is licensed under an Apache v2.0 license. See the included license file for details.
**jeuclid-fop-3.1.9** distribution is licensed under an Apache v2.0 license. See the included license file for details.
