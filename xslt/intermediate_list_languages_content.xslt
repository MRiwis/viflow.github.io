<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<xsl:variable name="definitions" select="document('../data/benutzerundsprachen.xml')" />
	<xsl:variable name="translations" select="document('../data/translations.xml')" />
	<xsl:variable name="currentdblanguage_doc" select="document('../data/spracheumschalten.xml')" />
	<xsl:variable name="currentdblanguage" select="$currentdblanguage_doc/rs/r/aktsprache" />

	<xsl:key name="translation_duplicates" match="r[not(not(table)) and not(not(column)) and not(not(record)) and not(not(language))]" use="concat(table, '_', column, '_', record, '_', value)" />

	<xsl:variable name="languages">
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:for-each select="$definitions/rs/r[id=4]/*[not(local-name()='id') and position()&lt;=10]">
			<xsl:variable name="id" select="position()" />
			<xsl:if test="count($translations/rs/r[generate-id() = generate-id(key('translation_duplicates', concat(table, '_', column, '_', record, '_', value))) and string-length(value) > 0 and (table='SProStamm' or table='SDatStamm' or table='SBerStamm')]/language[. = $id]) > 0">
				<xsl:value-of select="$id" />
				<xsl:text><![CDATA[|]]></xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:element name="list">
			<xsl:attribute name="id">
				<xsl:text><![CDATA[languages_content]]></xsl:text>
			</xsl:attribute>
			<xsl:apply-templates select="$definitions/rs/r[id = 4]/*[contains(concat('|', $currentdblanguage, $languages), concat('|', position()-1, '|'))]" >
				<xsl:sort select="bezeichnung_a" order="ascending" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r[id=4]/*">
		<xsl:variable name="id">
			<xsl:value-of select="substring-after(name(.), 'userlanguage')" />
		</xsl:variable>
		<xsl:element name="item">
			<xsl:element name="id">
				<xsl:choose>
					<xsl:when test="$id = $currentdblanguage">
						<xsl:text><![CDATA[A]]></xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$id" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="name">
				<xsl:value-of select="." />
			</xsl:element>
			<xsl:element name="shapetext">
				<xsl:value-of select="." />
			</xsl:element>
			<xsl:element name="image" />
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>