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
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:template match="*[contains(@class, ' mathml-d/mathml ')]">
        <xsl:apply-templates mode="dita-ot:mathml"/>
    </xsl:template>
    
    <!-- strip out the namespace for HTML5 -->
    <xsl:template match="m:*" mode="dita-ot:mathml" priority="10">
        <xsl:element name="{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:element>
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
    
    
</xsl:stylesheet>