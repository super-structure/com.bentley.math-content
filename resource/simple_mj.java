package resource;
// Java code illustrating start() method
import java.io.*;
import java.util.*;

////import javax.xml.parsers.*;
// import javax.xml.parsers.SAXParserFactory;
// import javax.xml.transform.Source;
import javax.xml.transform.stream.*;
//import org.xml.sax.InputSource;
// import org.xml.sax.SAXException;
//import org.w3c.dom.*;
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
        // creating list of commands
        List<String> commands = new ArrayList<String>();
        commands.add("node"); // command
        commands.add("call-mathjax.js"); // command
        commands.add("simple.mml");
 
        // creating the process
        ProcessBuilder pb = new ProcessBuilder(commands);
        pb.directory(new File("/Users/jasoncoleman/DITA/dita-ot-4.1.1/plugins/com.bentley.math-content/resource"));
        //pb.directory(new File("D:\\DITA\\DITA-OT_4.1.1_Dev\\plugins\\com.bentley.math-content\\resource"));
 
        // starting the process
        Process process = pb.start();
 
        // for reading the output from stream
        BufferedReader stdInput
            = new BufferedReader(new InputStreamReader(
                process.getInputStream()));
        String nodeOutString = null;
        while ((nodeOutString = stdInput.readLine()) != null) {

        // This is to build and parse a Document Element 
        // DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        // DocumentBuilder builder;
        // builder = factory.newDocumentBuilder();
        // StringReader sr = new StringReader(s);
        // InputSource is = new InputSource(sr);
        // Document document = builder.parse(is);
        // System.out.println(document.getDocumentElement().getTagName());


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
        transformer.transform(new StreamSource(new StringReader(nodeOutString)), dest);
        // return the getXdmNode() method as the function output
        System.out.println(dest.getXdmNode());

        // https://stackoverflow.com/questions/70618738/how-to-get-the-transformed-xml-from-saxon-10-6-as-a-string
        // https://stackoverflow.com/a/16652948/1080506

        // test to output file
        // PrintWriter outFile = new PrintWriter("simple-out.svg");
        // outFile.println(dest.getXdmNode());
        // outFile.close();
        }
    }
}