<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<xsl:variable name="process_structure" select="document('../data/sproverw.xml')" />
	<xsl:variable name="exclusions" select="document('../data/exclusions.xml')" />
	<xsl:variable name="exclusions_complete">
		<xsl:apply-templates select="$exclusions/exclusions/id" mode="getExclusions">
			<xsl:with-param name="structure" select="$process_structure" />
		</xsl:apply-templates>
	</xsl:variable>

	<xsl:include href="../xslt/intermediate_helper.xslt" />

	<xsl:template match="/">
		<xsl:element name="exclusions">
			<xsl:value-of select="$exclusions_complete" />
			<xsl:apply-templates select="$process_structure/rs/r" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="r">
		<xsl:if test="contains($exclusions_complete, concat('|', stammid, '|'))">
			<xsl:value-of select="concat('|', uniqueid, '|')"/>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>