<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mathjax="https://www.mathjax.org/MathMLToSVG"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    exclude-result-prefixes="xs mathjax saxon m"
    version="3.0">
    
    <xsl:output method="html" indent="yes"/>
    
    <xsl:template match="/doc">
        <html>
            <head>
                <title>Test</title>
            </head>
            <body>
                <xsl:apply-templates/>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="//p">
        <p><xsl:apply-templates/></p>
    </xsl:template>
    
    <xsl:template match="//m:math | //math">
        <xsl:variable name="contents" select="."/>
        <xsl:copy-of select="parse-xml(mathjax:mml2svg($contents))" use-when="not(function-available('saxon:parse'))"/>
        <xsl:copy-of select="saxon:parse(mathjax:mml2svg($contents))" use-when="function-available('saxon:parse')"/>
    </xsl:template>
    
   
</xsl:stylesheet>