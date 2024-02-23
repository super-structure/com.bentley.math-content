<?xml version="1.0" encoding="UTF-8"?>
<!-- ******************************************************************************
* XML Stylesheet to provide templates for equation domain items in DITA
* to PDF2 output.
*
* 2023-06-22 Jason Coleman
* Copyright © Bentley Systems, Incorporated. All rights reserved.
*
****************************************************************************** -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    exclude-result-prefixes="xs ditaarch"
    version="3.0">
    
    <xsl:import href="mathml-domain.xsl"/>
    
    <xsl:variable name="math-indent">10mm</xsl:variable>
    
    <xsl:template match="*[contains(@class,' equation-d/equation-block ')]" name="topic.equation-d.equation-block">
        <fo:block xsl:use-attribute-sets="font.math math-indent">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' equation-d/equation-figure ')]" name="topic.equation-d.equation-figure">
        <fo:block>
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
        <xsl:variable name="prev-eqn-num-count" select="count(preceding::*[contains(@class, ' equation-d/equation-number ')])"/>
        <xsl:variable name="eqn-count-actual" select="$prev-eqn-num-count + 1"/>
        <!-- TODO: equation numbers are on a new line; should be in same block.  -->
        <fo:inline>
            <xsl:call-template name="commonattributes"/>
            <xsl:attribute name="font-style">normal</xsl:attribute>
            <xsl:text>(</xsl:text>
            <xsl:choose>
                <xsl:when test="child::* or child::text()">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$eqn-count-actual"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>)</xsl:text>
        </fo:inline>
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
        <fo:table xsl:use-attribute-sets="dl-eqn" table-layout="fixed">
            <!-- TODO: Replace with mode="commonattributes" -->
            <xsl:call-template name="commonattributes"/>
            <xsl:if test="$follows-eqn-block = true()">
                <xsl:attribute name="margin-left" select="$math-indent"/>
            </xsl:if>
            <fo:table-column column-number="1" column-width="proportional-column-width(1)"/>
            <fo:table-column column-number="2" column-width="proportional-column-width(1)"/>
            <fo:table-column column-number="3" column-width="proportional-column-width(10)"/>
            <!-- TODO: handle dlhead -->
            <!--<xsl:apply-templates select="*[contains(@class, ' topic/dlhead ')]"/>-->
            <fo:table-body xsl:use-attribute-sets="dl-eqn__body">
                <xsl:apply-templates select="*[contains(@class, ' topic/dlentry ')]"/>
            </fo:table-body>
        </fo:table>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="outofline"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dlentry ')]">
        <fo:table-row xsl:use-attribute-sets="dlentry-eqn">
            <!-- TODO: vertical alignment of table cells (or baselines within cells) -->
            <!-- TODO: Replace with mode="commonattributes" -->
            <xsl:call-template name="commonattributes"/>
            <fo:table-cell xsl:use-attribute-sets="dlentry.dt-eqn">
                <xsl:apply-templates select="*[contains(@class, ' topic/dt ')]"/>
                <xsl:if test="empty(*[contains(@class, ' topic/dt ')])"><fo:block/></xsl:if>
            </fo:table-cell>
            <fo:table-cell>
                <fo:block xsl:use-attribute-sets="common.table.body.entry">=</fo:block>
            </fo:table-cell>
            <fo:table-cell xsl:use-attribute-sets="dlentry.dd-eqn">
                <xsl:apply-templates select="*[contains(@class, ' topic/dd ')]"/>
                <xsl:if test="empty(*[contains(@class, ' topic/dd ')])"><fo:block/></xsl:if>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dt ')]">
        <fo:block xsl:use-attribute-sets="dlentry.dt-eqn__content">
            <xsl:if test="not(preceding-sibling::*[contains(@class,' topic/dt ')])">
                <xsl:apply-templates select="../*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="outofline"/>
            </xsl:if>
            <xsl:apply-templates select="." mode="inlineTextOptionalKeyref"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/dd ')]">
        <fo:block xsl:use-attribute-sets="dlentry.dd-eqn__content">
            <!-- TODO: Replace with mode="commonattributes" -->
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates/>
            <xsl:if test="not(following-sibling::*[contains(@class,' topic/dd ')])">
                <xsl:apply-templates select="../*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="outofline"/>
            </xsl:if>
        </fo:block>
    </xsl:template>
    
    
    <xsl:attribute-set name="font.math" use-attribute-sets="font.serif">
        <xsl:attribute name="font-weight">400</xsl:attribute>
        <xsl:attribute name="font-style">italic</xsl:attribute>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="math-content">
        <xsl:attribute name="font-weight">400</xsl:attribute>
        <xsl:attribute name="font-style">italic</xsl:attribute>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="math-indent">
        <xsl:attribute name="margin-left"><xsl:value-of select="$math-indent"/></xsl:attribute>
    </xsl:attribute-set>
    
    <!-- attribute sets (taken from table-atts.xsl) -->
    <xsl:attribute-set name="dl-eqn">
        <!--DL is a table-->
        <xsl:attribute name="width">100%</xsl:attribute>
        <xsl:attribute name="space-before">5pt</xsl:attribute>
        <xsl:attribute name="space-after">5pt</xsl:attribute>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="dl-eqn__body">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="dl.dlhead-eqn">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="dlentry-eqn">
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
    
    <xsl:attribute-set name="dl.dlhead-eqn__row">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="dlhead.dthd-eqn__cell">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="dlhead.dthd-eqn__content" use-attribute-sets="common.table.body.entry common.table.head.entry">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="dlhead.ddhd-eqn__cell">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="dlhead.ddhd-eqn__content" use-attribute-sets="common.table.body.entry common.table.head.entry">
    </xsl:attribute-set>
    
</xsl:stylesheet>