<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<xsl:template match="r[not(not(fromid))]" mode="appendStructure">
		<xsl:element name="parent">
			<xsl:attribute name="id">
				<xsl:value-of select="fromid" />
			</xsl:attribute>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r[not(not(art_a))]" mode="appendTypes">
		<xsl:param name="translations" />
		<xsl:param name="language" />
		<xsl:param name="image" />
		<xsl:variable name="id" select="id" />
		<xsl:element name="item">
			<xsl:element name="id">
				<!-- UInt32.MaxVal: 0xFFFFFFFF -->
				<xsl:text><![CDATA[4294967295]]></xsl:text>
				<xsl:value-of select="$id" />
			</xsl:element>
			<xsl:element name="parents" />
			<xsl:variable name="displayname">
				<xsl:variable name="value">
					<xsl:if test="not($language='A')">
						<xsl:value-of select="$translations[column='Art' and record=$id]/value" />
					</xsl:if>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length($value) = 0">
						<xsl:value-of select="art_a" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$value" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:element name="name">
				<xsl:value-of select="$displayname" />
			</xsl:element>
			<xsl:element name="shapetext">
				<xsl:value-of select="$displayname" />
			</xsl:element>
			<xsl:element name="image">
				<xsl:value-of select="$image" />
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>