package resource;
// Java code illustrating start() method
import java.io.*;
import java.util.*;
import java.io.InputStreamReader;

import org.xml.sax.InputSource;
import javax.xml.parsers.*;
// import javax.xml.parsers.SAXParserFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.*;
//import org.xml.sax.InputSource;
// import org.xml.sax.SAXException;
import org.w3c.dom.*;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;


//import org.xml.sax.*;
// https://code.visualstudio.com/docs/java/java-project#_configure-classpath-for-unmanaged-folders
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.Xslt30Transformer;
import net.sf.saxon.s9api.XdmDestination;

class ProcessBuilderDemo {
    public static void main(String[] arg) throws Exception 
    // should put this in a try-catch-finally structure instead of using throws
    {

        String mmlContentString = readFile("./resource/simple.mml", StandardCharsets.UTF_8);

        String SVGout = null;

        String stringContents = null;
        try {
            stringContents = getXmlString(getXmlElement(mmlContentString));
        } catch (Exception e) {
            System.out.println("Coudn't make a node from that string");
            e.printStackTrace();
        }

        String tempMMLFile = null;
        try {
            tempMMLFile = createTempFile(stringContents);
        } catch (Exception e) {
            System.out.println("Couldn't create a file");
        }
        //System.out.println(tempMMLFile);
        
        // creating list of commands
        List<String> commands = new ArrayList<String>();
        commands.add("node"); // command
        commands.add("./resource/call-mathjax.js"); // command
        commands.add(tempMMLFile);
 
        // creating the process
        ProcessBuilder pb = new ProcessBuilder(commands);
        //pb.directory(new File("/Users/jasoncoleman/DITA/dita-ot-4.1.1/plugins/com.bentley.math-content/resource"));
        //pb.directory(new File("D:\\DITA\\DITA-OT_4.1.1_Dev\\plugins\\com.bentley.math-content\\resource"));
 
        // starting the process
        Process process = pb.start();
 
        // for reading the output from stream
        String nodeOutString = bufferToString(process.getInputStream());
        
        // This is to build and parse a Document Element 
        // DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        // DocumentBuilder builder;
        // builder = factory.newDocumentBuilder();
        // StringReader sr = new StringReader(s);
        // InputSource is = new InputSource(sr);
        // Document document = builder.parse(is);
        // System.out.println(document.getDocumentElement().getTagName());

        SVGout = postProcessMJSVG(nodeOutString);
        System.out.println(SVGout);

        // https://stackoverflow.com/questions/70618738/how-to-get-the-transformed-xml-from-saxon-10-6-as-a-string
        // https://stackoverflow.com/a/16652948/1080506

        // test to output file
        // PrintWriter outFile = new PrintWriter("simple-out.svg");
        // outFile.println(dest.getXdmNode());
        // outFile.close();
        // }
    }


    static Element getXmlElement(String contents)
    throws Exception
    {
        // Builds and parses string contents into an XML element
        DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        StringReader sr = new StringReader(contents);
        InputSource is = new InputSource(sr);
        Document document = builder.parse(is);
        return document.getDocumentElement();
    }

    static String getXmlString(Element node)
    throws Exception
    {
        // Converts an XmL node to a string (_without_ an XML Delcaration)   
        Transformer transformer = TransformerFactory.newInstance().newTransformer();
        StringWriter buffer = new StringWriter();
        transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
        transformer.transform(new DOMSource(node),
            new StreamResult(buffer));
        return buffer.toString();
    }

    static String createTempFile(String contents)
    throws IOException
    {
        File tempDir = new File(System.getProperty("java.io.tmpdir"));
        File tempFile = File.createTempFile("mathml-","-temp.mml",tempDir);
        PrintWriter outFile = new PrintWriter(tempFile.getAbsolutePath());
        outFile.println(contents);
        outFile.close();
        return tempFile.getAbsolutePath();
    }

    static String bufferToString(InputStream inputStream)
    throws Exception
    {
        // Read the output from stream to a String
        BufferedReader stdInput = new BufferedReader(new InputStreamReader(inputStream));
        StringBuilder result = new StringBuilder();
        for (String nodeOutString; (nodeOutString = stdInput.readLine()) != null;)
            { result.append(nodeOutString);}
            return result.toString();
    }

    static String postProcessMJSVG(String mathjaxSVString)
    throws Exception
    {
        // perform an XSLT post-processing to make the MathJax
        // SVG output conform to SVG DTD / schema
        String standardSVG = null;
        // Use Saxon XSLT Processor to post-process the SVG string
        // https://www.saxonica.com/documentation12/index.html#!using-xsl/embedding/s9api-transformation
        Processor processor = new Processor(false);
        XsltCompiler compiler = processor.newXsltCompiler();
        XsltExecutable stylesheet = compiler.compile(new StreamSource(new File("./xsl/mj-svg-clean.xsl")));
        Serializer outString = processor.newSerializer(new StringWriter());
        //https://www.saxonica.com/documentation12/index.html#!javadoc/net.sf.saxon.s9api/Serializer@serializeNodeToString
        outString.setOutputProperty(Serializer.Property.METHOD, "xml");
        outString.setOutputProperty(Serializer.Property.INDENT, "yes");
        Xslt30Transformer transformer = stylesheet.load30();
        // https://www.saxonica.com/documentation12/index.html#!javadoc/net.sf.saxon.s9api/Xslt30Transformer@transform
        
        XdmDestination dest = new XdmDestination();
        transformer.transform(new StreamSource(new StringReader(mathjaxSVString)), dest);
        // return the getXdmNode() method as the function output
        standardSVG =  String.valueOf(dest.getXdmNode());
        return standardSVG;
    }

    static String readFile(String path, Charset encoding)
    throws IOException
    {
        // This is really just used for testing purposes
        byte[] encoded = Files.readAllBytes(Paths.get(path));
        return new String(encoded, encoding);
    }

}
