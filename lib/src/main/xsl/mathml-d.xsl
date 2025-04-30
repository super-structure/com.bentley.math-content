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
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:mathjax="https://www.mathjax.org/MathMLToSVG"
    xmlns:jeuclid="https://jeuclid.sourceforge.net/MathMLToSVG"
    exclude-result-prefixes="#all"
    version="3.0">

    <xsl:param name="MATH-PROC"/>
    <xsl:param name="MATHML-SVG-FILE"/>
    
    <xsl:output name="svg" method="xml" doctype-public="-//W3C//DTD SVG 1.1//EN" doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" indent="no" encoding="UTF-8"/>
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <!-- *[contains(@class,' equation-d/equation-block ')]/ -->
    <xsl:template match="*[contains(@class, ' mathml-d/mathml ')]">        
        <xsl:variable name="element-type">
            <xsl:choose>
                <xsl:when test="parent::*[contains(@class,' equation-d/equation-inline ')]">span</xsl:when>
                <xsl:otherwise>div</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:element name="{$element-type}">
            <xsl:attribute name="class">mathml</xsl:attribute>
            <xsl:call-template name="apply-mathml"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="apply-mathml">
        <!-- pick a template mode based on the processing specified -->
        <xsl:choose>
            <xsl:when test="$MATH-PROC = 'mathjax-pre'">
                <xsl:apply-templates mode="mathjax:mathml"/>
            </xsl:when>
            <xsl:when test="$MATH-PROC = 'jeuclid'">
                <xsl:apply-templates mode="jeuclid:mathml"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- to have MathJax render client-side or to just do nothing -->
                <xsl:apply-templates mode="dita-ot:mathml"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ============ Client Side MathML Processing (dita-ot:mathml mode) ============ -->
    <!-- strip out the namespace for HTML5 -->
    <xsl:template match="m:*" mode="dita-ot:mathml" priority="10">
        <xsl:element name="{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
            <xsl:apply-templates select="* | @* | text()" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="m:*/@*" mode="dita-ot:mathml" priority="10">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <!-- to prevent breaks between equation content and line number -->
    <xsl:template match="@display" mode="dita-ot:mathml" priority="10"/>  

    <!-- TODO: this may need to be moved to 'topicpull' so that common mathml processing can also be done here -->
    <xsl:template match="*[contains(@class, ' mathml-d/mathmlref ')]" mode="dita-ot:mathml" priority="10">
        <xsl:apply-templates select="document(@href)/*" mode="dita-ot:mathml"/>
    </xsl:template>
    
    <!-- ============ DITA OT MathML Pre-Processing (mathjax:mathml mode) ============ -->
    
    <xsl:template match="m:math" mode="mathjax:mathml">
        <xsl:call-template name="convert-mathml2svg-mathjax">
            <xsl:with-param name="mathml">
                <xsl:copy-of select="."/>
            </xsl:with-param>
            <xsl:with-param name="filename" select="'MathML_' || generate-id(.) || '.mml'"/>
            <xsl:with-param name="img-alttext" select="./@alttext"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' mathml-d/mathmlref ')]" mode="mathjax:mathml" priority="10">
        <xsl:variable name="mathml">
            <xsl:copy-of select="document(@href)/*"/>
        </xsl:variable>
        
        <xsl:call-template name="convert-mathml2svg-mathjax">
            <xsl:with-param name="mathml" select="document(@href)/*"/>
            <xsl:with-param name="filename" select="@href"/>
            <xsl:with-param name="img-alttext" select="$mathml/*/@alttext"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="convert-mathml2svg-mathjax">
        <xsl:param name="mathml"/>
        <xsl:param name="filename"/>
        <xsl:param name="img-alttext"/>
        
        <xsl:choose>
            <!-- use custom java function 'mathjax:mml2svg'-->
            <xsl:when test="$MATHML-SVG-FILE = 'yes'">
                <xsl:variable name="svg-filename" select="substring-before($filename,'.mml') || '.svg'"/>
                <!-- writes the resulting SVG file to the *output* directory -->
                <xsl:result-document href="{$svg-filename}" format="svg">
                    <xsl:copy-of select="parse-xml(mathjax:mml2svg($mathml))" use-when="not(function-available('saxon:parse'))"/>
                    <xsl:copy-of select="saxon:parse(mathjax:mml2svg($mathml))" use-when="function-available('saxon:parse')"/>
                </xsl:result-document>
                <!--<img class="math" src="{$svg-filename}">
                    <xsl:choose>
                        <xsl:when test="not($img-alttext = '')">
                            <xsl:attribute name="alt" select="$img-alttext"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-\- TODO: improve this message with some identifier to the specific m:math element -\->
                            <xsl:call-template name="output-message">
                                <xsl:with-param name="id" select="'MJXX001I'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </img>-->
                
                
                <xsl:call-template name="write-svg-file">
                    <xsl:with-param name="svg-filename" select="$svg-filename"/>
                    <xsl:with-param name="img-alttext" select="$img-alttext"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>&#010; transforming MathML to SVG using MathJax</xsl:message>
                <xsl:copy-of select="parse-xml(mathjax:mml2svg($mathml))" use-when="not(function-available('saxon:parse'))"/>
                <xsl:copy-of select="saxon:parse(mathjax:mml2svg($mathml))" use-when="function-available('saxon:parse')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ============ DITA OT MathML Pre-Processing (jeuclid:mathml mode) ============ -->
    
    <xsl:template match="m:math" mode="jeuclid:mathml">
        <xsl:call-template name="convert-mathml2svg-jeuclid">
            <xsl:with-param name="mathml">
                <xsl:copy-of select="."/>
            </xsl:with-param>
            <xsl:with-param name="filename" select="'MathML_' || generate-id(.) || '.mml'"/>
            <xsl:with-param name="img-alttext" select="./@alttext"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' mathml-d/mathmlref ')]" mode="jeuclid:mathml" priority="10">
        <xsl:variable name="mathml">
            <xsl:copy-of select="document(@href)/*"/>
        </xsl:variable>
        
        <xsl:call-template name="convert-mathml2svg-jeuclid">
            <xsl:with-param name="mathml" select="document(@href)/*"/>
            <xsl:with-param name="filename" select="@href"/>
            <xsl:with-param name="img-alttext" select="$mathml/*/@alttext"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="convert-mathml2svg-jeuclid">
        <xsl:param name="mathml"/>
        <xsl:param name="filename"/>
        <xsl:param name="img-alttext"/>
        <!-- apply jeuclid function on this filename using custom java function 'jeuclid:mml2svg' -->
        <xsl:choose>
            <xsl:when test="$MATHML-SVG-FILE = 'yes'">
                <xsl:variable name="svg-filename" select="substring-before($filename,'.mml') || '.svg'"/>
                
                <!-- writes the resulting SVG file to the *output* directory -->
                <xsl:result-document href="{$svg-filename}" format="svg">
                    <xsl:copy-of select="parse-xml(mathjax:mml2svg($mathml))" use-when="not(function-available('saxon:parse'))"/>
                    <xsl:copy-of select="saxon:parse(mathjax:mml2svg($mathml))" use-when="function-available('saxon:parse')"/>
                </xsl:result-document>
                
                <xsl:call-template name="write-svg-file">
                    <xsl:with-param name="svg-filename" select="$svg-filename"/>
                    <xsl:with-param name="img-alttext" select="$img-alttext"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>&#010; transforming MathML to SVG using JEuclid</xsl:message>
                <xsl:copy-of select="parse-xml(jeuclid:mml2svg($mathml))" use-when="not(function-available('saxon:parse'))"/>
                <xsl:copy-of select="saxon:parse(jeuclid:mml2svg($mathml))" use-when="function-available('saxon:parse')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="write-svg-file">
        <xsl:param name="svg-filename"/>
        <xsl:param name="img-alttext"/>
        
        <img class="math" src="{$svg-filename}">
            <xsl:choose>
                <xsl:when test="not($img-alttext = '')">
                    <xsl:attribute name="alt" select="$img-alttext"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- TODO: improve this message with some identifier to the specific m:math element -->
                    <xsl:call-template name="output-message">
                        <xsl:with-param name="id" select="'MJXX001I'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </img>
    </xsl:template>
    
</xsl:stylesheet>