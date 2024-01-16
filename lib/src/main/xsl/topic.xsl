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
    
    <!-- ref: https://www.dita-ot.org/dev/topics/html-customization-plugin-javascript -->
    <xsl:template match="*[contains(@class,' topic/body ')][descendant::mathml]" mode="processFTR">
        <xsl:choose>
            <xsl:when test="$MATH-PROC = 'mathjax-cdn'">
                <xsl:message>Adding MathJax CDN script element…</xsl:message>
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
                <script src="https://polyfill.io/v3/polyfill.min.js?features=es6"><xsl:text> </xsl:text></script>
                <script type="text/javascript" id="MathJax-script" async="true"
                    src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-svg.js"><xsl:text> </xsl:text></script>
            </xsl:when>
            <!-- use a local mathjax copy for 'mathjax-local' -->
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
