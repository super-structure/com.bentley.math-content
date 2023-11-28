<?xml version="1.0" encoding="UTF-8"?>
<!-- ******************************************************************************
* XML Stylesheet to make corrections to MathJax SVG output for use in Apaohe FOP
*
* 2023-09-25 Jason Coleman
* Copyright © Bentley Systems, Incorporated. All rights reserved.
*
****************************************************************************** -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:svg="http://www.w3.org/2000/svg"
    exclude-result-prefixes="xs svg"
    version="2.0">
    
    <xsl:template match="//*[local-name()='svg'][@role='math']" priority="10">
        <xsl:comment>MathJax SVG</xsl:comment>
        <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
            <xsl:apply-templates mode="mathjax_css" select="@*"/>
            <xsl:apply-templates select="child::node()"/>
        </svg>
    </xsl:template>

    <xsl:template match="@width[contains(.,'ex')] | @height[contains(.,'ex')]" mode="mathjax_css" priority="10">
        <!-- MathJax SVGs use relative 'ex' length units, which causes an error in Apache FOP -->
        <xsl:attribute name="{./name()}">
            <xsl:call-template name="convert-ex-to-em">
                <xsl:with-param name="length-string" select="."/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="//*/@style[contains(.,'ex')]" mode="mathjax_css" priority="10">
        <!-- convert relative 'ex' units into 'em' units which can be used by FOP; leave other styles unchanced -->
        <!-- TODO: does not result in a propper sequence of nodes, thus the separator is not added -->
        <xsl:attribute name="{./name()}">
            <xsl:variable name="css-style">
                <xsl:for-each select="tokenize(.,';')">
                    <xsl:choose>
                        <xsl:when test="contains(.,'ex')"> <!-- TODO: need to use a regex pattern match here! -->
                            <xsl:variable name="style-name" select="substring-before(current(),':')"/>
                            <xsl:variable name="style-value" select="substring-after(current(),':')"/>
                            <xsl:variable name="length-in-em">
                                <xsl:call-template name="convert-ex-to-em">
                                    <xsl:with-param name="length-string" select="normalize-space($style-value)"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:value-of select="concat($style-name, ': ', $length-in-em,';')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="not(current()='')">
                                <xsl:value-of select="concat(current(),';')"/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="$css-style" separator=";"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template name="convert-ex-to-em">
        <!-- convert relative 'ex' units into 'em' units which can be used by FOP -->
        <xsl:param name="length-string"/>
        <xsl:variable name="length-ex" select="number(substring-before($length-string,'ex'))"/>
        <!-- Assume a value of 1em ≈ 2ex -->
        <xsl:value-of select="concat(0.5*$length-ex,'em')"/>
    </xsl:template>
    
    <xsl:template match="@*" mode="mathjax_css" priority="1">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node() | @*| comment()">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*| comment()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- web alt & accessibility items not used in PDF -->
    <xsl:template match="@role | @alt | @focusable | @aria-label" mode="mathjax_css" priority="2"/>
    
    <!-- specialized data attributes not part of SVG spec -->
    <xsl:template match="@data-mml-node | @data-c" priority="2"/>
    
</xsl:stylesheet>