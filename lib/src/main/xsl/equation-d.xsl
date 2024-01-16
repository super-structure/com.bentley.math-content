<?xml version="1.0" encoding="UTF-8"?>
<!-- ******************************************************************************
* XML Stylesheet to provide templates for equation domain items in DITA
* to HTML output.
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
    
    <xsl:param name="MATH-PROC"/>
    <xsl:param name="EQN-PREFIX"/>
    
    <xsl:import href="mathml-d.xsl"/>
    <!--<xsl:import href="xhtml_LaTeX2SVG.xsl"/>-->
    
    <xsl:template match="*[contains(@class,' equation-d/equation-block ')]" name="topic.equation-d.equation-block">
        <div>
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setid"/>
            <xsl:choose>
                <xsl:when test="count(child::*[contains(@class,' mathml-d/mathml ')]) &gt; 1">
                    <!-- nest multipel <mathml> elements in a div; need to put this in a for-each loop -->
                    <div class="mathmls">
                        <xsl:for-each select="*[contains(@class,' mathml-d/mathml ')]">
                            <xsl:apply-templates select="current()"/>
                        </xsl:for-each>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*[contains(@class,' mathml-d/mathml ')]"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="*[contains(@class,' equation-d/equation-number ')]"/>
        </div>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' equation-d/equation-figure ')]" name="topic.equation-d.equation-figure">
        <div>
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setid"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' equation-d/equation-inline ')]" name="topic.equation-d.equation-inline">
        <span>
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setid"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- also refer to mode="label" in \org.dita.html5\xsl\tables.xsl -->
    <!-- TODO: generate target ID value for linking -->
    <xsl:template match="*[contains(@class,' equation-d/equation-number ')]" name="topic.equation-d.equation-number">
        <xsl:variable name="prev-eqn-num-count" select="count(preceding::*[contains(@class, ' equation-d/equation-number ')])"/>
        <xsl:variable name="eqn-count-actual" select="$prev-eqn-num-count + 1"/>
        <span>
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setid"/>
            <xsl:text>(</xsl:text>
            <xsl:choose>
                <xsl:when test="child::* or child::text()">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <!--<xsl:call-template name="getVariable">
                        <xsl:with-param name="id">
                            <xsl:choose>
                                <xsl:when test="$EQN-PREFIX = 'abbr'">EqnAbbr</xsl:when>
                                <xsl:otherwise>Equation</xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:text> </xsl:text>-->
                    <xsl:value-of select="$eqn-count-actual"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>)</xsl:text>
        </span>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' equation-d/equation-figure ')]//*[contains(@class,'- topic/dl ')]"  name="topic.equation-d.fig.dl">
        <!-- generate leader text when <dt> follows an equation -->
        <xsl:if test="preceding-sibling::*[contains(@class,' equation-d/equation-block ')]">
            <p class="eqn-leader">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Where'"/>
                </xsl:call-template>
            </p>
        </xsl:if>
        <dl>
            <xsl:call-template name="commonattributes">
                <xsl:with-param name="default-output-class">dl eqn-dl</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="setid"/>
            <xsl:apply-templates mode="eqn-fig-dl"/>
        </dl>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dlentry ')]" name="topic.equation-d.fig.dlentry" mode="eqn-fig-dl">
        <div>
            <xsl:call-template name="commonattributes">
                <xsl:with-param name="default-output-class">eqn-dlentry</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="setid"/>
            <xsl:apply-templates mode="eqn-fig-dl"/>
        </div>    
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dt ')]" name="topic.equation-d.fig.dt" mode="eqn-fig-dl">
        <dt>
            <xsl:call-template name="commonattributes">
                <xsl:with-param name="default-output-class">eqn-dt</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="setid"/>
            <xsl:apply-templates/>
        </dt>
        <div class="eqn-equal">=</div>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dd ')]" name="topic.equation-d.fig.dd" mode="eqn-fig-dl">
        <dd>
            <xsl:call-template name="commonattributes">
                <xsl:with-param name="default-output-class">eqn-dd</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="setid"/>
            <xsl:apply-templates/>
        </dd>
    </xsl:template>
    
</xsl:stylesheet>