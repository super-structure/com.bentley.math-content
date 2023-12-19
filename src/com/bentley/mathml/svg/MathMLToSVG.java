package com.bentley.mathml.svg;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
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
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.*;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.Xslt30Transformer;
import net.sf.saxon.s9api.XdmDestination;

public class MathMLToSVG extends ExtensionFunctionDefinition {
/**
 * Returns SVG contents as a string for using in an XSLT stylesheet
 * 
 * @param	string	the MathML contents to convert
 * @return	string 	the SVG rendering of the MathML intput; using MathJax 3.x
 * @author	Jason T. Coleman
 * @version 1.00, 19 December, 2023
 */
	  @Override
	  public StructuredQName getFunctionQName() {
	    return new StructuredQName("mathjax", "https://www.mathjax.org/MathMLToSVG", "mml2svg");
	  }

	  @Override
	  public SequenceType[] getArgumentTypes() {
	    return new SequenceType[] { SequenceType.SINGLE_STRING};
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
			
			// String mmlContentString = ((StringValue)arguments[0]).getStringValue();
			String mmlContentString = ((StringValue) arguments[0].iterate().next()).getStringValue();
			/* 1) read in string contents to an XML element */
			String stringContents = null;
			try {
				stringContents = getXmlString(getXmlElement(mmlContentString));
			} catch (Exception e) {
				System.out.println("Coudn't make a node from that string");
				e.printStackTrace();
			}

			/* 2) write out mathml contents to file */
			String tempMMLFile = null;
			try {
				tempMMLFile = createTempFile(stringContents);
			} catch (Exception e) {
				System.out.println("Couldn't create a file");
				e.printStackTrace();
			}

			/* 3) use ProcessBuilder to create Node.js call */
			// make an array of the commands to pass to Process Builder
			List<String> commands = new ArrayList<String>();
			commands.add("node");
			commands.add("./resource/call-mathjax.js");
			commands.add(tempMMLFile);
	
			// creat & start the process
			ProcessBuilder pb = new ProcessBuilder(commands);
			Process process = null;
        	try {
				process = pb.start();
			} catch (IOException e) {
				System.out.println("Could not run Process:" + commands.toString());
				e.printStackTrace();
			}
			String nodeOutString = null;
			try {
				nodeOutString = bufferToString(process.getInputStream());
			} catch (Exception e) {
				System.out.println("Could not collect stream from Process");
				e.printStackTrace();
			}

			/* 4) perform any necessary post-processing on returned SVG via XSLT */
			Sequence SVGout = null;
			try {
				SVGout = StringValue.makeStringValue(postProcessMJSVG(nodeOutString));
			} catch (Exception e) {
				System.out.println("Could not post-process SVG string in XSLT");
				e.printStackTrace();
			}
			
			/* 5) return SVG string */
			return SVGout;
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
		};
	}

}