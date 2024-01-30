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
        <xsl:variable name="prev-eqn-num-count" select="count(preceding::*[contains(@class, ' equation-d/equation-number ')])"/>
        <xsl:variable name="eqn-count-actual" select="$prev-eqn-num-count + 1"/>
        <fo:inline>
            <xsl:call-template name="commonattributes"/>
            <xsl:attribute name="font-style">normal</xsl:attribute>
            <xsl:text>(</xsl:text>
            <xsl:choose>
                <xsl:when test="child::* or child::text()">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$eqn-count-actual"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>)</xsl:text>
        </fo:inline>
    </xsl:template>
    
    <!-- TODO: equation definition lists; see how normal dls are structured -->
    <!--<xsl:template match="*[contains(@class,' equation-d/equation-figure ')]//*[contains(@class,'- topic/dl ')]"  name="topic.equation-d.fig.dl">
        <!-\- generate leader text when <dt> follows an equation -\->
        <xsl:if test="preceding-sibling::*[contains(@class,' equation-d/equation-block ')]">
            <p class="eqn-leader">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Where'"/>
                </xsl:call-template>
            </p>
        </xsl:if>
    </xsl:template>-->
    
    
    <xsl:attribute-set name="math-content" use-attribute-sets="font.san-serif">
        <xsl:attribute name="font-weight">400</xsl:attribute>
        <xsl:attribute name="font-style">italic</xsl:attribute>
    </xsl:attribute-set>        
    
    
</xsl:stylesheet>