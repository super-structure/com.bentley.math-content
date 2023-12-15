<?xml version="1.0" encoding="UTF-8"?>
<!-- ******************************************************************************
* XML Stylesheet to provide templates for MathML domain items in DITA
* to HTML and PDF output.
*
* 2023-06-22 Jason Coleman
* Copyright © Bentley Systems, Incorporated. All rights reserved.
*
****************************************************************************** -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    xmlns:mathjax="https://www.mathjax.org/MathMLToSVG"
    xmlns:jeuclid="https://jeuclid.sourceforge.net/MathMLToSVG"
    exclude-result-prefixes="#all"
    version="3.0">

    <xsl:param name="MATH-PROC"/>
    
    <xsl:output name="mathml" method="xml" indent="no" encoding="UTF-8"
        doctype-public="-//W3C//DTD MathML 3.0//EN"
        doctype-system="http://www.w3.org/Math/DTD/mathml3/mathml3.dtd"/>
    
    <xsl:template match="*[contains(@class, ' mathml-d/mathml ')]">
        <!-- pick a template mode based on the processing specified -->
        <xsl:choose>
            <xsl:when test="$MATH-PROC = 'mathjax-pre' or $MATH-PROC = 'jeuclid'">
                <!-- write mathml contents out to .mml file -->
                <xsl:apply-templates mode="mathjax:mathml"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- to have MathJax render client-side or to just do nothing -->
                <xsl:apply-templates mode="dita-ot:mathml"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- strip out the namespace for HTML5 -->
    <xsl:template match="m:*" mode="dita-ot:mathml" priority="10">
        <xsl:element name="{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="m:math" mode="mathjax:mathml">
        <xsl:variable name="id" select="'mathml_' || generate-id(.)"/>
        <xsl:variable name="filename" select="$id || '.mml'"/>
        <!-- create a temporary .mml document -->
        <xsl:result-document href="{$filename}" format="mathml">
            <xsl:apply-templates select="." mode="dita-ot:mathml"/>
        </xsl:result-document>
        <!-- apply either mathjax-pre or jeuclid function on this filename; return SVG (or read in SVG file)? -->
        <xsl:choose>
            <xsl:when test="$MATH-PROC = 'mathjax-pre'">
                <!-- use custom java function 'mathjax:mml2svg'-->
            </xsl:when>
            <xsl:when test="$MATH-PROC = 'jeuclid'">
                <!-- use custom java function 'jeuclid:mml2svg' -->
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- identify function just in case -->
    <xsl:template match="@* | node()" mode="dita-ot:mathml">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@display" mode="dita-ot:mathml" priority="10"/>    <!-- to prevent breaks between equation content and line number -->

    <!-- JTC: this may need to be moved to 'topicpull' so that common mathml processing can also be done here -->
    <xsl:template match="*[contains(@class, ' mathml-d/mathmlref ')]" mode="dita-ot:mathml" priority="10">
        <xsl:apply-templates select="document(@href)/*" mode="dita-ot:mathml"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' mathml-d/mathmlref ')]" mode="mathjax:mathml" priority="10">
        <!-- already an external file -->
        <!-- apply either mathjax-pre or jeuclid function on this filename -->
    </xsl:template>
    
    
</xsl:stylesheet>