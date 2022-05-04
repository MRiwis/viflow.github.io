<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<xsl:param name="filter"><![CDATA[63]]></xsl:param>
	<xsl:param name="language"><![CDATA[A]]></xsl:param>
	<xsl:param name="dependents"><![CDATA[1]]></xsl:param>
	<xsl:param name="renferencedonly"><![CDATA[0]]></xsl:param>
	<xsl:param name="exclusionlist"><![CDATA[]]></xsl:param>

	<xsl:variable name="informationtypes" select="document('../data/dokumentenart.xml')" />
	<xsl:variable name="information" select="document('../data/sdatstamm.xml')" />
	<xsl:variable name="informationtree" select="document('../data/htdatstammdatstamm.xml')" />
	<xsl:variable name="informationuuids" select="document('../data/sdatverw.xml')" />
	<xsl:variable name="areauuids" select="document('../data/sberverw.xml')" />
	<xsl:variable name="participation_refs_global" select="document('../data/htprostammberstamm.xml')" />
	<xsl:variable name="participation_refs_local" select="document('../data/htproverwberstamm.xml')" />
	<xsl:variable name="informationdistribution" select="document('../data/htdatstammberstamm.xml')" />
	<xsl:variable name="areatree" select="document('../data/htberstammberstamm.xml')" />
	<xsl:variable name="translations_doc" select="document('../data/translations.xml')" />
	<xsl:variable name="translations" select="$translations_doc/rs/r[language=$language and table='SDatStamm' and (column='Beschreibung' or column='Bezeichnung')]" />
	<xsl:variable name="assignment_refs_global" select="document('../data/htprostammdatstamm.xml')" />
	<xsl:variable name="assignment_refs_local" select="document('../data/htproverwdatstamm.xml')" />
	<xsl:variable name="assignment_refs_area" select="document('../data/htdatstammberstamm.xml')" />
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

	<xsl:variable name="filterids">
		<xsl:text>|</xsl:text>
		<xsl:value-of select="$filter" />
		<xsl:text>|</xsl:text>
		<xsl:if test="not($dependents=0)">
			<xsl:apply-templates select="$areatree/rs/r[toid=$filter]" mode="getParentAreas" />
			<xsl:apply-templates select="$areatree/rs/r[fromid=$filter]" mode="getChildAreas" />
		</xsl:if>
	</xsl:variable>

	<xsl:variable name="ids">
		<xsl:text>|</xsl:text>
		<xsl:apply-templates select="$informationdistribution/rs/r[contains($filterids, concat('|', toid, '|'))]" mode="filterByArea" />
	</xsl:variable>

	<xsl:variable name="ids_complete">
		<xsl:text>|</xsl:text>
		<xsl:apply-templates select="$information/rs/r[contains($ids, concat('|', id, '|'))]" mode="getInformation">
			<xsl:sort select="bezeichnung_a" />
		</xsl:apply-templates>
	</xsl:variable>

	<xsl:include href="../xslt/intermediate_helper.xslt" />

	<xsl:template match="/">
		<xsl:element name="tree">
			<xsl:attribute name="id">
				<xsl:text><![CDATA[myinformation]]></xsl:text>
			</xsl:attribute>
			<xsl:apply-templates select="$information/rs/r[contains($ids_complete, concat('|', id, '|'))]" mode="appendNode">
				<xsl:sort select="bezeichnung_a" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r[not(not(fromid)) and not(not(toid))]" mode="getParentAreas">
		<xsl:variable name="id" select="fromid" />
		<xsl:value-of select="$id" />
		<xsl:text>|</xsl:text>
		<xsl:apply-templates select="$areatree/rs/r[toid=$id]" mode="getParentAreas" />
	</xsl:template>

	<xsl:template match="r[not(not(fromid)) and not(not(toid))]" mode="getChildAreas">
		<xsl:variable name="id" select="toid" />
		<xsl:value-of select="$id" />
		<xsl:text>|</xsl:text>
		<xsl:apply-templates select="$areatree/rs/r[fromid=$filter]" mode="getParentAreas" />
	</xsl:template>

	<xsl:template match="r[not(not(fromid)) and not(not(toid))]" mode="filterByArea">
		<xsl:variable name="id">
			<xsl:value-of select="fromid" />
		</xsl:variable>
		<xsl:value-of select="$id" />
		<xsl:text>|</xsl:text>
		<xsl:apply-templates select="$informationtree/rs/r[toid=$id or fromid=$id]" mode="filterByInformation">
			<xsl:with-param name="id" select="$id" />
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="r[not(not(fromid)) and not(not(toid))]" mode="filterByInformation">
		<xsl:param name="id"><![CDATA[0]]></xsl:param>
		<xsl:choose>
			<xsl:when test="fromid=$id">
				<xsl:value-of select="toid" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="fromid" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>|</xsl:text>
	</xsl:template>

	<xsl:template match="r[not(not(fromid)) and not(not(toid))]" mode="getParentInformation">
		<xsl:variable name="id" select="fromid" />
		<xsl:value-of select="$id"/>
		<xsl:text>|</xsl:text>
	</xsl:template>

	<xsl:template match="r[not(not(fromid)) and not(not(toid))]" mode="getChildInformation">
		<xsl:variable name="id" select="toid" />
		<xsl:value-of select="$id"/>
		<xsl:text>|</xsl:text>
		<xsl:apply-templates select="$information/rs/r[id=$id and not(contains($ids, concat('|', $id, '|')))]" mode="getInformation" />
	</xsl:template>

	<xsl:template match="r[not(not(id))]" mode="getInformation">
		<xsl:param name="with-parents" select="0" />
		<xsl:variable name="id" select="id" />
		<xsl:value-of select="$id" />
		<xsl:text>|</xsl:text>
		<xsl:if test="not($with-parents=0)">
			<xsl:apply-templates select="$informationtree/rs/r[toid=$id]" mode="getParentInformation" />
		</xsl:if>

		<xsl:if test="$with-parents=0">
			<xsl:if test="count($informationtree/rs/r[toid=$id]) > 0">
				<xsl:apply-templates select="." mode="getInformation">
					<xsl:with-param name="with-parents" select="1" />
				</xsl:apply-templates>
			</xsl:if>
			<xsl:apply-templates select="$informationtree/rs/r[fromid=$id]" mode="getChildInformation" />
		</xsl:if>
	</xsl:template>

	<xsl:template match="r[not(not(fromid)) and not(not(toid))]" mode="appendParents">
		<xsl:element name="parent">
			<xsl:attribute name="id">
				<xsl:value-of select="fromid" />
			</xsl:attribute>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r[not(not(id))]" mode="appendNode">
		<xsl:param name="with-parents" select="0" />
		<xsl:variable name="id" select="id" />
		<xsl:variable name="isReferenced">
			<xsl:call-template name="isReferenced">
				<xsl:with-param name="information" select="." />
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="boolean(number($isReferenced))">
			<xsl:element name="item">
				<xsl:element name="id">
					<xsl:value-of select="id" />
				</xsl:element>
				<xsl:element name="parents">
					<xsl:if test="not($with-parents=0)">
						<xsl:apply-templates select="$informationtree/rs/r[toid=$id]" mode="appendParents" />
					</xsl:if>
				</xsl:element>
				<xsl:element name="name">
					<xsl:variable name="value">
						<xsl:if test="not($language='A')">
							<xsl:value-of select="$translations[table='SDatStamm' and column='Beschreibung' and record=$id]/value" />
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
							<xsl:value-of select="$translations[table='SDatStamm' and column='Bezeichnung' and record=$id]/value" />
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
						<xsl:when test="string-length(dokument) > 0">
							<xsl:text><![CDATA[./images/ui/information_link.png]]></xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text><![CDATA[./images/ui/information.png]]></xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:element>
		</xsl:if>

		<xsl:if test="$with-parents=0">
			<xsl:if test="count($informationtree/rs/r[toid=$id]) > 0">
				<xsl:apply-templates select="." mode="appendNode">
					<xsl:with-param name="with-parents" select="1" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template name="isReferenced" match="r" mode="isReferenced">
		<xsl:param name="information" />
		<xsl:variable name="id" select="id" />
		<xsl:variable name="typeid">
			<xsl:choose>
				<xsl:when test="string-length(dokumentenartid) > 0">
					<xsl:value-of select="dokumentenartid" />
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
			<xsl:when test="count($informationuuids/rs/r[stammid=$id]) > 0 and not(contains($exclusions_complete, concat('|', $informationuuids/rs/r[stammid=$id]/dateiid, '|')))">
				<xsl:value-of select="1" />
			</xsl:when>
			<xsl:when test="count($assignment_refs_global/rs/r[toid=$id]) > 0 and not(contains($exclusions_complete, concat('|', $assignment_refs_global/rs/r[toid=$id]/fromid, '|')))">
				<xsl:value-of select="1" />
			</xsl:when>
			<xsl:when test="count($assignment_refs_local/rs/r[toid=$id]) > 0">
				<xsl:variable name="uuid" select="$assignment_refs_local/rs/r[toid=$id]/uniquefromid" />
				<xsl:variable name="pid" select="$processtree/rs/r[uniqueid=$uuid]/stammid" />
				<xsl:if test="not(contains($exclusions_complete, concat('|', $pid, '|')))">
					<xsl:value-of select="1" />
				</xsl:if>
			</xsl:when>
			<xsl:when test="count($assignment_refs_area/rs/r[fromid=$id]) > 0">
				<xsl:apply-templates select="$assignment_refs_area/rs/r[fromid=$id]" mode="isReferencedArea" />
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="isReferencedArea" match="r" mode="isReferencedArea">
		<xsl:variable name="id" select="toid" />
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