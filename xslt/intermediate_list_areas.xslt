<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<xsl:param name="language"><![CDATA[A]]></xsl:param>
	<xsl:param name="renferencedonly"><![CDATA[0]]></xsl:param>
	<xsl:param name="exclusionlist"><![CDATA[]]></xsl:param>

	<xsl:variable name="areas" select="document('../data/sberstamm.xml')" />
	<xsl:variable name="areauuids" select="document('../data/sberverw.xml')" />
	<xsl:variable name="translations_doc" select="document('../data/translations.xml')" />
	<xsl:variable name="translations" select="$translations_doc/rs/r[language=$language and table='SBerStamm' and (column='Beschreibung' or column='Bezeichnung')]" />
	<xsl:variable name="participation_refs_global" select="document('../data/htprostammberstamm.xml')" />
	<xsl:variable name="participation_refs_local" select="document('../data/htproverwberstamm.xml')" />
	<xsl:variable name="processtree" select="document('../data/sproverw.xml')" />
	<xsl:variable name="processes" select="document('../data/sprostamm.xml')" />
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

	<xsl:template match="/">
		<xsl:element name="list">
			<xsl:attribute name="id">
				<xsl:text><![CDATA[areas]]></xsl:text>
			</xsl:attribute>
			<xsl:apply-templates select="$areas/rs/r" >
				<xsl:sort select="bezeichnung_a" order="ascending" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<!-- areas -->
	<xsl:template match="r[not(not(email))]">
		<xsl:variable name="id" select="id" />
		<xsl:variable name="isReferenced">
			<xsl:call-template name="isReferenced">
				<xsl:with-param name="area" select="." />
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="boolean(number($isReferenced))">
			<xsl:element name="item">
				<xsl:element name="id">
					<xsl:value-of select="$id" />
				</xsl:element>
				<xsl:element name="name">
					<xsl:variable name="value">
						<xsl:if test="not($language='A')">
							<xsl:value-of select="$translations[table='SBerStamm' and column='Beschreibung' and record=$id]/value" />
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
							<xsl:value-of select="$translations[table='SBerStamm' and column='Bezeichnung' and record=$id]/value" />
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
					<xsl:text><![CDATA[./images/ui/area.png]]></xsl:text>
				</xsl:element>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template name="isReferenced" match="r" mode="isReferenced">
		<xsl:param name="area" />
		<xsl:variable name="id" select="id" />
		<xsl:variable name="typeid">
			<xsl:choose>
				<xsl:when test="string-length(art) > 0">
					<xsl:value-of select="art" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text><![CDATA[0]]></xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="number($renferencedonly) = 0">
				<xsl:value-of select="1" />
			</xsl:when>
			<xsl:when test="count($areauuids/rs/r[stammid=$id]) > 0 and not(contains($exclusions_complete, concat('|', $areauuids/rs/r[stammid=$id]/dateiid, '|')))">
				<xsl:value-of select="1" />
			</xsl:when>
			<xsl:when test="count($participation_refs_global/rs/r[toid=$id]) > 0 and not(contains($exclusions_complete, concat('|', $participation_refs_global/rs/r[toid=$id]/fromid, '|')))">
				<xsl:value-of select="1" />
			</xsl:when>
			<xsl:when test="count($participation_refs_local/rs/r[toid=$id]) > 0">
				<xsl:variable name="uuid" select="$participation_refs_local/rs/r[toid=$id]/uniquefromid" />
				<xsl:variable name="pid" select="$processtree/rs/r[uniqueid=$uuid]/stammid" />
				<xsl:if test="not(contains($exclusions_complete, concat('|', $pid, '|')))">
					<xsl:value-of select="1" />
				</xsl:if>
			</xsl:when>
			<xsl:when test="count($processes/rs/r[(responsibleid=$id or freigeberid=$id or prueferid=$id) and not(contains($exclusions_complete, concat('|', id, '|')))]) > 0">
				<xsl:value-of select="1" />
			</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>