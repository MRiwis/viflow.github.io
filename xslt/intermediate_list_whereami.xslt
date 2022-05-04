<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<xsl:param name="filter" />
	<xsl:param name="language"><![CDATA[A]]></xsl:param>
	<xsl:param name="exclusionlist"><![CDATA[]]></xsl:param>

	<xsl:key name="index" match="r" use="concat(dateiid, stammid)" />

	<xsl:variable name="process_structure" select="document('../data/sproverw.xml')" />
	<xsl:variable name="process_info" select="document('../data/sprostamm.xml')" />
	<xsl:variable name="translations_doc" select="document('../data/translations.xml')" />
	<xsl:variable name="translations" select="$translations_doc/rs/r[language=$language]" />
	<xsl:variable name="exclusions" select="document('../data/exclusions.xml')" />
	<xsl:variable name="exclusions_complete">
		<xsl:choose>
			<xsl:when test="string-length($exclusionlist) > 0">
				<xsl:value-of select="$exclusionlist" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$exclusions/exclusions/id" mode="getExclusions">
					<xsl:with-param name="structure" select="$process_structure" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:include href="../xslt/intermediate_helper.xslt" />

	<xsl:template match="/">
		<xsl:element name="list">
			<xsl:attribute name="id">
				<xsl:text><![CDATA[hyperlinks]]></xsl:text>
			</xsl:attribute>
			<xsl:apply-templates select="$process_info/rs/r[id=$process_structure/rs/r[stammid=$filter and generate-id()=generate-id(key('index', concat(dateiid, stammid))[1])]/dateiid]">
				<xsl:sort select="bezeichnung_a" order="ascending" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r">
		<xsl:variable name="id" select="id" />
		<xsl:variable name="graphic" select="count($process_structure/rs/r[dateiid=$id]) > 0" />
		<xsl:if test="not(contains($exclusions_complete, concat('|', $id, '|')))">
			<xsl:element name="item">
				<xsl:element name="id">
					<xsl:value-of select="$id" />
				</xsl:element>
				<xsl:element name="name">
					<xsl:variable name="value">
						<xsl:if test="not($language='A')">
							<xsl:value-of select="$translations[table='SProStamm' and column='Beschreibung' and record=$id]/value" />
						</xsl:if>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="string-length($value) = 0">
							<xsl:value-of select="$process_info/rs/r[id=$id]/beschreibung" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$value" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:element name="shapetext">
					<xsl:variable name="value">
						<xsl:if test="not($language='A')">
							<xsl:value-of select="$translations[table='SProStamm' and column='Bezeichnung' and record=$id]/value" />
						</xsl:if>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="string-length($value) = 0">
							<xsl:value-of select="$process_info/rs/r[id=$id]/bezeichnung_a" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$value" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:element name="image">
					<xsl:choose>
						<xsl:when test="$process_info/rs/r[id=$id]/typ='V'">
							<xsl:text><![CDATA[./images/ui/decisions.png]]></xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text><![CDATA[./images/ui/processes.png]]></xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:element name="uri">
					<xsl:value-of select="$id" />
				</xsl:element>
			</xsl:element>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>