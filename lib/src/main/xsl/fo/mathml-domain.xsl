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
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:mathjax="https://www.mathjax.org/MathMLToSVG"
    xmlns:jeuclid="https://jeuclid.sourceforge.net/MathMLToSVG"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:param name="MATH-PROC"/>
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="*[contains(@class, ' mathml-d/mathml ')]">
        <xsl:message>MATH-PROC: [<xsl:value-of select="$MATH-PROC"/>]</xsl:message>
        <fo:inline>
            <xsl:call-template name="apply-mathml"/>
        </fo:inline>
    </xsl:template>
    
    <xsl:template name="apply-mathml">
        <fo:instream-foreign-object alignment-baseline="mathematical">
            <xsl:if test="ancestor::equation-figure/@scale">
                <xsl:attribute name="content-width" select="ancestor::equation-figure/@scale || '%'"/>
            </xsl:if>
            <!-- pick a template mode based on the processing specified -->
            <xsl:choose>
                <xsl:when test="$MATH-PROC = 'mathjax-pre'">
                    <xsl:apply-templates mode="mathjax:mathml"/>
                </xsl:when>
                <xsl:when test="$MATH-PROC = 'jeuclid'">
                    <xsl:apply-templates mode="jeuclid:mathml"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- or just do nothing (let the FO rendering deal with MathML) -->
                    <xsl:apply-templates mode="dita-ot:mathml"/>
                </xsl:otherwise>
            </xsl:choose>
        </fo:instream-foreign-object>
    </xsl:template>
    
    <xsl:template match="m:*" mode="dita-ot:mathml" priority="10">
        <xsl:element name="{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
            <xsl:apply-templates select="* | @* | text()" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="m:*/@*" mode="dita-ot:mathml" priority="10">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' mathml-d/mathmlref ')]" mode="dita-ot:mathml" priority="10">
        <xsl:variable name="mathml">
            <xsl:copy-of select="document(@href)/*"/>
        </xsl:variable>
        <xsl:call-template name="convert-mathml2svg-mathjax">
            <xsl:with-param name="mathml" select="document(@href)/*"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="m:math" mode="mathjax:mathml">
        <!-- apply mathjax-pre function on this filename; return SVG -->
        <xsl:variable name="mathml" select="."/>        
        <xsl:call-template name="convert-mathml2svg-mathjax">
            <xsl:with-param name="mathml">
                <xsl:copy-of select="."/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' mathml-d/mathmlref ')]" mode="mathjax:mathml" priority="10">
        <xsl:variable name="mathml">
            <xsl:copy-of select="document(@href)/*"/>
        </xsl:variable>        
        <xsl:call-template name="convert-mathml2svg-mathjax">
            <xsl:with-param name="mathml" select="document(@href)/*"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="convert-mathml2svg-mathjax">
        <xsl:param name="mathml"/>
        <!-- apply mathjax-pre function on this filename using custom java function 'mathjax:mml2svg'-->
        <xsl:message>Transforming MathML to SVG using MathJax</xsl:message>
        <xsl:copy-of select="parse-xml(mathjax:mml2svg($mathml))" use-when="not(function-available('saxon:parse'))"/>
        <xsl:copy-of select="saxon:parse(mathjax:mml2svg($mathml))" use-when="function-available('saxon:parse')"/>
    </xsl:template>
    
    <xsl:template match="m:math" mode="jeuclid:mathml">
        <!-- apply jeuclid function on this filename; return SVG -->
        <xsl:variable name="mathml" select="."/>        
        <xsl:call-template name="convert-mathml2svg-jeuclid">
            <xsl:with-param name="mathml">
                <xsl:copy-of select="."/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' mathml-d/mathmlref ')]" mode="jeuclid:mathml" priority="10">
        <xsl:variable name="mathml">
            <xsl:copy-of select="document(@href)/*"/>
        </xsl:variable>        
        <xsl:call-template name="convert-mathml2svg-jeuclid">
            <xsl:with-param name="mathml" select="document(@href)/*"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="convert-mathml2svg-jeuclid">
        <xsl:param name="mathml"/>
        <!-- apply jeuclid function on this filename using custom java function 'jeuclid:mml2svg' -->
        <xsl:message>Transforming MathML to SVG using JEuclid</xsl:message>
        <xsl:copy-of select="parse-xml(jeuclid:mml2svg($mathml))" use-when="not(function-available('saxon:parse'))"/>
        <xsl:copy-of select="saxon:parse(jeuclid:mml2svg($mathml))" use-when="function-available('saxon:parse')"/>
    </xsl:template>
    
</xsl:stylesheet>