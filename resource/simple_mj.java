package resource;
// Java code illustrating start() method
import java.io.*;
import java.util.*;
import javax.xml.parsers.*;
import org.xml.sax.InputSource;
// import org.xml.sax.SAXException;
import org.w3c.dom.*;
//import org.xml.sax.*;
// https://code.visualstudio.com/docs/java/java-project#_configure-classpath-for-unmanaged-folders
// import net.sf.saxon.s9api.Processor;
// import net.sf.saxon.s9api.XsltCompiler;

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
 
        // starting the process
        Process process = pb.start();
 
        // for reading the output from stream
        BufferedReader stdInput
            = new BufferedReader(new InputStreamReader(
                process.getInputStream()));
        String s = null;
        while ((s = stdInput.readLine()) != null) {
            // This line works:
            // System.out.println(s);

            // This is working
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder;
            builder = factory.newDocumentBuilder();
            StringReader sr = new StringReader(s);
            InputSource is = new InputSource(sr);
            Document document = builder.parse(is);
            System.out.println(document.getDocumentElement().getTagName());

        // Use XSLT to post-process the SVG string
        // https://www.saxonica.com/documentation12/index.html#!using-xsl/embedding/s9api-transformation
        // Processor processor = new Processor(false);
        // XsltCompiler compiler = processor.newXsltCompiler();

        }
    

    }
}