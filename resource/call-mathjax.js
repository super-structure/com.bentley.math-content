// this still needs to actually parse the .mml file XML data; and then write the
// root <math> node structure to a string. Currently, if there is an <?xml> declaration
// or a Doctype, it fails.

// usage: node call-mathjax.js simple.mml

var input = process.argv[2];

const fs = require('node:fs');
const xml = fs.readFileSync(input, 'utf8');

require('mathjax').init({
    loader: {load: ['input/mml', 'output/svg'],
    container: false}
  }).then((MathJax) => {
    const svg = MathJax.mathml2svg(xml, {display: true});
    fs.writeFileSync('simple.svg', MathJax.startup.adaptor.innerHTML(svg),'utf8');
    console.log(MathJax.startup.adaptor.innerHTML(svg));
  }).catch((err) => console.log(err.message));
