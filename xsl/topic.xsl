<?xml version="1.0" encoding="UTF-8"?>
<!-- ******************************************************************************
* XML Stylesheet to add MathJax to HTML5 head where required.
*
* Copyright © Bentley Systems, Incorporated. All rights reserved.
*
****************************************************************************** -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">    
    
    <xsl:template match="/ | @* | node()" mode="processHDR">
        <!-- Need to integrate this template with other plugins
             Currently hard-coded in com.bentley.html5: includes/bentley-hdf.xml
        -->
        <xsl:if test="descendant::mathml">
            <!-- TODO:
                - Include flag for using MathJax client-side rendering (vs. pre-render)
                - Include flag for using local copy of MathJax vs CDN
                - Move this to the processFTR template
            -->
            <script type="text/javascript" id="MathJax-script" async="true"
                src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-svg.js"><xsl:text> </xsl:text></script>
        </xsl:if>
    </xsl:template>

    
</xsl:stylesheet>