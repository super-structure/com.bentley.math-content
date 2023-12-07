// mini example at 
// https://github.com/mathjax/MathJax#using-mathjax-components-in-a-node-application
// adaptor.outerHTMLT produces <mjx-container> XML element output in console.
// using adaptor.innerHTML just produces SVG content with no wrapper

require('mathjax').init({
    loader: {load: ['input/tex', 'output/svg'],
    container: false}
  }).then((MathJax) => {
    const svg = MathJax.tex2svg('\\frac{1}{x^2-1}', {display: true});
    console.log(MathJax.startup.adaptor.innerHTML(svg));
  }).catch((err) => console.log(err.message));
