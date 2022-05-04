<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<xsl:param name="filter"><![CDATA[2]]></xsl:param>
	<xsl:param name="language"><![CDATA[A]]></xsl:param>
	<xsl:param name="dependents"><![CDATA[0]]></xsl:param>
	<xsl:param name="exclusionlist"><![CDATA[]]></xsl:param>

	<xsl:variable name="processes" select="document('../data/sprostamm.xml')" />
	<xsl:variable name="processesstructure" select="document('../data/sproverw.xml')" />
	<xsl:variable name="areas" select="document('../data/sberstamm.xml')" />
	<xsl:variable name="areastructure" select="document('../data/htberstammberstamm.xml')" />
	<xsl:variable name="participation_global" select="document('../data/htprostammberstamm.xml')" />
	<xsl:variable name="participation_local" select="document('../data/htproverwberstamm.xml')" />
	<xsl:variable name="participation_types" select="document('../data/beteiligungsart.xml')" />
	<xsl:variable name="tree_processes" select="document('../data/sproverw.xml')" />
	<xsl:variable name="tree_areas" select="document('../data/sberverw.xml')" />
	<xsl:variable name="translations_doc" select="document('../data/translations.xml')" />
	<xsl:variable name="translations" select="$translations_doc/rs/r[language=$language and (table='SProStamm' or table='BeteiligungsArt') and (column='Beteiligung' or column='Beschreibung' or column='Bezeichnung')]" />
	<xsl:variable name="exclusions" select="document('../data/exclusions.xml')" />
	<xsl:variable name="exclusions_complete">
		<xsl:choose>
			<xsl:when test="string-length($exclusionlist) > 0">
				<xsl:value-of select="$exclusionlist" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$exclusions/exclusions/id" mode="getExclusions">
					<xsl:with-param name="structure" select="$processesstructure" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="filterids">
		<xsl:text>|</xsl:text>
		<xsl:value-of select="$filter" />
		<xsl:text>|</xsl:text>
		<xsl:if test="not($dependents=0)">
			<xsl:apply-templates select="$areastructure/rs/r[toid=$filter]" mode="getParentAreas" />
			<xsl:apply-templates select="$areastructure/rs/r[fromid=$filter]" mode="getChildAreas" />
		</xsl:if>
	</xsl:variable>

	<xsl:variable name="ids">
		<xsl:text>|</xsl:text>
		<xsl:apply-templates select="$participation_global/rs/r[contains($filterids, concat('|', toid, '|'))]" mode="participation_global" />
		<xsl:apply-templates select="$participation_local/rs/r[contains($filterids, concat('|', toid, '|'))]" mode="participation_local" />
		<xsl:apply-templates select="$tree_areas/rs/r[contains($filterids, concat('|', stammid, '|'))]" mode="tree_areas" />
		<xsl:apply-templates select="$processes/rs/r[contains($filterids, concat('|', responsibleid, '|')) or contains($filterids, concat('|', prueferid, '|')) or contains($filterids, concat('|', freigeberid, '|'))]" mode="directly_assigned" />
	</xsl:variable>

	<xsl:variable name="parentids">
		<xsl:call-template name="filter_parents" />
	</xsl:variable>

	<xsl:include href="../xslt/intermediate_helper.xslt" />

	<xsl:template match="/">
		<xsl:element name="tree">
			<xsl:attribute name="id">
				<xsl:text><![CDATA[myprocesses]]></xsl:text>
			</xsl:attribute>
			<xsl:apply-templates select="$processes/rs/r[contains($ids, concat('|', id, ';'))]" mode="appendNode">
				<xsl:sort select="bezeichnung_a" />
			</xsl:apply-templates>
			<xsl:apply-templates select="$processes/rs/r[contains($parentids, concat('|', id, '|')) and not(contains($ids, concat('|', id, ';')))]" mode="appendNode">
				<xsl:sort select="bezeichnung_a" />
				<xsl:with-param name="with-parents" select="0" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r[not(not(fromid)) and not(not(toid))]" mode="getParentAreas">
		<xsl:variable name="id" select="fromid" />
		<xsl:value-of select="$id" />
		<xsl:text>|</xsl:text>
		<xsl:apply-templates select="$areastructure/rs/r[toid=$id]" mode="getParentAreas" />
	</xsl:template>

	<xsl:template match="r[not(not(fromid)) and not(not(toid))]" mode="getChildAreas">
		<xsl:variable name="id" select="toid" />
		<xsl:value-of select="$id" />
		<xsl:text>|</xsl:text>
		<xsl:apply-templates select="$areastructure/rs/r[fromid=$id]" mode="getChildAreas" />
	</xsl:template>

	<xsl:template match="r[not(not(fromid)) and not(not(toid))]" mode="participation_global">
		<xsl:variable name="id">
			<xsl:value-of select="fromid" />
		</xsl:variable>
		<xsl:value-of select="$id" />
		<xsl:text>;</xsl:text>
		<xsl:text>;</xsl:text>
		<xsl:text>;</xsl:text>
		<xsl:text>;</xsl:text>
		<xsl:text>|</xsl:text>
	</xsl:template>

	<xsl:template match="r[not(not(uniquefromid)) and not(not(toid))]" mode="participation_local">
		<xsl:variable name="id" select="uniquefromid" />
		<xsl:variable name="participation_id" select="beteiligungsid" />
		<xsl:value-of select="$tree_processes/rs/r[uniqueid=$id]/stammid" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$tree_processes/rs/r[uniqueid=$id]/uniqueid" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$tree_processes/rs/r[uniqueid=$id]/nummer" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$tree_processes/rs/r[uniqueid=$id]/dateiid" />
		<xsl:text>;</xsl:text>
		<xsl:variable name="value">
			<xsl:if test="not($language='A')">
				<xsl:value-of select="$translations[table='BeteiligungsArt' and column='Beteiligung' and record=$participation_id]/value" />
			</xsl:if>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length($value) = 0">
				<xsl:value-of select="$participation_types/rs/r[id=$participation_id]/beteiligung_a" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>|</xsl:text>
	</xsl:template>

	<xsl:template match="r[not(not(uniqueid)) and not(not(stammid))]" mode="tree_areas">
		<xsl:variable name="id">
			<xsl:value-of select="dateiid" />
		</xsl:variable>
		<xsl:variable name="ypos">
			<xsl:value-of select="ypos" />
		</xsl:variable>
		<xsl:apply-templates select="$tree_processes/rs/r[dateiid=$id and ypos=$ypos]" mode="process_children" />
	</xsl:template>

	<xsl:template match="r[not(not(uniqueid)) and not(not(stammid)) and not(not(dateiid))]" mode="process_children">
		<xsl:value-of select="stammid" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="uniqueid" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="nummer" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="dateiid" />
		<xsl:text>;</xsl:text>
		<xsl:text>|</xsl:text>
	</xsl:template>

	<xsl:template match="r[not(not(id))]" mode="directly_assigned">
		<xsl:value-of select="id" />
		<xsl:text>;</xsl:text>
		<xsl:text>;</xsl:text>
		<xsl:text>;</xsl:text>
		<xsl:text>;</xsl:text>
		<xsl:text>|</xsl:text>
	</xsl:template>

	<xsl:template match="r[not(not(id))]" mode="appendNode">
		<xsl:param name="with-parents" select="1" />
		<xsl:variable name="id" select="id" />
		<xsl:variable name="sliced_start_and_id" select="substring-after($ids, concat('|', $id, ';'))" />
		<xsl:variable name="uuid" select="substring-before($sliced_start_and_id, ';')" />
		<xsl:variable name="sliced_uuid" select="substring-after($sliced_start_and_id, ';')" />
		<xsl:variable name="number" select="substring-before($sliced_uuid, ';')" />
		<xsl:variable name="sliced_number" select="substring-after($sliced_uuid, ';')" />
		<xsl:variable name="parentid" select="substring-before($sliced_number, ';')" />
		<xsl:variable name="sliced_parent" select="substring-after($sliced_number, ';')" />
		<xsl:variable name="participation" select="substring-before($sliced_parent, '|')" />
		<xsl:if test="not(contains($exclusions_complete, concat('|', id, '|')))">
			<xsl:element name="item">
				<xsl:element name="id">
					<xsl:value-of select="id" />
				</xsl:element>
				<xsl:element name="parents">
					<xsl:if test="$with-parents=1 and string-length($parentid) > 0 and string-length($uuid) > 0 and string-length($number) > 0">
						<xsl:element name="parent">
							<xsl:attribute name="id">
								<xsl:value-of select="$parentid" />
							</xsl:attribute>
							<xsl:attribute name="uuid">
								<xsl:value-of select="$uuid" />
							</xsl:attribute>
							<xsl:attribute name="number">
								<xsl:value-of select="$number" />
							</xsl:attribute>
						</xsl:element>
					</xsl:if>
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
					<xsl:if test="string-length($participation) > 0">
						<xsl:text><![CDATA[ (]]></xsl:text>
						<xsl:value-of select="$participation" />
						<xsl:text><![CDATA[)]]></xsl:text>
					</xsl:if>
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
					<xsl:if test="string-length($participation) > 0">
						<xsl:text><![CDATA[ (]]></xsl:text>
						<xsl:value-of select="$participation" />
						<xsl:text><![CDATA[)]]></xsl:text>
					</xsl:if>
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

	<xsl:template name="filter_parents">
		<xsl:param name="data" select="$ids" />
		<xsl:variable name="sliced_start" select="substring-after($data, '|')" />
		<xsl:variable name="sliced_id" select="substring-after($sliced_start, ';')" />
		<xsl:variable name="sliced_uuid" select="substring-after($sliced_id, ';')" />
		<xsl:variable name="sliced_number" select="substring-after($sliced_uuid, ';')" />
		<xsl:variable name="parentid" select="substring-before($sliced_number, ';')" />
		<xsl:variable name="sliced_parent" select="substring-after($sliced_number, ';')" />
		<xsl:variable name="sliced_participation" select="substring-after($sliced_parent, '|')" />
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="$parentid" />
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:if test="string-length($sliced_participation) > 0">
			<xsl:call-template name="filter_parents">
				<xsl:with-param name="data" select="concat('|', $sliced_participation)" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>