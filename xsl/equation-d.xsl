<?xml version="1.0" encoding="UTF-8"?>
<!-- ******************************************************************************
* XML Stylesheet to provide templates for equation domain items in DITA
* to HTML output.
*
* 2023-06-22 Jason Coleman
* Copyright © Bentley Systems, Incorporated. All rights reserved.
*
****************************************************************************** -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    xmlns:topicpull="http://dita-ot.sourceforge.net/ns/200704/topicpull"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="mathml-d.xsl"/>
    <xsl:import href="xhtml_LaTeX2SVG.xsl"/>
    
    <xsl:template match="*[contains(@class,' equation-d/equation-block ')]" name="topic.equation-d.equation-block">
        <div>
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setid"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' equation-d/equation-figure ')]" name="topic.equation-d.equation-figure">
        <div>
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setid"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' equation-d/equation-inline ')]" name="topic.equation-d.equation-inline">
        <span>
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setid"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- also refer to mode="label" in \org.dita.html5\xsl\tables.xsl -->
    <xsl:template match="*[contains(@class,' equation-d/equation-number ')]" name="topic.equation-d.equation-number">
        <xsl:variable name="prev-eqn-num-count" select="count(preceding::*[contains(@class, ' equation-d/equation-number ')])"/>
        <xsl:variable name="eqn-count-actual" select="$prev-eqn-num-count + 1"/>
        <span>
            <xsl:call-template name="commonattributes"/>
            <xsl:text>(</xsl:text>
            <xsl:choose>
                <xsl:when test="child::* or child::text()">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Eqn'"/>
                    </xsl:call-template>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$eqn-count-actual"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>)</xsl:text>
        </span>
    </xsl:template>
    
</xsl:stylesheet>