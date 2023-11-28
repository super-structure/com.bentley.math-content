<?xml version="1.0" encoding="UTF-8"?>
<!-- ******************************************************************************
* XML Stylesheet to provide templates for equation domain items in DITA
* to PDF2 output.
*
* 2023-06-22 Jason Coleman
* Copyright © Bentley Systems, Incorporated. All rights reserved.
*
****************************************************************************** -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    exclude-result-prefixes="xs ditaarch"
    version="2.0">
    
    <xsl:import href="mathml-domain.xsl"/>
    <!--<xsl:import href="pdf_LaTeX2SVG.xsl"/>-->
    <!--<xsl:import href="MathJax_SVG.xsl"/>-->
    
    <xsl:template match="*[contains(@class,' equation-d/equation-block ')]" name="topic.equation-d.equation-block">
        <xsl:message>Reached equation-domain</xsl:message>
        <fo:block xsl:use-attribute-sets="math-content">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' equation-d/equation-figure ')]" name="topic.equation-d.equation-figure">
        <fo:block xsl:use-attribute-sets="math-content">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' equation-d/equation-inline ')]" name="topic.equation-d.equation-inline">
        <fo:inline xsl:use-attribute-sets="math-content">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' equation-d/equation-number ')]" name="topic.equation-d.equation-number">
        <fo:inline>()<xsl:comment>eqn number</xsl:comment></fo:inline>
    </xsl:template>
    
    <xsl:attribute-set name="math-content" use-attribute-sets="base-font">
        <xsl:attribute name="font-family">serif</xsl:attribute>
    </xsl:attribute-set>
    
</xsl:stylesheet>