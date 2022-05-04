<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<xsl:variable name="definitions" select="document('../data/ui.xml')" />

	<xsl:template match="/">
		<xsl:element name="list">
			<xsl:attribute name="id">
				<xsl:text><![CDATA[languages_ui]]></xsl:text>
			</xsl:attribute>
			<xsl:call-template name="createlanguagelist">
				<xsl:with-param name="list" select="$definitions/root/@availablelanguages" />
			</xsl:call-template>
		</xsl:element>
	</xsl:template>

	<xsl:template name="createlanguagelist" match="availablelanguages">
		<xsl:param name="list" />
		<xsl:if test="string-length($list)>0">
			<xsl:element name="item">
				<xsl:variable name="id">
					<xsl:choose>
						<xsl:when test="contains($list, ';')">
							<xsl:value-of select="substring-before($list, ';')" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$list" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:element name="id">
					<xsl:value-of select="$id" />
				</xsl:element>
				<xsl:variable name="jscode">
					<xsl:text><![CDATA[eval('ISOLanguages.]]></xsl:text>
					<xsl:value-of select="$id" />
					<xsl:text><![CDATA[.nativeName') + ' (' + eval('ISOLanguages.]]></xsl:text>
					<xsl:value-of select="$id" />
					<xsl:text><![CDATA[.name') + ')']]></xsl:text>
				</xsl:variable>
				<xsl:element name="name">
					<xsl:value-of select="$jscode" />
				</xsl:element>
				<xsl:element name="shapetext">
					<xsl:value-of select="$jscode" />
				</xsl:element>
				<xsl:element name="image" />
			</xsl:element>
			<xsl:call-template name="createlanguagelist">
				<xsl:with-param name="list" select="substring-after($list, ';')" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>