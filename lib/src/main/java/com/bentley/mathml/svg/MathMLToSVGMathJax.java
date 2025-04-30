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
import java.net.URISyntaxException;
import java.util.*;

import org.w3c.dom.*;
import org.xml.sax.InputSource;
import javax.xml.parsers.*;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.*;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
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
import net.sf.saxon.om.LazySequence;
import net.sf.saxon.om.TreeModel;
// import net.sf.saxon.TransformerFactoryImpl;
// import net.sf.saxon.BasicTransformerFactory;

public class MathMLToSVGMathJax extends ExtensionFunctionDefinition {
/**
 * Returns SVG contents as a string for using in an XSLT stylesheet.
 * Takes an input MathML string and returns the SVG rendering of that
 * input using MathJax 3.x; with some postprocessing so the results
 * conform to the SVG v1.1 standard schema.
 * 
 * This class uses Saxon extension functions and is intended for
 * use in XSLT stylesheets in a DITA Open Toolkit plugin.
 * 
 * @author	Jason T. Coleman
 * @version 1.10, 15 February, 2024
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

	  public File getFilePath() throws URISyntaxException {
		/**Return the File URI of the Jar file
		 * Source: https://stackoverflow.com/questions/320542/how-to-get-the-path-of-a-running-jar-file
		 */
		return new File(MathMLToSVGMathJax.class.getProtectionDomain().getCodeSource().getLocation().toURI());
	  }

	  @Override
	  public ExtensionFunctionCall makeCallExpression() {
		  return new ExtensionFunctionCall() {
			  @Override
			  public Sequence call(XPathContext arg0, Sequence[] arguments) throws XPathException {

			/* 1) read in MathML to an XML elemetn */
			// TODO: get encoding from source string? Or just always assume UTF-8?
			// TODO: allow for entitiy names (eg, &beta;)?
			LazySequence mmlLazySequence = (LazySequence) arguments[0];
			Sequence mmlSequence = mmlLazySequence.makeRepeatable();	//Lazy sequence can only be evaluated once
			TinyParentNodeImpl mmlContentTiny = (TinyParentNodeImpl) mmlSequence.head(); // cast to general object of TinyElementImpl and TinyDocumentImpl
			TinyElementImpl mmlContentTinyELem = (TinyElementImpl) mmlContentTiny.getTree().getNode(1); // get the first node in the tree

			/* 2) transfor XML element to a string (without XML declaration) */
			String stringContents = null;
			try {
				stringContents = getXmlString(mmlContentTinyELem);
			} catch (Exception e) {
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
			//System.out.println("MML File Name: ["+tempMMLFileName+"]");

			/* 4) use ProcessBuilder to create Node.js call */
			// get the directory for this jar
			File here = null;
			try {
				here = getFilePath().getParentFile();
			} catch (Exception e) {
				// TODO: handle exception
			}
			// make an array of the commands to pass to Process Builder
			List<String> commands = new ArrayList<String>();
			commands.add("node");
			commands.add("call-mathjax.js");
			commands.add(tempMMLFileName);
			
			// creat & start the process
			ProcessBuilder pb = new ProcessBuilder(commands);
			pb.directory(here);	// run the process in the directory as the Jar, where the JavaScript & Node files are
			pb.redirectErrorStream(true);
			Process process = null;
        	try {
				process = pb.start();	// Do NOT use in .inheritIO() method here except for troubleshooting; it disrupts the return stream for getting the SVG back
			} catch (IOException e) {
				System.out.println("Could not run Process:" + commands.toString());
				e.printStackTrace();
			}

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
			return SVGout;
			}

			static String getXmlString(TinyElementImpl node)
			throws Exception
			{
				// Converts an XML node to a string (_without_ an XML Delcaration)   
				TransformerFactory tFactory = TransformerFactory.newInstance("net.sf.saxon.TransformerFactoryImpl", null);
				StringWriter sbuffer = new StringWriter();
				Transformer transformer = tFactory.newTransformer();
				transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
				transformer.transform(node,
					new StreamResult(sbuffer));
				return sbuffer.toString();
			}

			static File createTempFile(String contents)
			throws IOException
			{
				// Writes out string to a temporary file to pass to Node.js
				File tempDir = new File(System.getProperty("java.io.tmpdir"));
				File tempFile = File.createTempFile("mathml-","-temp.mml",tempDir);
				OutputStream outStream = new FileOutputStream(tempFile.getAbsolutePath());
				PrintWriter outFile = new PrintWriter(new OutputStreamWriter(outStream, "UTF-8")); // use StreamWriter to include encoding
				outFile.println(contents);
				outFile.close();
				return tempFile;
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
				InputStream stream = MathMLToSVGMathJax.class.getResourceAsStream("/mj-svg-clean.xsl");
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
