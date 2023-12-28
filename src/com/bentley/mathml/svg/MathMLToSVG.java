package com.bentley.mathml.svg;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.*;

// import javax.swing.JLabel;

import org.w3c.dom.*;
// import org.w3c.dom.DOMImplementation;
// import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import javax.xml.parsers.*;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.*;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.AtomicSequence;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.*;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.str.UnicodeString;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.Xslt30Transformer;
import net.sf.saxon.s9api.XdmDestination;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.tree.tiny.*;
import net.sf.saxon.om.TreeModel;

public class MathMLToSVG extends ExtensionFunctionDefinition {
/**
 * Returns SVG contents as a string for using in an XSLT stylesheet.
 * Takes an input MathML string and returns the SVG rendering of that
 * input using MathJax 3.x; with some postprocessing so the results
 * conform to the SVG v1.1 standard schema.
 * 
 * This is class uses Saxon extension functions and is intended for
 * use in XSLT stylesheets in a DITA Open Toolkit plugin.
 * 
 * @author	Jason T. Coleman
 * @version 1.00, 19 December, 2023
 */
	  @Override
	  public StructuredQName getFunctionQName() {
	    return new StructuredQName("mathjax", "https://www.mathjax.org/MathMLToSVG", "mml2svg");
	  }

	  @Override
	  public SequenceType[] getArgumentTypes() {
	    return new SequenceType[] { SequenceType.SINGLE_NODE};
	  }
    
	  @Override
	  public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
		  return SequenceType.SINGLE_STRING;
	  }

	  @Override
	  public ExtensionFunctionCall makeCallExpression() {
		  return new ExtensionFunctionCall() {
			  @Override
			  public Sequence call(XPathContext arg0, Sequence[] arguments) throws XPathException {

			System.out.println("============================");

			/* 1) make a string from the element */
			// TODO: Current going from TinyElementImpl -> String -> Document; can we just get the XML from TinyElementImpl?
			// TODO: get encoding from source string? Or just always assume UTF-8?
			// TODO: allow for entitiy names (eg, &beta;)?
			TinyElementImpl mmlContentTinyELem = (TinyElementImpl) arguments[0];
			String mmlContentString = null;
			try {
				mmlContentString = getInputXmlString(mmlContentTinyELem);
			} catch (Exception e) {
				System.out.println("Coudn't resolve input node into a string");
				e.printStackTrace();
			}

			/* 2) read in string contents to an XML element */
			String stringContents = null;
			try {
				stringContents = getXmlString(getXmlElement(mmlContentString));
			} catch (Exception e) {
				System.out.println("Coudn't make a node from that string");
				e.printStackTrace();
			}

			/* 3) write out mathml contents to file */
			File tempMMLFile = null;
			try {
				tempMMLFile = createTempFile(stringContents);
			} catch (Exception e) {
				System.out.println("Couldn't create a file");
				e.printStackTrace();
			}
			String tempMMLFileName = tempMMLFile.getAbsolutePath();
			System.out.println("tempMMLFileName:["+tempMMLFileName+"]");

			/* 4) use ProcessBuilder to create Node.js call */
			// make an array of the commands to pass to Process Builder
			List<String> commands = new ArrayList<String>();
			commands.add("node");
			//commands.add("./resource/call-mathjax.js");
			commands.add("D:/DITA/DITA-OT_4.1.1_Dev/plugins/com.bentley.math-content/resource/call-mathjax.js");
			commands.add(tempMMLFileName);
			
			// creat & start the process
			ProcessBuilder pb = new ProcessBuilder(commands);
			pb.redirectErrorStream(true);
			Process process = null;
        	try {
				process = pb.start();	// Do NOT use in .inheritIO() method here except for troubleshooting; it disrupts the return stream for getting the SVG back
			} catch (IOException e) {
				System.out.println("Could not run Process:" + commands.toString());
				e.printStackTrace();
			}
			System.out.println("Process: ["+process.toString()+"]");

			String nodeOutString = ""; // 'prime' the emtpy string
			try {
				// prevent buffer from blocking subprocess
				BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
				String line;
				while ((line = reader.readLine()) != null)
					nodeOutString += line;
				process.waitFor();	// wait for Node to finish
			} catch (Exception e) {
				System.out.println("Could not collect stream from Process");
				e.printStackTrace();
			}
			System.out.println("Process ["+process.toString()+"]");

			/* 5) perform any necessary post-processing on returned SVG via XSLT */
			Sequence SVGout = null;
			try {
				SVGout = StringValue.makeStringValue(postProcessMJSVG(nodeOutString));
			} catch (Exception e) {
				System.out.println("Could not post-process SVG string in XSLT");
				e.printStackTrace();
			}
			
			/* 6) return SVG string */
			// Delete temporary MML file
			tempMMLFile.delete();
			System.out.println("great work so far!");
			return SVGout;
			}

			static String getInputXmlString(TinyElementImpl tinyElement)
			throws Exception {
				Processor proc = new Processor(false);
				System.out.println(proc.getSaxonEdition()+", "+proc.getSaxonProductVersion());
				StringWriter writer = new StringWriter();
				Serializer serializer = proc.newSerializer(writer);
				String mmlContentString = null;
				try {
					mmlContentString = serializer.serializeToString(tinyElement);
				} catch (Exception e) {
					// TODO: handle exception
				}
				return mmlContentString;
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

			static File createTempFile(String contents)
			throws IOException
			{
				File tempDir = new File(System.getProperty("java.io.tmpdir"));
				File tempFile = File.createTempFile("mathml-","-temp.mml",tempDir);
				OutputStream outStream = new FileOutputStream(tempFile.getAbsolutePath());
				PrintWriter outFile = new PrintWriter(new OutputStreamWriter(outStream, "UTF-8")); // use StreamWriter to include encoding
				outFile.println(contents);
				outFile.close();
				return tempFile;
			}

			// static String bufferToString(InputStream inputStream)
			// throws Exception
			// {
			// 	// Read the output from stream to a String
			// 	BufferedReader stdInput = new BufferedReader(new InputStreamReader(inputStream));
			// 	StringBuilder result = new StringBuilder();
			// 	for (String nodeOutString; (nodeOutString = stdInput.readLine()) != null;)
			// 		{ result.append(nodeOutString);}
			// 		return result.toString();
			// }

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
				String path = "D:\\DITA\\DITA-OT_4.1.1_Dev\\plugins\\com.bentley.math-content\\xsl\\mj-svg-clean.xsl";
				InputStream stream = MathMLToSVG.class.getResourceAsStream("mj-svg-clean.xsl");
				//XsltExecutable stylesheet = compiler.compile(new StreamSource(new File(path)));
				XsltExecutable stylesheet = compiler.compile(new StreamSource(stream));
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
		};
	}

}