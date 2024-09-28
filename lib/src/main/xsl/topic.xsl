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
    <!--<xsl:param name="MATHJAX-DIR"/>-->
    
    <xsl:template match="/ | @* | node()" mode="processHDF">
        <xsl:variable name="relpath">
            <xsl:choose>
                <xsl:when test="$FILEDIR='.'">
                    <xsl:text>.</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="replace(replace($FILEDIR, '\\', '/') ,'[^/]+','..')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$MATH-PROC = 'mathjax-cdn'">
                <xsl:message>Adding MathJax CDN script element...</xsl:message>
                <script>
                    MathJax = {
                        tex: {
                            inlineMath: [['$', '$'], ['\\(', '\\)']]
                        },
                        svg: {
                            scale: 1.25,
                            fontCache: 'global'
                        }
                    };
                </script>
                <script type="text/javascript" id="MathJax-script" async="true"
                    src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-svg.js"><xsl:text> </xsl:text></script>
            </xsl:when>
            <!-- use a local mathjax copy for 'mathjax-local' -->
            <xsl:when test="$MATH-PROC = 'mathjax-local'">
                <xsl:message>Adding local MathJax script element...</xsl:message>
                <script type="text/javascript" id="MathJax-script"
                    src="{$relpath}/js/tex-mml-svg.js"><xsl:text> </xsl:text></script>
            </xsl:when>
        </xsl:choose>
        
        <xsl:next-match/>
    </xsl:template>
    
</xsl:stylesheet>
