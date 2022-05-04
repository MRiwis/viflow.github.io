<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<xsl:param name="filter"><![CDATA[207]]></xsl:param>

	<xsl:variable name="processes" select="document('../data/sprostamm.xml')" />
	<xsl:variable name="areas" select="document('../data/sberstamm.xml')" />

	<xsl:include href="../xslt/intermediate_helper.xslt" />

	<xsl:template match="/">
		<xsl:element name="list">
			<xsl:attribute name="feedbackuri">
				<xsl:variable name="uri">
				<xsl:if test="boolean(number($filter)) and boolean(number($processes/rs/r[id=$filter]/responsibleid))">
					<xsl:variable name="id">
						<xsl:value-of select="$processes/rs/r[id=$filter]/responsibleid"/>
					</xsl:variable>
					<xsl:value-of select="$areas/rs/r[id=$id]/email" />
				</xsl:if>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="string-length($uri) > 0">
					<xsl:text><![CDATA[mailto:]]></xsl:text>
					<xsl:value-of select="$uri" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="settings/FeedbackURI" />
				</xsl:otherwise>
			</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="id">
				<xsl:text><![CDATA[hyperlinks]]></xsl:text>
			</xsl:attribute>
			<xsl:apply-templates select="settings/LinkList/Link[string-length(@url) > 0]">
				<xsl:sort select="." order="ascending" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Link">
		<xsl:element name="item">
			<xsl:element name="id">
				<xsl:value-of select="position()" />
			</xsl:element>
			<xsl:element name="name">
				<xsl:choose>
					<xsl:when test="string-length(.) > 0">
						<xsl:value-of select="." />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@url" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="shapetext">
				<xsl:choose>
					<xsl:when test="string-length(.) > 0">
						<xsl:value-of select="." />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@url" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="image" />
			<xsl:element name="uri">
				<xsl:value-of select="@url" />
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>