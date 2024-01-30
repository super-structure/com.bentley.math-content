# TODO

Track these issues & features in ADO or in GitHub?

* [ ] Review [MathML specs](https://w3c.github.io/mathml-core/) and document usage for the plug-in
* [ ] Review [AMSMath Package User's Guide](https://www.ams.org/arc/tex/amsmath/amsldoc.pdf) and document LaTeX usage
* [ ] Add L10N strings (`/cfg/common/vars/`)
* [x] Support for [&lt;mathmlref&gt;](https://docs.oasis-open.org/dita/dita/v1.3/os/part2-tech-content/langRef/technicalContent/mathmlref.html) element (looks like it works out-of-the-box!)
* [x] Parameters
    - Math rendering option (none / MathJax-Node / MathJax CDN / MathJax Local / JEuclid)
    - Equation linking style (~~number / title / number & title~~) An equation block element doesn't have a title, but it may be useful to allow for using 'Equation' or 'eqn.' ( full / abbr )
* [ ] Include parameter to fetch latest MathJax build? Other 3rd party softare?
* [ ] Does FOP support LaTeX? Verify PDF rendering engine.
* [x] Pass params to XSL
    - rendering method will affect: mode for `<mathml>` and `<mathref>` processing
    - rendering also affects `processFTR` mode (if MathJax CDN or Local is used)
* [ ] Use an external config file for MathJax SVG parameters? [https://docs.mathjax.org/en/latest/options/output/svg.html#the-configuration-block](https://docs.mathjax.org/en/latest/options/output/svg.html#the-configuration-block)

## Issues

* [x] Mathref not working for HTML5 (check PDF) - add to topicpullImpl eqn? 
    - Copy over .mml files to temp *first* using depend.preprocess.topicpull.pre
    - Is there a possibility that .mml files have different extension? Have different namespace inside?
    - Different extensions can be in a dita extension for file types?
* [ ] Need to use dita.xsl.topicpull extension point; still not working with empty eqn numbers
    - need to have the topicpull steps count up the equation-numbers?

## Won't Do

* [ ] ~~do we need to gen-list for all mathml references?~~ All mathml topics? Probably doesn't make sense in the way a `<figurelist>` or `<tablelist>` in a bookmap does; as those have titles (where as equation blocks with numbers do not)
