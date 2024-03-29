<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:bentley="http://www.bentley.com"
    exclude-result-prefixes="#all"
    version="3.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <xsl:mode on-no-match="shallow-copy" />

    <xsl:template match="@style">
        <xsl:attribute name="style">
            <xsl:for-each select="tokenize(current(), ';')">
                <xsl:choose>
                    <xsl:when test="contains(current(), 'vertical-align:')">
                        <xsl:variable name="align-val-ex">
                            <xsl:value-of select="substring-after(current(),'vertical-align:')"/>
                        </xsl:variable>
                        <xsl:text>vertical-align: </xsl:text>
                        <xsl:value-of select="bentley:ex-2-px($align-val-ex)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="current()"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>;</xsl:text>
            </xsl:for-each>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="@width | @height">
        <xsl:variable name="value" select="substring-before(.,'ex')"/>
        <xsl:attribute name="{name(.)}">
            <xsl:choose>
                <xsl:when test="contains(.,'ex')">
                    <xsl:value-of select="bentley:ex-2-px(.)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="@role | @focusable | @data-c"/>

    <xsl:template match="@data-mml-node">
        <xsl:attribute name="class" select="."/>
    </xsl:template>
    
    <xsl:function name="bentley:ex-2-em">
        <xsl:param name="string"/>
        <xsl:variable name="value" select="substring-before($string,'ex')"/>
        <xsl:variable name="ratio" as="xs:double">0.5</xsl:variable> <!-- 1em / 2ex -->
        <xsl:value-of select="bentley:convert-size($ratio, $value)"/>
        <xsl:text>em</xsl:text>
    </xsl:function>

    <xsl:function name="bentley:ex-2-pt">
        <xsl:param name="string"/>
        <xsl:variable name="value" select="substring-before($string,'ex')"/>
        <xsl:variable name="ratio" as="xs:double">6</xsl:variable> <!-- 12pt / 2ex -->
        <xsl:value-of select="bentley:convert-size($ratio, $value)"/>
        <xsl:text>pt</xsl:text>
    </xsl:function>
    
    <xsl:function name="bentley:ex-2-px">
        <xsl:param name="string"/>
        <xsl:variable name="value" select="substring-before($string,'ex')"/>
        <xsl:variable name="ratio" as="xs:double">8</xsl:variable> <!-- 16px / 2ex -->
        <xsl:value-of select="bentley:convert-size($ratio, $value)"/> 
        <xsl:text>px</xsl:text>
    </xsl:function>
    
    <xsl:function name="bentley:convert-size">
        <xsl:param name="ratio"/>
        <xsl:param name="value"/>
        <xsl:value-of select="number($ratio) * number($value)"/>
    </xsl:function>
</xsl:stylesheet>