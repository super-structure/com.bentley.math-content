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
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:mathjax="https://www.mathjax.org/MathMLToSVG"
    xmlns:jeuclid="https://jeuclid.sourceforge.net/MathMLToSVG"
    exclude-result-prefixes="#all"
    version="3.0">

    <xsl:param name="MATH-PROC"/>
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <!-- *[contains(@class,' equation-d/equation-block ')]/ -->
    <xsl:template match="*[contains(@class, ' mathml-d/mathml ')]">        
        <xsl:variable name="element-type">
            <xsl:choose>
                <xsl:when test="parent::*[contains(@class,' equation-d/equation-inline ')]">span</xsl:when>
                <xsl:otherwise>div</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:element name="{$element-type}">
            <xsl:attribute name="class">mathml</xsl:attribute>
            <xsl:call-template name="apply-mathml"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="apply-mathml">
        <!-- pick a template mode based on the processing specified -->
        <xsl:choose>
            <xsl:when test="$MATH-PROC = 'mathjax-pre' or $MATH-PROC = 'jeuclid'">
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
            <xsl:apply-templates select="* | @* | text()" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="m:*/@*" mode="dita-ot:mathml" priority="10">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="m:math" mode="mathjax:mathml">
        <!-- apply either mathjax-pre or jeuclid function on this filename; return SVG -->
        <xsl:variable name="mathml" select="."/>
        <!--<xsl:call-template name="convert-mathml2svg-mathjax">
            <xsl:with-param name="mathml">
                <xsl:copy-of select="."/>
            </xsl:with-param>
        </xsl:call-template>-->
        <xsl:choose>
            <xsl:when test="$MATH-PROC = 'mathjax-pre'">
                <!-- use custom java function 'mathjax:mml2svg'-->
                <xsl:message>Transforming MathML to SVG using MathJax</xsl:message>
                <xsl:copy-of select="parse-xml(mathjax:mml2svg($mathml))" use-when="not(function-available('saxon:parse'))"/>
                <xsl:copy-of select="saxon:parse(mathjax:mml2svg($mathml))" use-when="function-available('saxon:parse')"/>
            </xsl:when>
            <xsl:when test="$MATH-PROC = 'jeuclid'">
                <!-- use custom java function 'jeuclid:mml2svg' -->
                <xsl:message>**JEuclid support for transforming MathML to be completed.**</xsl:message>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- to prevent breaks between equation content and line number -->
    <xsl:template match="@display" mode="dita-ot:mathml" priority="10"/>  

    <!-- TODO: this may need to be moved to 'topicpull' so that common mathml processing can also be done here -->
    <xsl:template match="*[contains(@class, ' mathml-d/mathmlref ')]" mode="dita-ot:mathml" priority="10">
        <xsl:apply-templates select="document(@href)/*" mode="dita-ot:mathml"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' mathml-d/mathmlref ')]" mode="mathjax:mathml" priority="10">
        <!-- apply either mathjax-pre or jeuclid function on this filename -->
        <xsl:variable name="mathml-root" select="name(document(@href)/*/*)"/>
        <xsl:variable name="mathml">
            <xsl:copy-of select="document(@href)/math/*"/>
        </xsl:variable>
        
        <!--<xsl:call-template name="convert-mathml2svg-mathjax">
            <xsl:with-param name="mathml" select="document(@href)/*"/>
        </xsl:call-template>-->
        <xsl:message>root element of file: <xsl:value-of select="name($mathml/*)"/></xsl:message>
        <xsl:choose>
            <xsl:when test="$MATH-PROC = 'mathjax-pre'">
                <!-- use custom java function 'mathjax:mml2svg'-->
                <xsl:message>Transforming MathML to SVG using MathJax</xsl:message>
                <xsl:copy-of select="parse-xml(mathjax:mml2svg($mathml))" use-when="not(function-available('saxon:parse'))"/>
                <xsl:copy-of select="saxon:parse(mathjax:mml2svg($mathml))" use-when="function-available('saxon:parse')"/>
            </xsl:when>
            <xsl:when test="$MATH-PROC = 'jeuclid'">
                <!-- use custom java function 'jeuclid:mml2svg' -->
                <xsl:message>**JEuclid support for transforming MathML to be completed.**</xsl:message>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="convert-mathml2svg-mathjax">
        <xsl:param name="mathml"/>
        <xsl:choose>
            <xsl:when test="$MATH-PROC = 'mathjax-pre'">
                <!-- use custom java function 'mathjax:mml2svg'-->
                <xsl:message>Transforming MathML to SVG using MathJax</xsl:message>
                <xsl:copy-of select="parse-xml(mathjax:mml2svg($mathml))" use-when="not(function-available('saxon:parse'))"/>
                <xsl:copy-of select="saxon:parse(mathjax:mml2svg($mathml))" use-when="function-available('saxon:parse')"/>
            </xsl:when>
            <xsl:when test="$MATH-PROC = 'jeuclid'">
                <!-- use custom java function 'jeuclid:mml2svg' -->
                <xsl:message>**JEuclid support for transforming MathML to be completed.**</xsl:message>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- identify function just in case -->
    <!--<xsl:template match="@* | node()" mode="dita-ot:mathml">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>-->
    
</xsl:stylesheet>