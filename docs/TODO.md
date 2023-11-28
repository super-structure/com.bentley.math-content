# TODO

Track these issues & features in ADO or in GitHub?

* [ ] Add L10N strings (`/cfg/common/vars/`)
* [x] Support for [&lt;mathmlref&gt;](https://docs.oasis-open.org/dita/dita/v1.3/os/part2-tech-content/langRef/technicalContent/mathmlref.html) element (looks like it works out-of-the-box!)
* [ ] Parameters
    - Math rendering option (none / MathJax-Node / MathJax CDN / MathJax Local / JEuclid)
    - Equation linking style (number / title / number & title )
* [ ] Include parameter to fetch latest MathJax build? Other 3rd party softare?
* [ ] Does FOP support LaTeX? Verify PDF rendering engine.
* [ ] Pass params to XSL

## Issues

* [x] Mathref not working for HTML5 (check PDF) - add to topicpullImpl eqn? 
    - Copy over .mml files to temp *first* using depend.preprocess.topicpull.pre
    - Is there a possibility that .mml files have different extension? Have different namespace inside?
    - Different extensions can be in a dita extension for file types?
* [ ] Need to use dita.xsl.topicpull extension point; still not working with empty eqn numbers
    - need to have the topicpull steps count up the equation-numbers?
* [ ] display content 
* [ ] do we need to gen-list for all mathml references? All mathml topics?
* [ ] DITA OT cannot find function in Oxgyen LaTex2SVG Java class

