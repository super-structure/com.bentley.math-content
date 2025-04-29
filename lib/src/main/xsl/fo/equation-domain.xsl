<?xml version="1.0" encoding="UTF-8"?>
<!-- ***************************************************************************************
* XML Stylesheet to provide templates for equation domain items in DITA
* to PDF2 output.
*
* 2023-06-22 Jason Coleman
* Copyright © Bentley Systems, Incorporated. All rights reserved.
*
* Rev 1: 2025-04-25 JTC: 1) added xref using equation number; fixed minor layout issues
*                        2) equations numbrered by chapter or appendix in PDF output
*                        (thanks to Felipe Fonseca); using input param option
*                        3) <dlhead> processing for <dl>s within an <equation-figure>
*
**************************************************************************************** -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    exclude-result-prefixes="xs ditaarch opentopic"
    version="3.0">
    
    <xsl:import href="mathml-domain.xsl"/>
    
    <xsl:param name="EQN-PREFIX" select="'abbr'"/>
    <xsl:param name="EQN-NUM-BYCHAPTER" select="'no'"/>
    
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
    
    <!-- Key based on chapter -->
    <xsl:key name="equations-by-chapter"
        match="*[contains(@class, ' equation-d/equation-number ')][not(ancestor::draft-comment) and not(child::* or child::text())]"
        use="generate-id(
        key('map-id', ancestor::*[contains(@class, ' topic/topic ')][1]/@id)
        /ancestor-or-self::*[contains(@class, ' map/topicref ')]
        [not(contains(@class, ' bookmap/part ')) and
        not(contains(@class, ' bookmap/appendices ')) and
        not(contains(@class, ' bookmap/backmatter '))]
        [parent::opentopic:map or
        parent::*[contains(@class, ' bookmap/part ')] or
        parent::*[contains(@class, ' bookmap/appendices ')]
        ][1]
        )"/>
    <xsl:key name="equations-by-document" 
        match="*[contains(@class, ' equation-d/equation-number ')][not(ancestor::draft-comment) and not(child::* or child::text())]"
        use="'include'"/>
    
    <xsl:variable name="math-indent">10mm</xsl:variable>
    
    <xsl:template match="*[contains(@class,' equation-d/equation-block ')]" name="topic.equation-d.equation-block">
        <fo:block xsl:use-attribute-sets="eqn-block">
            <xsl:if test="not(ancestor::*[contains(@class,' topic/dd ')] or ancestor::*[contains(@class,' topic/entry ')])">
                <xsl:attribute name="margin-left" select="$math-indent"/>
            </xsl:if>
            <!-- the following use the leading spaces to adjust the equation number to the right edge -->
            <xsl:if test="child::*[contains(@class, ' equation-d/equation-number ')]">
                <xsl:attribute name="text-align-last">justify</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="commonattributes"/>
            <fo:inline text-align-last="start">
                <xsl:apply-templates select="*[not(contains(@class, ' equation-d/equation-number '))] | text()"/>
            </fo:inline>
            <fo:inline/>
            <xsl:apply-templates select="*[contains(@class, ' equation-d/equation-number ')]"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' equation-d/equation-figure ')]" name="topic.equation-d.equation-figure">
        <fo:block xsl:use-attribute-sets="eqn-fig">
            <xsl:if test="parent::*[contains(@class,' topic/dd ')]">
                <xsl:attribute name="space-before">15pt</xsl:attribute><!-- TODO: remove hard-coded padding -->
            </xsl:if>
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' equation-d/equation-inline ')]" name="topic.equation-d.equation-inline">
        <fo:inline xsl:use-attribute-sets="font.math">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' equation-d/equation-number ')]" name="topic.equation-d.equation-number">
        <fo:leader leader-pattern="space" />
        <fo:inline xsl:use-attribute-sets="eqn-num">
            <xsl:if test="ancestor::*[contains(@class,' topic/dd ')]">
                <xsl:attribute name="padding-right"><xsl:value-of select="$math-indent"/></xsl:attribute>
            </xsl:if>
            <xsl:text>(</xsl:text>
            <xsl:apply-templates select="." mode="eqn.title-number"/>
            <xsl:text>)</xsl:text>
        </fo:inline>
    </xsl:template>
    
    <!-- Numbering equation by chapter with reset in each chaper  [chapterprefix-Eq#] -->
    <xsl:template match="*[contains(@class,' equation-d/equation-number ')]" mode="eqn.title-number">
        <xsl:variable name="chapter-prefix">
            <xsl:call-template name="getChapterPrefix"/>
        </xsl:variable>
        <xsl:variable name="chapter-topicref" as="element()?"
            select="key('map-id', ancestor::*[contains(@class, ' topic/topic ')][1]/@id)
            /ancestor-or-self::*[contains(@class, ' map/topicref ')]
            [not(contains(@class, ' bookmap/part ')) and
            not(contains(@class, ' bookmap/appendices ')) and
            not(contains(@class, ' bookmap/backmatter '))]
            [parent::opentopic:map or
            parent::*[contains(@class, ' bookmap/part ')] or
            parent::*[contains(@class, ' bookmap/appendices ')]
            ][1]"/>
        <xsl:variable name="chapter-id" select="generate-id($chapter-topicref)"/>
        <xsl:variable name="eqn-count-actual" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$EQN-NUM-BYCHAPTER = 'yes'">
                    <xsl:value-of select="count(key('equations-by-chapter', $chapter-id)[. &lt;&lt; current()]) + 1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="count(key('equations-by-document', 'include')[. &lt;&lt; current()]) + 1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="child::* or child::text()">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="$EQN-NUM-BYCHAPTER = 'yes'">
                <xsl:value-of select="$chapter-prefix"/><xsl:value-of select="$eqn-count-actual"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$eqn-count-actual"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- definition lists contained within an equation-figured are formatted as a symbols and notation list -->
    <xsl:template match="*[contains(@class,' equation-d/equation-figure ')]//*[contains(@class,'- topic/dl ')]">
        <!-- generate leader text when <dt> follows an equation -->
        <xsl:variable name="follows-eqn-block" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="preceding-sibling::*[contains(@class,' equation-d/equation-block ')]"><xsl:value-of select="true()"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$follows-eqn-block = true()">
            <fo:block xsl:use-attribute-sets="common.block">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Where'"/>
                </xsl:call-template>
            </fo:block>
        </xsl:if>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="outofline"/>
        <fo:table xsl:use-attribute-sets="dl-eqn">
            <xsl:if test="$follows-eqn-block = true()">
                <xsl:attribute name="margin-left" select="$math-indent"/>
            </xsl:if>
            <xsl:call-template name="commonattributes"/>
            <fo:table-column column-number="1" column-width="proportional-column-width(1)"/>
            <fo:table-column column-number="2" column-width="proportional-column-width(1)"/>
            <fo:table-column column-number="3" column-width="proportional-column-width(10)"/>
            <fo:table-body xsl:use-attribute-sets="dl-eqn__body">
                <xsl:apply-templates select="*[contains(@class, ' topic/dlhead ')]" mode="eqn-fig-dl"/>
                <xsl:apply-templates select="*[contains(@class, ' topic/dlentry ')]" mode="eqn-fig-dl"/>
            </fo:table-body>
        </fo:table>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="outofline"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dlentry ')]" mode="eqn-fig-dl">
        <fo:table-row xsl:use-attribute-sets="dlentry-eqn">
            <!-- TODO: vertical alignment of table cells (or baselines within cells) -->
            <xsl:call-template name="commonattributes"/>
            <fo:table-cell xsl:use-attribute-sets="dlentry.dt-eqn">
                <xsl:apply-templates select="*[contains(@class, ' topic/dt ')]" mode="eqn-fig-dl"/>
                <xsl:if test="empty(*[contains(@class, ' topic/dt ')])"><fo:block/></xsl:if>
            </fo:table-cell>
            <fo:table-cell>
                <fo:block xsl:use-attribute-sets="common.table.body.entry">=</fo:block>
            </fo:table-cell>
            <fo:table-cell xsl:use-attribute-sets="dlentry.dd-eqn">
                <xsl:apply-templates select="*[contains(@class, ' topic/dd ')]" mode="eqn-fig-dl"/>
                <xsl:if test="empty(*[contains(@class, ' topic/dd ')])"><fo:block/></xsl:if>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dt ')]" mode="eqn-fig-dl">
        <fo:block xsl:use-attribute-sets="dlentry.dt-eqn__content">
            <xsl:if test="not(preceding-sibling::*[contains(@class,' topic/dt ')])">
                <xsl:apply-templates select="../*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="outofline"/>
            </xsl:if>
            <xsl:apply-templates select="." mode="inlineTextOptionalKeyref"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dd ')]" mode="eqn-fig-dl">
        <fo:block xsl:use-attribute-sets="dlentry.dd-eqn__content">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates/>
            <xsl:if test="not(following-sibling::*[contains(@class,' topic/dd ')])">
                <xsl:apply-templates select="../*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="outofline"/>
            </xsl:if>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dlhead ')]" mode="eqn-fig-dl">
        <fo:table-row xsl:use-attribute-sets="dlhead-eqn">
            <xsl:call-template name="commonattributes"/>
            <fo:table-cell xsl:use-attribute-sets="dlhead.dthd-eqn">
                <xsl:apply-templates select="*[contains(@class, ' topic/dthd ')]" mode="eqn-fig-dl"/>
                <xsl:if test="empty(*[contains(@class, ' topic/dthd ')])"><fo:block/></xsl:if>
            </fo:table-cell>
            <fo:table-cell>
                <fo:block xsl:use-attribute-sets="common.table.body.entry">&#160;</fo:block>
            </fo:table-cell>
            <fo:table-cell xsl:use-attribute-sets="dlhead.ddhd-eqn">
                <xsl:apply-templates select="*[contains(@class, ' topic/ddhd ')]" mode="eqn-fig-dl"/>
                <xsl:if test="empty(*[contains(@class, ' topic/ddhd ')])"><fo:block/></xsl:if>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dthd ')]" mode="eqn-fig-dl">
        <fo:block xsl:use-attribute-sets="dlhead.dthd-eqn__content">
            <xsl:if test="not(preceding-sibling::*[contains(@class,' topic/dthd ')])">
                <xsl:apply-templates select="../*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="outofline"/>
            </xsl:if>
            <xsl:apply-templates select="." mode="inlineTextOptionalKeyref"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/ddhd ')]" mode="eqn-fig-dl">
        <fo:block xsl:use-attribute-sets="dlhead.ddhd-eqn__content">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates/>
            <xsl:if test="not(following-sibling::*[contains(@class,' topic/ddhd ')])">
                <xsl:apply-templates select="../*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="outofline"/>
            </xsl:if>
        </fo:block>
    </xsl:template>
    
    
    <xsl:template match="*[contains(@class, ' equation-d/equation-figure ')][descendant::*[contains(@class, ' equation-d/equation-number ')]] | 
                         *[contains(@class, ' equation-d/equation-block ')][child::*[contains(@class, ' equation-d/equation-number ')]]" 
                  mode="retrieveReferenceTitle">
        <xsl:value-of select="$equationlink.lead"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="current()//*[contains(@class, ' equation-d/equation-number ')][1]" mode="eqn.title-number"/>
    </xsl:template>
    
    <xsl:attribute-set name="eqn-fig">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="eqn-block" use-attribute-sets="font.math">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="eqn-num" use-attribute-sets="font.san-serif">
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="font.math">
        <xsl:attribute name="font-family">Georgia</xsl:attribute>
        <xsl:attribute name="font-weight">400</xsl:attribute>
        <xsl:attribute name="font-style">italic</xsl:attribute>
    </xsl:attribute-set>
    
    <!-- attribute sets (taken from table-atts.xsl) -->
    <xsl:attribute-set name="dl-eqn">
        <!--DL is a table-->
        <xsl:attribute name="table-layout">fixed</xsl:attribute><!-- required by Apache FOP; does not support 'auto' layout -->
        <xsl:attribute name="width">100%</xsl:attribute>
        <xsl:attribute name="space-before">5pt</xsl:attribute>
        <xsl:attribute name="space-after">5pt</xsl:attribute>
        <xsl:attribute name="text-align-last">start</xsl:attribute><!-- reset 'justify' for equation numbering? -->
    </xsl:attribute-set>
    
    <xsl:attribute-set name="dl-eqn__body">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="dlentry-eqn">
    </xsl:attribute-set>
    
       <xsl:attribute-set name="dlhead-eqn">
           <xsl:attribute name="font-style">normal</xsl:attribute>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="dlentry.dt-eqn">
        <xsl:attribute name="relative-align">baseline</xsl:attribute>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="dlentry.dt-eqn__content" use-attribute-sets="common.table.body.entry font.math">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="dlentry.dd-eqn">
        <xsl:attribute name="relative-align">baseline</xsl:attribute>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="dlentry.dd-eqn__content" use-attribute-sets="common.table.body.entry common.block">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="dlhead.dthd-eqn">
        <xsl:attribute name="relative-align">baseline</xsl:attribute>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="dlhead.dthd-eqn__content" use-attribute-sets="common.table.body.entry common.table.head.entry">
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="text-decoration">underline</xsl:attribute>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="dlhead.ddhd-eqn">
        <xsl:attribute name="relative-align">baseline</xsl:attribute>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="dlhead.ddhd-eqn__content" use-attribute-sets="common.table.body.entry common.table.head.entry">
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="text-decoration">underline</xsl:attribute>
    </xsl:attribute-set>
    
</xsl:stylesheet>