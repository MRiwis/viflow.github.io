<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<xsl:param name="language"><![CDATA[A]]></xsl:param>
	<xsl:param name="exclusionlist"><![CDATA[]]></xsl:param>

	<xsl:variable name="processes" select="document('../data/sprostamm.xml')" />
	<xsl:variable name="processtree" select="document('../data/sproverw.xml')" />
	<xsl:variable name="translations_doc" select="document('../data/translations.xml')" />
	<xsl:variable name="translations" select="$translations_doc/rs/r[language=$language and table='SProStamm' and (column='Beschreibung' or column='Bezeichnung')]" />
	<xsl:variable name="exclusions" select="document('../data/exclusions.xml')" />
	<xsl:variable name="exclusions_complete">
		<xsl:choose>
			<xsl:when test="string-length($exclusionlist) > 0">
				<xsl:value-of select="$exclusionlist" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$exclusions/exclusions/id" mode="getExclusions">
					<xsl:with-param name="structure" select="$processtree" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:include href="../xslt/intermediate_helper.xslt" />

	<xsl:template match="/">
		<xsl:element name="tree">
			<xsl:attribute name="id">
				<xsl:text><![CDATA[processes]]></xsl:text>
			</xsl:attribute>
			<xsl:apply-templates select="$processes/rs/r[not($exclusions/id=@id)]" mode="appendNode">
				<xsl:sort select="bezeichnung_a" order="ascending" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="appendNode">
		<xsl:variable name="id" select="id" />
		<xsl:variable name="parents" select="count($processtree/rs/r[stammid=$id])" />
		<xsl:if test="not(contains($exclusions_complete, concat('|', $id, '|'))) and (number($parents) > 0 or string-length(blob) > 0)">
			<xsl:element name="item">
				<xsl:element name="id">
					<xsl:value-of select="$id" />
				</xsl:element>
				<xsl:element name="parents">
					<xsl:apply-templates select="$processtree/rs/r[stammid=$id]" mode="appendParents">
						<xsl:sort select="dateiid" order="ascending" />
					</xsl:apply-templates>
				</xsl:element>
				<xsl:element name="name">
					<xsl:variable name="value">
						<xsl:if test="not($language='A')">
							<xsl:value-of select="$translations[table='SProStamm' and column='Beschreibung' and record=$id]/value" />
						</xsl:if>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="string-length($value) = 0">
							<xsl:value-of select="beschreibung" />
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
							<xsl:value-of select="bezeichnung_a" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$value" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:element name="image">
					<xsl:choose>
						<xsl:when test="typ='V' and string-length(blob) > 0">
							<xsl:text><![CDATA[./images/ui/decisions.png]]></xsl:text>
						</xsl:when>
						<xsl:when test="typ='V' and string-length(blob) = 0">
							<xsl:text><![CDATA[./images/ui/decision.png]]></xsl:text>
						</xsl:when>
						<xsl:when test="typ='P' and string-length(blob) > 0">
							<xsl:text><![CDATA[./images/ui/processes.png]]></xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text><![CDATA[./images/ui/process.png]]></xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="r" mode="appendParents">
		<xsl:element name="parent">
			<xsl:attribute name="id">
				<xsl:value-of select="dateiid" />
			</xsl:attribute>
			<xsl:attribute name="uuid">
				<xsl:value-of select="uniqueid" />
			</xsl:attribute>
			<xsl:attribute name="number">
				<xsl:value-of select="nummer" />
			</xsl:attribute>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>