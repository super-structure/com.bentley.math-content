<?xml version="1.0" encoding="UTF-8"?>
<!-- ******************************************************************************
* XML Stylesheet to provide templates for equation domain items in DITA
* to HTML output.
*
* 2023-06-22 Jason Coleman
* Copyright © Bentley Systems, Incorporated. All rights reserved.
*
* Rev 1: 2025-04-25 JTC: added xref using equation number; updated to XSLT 3.0
*
****************************************************************************** -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    xmlns:topicpull="http://dita-ot.sourceforge.net/ns/200704/topicpull"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:import href="mathml-d.xsl"/>
    
    <xsl:param name="MATH-PROC"/>
    <xsl:param name="EQN-PREFIX" select="'abbr'"/>
    <!--<xsl:param name="equationlink.style" select="'NUMBER'"/>-->
    
    <xsl:variable name="equationlink.lead">
        <xsl:choose>
            <xsl:when test="$EQN-PREFIX = 'full'">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Equation'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'EqnAbbr'"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    
    <xsl:key name="count.topic.equations"
        match="*[contains(@class, ' equation-d/equation-block ')][*[contains(@class, ' equation-d/equation-number ')]]"
        use="'include'"/>
    
    <xsl:template match="*[contains(@class,' equation-d/equation-block ')]" name="topic.equation-d.equation-block">
        <div>
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setid"/>
            <!-- process 'text' math content -->
            <div class="equation-text">
               <xsl:apply-templates select="*[not(self::*[contains(@class,' mathml-d/mathml ')] or
                self::*[contains(@class,' equation-d/equation-number ')])] | text()"/>
            </div>
            <!-- process mathml content -->
            <xsl:choose>
                <xsl:when test="count(child::*[contains(@class,' mathml-d/mathml ')]) &gt; 1">
                    <!-- nest multiple <mathml> elements in a div; need to put this in a for-each loop -->
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
            <!-- process equation number -->
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
    <!-- TODO: allow for 'formatting' of the equation number, such as for PLAXIS: Eq [#] -->
    <xsl:template match="*[contains(@class,' equation-d/equation-number ')]" name="topic.equation-d.equation-number">
        <!--<xsl:variable name="prev-eqn-num-count" select="count(preceding::*[contains(@class, ' equation-d/equation-number ')])"/>
        <xsl:variable name="eqn-count-actual" select="$prev-eqn-num-count + 1"/>-->
        <span>
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setid"/>
            <xsl:text>(</xsl:text>
            <xsl:apply-templates select="." mode="eqn.title-number"/>
            <xsl:text>)</xsl:text>
        </span>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' equation-d/equation-number ')]" mode="eqn.title-number">
        <!-- 2025-04-25 JTC: This is a different approach that using 'key's; which is how tables and figures are handled -->
        <xsl:variable name="prev-eqn-num-count" select="count(preceding::*[contains(@class, ' equation-d/equation-number ')][not(ancestor::draft-comment) and not(child::* or child::text())])"/>
        <xsl:variable name="eqn-count-actual" select="$prev-eqn-num-count + 1"/>
        <xsl:choose>
            <xsl:when test="child::* or child::text()">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$eqn-count-actual"/>
            </xsl:otherwise>
        </xsl:choose>
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
    
    <xsl:template match="*[contains(@class, ' equation-d/equation-figure ')][descendant::*[contains(@class, ' equation-d/equation-number ')]] | 
        *[contains(@class, ' equation-d/equation-block ')][child::*[contains(@class, ' equation-d/equation-number ')]] |
        *[contains(@class, ' equation-d/equation-block ')] | *[contains(@class, ' equation-d/equation-figure ')]" 
        mode="topicpull:resolvelinktext"
        priority="10">
        <xsl:param name="linkElement" as="element()"/>
       <!-- <xsl:variable name="fig-count-actual">
            <xsl:apply-templates select="*[contains(@class,' equation-d/equation-number ')][1]" mode="topicpull:eqnnumber"/>
        </xsl:variable>-->
        <xsl:message>******** Equation Link Text ************</xsl:message>
        <xsl:value-of select="$equationlink.lead"/>
        <xsl:text> </xsl:text>
        <!--<xsl:apply-templates select="$targetElement//*[contains(@class, ' equation-d/equation-number ')][1]" mode="eqn.title-number"/>-->
        <xsl:apply-templates select="*[contains(@class,' equation-d/equation-number ')][1]" mode="topicpull:eqnnumber"/>
    </xsl:template>
    
    <!-- Determine the number of the equation being linked to -->
    <xsl:template match="*[contains(@class,' equation-d/equation-block ')]/*[contains(@class,' equation-d/equation-number ')]" mode="topicpull:eqnnumber">
        <xsl:call-template name="compute-number">
            <xsl:with-param name="all">
                <xsl:number from="/*" count="key('count.topic.equations','include')" level="any"/>
            </xsl:with-param>
            <xsl:with-param name="except">
                <xsl:number from="/*" count="key('count.topic.equations','exclude')" level="any"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!--<xsl:template match="*" mode="topicpull:equation-linktext">
        <xsl:param name="eqncount"/>
        
        <xsl:choose>
            <xsl:when test="$FIGURELINK = 'TITLE'">
                <xsl:apply-templates select="$figtitle" mode="text-only"/>
            </xsl:when>
            <!-\- $FIGURELINK = 'NUMBER' -\->
            <xsl:otherwise>
                <xsl:value-of select="$figtext"/>
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'figure-number-separator'"/>
                </xsl:call-template>
                <xsl:value-of select="$figcount"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->
    
    <!-- If a link is to an equation number, assume the parent is the real target, process accordingly -->
    <xsl:template match="*[contains(@class,' equation-d/equation-number ')]" mode="topicpull:resolvelinktext">
        <xsl:apply-templates select=".." mode="#current"/>
    </xsl:template>
    
    <xsl:template name="compute-number">
        <xsl:param name="except"/>
        <xsl:param name="all"/>
        
        <xsl:choose>
            <xsl:when test="$except != ''">
                <xsl:value-of select="number($all) - number($except)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$all"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>