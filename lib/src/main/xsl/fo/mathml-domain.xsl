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
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:template match="*[contains(@class, ' mathml-d/mathml ')]">
        <xsl:message>Reached matml-domain</xsl:message>
        <xsl:if test="child::*">
            <fo:instream-foreign-object>
                <xsl:apply-templates mode="dita-ot:mathml"/>
                <!--<m:math mode="inline">
                    <m:mtext>here!</m:mtext>
                </m:math>-->
            </fo:instream-foreign-object>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="m:*" mode="dita-ot:mathml" priority="10">
        <xsl:element name="m:{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
            <xsl:if test="local-name()='math'">
                <xsl:attribute name="mode">inline</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' mathml-d/mathmlref ')]" mode="dita-ot:mathml" priority="10">
        <xsl:apply-templates select="document(@href)/*" mode="dita-ot:mathml"/>    
    </xsl:template>
    
</xsl:stylesheet>