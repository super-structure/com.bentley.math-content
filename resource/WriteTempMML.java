package resource;

import java.io.*;
import org.xml.sax.InputSource;
import javax.xml.parsers.*;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.*;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

public class WriteTempMML {

    public static void main(String[] args) throws IOException, Exception {
        /* Given an MML string, this will write the
         * string to a temp file and return that 
         * file location.
         */
        // For testing, use read in the MML contents from a file. Ironic, no?
        String mmlContentString = readFile("./resource/simple.mml", StandardCharsets.UTF_8);
        
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
        System.out.println(tempMMLFile);

        // test reading back the file using the returned string as a path
        // String mmlContentString2 = readFile(tempMMLFile, StandardCharsets.UTF_8);
        // System.out.println(mmlContentString2);

    }

    static String readFile(String path, Charset encoding)
    throws IOException
    {
        byte[] encoded = Files.readAllBytes(Paths.get(path));
        return new String(encoded, encoding);
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

}
