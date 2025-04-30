package com.bentley.mathml.svg;

import java.io.OutputStream;
import java.io.StringReader;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.io.ByteArrayOutputStream;
import java.io.IOException;

// import org.apache.commons.io.output.ByteArrayOutputStream;
import org.w3c.dom.*;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import javax.xml.parsers.*;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.LazySequence;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.tiny.TinyElementImpl;
import net.sf.saxon.tree.tiny.TinyParentNodeImpl;
import net.sf.saxon.value.*;

import net.sourceforge.jeuclid.converter.Converter;
import net.sourceforge.jeuclid.converter.BatikConverter;
import net.sourceforge.jeuclid.MutableLayoutContext;
import net.sourceforge.jeuclid.context.LayoutContextImpl;
import net.sourceforge.jeuclid.parser.Parser;

import de.rototor.jeuclid.*;

public class MathMLToSVGJEuclid extends ExtensionFunctionDefinition {
/**
 * Returns SVG contents as a string for using in an XSLT stylesheet.
 * Takes an input MathML string and returns the SVG rendering of that
 * input using JEuclid; with some postprocessing so the results
 * conform to the SVG v1.1 standard schema.
 * 
 * This class uses Saxon extension functions and is intended for
 * use in XSLT stylesheets in a DITA Open Toolkit plugin.
 * 
 * @author	Jason T. Coleman
 * @version 1.00, 29 April, 2025
 */
	  @Override
	  public StructuredQName getFunctionQName() {
	    return new StructuredQName("jeuclid", "https://jeuclid.sourceforge.net/MathMLToSVG", "mml2svg");
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

			/* 1) read in MathML to an XML elemetn */
			// TODO: get encoding from source string? Or just always assume UTF-8?
			// TODO: allow for entitiy names (eg, &beta;)?

			// This does not work; casts net.sf.saxon.tree.tiny.TinyDocumentImpl to net.sf.saxon.value.StringValue
			// String mml = ((StringValue) arguments[0].iterate().next()).getStringValue();

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
			System.out.println("MathML data converted to string...");
			System.out.println(stringContents);

			/* 2) parse TinyElement into JEuclid readable dom? */
			// Parser parser = Parser.getInstance();
			// parser.parse(mml);
			// https://stackoverflow.com/questions/729621/convert-string-xml-fragment-to-document-node-in-java
			Document document = null;
			try {
				document = loadXML(stringContents);
			} catch (Exception e) {
				System.out.println("Could not convert MML input to string");
				e.printStackTrace();
			}
			System.out.println("Root element: " + document.getDocumentElement().getNodeName());
			System.out.println("MathML string loaded as node..."); // good to this point

			/* 3) convert using JEuclid */
			// https://stackoverflow.com/questions/5904869/help-with-jeuclid-in-java
			Converter converter = Converter.getInstance();
			System.out.println("Converter initialized...");
			MutableLayoutContext params = new LayoutContextImpl(LayoutContextImpl.getDefaultLayoutContext());
			OutputStream outStream = null;

			try {
				System.out.println("Converting with JEuclid...");
				converter.convert(document, outStream, "image/svg+xml", params);
				System.out.println("...success!");
			} catch (Exception e) {
				System.out.println("Could not convert MML into SVG");
				e.printStackTrace();
			}
			System.out.println("JEuclid converter ran..");
			
			/* 6) return SVG string */
			// https://www.geeksforgeeks.org/io-bytearrayoutputstream-class-java/
			ByteArrayOutputStream baos = new ByteArrayOutputStream(); 
			try {
				baos.writeTo(outStream);
			} catch (Exception e) {
				System.out.println("Could not convert byte to outstream");
				e.printStackTrace();
			}

			//return baos.toString("UTF-8");
			Sequence SVGout = null;
			try {
				SVGout = StringValue.makeStringValue(baos.toString(StandardCharsets.UTF_8));
			} catch (Exception e) {
				System.out.println("Could not post-process SVG string in XSLT");
				e.printStackTrace();
			}
			return SVGout;
		}

		static Document loadXML(String xml) 
		throws Exception
		{
			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = factory.newDocumentBuilder();
			InputSource insrc = new InputSource(new StringReader(xml));
			Document xmlDoc = null;
			try {
				xmlDoc = builder.parse(insrc);
			} catch (SAXException e) {
				throw new RuntimeException(e);
			} catch (IOException e) {
				throw new RuntimeException(e);
			}
			
			System.out.println("Root element: " + xmlDoc.getDocumentElement().getNodeName());
			return xmlDoc;
		}

		static String getXmlString(TinyElementImpl node)
		throws Exception
		{
			// Converts an XML node to a string (_with_ an XML Delcaration)   
			TransformerFactory tFactory = TransformerFactory.newInstance("net.sf.saxon.TransformerFactoryImpl", null);
			StringWriter sbuffer = new StringWriter();
			Transformer transformer = tFactory.newTransformer();
			transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "no");
			transformer.transform(node,
				new StreamResult(sbuffer));
			return sbuffer.toString();
		}

		};
	}

}