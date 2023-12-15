<?xml version="1.0" encoding="UTF-8"?>
<!-- ******************************************************************************
* XML Stylesheet to add MathJax to end of the HTML5 body where required.
*
* Copyright © Bentley Systems, Incorporated. All rights reserved.
*
****************************************************************************** -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:param name="MATH-PROC"/>
    <xsl:param name="MATHJAX-DIR"/>
    
    <!-- ref: https://www.dita-ot.org/dev/topics/html-customization-plugin-javascript -->
    <xsl:template match="*[contains(@class,' topic/body ')]//mathml" mode="processFTR">
        <xsl:choose>
            <xsl:when test="$MATH-PROC = 'mathjax-cdn'">
                <script type="text/javascript" id="MathJax-script" async="true"
                    src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-svg.js"><xsl:text> </xsl:text></script>
            </xsl:when>
            <xsl:when test="$MATH-PROC = 'mathjax-local'">
                <script type="text/javascript" id="MathJax-script" async="true"
                    src="{$MATHJAX-DIR}/tex-mml-svg.js"><xsl:text> </xsl:text></script>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
