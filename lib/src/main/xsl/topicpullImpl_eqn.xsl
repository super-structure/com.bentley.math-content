<?xml version="1.0" encoding="UTF-8"?>
<!-- ******************************************************************************
* XML Stylesheet to pull link text for references to equations.
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
    
    <xsl:template match="*[contains(@class, ' equation-d/equation-number ')]" mode="topicpull:resolvelinktext">
        <xsl:apply-templates select="." mode="text-only"/>
    </xsl:template>
    <!-- Set the format for generated text for links to tables and figures.   -->
    <!-- Recognized values are 'NUMBER' (Table 5) and 'TITLE' (Table Caption) -->
    <xsl:param name="EQUATIONLINK">NUMBER</xsl:param>   <!-- should be set using the args.eqnlink.style dita-ot parameter for this plugin -->
    
    <xsl:key name="count.topic.equation"
        match="*[contains(@class, ' equation-d/equation-block ')][*[contains(@class,' equation-d/equation-number ')]]"
        use="'include'"/>
    
    <xsl:template match="*[contains(@class, ' equation-d/equation-block ')][*[contains(@class,' equation-d/equation-number ')]]" mode="topicpull:resolvelinktext">
        <xsl:variable name="eqn-count-actual">
            <xsl:apply-templates select="*[contains(@class,' equation-d/equation-number ')][1]" mode="topicpull:eqnnumber"/>
        </xsl:variable>
        <xsl:apply-templates select="." mode="topicpull:equation-linktext">
            <xsl:with-param name="eqntext"><xsl:call-template name="getVariable"><xsl:with-param name="id" select="'Equation'"/></xsl:call-template></xsl:with-param>
            <xsl:with-param name="eqncount" select="$eqn-count-actual"/>
            <xsl:with-param name="eqntitle" as="node()*">
                <xsl:sequence select="*[contains(@class,' equation-d/equation-number ')][1]"/>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- Determine the text for a link to a table. Currently uses table title. -->
    <xsl:template match="*" mode="topicpull:equation-linktext">
        <xsl:param name="eqntext"/>
        <xsl:param name="eqncount"/>
        <xsl:param name="eqntitle"/> <!-- Currently unused, but may be picked up by an override -->
        <xsl:param name="eqnnum"/>
        <xsl:choose>
            <xsl:when test="$EQUATIONLINK='TITLE'">
                <xsl:apply-templates select="$eqntitle" mode="text-only"/>
            </xsl:when>
            <xsl:otherwise> <!-- Default: EQUATIONLINK='NUMBER' -->
                <!--<xsl:value-of select="$eqntext"/>-->
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'equation-number-separator'"/>
                </xsl:call-template>
                <xsl:value-of select="$eqncount"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Determine the number of the equation being linked to -->
    <xsl:template match="*[contains(@class, ' equation-d/equation-block ')][*[contains(@class,' equation-d/equation-number ')]] | *[contains(@class,' equation-d/equation-block ')][@spectitle]" mode="topicpull:eqnnumber">
        <xsl:call-template name="compute-number">
            <xsl:with-param name="all">
                <xsl:number from="/*" count="key('count.topic.equation','include')" level="any"/>
            </xsl:with-param>
            <xsl:with-param name="except">
                <xsl:number from="/*" count="key('count.topic.equation','exclude')" level="any"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
</xsl:stylesheet>