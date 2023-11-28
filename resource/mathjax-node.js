const fs = require('fs');
const { DOMParser } = require('xmldom')
var path = require('path');
var mjAPI = require("mathjax-node");

void Main()

async function Main() {
    const topicsDir = process.argv[2]

    if (topicsDir == null)
        throw new Error("Temporary topics folder not declared.")

    var topics = []

    ReadDirectory(topicsDir, '.dita', topics)
    const parser = new DOMParser()

    for (let i = 0; i < topics.length; i++) {
        const fileContent = fs.readFileSync(topics[i])
        var resultContent = fileContent.toString()

        const xmlDoc = parser.parseFromString(fileContent.toString(), "text/xml")
        const mathjaxElements = xmlDoc.getElementsByTagName('mathjax')  //* this element should be 'mathml'' */
        for (let i = 0; i < mathjaxElements.length; i++) {
            const fullLine = mathjaxElements.item(i)
            const formatValue = fullLine.getAttribute('format')
            const lineValue = fullLine.textContent

            const data = await mjAPI.typeset({
                math: lineValue,
                format: formatValue,
                svg: true
            });

            if (!data.errors) {
                resultContent = resultContent.replace(fullLine, data.svg)
            }
        }

        // change ex units to pixels for svg height, width and style attributes
        const xmlDocSvg = parser.parseFromString(resultContent, "text/xml")
        const svgElements = xmlDocSvg.getElementsByTagName('svg')
        for (let i = 0; i < svgElements.length; i++) {
            const fullLine = svgElements.item(i)

            const widthValue = fullLine.getAttribute('width')
            const heightValue = fullLine.getAttribute('height')
            const styleValue = fullLine.getAttribute('style')

            var widthValueFloat = parseFloat(widthValue)
            fullLine.setAttribute('width', widthValueFloat * 6)

            var heightValueFloat = parseFloat(heightValue)
            fullLine.setAttribute('height', heightValueFloat * 6)

            var styleArray = styleValue.split(" ")
            styleArray[1] = ((parseFloat(styleValue.match(/-?\d+\.?\d*/))) * 6)
            var styleVerticalAlignValueUpdated = styleArray.join(" ")
            fullLine.setAttribute('style', styleVerticalAlignValueUpdated)

        }
        fs.writeFileSync(topics[i], xmlDocSvg.toString(), { encoding: 'utf8', flag: 'w' })
    }
}

function fromDir(startPath, filter, topics) {

    if (!fs.existsSync(startPath)) {
        console.log("no dir ", startPath);
        return;
    }

    var files = fs.readdirSync(startPath);
    for (var i = 0; i < files.length; i++) {
        var filename = path.join(startPath, files[i]);
        var stat = fs.lstatSync(filename);
        if (stat.isDirectory()) {
            fromDir(filename, filter, topics); //recurse
        } else if (filename.endsWith(filter)) {
            topics.push(filename)
            console.log('-- found: ', filename);
        };
    };
};

// Get all .dita files in temp folder
function ReadDirectory(startPath, filter, topics) {
    if (!fs.existsSync(startPath)) {
        console.log("no dir ", startPath);
        return
    }

    var files = fs.readdirSync(startPath)
    for (var i = 0; i < files.length; i++) {
        var filename = path.join(startPath, files[i])
        var stat = fs.lstatSync(filename)
        if (stat.isDirectory()) {
            fromDir(filename, filter, topics) //recurse
        }
        else if (filename.endsWith(filter)) {
            topics.push(filename)
            console.log('-- found: ', filename)
        }
    }
}