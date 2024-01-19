// This script assumes that the input file does *not* have an <?xml> declaration or
// DocType present. Rather, that the <math> node structure is the beginning of the file
// string. Currently, if there is an <?xml> declaration or a Doctype, it fails.
// TODO: Can xml.innerHTML in the mathml2svg function handle this?

// usage: node call-mathjax.js <filename>.mml

var input = process.argv[2];

const fs = require('node:fs');
const xml = fs.readFileSync(input, 'utf8');

require('mathjax').init({
    loader: {load: ['input/mml', 'output/svg'],
    svg: {fontCache: 'local', 
          mtextInheritFont: true},
    container: false}
  }).then((MathJax) => {
    const svg = MathJax.mathml2svg(xml, {display: true});
    console.log(MathJax.startup.adaptor.innerHTML(svg));
  }).catch((err) => console.log(err.message));
