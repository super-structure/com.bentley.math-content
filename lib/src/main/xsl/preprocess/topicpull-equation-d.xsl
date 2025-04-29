<?xml version="1.0" encoding="UTF-8"?>
<!-- ******************************************************************************
* XML Stylesheet to for pulling link text of XREFs to equation-blocks containing
* equation-numbers in HTML5 output.
*
* 2025-04-28 Jason Coleman
* Copyright © Bentley Systems, Incorporated. All rights reserved.
*
****************************************************************************** -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    xmlns:topicpull="http://dita-ot.sourceforge.net/ns/200704/topicpull"
    xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:param name="EQN-PREFIX" select="'abbr'"/>
    
    <xsl:variable name="equationlink.lead">
        <xsl:choose>
            <xsl:when test="$EQN-PREFIX = 'full'">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Equation'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'EqnAbbr'"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    
    <xsl:key name="count.topic.equation"
        match="*[contains(@class, ' equation-d/equation-block ')][*[contains(@class,' equation-d/equation-number ')]]"
        use="'include'"/>
    
    <xsl:template match="*[contains(@class, ' equation-d/equation-figure ')][descendant::*[contains(@class, ' equation-d/equation-number ')]] | 
        *[contains(@class, ' equation-d/equation-block ')][child::*[contains(@class, ' equation-d/equation-number ')]]" 
        mode="topicpull:resolvelinktext"
        priority="10">
        <xsl:value-of select="$equationlink.lead"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="descendant::*[contains(@class,' equation-d/equation-number ')][1]" mode="topicpull:eqnnumber"/>
    </xsl:template>
    
    <!-- Determine the number of the equation being linked to -->
    <xsl:template match="*[contains(@class,' equation-d/equation-number ')]" mode="topicpull:eqnnumber">
        <!-- 2025-04-25 JTC: This is a different approach that using 'key's; which is how tables and figures are handled -->
        <xsl:variable name="prev-eqn-num-count" select="count(preceding::*[contains(@class, ' equation-d/equation-number ')][not(ancestor::draft-comment) and not(child::* or child::text())])"/>
        <xsl:variable name="eqn-count-actual" select="$prev-eqn-num-count + 1"/>
        <xsl:choose>
            <xsl:when test="child::* or child::text()">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$eqn-count-actual"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>