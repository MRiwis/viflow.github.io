<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<xsl:param name="filter"><![CDATA[{8259DE38-F5C5-4BA8-B8E6-DB981F21E98E}]]></xsl:param>
	<xsl:param name="language"><![CDATA[A]]></xsl:param>
	<xsl:param name="displaytext"><![CDATA[1]]></xsl:param>
	<xsl:param name="linkfallback"><![CDATA[1]]></xsl:param>
	<xsl:param name="searchterms"><![CDATA[]]></xsl:param>
	<xsl:param name="exclusionlist"><![CDATA[]]></xsl:param>

	<xsl:variable name="information" select="document('../data/sdatstamm.xml')" />
	<xsl:variable name="information_unique" select="document('../data/sdatverw.xml')" />
	<xsl:variable name="informationtypes" select="document('../data/dokumentenart.xml')" />
	<xsl:variable name="translations_doc" select="document('../data/translations.xml')" />
	<xsl:variable name="translations" select="$translations_doc/rs/r[language=$language]" />
	<xsl:variable name="usermap_global" select="document('../data/htdatstammuserfieldvalues.xml')" />
	<xsl:variable name="usermap_local" select="document('../data/htdatverwuserfieldvalues.xml')" />
	<xsl:variable name="usermap" select="$usermap_global | $usermap_local" />
	<xsl:variable name="history_map" select="document('../data/htdatstammhistorie.xml')" />
	<xsl:variable name="criteria_map_global" select="document('../data/htdatstammkriterien.xml')" />
	<xsl:variable name="criteria_map_local" select="document('../data/htdatverwkriterienart.xml')" />
	<xsl:variable name="criteria_map" select="$criteria_map_global | $criteria_map_local" />
	<xsl:variable name="distribution" select="document('../data/htdatstammberstamm.xml')" />
	<xsl:variable name="areas" select="document('../data/sberstamm.xml')" />
	<xsl:variable name="areatypes" select="document('../data/berstammart.xml')" />
	<xsl:variable name="processes" select="document('../data/sprostamm.xml')" />
	<xsl:variable name="processes_unique" select="document('../data/sproverw.xml')" />
	<xsl:variable name="assignedinfo_global" select="document('../data/htprostammdatstamm.xml')" />
	<xsl:variable name="assignedinfo_local" select="document('../data/htproverwdatstamm.xml')" />
	<xsl:variable name="assignedinfo" select="$assignedinfo_global | $assignedinfo_local" />
	<xsl:variable name="assignedinfo_types" select="document('../data/usagetypes.xml')" />
	<xsl:variable name="transmission" select="document('../data/htdatverwdatverwart.xml')" />
	<xsl:variable name="transmission_types" select="document('../data/datverwart.xml')" />
	<xsl:variable name="archive_types" select="document('../data/archivetypes.xml')" />
	<xsl:variable name="archive_locations" select="document('../data/archivelocations.xml')" />
	<xsl:variable name="timeunits" select="document('../data/zeitart.xml')" />
	<xsl:variable name="exchange_types" select="document('../data/austauschart.xml')" />
	<xsl:variable name="invalidation_types" select="document('../data/vernichtungsart.xml')" />
	<xsl:variable name="assignments" select="document('../data/htdatstammdatstamm.xml')" />
	<xsl:variable name="exclusions" select="document('../data/exclusions.xml')" />
	<xsl:variable name="exclusions_complete">
		<xsl:choose>
			<xsl:when test="string-length($exclusionlist) > 0">
				<xsl:value-of select="$exclusionlist" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$exclusions/exclusions/id" mode="getExclusions">
					<xsl:with-param name="structure" select="$processes_unique" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="gid">
		<xsl:value-of select="$information/rs/r[id=$filter]/id" />
		<xsl:value-of select="$information_unique/rs/r[uniqueid=$filter]/stammid" />
	</xsl:variable>

	<xsl:variable name="uid">
		<xsl:value-of select="$information_unique/rs/r[uniqueid=$filter]/uniqueid" />
	</xsl:variable>

	<xsl:key name="references_duplicates" match="r[not(not(uniqueid)) and not(not(dateiid)) and not(not(stammid)) and not(not(fromid)) and not(not(toid))]" use="concat(uniqueid, '_', dateiid)" />

	<xsl:include href="../xslt/intermediate_helper.xslt" />
	<xsl:include href="../xslt/intermediate_properties_shared.xslt" />

	<xsl:template match="/">
		<xsl:element name="data">
			<xsl:element name="general">
				<xsl:apply-templates select="$information/rs/r[id=$gid]" mode="general" />
			</xsl:element>
			<xsl:element name="userfields">
				<xsl:apply-templates select="$information/rs/r[id=$gid]" mode="userfields">
					<xsl:with-param name="gid" select="$gid" />
					<xsl:with-param name="uid" select="$uid" />
					<xsl:with-param name="language" select="$language" />
					<xsl:with-param name="translations" select="$translations" />
					<xsl:with-param name="usermap" select="$usermap" />
				</xsl:apply-templates>
			</xsl:element>
			<xsl:element name="history">
				<xsl:apply-templates select="$information/rs/r[id=$gid]" mode="history">
					<xsl:with-param name="gid" select="$gid" />
					<xsl:with-param name="uid" select="$uid" />
					<xsl:with-param name="language" select="$language" />
					<xsl:with-param name="translations" select="$translations" />
					<xsl:with-param name="history_map" select="$history_map" />
				</xsl:apply-templates>
			</xsl:element>
			<xsl:element name="criteria">
				<xsl:apply-templates select="$information/rs/r[id=$gid]" mode="criteria">
					<xsl:with-param name="gid" select="$gid" />
					<xsl:with-param name="uid" select="$uid" />
					<xsl:with-param name="language" select="$language" />
					<xsl:with-param name="translations" select="$translations" />
					<xsl:with-param name="criteria_map" select="$criteria_map" />
				</xsl:apply-templates>
			</xsl:element>
			<xsl:element name="distribution">
				<xsl:apply-templates select="$information/rs/r[id=$gid]" mode="distribution" />
			</xsl:element>
			<xsl:element name="references">
				<xsl:apply-templates select="$information/rs/r[id=$gid]" mode="references" />
			</xsl:element>
			<xsl:element name="transmission">
				<xsl:apply-templates select="$information/rs/r[id=$gid]" mode="transmission" />
			</xsl:element>
			<xsl:element name="management">
				<xsl:apply-templates select="$information/rs/r[id=$gid]" mode="management" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="general">
		<xsl:element name="table">
			<xsl:attribute name="class"><![CDATA[propTable]]></xsl:attribute>
			<xsl:element name="tr">
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[shortname]]></xsl:attribute>
					<xsl:text><![CDATA[Short Name]]></xsl:text>
				</xsl:element>
				<xsl:element name="td">
					<xsl:variable name="value">
						<xsl:apply-templates select="bezeichnung_a" mode="translate">
							<xsl:with-param name="record" select="id" />
							<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
							<xsl:with-param name="table"><![CDATA[SDatStamm]]></xsl:with-param>
							<xsl:with-param name="language" select="$language" />
							<xsl:with-param name="translations" select="$translations" />
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:value-of select="$value" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="tr">
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[longname]]></xsl:attribute>
					<xsl:text><![CDATA[Long Name]]></xsl:text>
				</xsl:element>
				<xsl:element name="td">
					<xsl:variable name="value">
						<xsl:apply-templates select="beschreibung" mode="translate">
							<xsl:with-param name="record" select="id" />
							<xsl:with-param name="column"><![CDATA[Beschreibung]]></xsl:with-param>
							<xsl:with-param name="table"><![CDATA[SDatStamm]]></xsl:with-param>
							<xsl:with-param name="language" select="$language" />
							<xsl:with-param name="translations" select="$translations" />
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:value-of select="$value" />
				</xsl:element>
			</xsl:element>
			<xsl:variable name="type">
				<xsl:variable name="typeid">
					<xsl:value-of select="dokumentenartid" />
				</xsl:variable>
				<xsl:variable name="value">
					<xsl:apply-templates select="$informationtypes/rs/r[id=$typeid]/art_a" mode="translate">
						<xsl:with-param name="record" select="$typeid" />
						<xsl:with-param name="column"><![CDATA[Art]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[DokumentenArt]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:variable>
			<xsl:if test="string-length($type) > 0">
				<xsl:element name="tr">
					<xsl:element name="th">
						<xsl:attribute name="id"><![CDATA[informationtype]]></xsl:attribute>
						<xsl:text><![CDATA[Information Type]]></xsl:text>
					</xsl:element>
					<xsl:element name="td">
						<xsl:value-of select="$type" />
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:variable name="document">
				<xsl:apply-templates select="dokument" mode="translate">
					<xsl:with-param name="fallback" select="boolean(number($linkfallback))" />
					<xsl:with-param name="record" select="id" />
					<xsl:with-param name="column"><![CDATA[Dokument]]></xsl:with-param>
					<xsl:with-param name="table"><![CDATA[SDatStamm]]></xsl:with-param>
					<xsl:with-param name="language" select="$language" />
					<xsl:with-param name="translations" select="$translations" />
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:if test="string-length($document) > 0">
				<xsl:element name="tr">
					<xsl:element name="th">
						<xsl:attribute name="id"><![CDATA[link]]></xsl:attribute>
						<xsl:text><![CDATA[Link]]></xsl:text>
					</xsl:element>
					<xsl:element name="td">
						<xsl:variable name="display">
							<xsl:call-template name="substring-after-last">
								<xsl:with-param name="string" select="translate($document, '\', '/')" />
								<xsl:with-param name="search" select="'/'" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:element name="a">
							<xsl:attribute name="href">
								<xsl:value-of select="$document" />
							</xsl:attribute>
							<xsl:attribute name="onclick"><![CDATA[WebModel.UI.navigateURI(window.event || event);]]></xsl:attribute>
							<xsl:attribute name="target"><![CDATA[_blank]]></xsl:attribute>
							<xsl:value-of select="$display" />
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:variable name="comment_g">
				<xsl:variable name="value">
					<xsl:apply-templates select="anmerkung" mode="translate">
						<xsl:with-param name="fallback" />
						<xsl:with-param name="record" select="id" />
						<xsl:with-param name="column"><![CDATA[Anmerkung]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[SDatStamm]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:variable>
			<xsl:variable name="comment_l">
				<xsl:variable name="value">
					<xsl:apply-templates select="$information_unique/rs/r[uniqueid=$uid]/anmerkung" mode="translate">
						<xsl:with-param name="fallback" />
						<xsl:with-param name="record" select="$uid" />
						<xsl:with-param name="column"><![CDATA[Anmerkung]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[SDatVerw]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:variable>
			<xsl:if test="string-length($comment_g) > 0">
				<xsl:element name="tr">
					<xsl:element name="th">
						<xsl:attribute name="id"><![CDATA[comment]]></xsl:attribute>
						<xsl:if test="string-length($comment_l) > 0">
							<xsl:attribute name="rowspan"><![CDATA[2]]></xsl:attribute>
						</xsl:if>
						<xsl:text><![CDATA[Comment]]></xsl:text>
					</xsl:element>
					<xsl:element name="td">
						<xsl:value-of select="$comment_g" />
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length($comment_l) > 0">
				<xsl:element name="tr">
					<xsl:if test="not(string-length($comment_g) > 0)">
						<xsl:element name="th">
							<xsl:attribute name="id"><![CDATA[comment]]></xsl:attribute>
							<xsl:text><![CDATA[Comment]]></xsl:text>
						</xsl:element>
					</xsl:if>
					<xsl:element name="td">
						<xsl:value-of select="$comment_l" />
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length($searchterms) > 0">
				<xsl:variable name="id" select="id" />
				<xsl:apply-templates select="$information_unique/rs/r[stammid=$id and not(uniqueid=$uid)]" mode="search">
					<xsl:with-param name="terms" select="$searchterms" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="distribution">
		<xsl:element name="table">
			<xsl:attribute name="class"><![CDATA[propTable sortable]]></xsl:attribute>
			<xsl:element name="tr">
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[area]]></xsl:attribute>
					<xsl:text><![CDATA[Area]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[areatype]]></xsl:attribute>
					<xsl:text><![CDATA[Area Type]]></xsl:text>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="$distribution/rs/r[fromid=$gid]" mode="distribution_rows" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="distribution_rows">
		<xsl:variable name="fieldid" select="toid" />
		<xsl:variable name="typeid" select="$areas/rs/r[id=$fieldid]/art" />
		<xsl:element name="tr">
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:choose>
						<xsl:when test="not(boolean(number($displaytext)))">
							<xsl:apply-templates select="$areas/rs/r[id=$fieldid]/bezeichnung_a" mode="translate">
								<xsl:with-param name="record" select="$fieldid" />
								<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
								<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
								<xsl:with-param name="language" select="$language" />
								<xsl:with-param name="translations" select="$translations" />
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="$areas/rs/r[id=$fieldid]/beschreibung" mode="translate">
								<xsl:with-param name="record" select="$fieldid" />
								<xsl:with-param name="column"><![CDATA[Beschreibung]]></xsl:with-param>
								<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
								<xsl:with-param name="language" select="$language" />
								<xsl:with-param name="translations" select="$translations" />
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:element name="a">
					<xsl:attribute name="href">
						<xsl:text><![CDATA[#]]></xsl:text>
					</xsl:attribute>
					<xsl:attribute name="onclick">
						<xsl:text><![CDATA[WebModel.navigate(']]></xsl:text>
						<xsl:value-of select="$fieldid" />
						<xsl:text><![CDATA[', 'globalAreaTree'); return false;]]></xsl:text>
					</xsl:attribute>
					<xsl:value-of select="$value" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:apply-templates select="$areatypes/rs/r[id=$typeid]/art_a" mode="translate">
						<xsl:with-param name="record" select="$typeid" />
						<xsl:with-param name="column"><![CDATA[Art]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[BerStammArt]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="references">
		<xsl:element name="table">
			<xsl:attribute name="class"><![CDATA[propTable sortable]]></xsl:attribute>

			<xsl:variable name="refdata">
				<xsl:apply-templates select="$information_unique/rs/r[stammid=$gid and generate-id() = generate-id(key('references_duplicates', concat(uniqueid, '_', dateiid)))] | $assignedinfo/rs/r[toid=$gid]" mode="references_rows" />
			</xsl:variable>
			<xsl:if test="string-length($refdata) > 0 or count($assignments/rs/r[fromid=$gid]/toid | $assignments/rs/r[toid=$gid]/fromid) &lt;= 0">
				<xsl:element name="tr">
					<xsl:element name="th">
						<xsl:attribute name="id"><![CDATA[graphic]]></xsl:attribute>
						<xsl:attribute name="class"><![CDATA[sorted_desc]]></xsl:attribute>
						<xsl:text><![CDATA[Graphic]]></xsl:text>
					</xsl:element>
					<xsl:element name="th">
						<xsl:attribute name="id"><![CDATA[process]]></xsl:attribute>
						<xsl:attribute name="class"><![CDATA[sorted_desc]]></xsl:attribute>
						<xsl:text><![CDATA[Process]]></xsl:text>
					</xsl:element>
					<xsl:element name="th">
						<xsl:attribute name="id"><![CDATA[usagetype]]></xsl:attribute>
						<xsl:text><![CDATA[Usage Type]]></xsl:text>
					</xsl:element>
				</xsl:element>
				<xsl:copy-of select="$refdata" />
			</xsl:if>

			<xsl:if test="count($assignments/rs/r[fromid=$gid]/toid | $assignments/rs/r[toid=$gid]/fromid) > 0">
				<xsl:element name="tr">
					<xsl:element name="th">
						<xsl:if test="string-length($refdata) > 0">
							<xsl:attribute name="style"><![CDATA[padding-top: 1.5em;]]></xsl:attribute>
						</xsl:if>
						<xsl:attribute name="id"><![CDATA[information]]></xsl:attribute>
						<xsl:attribute name="class"><![CDATA[sorted_desc]]></xsl:attribute>
						<xsl:text><![CDATA[Information]]></xsl:text>
					</xsl:element>
					<xsl:element name="th">
						<xsl:if test="string-length($refdata) > 0">
							<xsl:attribute name="style"><![CDATA[padding-top: 1.5em;]]></xsl:attribute>
						</xsl:if>
						<xsl:attribute name="id"><![CDATA[informationtype]]></xsl:attribute>
						<xsl:attribute name="class"><![CDATA[sorted_desc]]></xsl:attribute>
						<xsl:text><![CDATA[Information Type]]></xsl:text>
					</xsl:element>
					<xsl:element name="th">
						<xsl:if test="string-length($refdata) > 0">
							<xsl:attribute name="style"><![CDATA[padding-top: 1.5em;]]></xsl:attribute>
						</xsl:if>
						<xsl:attribute name="id"><![CDATA[usagetype]]></xsl:attribute>
						<xsl:text><![CDATA[Usage Type]]></xsl:text>
					</xsl:element>
				</xsl:element>
				<xsl:apply-templates select="$assignments/rs/r[fromid=$gid]/toid | $assignments/rs/r[toid=$gid]/fromid" mode="references_rows_assigned" />
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="references_rows">
		<xsl:variable name="fieldid" select="fromid | uniquefromid | dateiid" />
		<xsl:variable name="fromid" select="fromid" />
		<xsl:variable name="toid" select="toid" />
		<xsl:variable name="activityid">
			<xsl:value-of select="$processes_unique/rs/r[uniqueid=$fieldid]/stammid" />
		</xsl:variable>
		<xsl:variable name="graphicid">
			<xsl:choose>
				<xsl:when test="string-length($processes_unique/rs/r[uniqueid=$fieldid]/dateiid) > 0">
					<xsl:value-of select="$processes_unique/rs/r[uniqueid=$fieldid]/dateiid" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$fieldid" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="usagetypeid" select="usagetypeid" />
		<xsl:variable name="shapeid">
			<xsl:choose>
				<xsl:when test="$usagetypeid">
					<xsl:value-of select="uniquefromid"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="$information_unique/rs/r[dateiid=$graphicid and stammid=$gid]/uniqueid">
						<xsl:if test="position() > 1">
							<xsl:text><![CDATA[;]]></xsl:text>
						</xsl:if>
						<xsl:value-of select="." />
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="not(contains($exclusions_complete, concat('|', $graphicid, '|')))">
			<xsl:variable name="sid" select="$processes/rs/r[id=$fieldid or id=$graphicid]/id" />
			<xsl:variable name="value">
				<xsl:choose>
					<xsl:when test="not(boolean(number($displaytext)))">
						<xsl:apply-templates select="$processes/rs/r[id=$sid]/bezeichnung_a" mode="translate">
							<xsl:with-param name="record" select="$sid" />
							<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
							<xsl:with-param name="table"><![CDATA[SProStamm]]></xsl:with-param>
							<xsl:with-param name="language" select="$language" />
							<xsl:with-param name="translations" select="$translations" />
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$processes/rs/r[id=$sid]/beschreibung" mode="translate">
							<xsl:with-param name="record" select="$sid" />
							<xsl:with-param name="column"><![CDATA[Beschreibung]]></xsl:with-param>
							<xsl:with-param name="table"><![CDATA[SProStamm]]></xsl:with-param>
							<xsl:with-param name="language" select="$language" />
							<xsl:with-param name="translations" select="$translations" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:element name="tr">
				<xsl:element name="td">
					<xsl:if test="boolean(number($activityid)) or not(not(uniqueid))">
						<xsl:element name="a">
							<xsl:attribute name="href">
								<xsl:text><![CDATA[#]]></xsl:text>
							</xsl:attribute>
							<xsl:attribute name="onclick">
								<xsl:text><![CDATA[WebModel.navigate(']]></xsl:text>
								<xsl:value-of select="$graphicid" />
								<xsl:text><![CDATA[', 'globalProcessTree', true, undefined, undefined, ']]></xsl:text>
								<xsl:value-of select="$shapeid"/>
								<xsl:text><![CDATA['); WebModel.UI.PropertyWindow.close(); return false;]]></xsl:text>
							</xsl:attribute>
							<xsl:value-of select="$value" />
						</xsl:element>
					</xsl:if>
				</xsl:element>
				<xsl:element name="td">
					<xsl:variable name="subsid">
						<xsl:choose>
							<xsl:when test="$usagetypeid">
								<xsl:value-of select="$activityid" />
							</xsl:when>
							<xsl:when test="string-length($fromid) > 0 and string-length($toid) = 0">
								<xsl:variable name="pid" select="$processes_unique/rs/r[uniqueid=$fromid]/stammid" />
								<xsl:value-of select="$pid" />
							</xsl:when>
							<xsl:when test="string-length($fromid) = 0 and string-length($toid) > 0">
								<xsl:variable name="pid" select="$processes_unique/rs/r[uniqueid=$toid]/stammid" />
								<xsl:value-of select="$pid" />
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="subuid">
						<xsl:choose>
							<xsl:when test="$usagetypeid">
								<xsl:value-of select="string($fieldid)" />
							</xsl:when>
							<xsl:when test="string-length($fromid) > 0 and string-length($toid) = 0">
								<xsl:value-of select="$fromid" />
							</xsl:when>
							<xsl:when test="string-length($fromid) = 0 and string-length($toid) > 0">
								<xsl:value-of select="$toid" />
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="subvalue">
						<xsl:choose>
							<xsl:when test="not(boolean(number($displaytext)))">
								<xsl:apply-templates select="$processes/rs/r[id=$subsid]/bezeichnung_a" mode="translate">
									<xsl:with-param name="record" select="$sid" />
									<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
									<xsl:with-param name="table"><![CDATA[SProStamm]]></xsl:with-param>
									<xsl:with-param name="language" select="$language" />
									<xsl:with-param name="translations" select="$translations" />
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="$processes/rs/r[id=$subsid]/beschreibung" mode="translate">
									<xsl:with-param name="record" select="$sid" />
									<xsl:with-param name="column"><![CDATA[Beschreibung]]></xsl:with-param>
									<xsl:with-param name="table"><![CDATA[SProStamm]]></xsl:with-param>
									<xsl:with-param name="language" select="$language" />
									<xsl:with-param name="translations" select="$translations" />
								</xsl:apply-templates>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:element name="a">
						<xsl:attribute name="href">
							<xsl:text><![CDATA[#]]></xsl:text>
						</xsl:attribute>
						<xsl:attribute name="onclick">
							<xsl:text><![CDATA[WebModel.navigate(']]></xsl:text>
							<xsl:choose>
								<xsl:when test="boolean(number($subsid)) or not(not(uniqueid))">
									<xsl:value-of select="$subuid" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$graphicid" />
								</xsl:otherwise>
							</xsl:choose>
							<xsl:text><![CDATA[', 'globalProcessTree', false); return false;]]></xsl:text>
						</xsl:attribute>
						<xsl:choose>
							<xsl:when test="boolean(number($subsid)) or not(not(uniqueid))">
								<xsl:value-of select="$subvalue" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$value" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:element>
				<xsl:element name="td">
					<xsl:choose>
						<xsl:when test="$usagetypeid">
							<xsl:value-of select="$assignedinfo_types/rs/r[id=$usagetypeid]/name_a" />
						</xsl:when>
						<xsl:when test="string-length($fromid) > 0 and string-length($toid) = 0">
							<xsl:element name="span">
								<xsl:attribute name="id"><![CDATA[output]]></xsl:attribute>
								<xsl:text><![CDATA[Output]]></xsl:text>
							</xsl:element>
						</xsl:when>
						<xsl:when test="string-length($fromid) = 0 and string-length($toid) > 0">
							<xsl:element name="span">
								<xsl:attribute name="id"><![CDATA[input]]></xsl:attribute>
								<xsl:text><![CDATA[Input]]></xsl:text>
							</xsl:element>
						</xsl:when>
					</xsl:choose>
				</xsl:element>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="fromid|toid" mode="references_rows_assigned">
		<xsl:variable name="id">
			<xsl:choose>
				<xsl:when test="name(.)='toid'">
					<xsl:value-of select="../toid" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="../fromid" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="type">
			<xsl:value-of select="$information/rs/r[id=$id]/dokumentenartid" />
		</xsl:variable>
		<xsl:element name="tr">
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:choose>
						<xsl:when test="not(boolean(number($displaytext)))">
							<xsl:apply-templates select="$information/rs/r[id=$id]/bezeichnung_a" mode="translate">
								<xsl:with-param name="record" select="$id" />
								<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
								<xsl:with-param name="table"><![CDATA[SDatStamm]]></xsl:with-param>
								<xsl:with-param name="language" select="$language" />
								<xsl:with-param name="translations" select="$translations" />
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="$information/rs/r[id=$id]/beschreibung" mode="translate">
								<xsl:with-param name="record" select="$id" />
								<xsl:with-param name="column"><![CDATA[Beschreibung]]></xsl:with-param>
								<xsl:with-param name="table"><![CDATA[SDatStamm]]></xsl:with-param>
								<xsl:with-param name="language" select="$language" />
								<xsl:with-param name="translations" select="$translations" />
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:element name="a">
					<xsl:attribute name="href">
						<xsl:text><![CDATA[#]]></xsl:text>
					</xsl:attribute>
					<xsl:attribute name="onclick">
						<xsl:text><![CDATA[WebModel.navigate(']]></xsl:text>
						<xsl:value-of select="$id" />
						<xsl:text><![CDATA[', 'globalInformationTree'); return false;]]></xsl:text>
					</xsl:attribute>
					<xsl:value-of select="$value" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:apply-templates select="$informationtypes/rs/r[id=$type]/art_a" mode="translate">
						<xsl:with-param name="record" select="$type" />
						<xsl:with-param name="column"><![CDATA[Art]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[DokumentenArt]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:element>
			<xsl:element name="td">
				<xsl:choose>
					<xsl:when test="name(.)='fromid'">
						<xsl:element name="span">
							<xsl:attribute name="id"><![CDATA[sup]]></xsl:attribute>
							<xsl:text><![CDATA[Superordinate]]></xsl:text>
						</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="span">
							<xsl:attribute name="id"><![CDATA[sub]]></xsl:attribute>
							<xsl:text><![CDATA[Subordinate]]></xsl:text>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="transmission">
		<xsl:element name="table">
			<xsl:attribute name="class"><![CDATA[propTable sortable]]></xsl:attribute>
			<xsl:element name="tr">
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[transmissionheader]]></xsl:attribute>
					<xsl:attribute name="class"><![CDATA[sorted_desc]]></xsl:attribute>
					<xsl:text><![CDATA[Transmission Types]]></xsl:text>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="$transmission/rs/r[fromid=$uid]" mode="transmission_rows" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="transmission_rows">
		<xsl:variable name="fieldid" select="toid" />
		<xsl:element name="tr">
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:apply-templates select="$transmission_types/rs/r[id=$fieldid]/art_a" mode="translate">
						<xsl:with-param name="fallback" />
						<xsl:with-param name="record" select="$fieldid" />
						<xsl:with-param name="column"><![CDATA[Art]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[DatVerwArt]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="management">
		<xsl:element name="table">
			<xsl:attribute name="class"><![CDATA[propTable]]></xsl:attribute>
			<xsl:if test="string-length(erstellerid) > 0">
				<xsl:element name="tr">
					<xsl:element name="th">
						<xsl:attribute name="id"><![CDATA[created]]></xsl:attribute>
						<xsl:text><![CDATA[Created]]></xsl:text>
					</xsl:element>
					<xsl:element name="td">
						<xsl:variable name="fieldid" select="erstellerid" />
						<xsl:variable name="value">
							<xsl:choose>
								<xsl:when test="not(boolean(number($displaytext)))">
									<xsl:apply-templates select="$areas/rs/r[id=$fieldid]/bezeichnung_a" mode="translate">
										<xsl:with-param name="record" select="$fieldid" />
										<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
										<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
										<xsl:with-param name="language" select="$language" />
										<xsl:with-param name="translations" select="$translations" />
									</xsl:apply-templates>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="$areas/rs/r[id=$fieldid]/beschreibung" mode="translate">
										<xsl:with-param name="record" select="$fieldid" />
										<xsl:with-param name="column"><![CDATA[Beschreibung]]></xsl:with-param>
										<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
										<xsl:with-param name="language" select="$language" />
										<xsl:with-param name="translations" select="$translations" />
									</xsl:apply-templates>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:element name="a">
							<xsl:attribute name="href">
								<xsl:text><![CDATA[#]]></xsl:text>
							</xsl:attribute>
							<xsl:attribute name="onclick">
								<xsl:text><![CDATA[WebModel.navigate(']]></xsl:text>
								<xsl:value-of select="$fieldid" />
								<xsl:text><![CDATA[', 'globalAreaTree'); return false;]]></xsl:text>
							</xsl:attribute>
							<xsl:value-of select="$value" />
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length(archivetypesid) > 0">
				<xsl:element name="tr">
					<xsl:element name="th">
						<xsl:if test="string-length(erstellerid) > 0">
							<xsl:attribute name="class">
								<xsl:text><![CDATA[para]]></xsl:text>
							</xsl:attribute>
						</xsl:if>
						<xsl:attribute name="id"><![CDATA[archivetype]]></xsl:attribute>
						<xsl:text><![CDATA[Archive Type]]></xsl:text>
					</xsl:element>
					<xsl:element name="td">
						<xsl:if test="string-length(erstellerid) > 0">
							<xsl:attribute name="class">
								<xsl:text><![CDATA[para]]></xsl:text>
							</xsl:attribute>
						</xsl:if>
						<xsl:variable name="archivetypesid" select="archivetypesid" />
						<xsl:variable name="value">
							<xsl:apply-templates select="$archive_types/rs/r[id=$archivetypesid]/name_a" mode="translate">
								<xsl:with-param name="record" select="$archivetypesid" />
								<xsl:with-param name="column"><![CDATA[Name]]></xsl:with-param>
								<xsl:with-param name="table"><![CDATA[ArchiveTypes]]></xsl:with-param>
								<xsl:with-param name="language" select="$language" />
								<xsl:with-param name="translations" select="$translations" />
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:value-of select="$value" />
					</xsl:element>
				</xsl:element>
				<xsl:if test="string-length(archivelocationsid) > 0">
					<xsl:element name="tr">
						<xsl:element name="th">
							<xsl:attribute name="id"><![CDATA[archivelocation]]></xsl:attribute>
							<xsl:text><![CDATA[Archive Location]]></xsl:text>
						</xsl:element>
						<xsl:element name="td">
							<xsl:variable name="archivelocationsid" select="archivelocationsid" />
							<xsl:variable name="value">
								<xsl:apply-templates select="$archive_locations/rs/r[id=$archivelocationsid]/name_a" mode="translate">
									<xsl:with-param name="record" select="$archivelocationsid" />
									<xsl:with-param name="column"><![CDATA[Name]]></xsl:with-param>
									<xsl:with-param name="table"><![CDATA[ArchiveLocations]]></xsl:with-param>
									<xsl:with-param name="language" select="$language" />
									<xsl:with-param name="translations" select="$translations" />
								</xsl:apply-templates>
							</xsl:variable>
							<xsl:value-of select="$value" />
						</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:if test="string-length(archiveduration) > 0">
					<xsl:element name="tr">
						<xsl:element name="th">
							<xsl:attribute name="id"><![CDATA[archiveduration]]></xsl:attribute>
							<xsl:text><![CDATA[Archive Duration]]></xsl:text>
						</xsl:element>
						<xsl:element name="td">
							<xsl:variable name="timeunitid" select="archivedurationid" />
							<xsl:value-of select="archiveduration" />
							<xsl:text><![CDATA[ ]]></xsl:text>
							<xsl:value-of select="$timeunits/rs/r[id=$timeunitid]/art_a" />
						</xsl:element>
					</xsl:element>
				</xsl:if>
			</xsl:if>
			<xsl:element name="tr">
				<xsl:element name="th">
					<xsl:if test="string-length(erstellerid) > 0 or string-length(archivetypesid) > 0">
						<xsl:attribute name="class">
							<xsl:text><![CDATA[para]]></xsl:text>
						</xsl:attribute>
					</xsl:if>
					<xsl:attribute name="id"><![CDATA[managementtype]]></xsl:attribute>
					<xsl:text><![CDATA[Document Type]]></xsl:text>
				</xsl:element>
				<xsl:element name="td">
					<xsl:if test="string-length(erstellerid) > 0 or string-length(archivetypesid) > 0">
						<xsl:attribute name="class">
							<xsl:text><![CDATA[para]]></xsl:text>
						</xsl:attribute>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="dokumententypid=0">
							<xsl:element name="span">
								<xsl:attribute name="id"><![CDATA[doctypespecification]]></xsl:attribute>
								<xsl:text><![CDATA[Specification]]></xsl:text>
							</xsl:element>
						</xsl:when>
						<xsl:when test="dokumententypid=1">
							<xsl:element name="span">
								<xsl:attribute name="id"><![CDATA[doctyperecord]]></xsl:attribute>
								<xsl:text><![CDATA[Record]]></xsl:text>
							</xsl:element>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="span">
								<xsl:attribute name="id"><![CDATA[doctypeother]]></xsl:attribute>
								<xsl:text><![CDATA[Other]]></xsl:text>
							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:element>
			<xsl:if test="dokumententypid=0">
				<xsl:if test="string-length(vorgaberevision) > 0">
					<xsl:element name="tr">
						<xsl:element name="th">
							<xsl:attribute name="id"><![CDATA[version]]></xsl:attribute>
							<xsl:text><![CDATA[Version]]></xsl:text>
						</xsl:element>
						<xsl:element name="td">
							<xsl:value-of select="vorgaberevision" />
						</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:if test="string-length(vorgabeprueferid) > 0">
					<xsl:element name="tr">
						<xsl:element name="th">
							<xsl:attribute name="id"><![CDATA[verified]]></xsl:attribute>
							<xsl:text><![CDATA[Verified]]></xsl:text>
						</xsl:element>
						<xsl:element name="td">
							<xsl:variable name="fieldid" select="vorgabeprueferid" />
							<xsl:variable name="value">
								<xsl:choose>
									<xsl:when test="not(boolean(number($displaytext)))">
										<xsl:apply-templates select="$areas/rs/r[id=$fieldid]/bezeichnung_a" mode="translate">
											<xsl:with-param name="record" select="$fieldid" />
											<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
											<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
											<xsl:with-param name="language" select="$language" />
											<xsl:with-param name="translations" select="$translations" />
										</xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="$areas/rs/r[id=$fieldid]/beschreibung" mode="translate">
											<xsl:with-param name="record" select="$fieldid" />
											<xsl:with-param name="column"><![CDATA[Beschreibung]]></xsl:with-param>
											<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
											<xsl:with-param name="language" select="$language" />
											<xsl:with-param name="translations" select="$translations" />
										</xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:element name="a">
								<xsl:attribute name="href">
									<xsl:text><![CDATA[#]]></xsl:text>
								</xsl:attribute>
								<xsl:attribute name="onclick">
									<xsl:text><![CDATA[WebModel.navigate(']]></xsl:text>
									<xsl:value-of select="$fieldid" />
									<xsl:text><![CDATA[', 'globalAreaTree'); return false;]]></xsl:text>
								</xsl:attribute>
								<xsl:value-of select="$value" />
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:if test="string-length(vorgabefreigeberid) > 0">
					<xsl:element name="tr">
						<xsl:element name="th">
							<xsl:attribute name="id"><![CDATA[approved]]></xsl:attribute>
							<xsl:text><![CDATA[Approved]]></xsl:text>
						</xsl:element>
						<xsl:element name="td">
							<xsl:variable name="fieldid" select="vorgabefreigeberid" />
							<xsl:variable name="value">
								<xsl:choose>
									<xsl:when test="not(boolean(number($displaytext)))">
										<xsl:apply-templates select="$areas/rs/r[id=$fieldid]/bezeichnung_a" mode="translate">
											<xsl:with-param name="record" select="$fieldid" />
											<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
											<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
											<xsl:with-param name="language" select="$language" />
											<xsl:with-param name="translations" select="$translations" />
										</xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="$areas/rs/r[id=$fieldid]/beschreibung" mode="translate">
											<xsl:with-param name="record" select="$fieldid" />
											<xsl:with-param name="column"><![CDATA[Beschreibung]]></xsl:with-param>
											<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
											<xsl:with-param name="language" select="$language" />
											<xsl:with-param name="translations" select="$translations" />
										</xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:element name="a">
								<xsl:attribute name="href">
									<xsl:text><![CDATA[#]]></xsl:text>
								</xsl:attribute>
								<xsl:attribute name="onclick">
									<xsl:text><![CDATA[WebModel.navigate(']]></xsl:text>
									<xsl:value-of select="$fieldid" />
									<xsl:text><![CDATA[', 'globalAreaTree'); return false;]]></xsl:text>
								</xsl:attribute>
								<xsl:value-of select="$value" />
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:if test="string-length(vorgabeaustauschartid) > 0">
					<xsl:element name="tr">
						<xsl:element name="th">
							<xsl:attribute name="id"><![CDATA[exchangetype]]></xsl:attribute>
							<xsl:text><![CDATA[Exchange Type]]></xsl:text>
						</xsl:element>
						<xsl:element name="td">
							<xsl:variable name="exchangetypeid" select="vorgabeaustauschartid" />
							<xsl:variable name="value">
								<xsl:apply-templates select="$exchange_types/rs/r[id=$exchangetypeid]/art_a" mode="translate">
									<xsl:with-param name="record" select="$exchangetypeid" />
									<xsl:with-param name="column"><![CDATA[Art]]></xsl:with-param>
									<xsl:with-param name="table"><![CDATA[AustauschArt]]></xsl:with-param>
									<xsl:with-param name="language" select="$language" />
									<xsl:with-param name="translations" select="$translations" />
								</xsl:apply-templates>
							</xsl:variable>
							<xsl:value-of select="$value" />
						</xsl:element>
					</xsl:element>
				</xsl:if>
			</xsl:if>
			<xsl:if test="dokumententypid=1">
				<xsl:if test="string-length(nachweisvernichtungsartid) > 0">
					<xsl:element name="tr">
						<xsl:element name="th">
							<xsl:attribute name="id"><![CDATA[invalidation]]></xsl:attribute>
							<xsl:text><![CDATA[Invalidation]]></xsl:text>
						</xsl:element>
						<xsl:element name="td">
							<xsl:variable name="invalidationid" select="nachweisvernichtungsartid" />
							<xsl:variable name="value">
								<xsl:apply-templates select="$invalidation_types/rs/r[id=$invalidationid]/art_a" mode="translate">
									<xsl:with-param name="record" select="$invalidationid" />
									<xsl:with-param name="column"><![CDATA[Art]]></xsl:with-param>
									<xsl:with-param name="table"><![CDATA[VernichtungsArt]]></xsl:with-param>
									<xsl:with-param name="language" select="$language" />
									<xsl:with-param name="translations" select="$translations" />
								</xsl:apply-templates>
							</xsl:variable>
							<xsl:value-of select="$value" />
						</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:if test="string-length(nachweisverantwortungid) > 0">
					<xsl:element name="tr">
						<xsl:element name="th">
							<xsl:attribute name="id"><![CDATA[responsible]]></xsl:attribute>
							<xsl:text><![CDATA[Responsible]]></xsl:text>
						</xsl:element>
						<xsl:element name="td">
							<xsl:variable name="fieldid" select="nachweisverantwortungid" />
							<xsl:variable name="value">
								<xsl:choose>
									<xsl:when test="not(boolean(number($displaytext)))">
										<xsl:apply-templates select="$areas/rs/r[id=$fieldid]/bezeichnung_a" mode="translate">
											<xsl:with-param name="record" select="$fieldid" />
											<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
											<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
											<xsl:with-param name="language" select="$language" />
											<xsl:with-param name="translations" select="$translations" />
										</xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="$areas/rs/r[id=$fieldid]/beschreibung" mode="translate">
											<xsl:with-param name="record" select="$fieldid" />
											<xsl:with-param name="column"><![CDATA[Beschreibung]]></xsl:with-param>
											<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
											<xsl:with-param name="language" select="$language" />
											<xsl:with-param name="translations" select="$translations" />
										</xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:element name="a">
								<xsl:attribute name="href">
									<xsl:text><![CDATA[#]]></xsl:text>
								</xsl:attribute>
								<xsl:attribute name="onclick">
									<xsl:text><![CDATA[WebModel.navigate(']]></xsl:text>
									<xsl:value-of select="$fieldid" />
									<xsl:text><![CDATA[', 'globalAreaTree'); return false;]]></xsl:text>
								</xsl:attribute>
								<xsl:value-of select="$value" />
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:if test="string-length(nachweisauswertungid) > 0">
					<xsl:element name="tr">
						<xsl:element name="th">
							<xsl:attribute name="id"><![CDATA[Evaluation]]></xsl:attribute>
							<xsl:text><![CDATA[Evaluation]]></xsl:text>
						</xsl:element>
						<xsl:element name="td">
							<xsl:variable name="fieldid" select="nachweisauswertungid" />
							<xsl:variable name="value">
								<xsl:choose>
									<xsl:when test="not(boolean(number($displaytext)))">
										<xsl:apply-templates select="$areas/rs/r[id=$fieldid]/bezeichnung_a" mode="translate">
											<xsl:with-param name="record" select="$fieldid" />
											<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
											<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
											<xsl:with-param name="language" select="$language" />
											<xsl:with-param name="translations" select="$translations" />
										</xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="$areas/rs/r[id=$fieldid]/beschreibung" mode="translate">
											<xsl:with-param name="record" select="$fieldid" />
											<xsl:with-param name="column"><![CDATA[Beschreibung]]></xsl:with-param>
											<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
											<xsl:with-param name="language" select="$language" />
											<xsl:with-param name="translations" select="$translations" />
										</xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:element name="a">
								<xsl:attribute name="href">
									<xsl:text><![CDATA[#]]></xsl:text>
								</xsl:attribute>
								<xsl:attribute name="onclick">
									<xsl:text><![CDATA[WebModel.navigate(']]></xsl:text>
									<xsl:value-of select="$fieldid" />
									<xsl:text><![CDATA[', 'globalAreaTree'); return false;]]></xsl:text>
								</xsl:attribute>
								<xsl:value-of select="$value" />
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="search">
		<xsl:param name="start" />
		<xsl:param name="stop" />
		<xsl:param name="terms" />
		<xsl:param name="source">
			<xsl:apply-templates select="anmerkung" mode="translate">
				<xsl:with-param name="fallback" />
				<xsl:with-param name="record" select="$uid" />
				<xsl:with-param name="column"><![CDATA[Anmerkung]]></xsl:with-param>
				<xsl:with-param name="table"><![CDATA[SDatVerw]]></xsl:with-param>
				<xsl:with-param name="language" select="$language" />
				<xsl:with-param name="translations" select="$translations" />
			</xsl:apply-templates>
		</xsl:param>
		<xsl:choose>
			<xsl:when test="string-length($terms) = 0">
				<xsl:variable name="result">
					<xsl:variable name="cut_right">
						<xsl:choose>
							<xsl:when test="string-length(substring-after(substring($source, $start - 50, $stop - $start + 100), ' ')) > 0">
								<xsl:value-of select="substring-after(substring($source, $start - 50, $stop - $start + 100), ' ')" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="substring($source, $start - 50, $stop - $start + 100)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="cut_left">
						<xsl:call-template name="substring-before-last">
							<xsl:with-param name="string" select="$cut_right" />
							<xsl:with-param name="search" select="' '" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="string-length($cut_left) > 0">
							<xsl:value-of select="$cut_left" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$cut_right" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="cleanresult">
					<xsl:call-template name="replace">
						<xsl:with-param name="string" select="$result" />
						<xsl:with-param name="search" select="'&amp;#13;&amp;#10;'" />
						<xsl:with-param name="replacement" select="' '" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="string-length(normalize-space($cleanresult)) > 0">
					<xsl:element name="tr">
						<xsl:element name="td" />
						<xsl:element name="td">
							<xsl:element name="a">
								<xsl:attribute name="href">
									<xsl:text><![CDATA[#]]></xsl:text>
								</xsl:attribute>
								<xsl:attribute name="onclick">
									<xsl:text><![CDATA[WebModel.navigate(']]></xsl:text>
									<xsl:value-of select="uniqueid" />
									<xsl:text><![CDATA[', 'globalInformationTree', false, true); return false;]]></xsl:text>
								</xsl:attribute>
								<xsl:text><![CDATA[[...]]]></xsl:text>
								<xsl:value-of select="normalize-space($cleanresult)" />
								<xsl:text><![CDATA[[...]]]></xsl:text>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>
			</xsl:when>
			<xsl:when test="starts-with($terms, ' ')">
				<xsl:apply-templates select="." mode="search">
					<xsl:with-param name="source" select="$source" />
					<xsl:with-param name="terms" select="substring-after($terms, ' ')" />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="term">
					<xsl:choose>
						<xsl:when test="starts-with($terms, '&quot;') and contains(substring-after($terms, '&quot;'), '&quot;')">
							<xsl:value-of select="substring-before(substring-after($terms, '&quot;'), '&quot;')" />
						</xsl:when>
						<xsl:when test="contains($terms, ' ')">
							<xsl:value-of select="substring-before($terms, ' ')" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$terms" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="new_terms">
					<xsl:choose>
						<xsl:when test="starts-with($terms, '&quot;') and contains(substring-after($terms, '&quot;'), '&quot;')">
							<xsl:value-of select="substring-after(substring-after($terms, '&quot;'), '&quot;')" />
						</xsl:when>
						<xsl:when test="contains($terms, ' ')">
							<xsl:value-of select="substring-after($terms, ' ')" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="substring-after($terms, $term)" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="i_source">
					<xsl:call-template name="toLowerCase">
						<xsl:with-param name="string" select="string($source)" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="i_term">
					<xsl:call-template name="toLowerCase">
						<xsl:with-param name="string" select="string($term)" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="contains($i_source, $i_term)">
						<xsl:apply-templates select="." mode="search">
							<xsl:with-param name="source" select="$source" />
							<xsl:with-param name="terms" select="$new_terms" />
							<xsl:with-param name="start">
								<xsl:choose>
									<xsl:when test="boolean($start)">
										<xsl:value-of select="$start" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="before">
											<xsl:call-template name="substring-before-last">
												<xsl:with-param name="string" select="substring-before($i_source, $i_term)" />
												<xsl:with-param name="search" select="' '" />
											</xsl:call-template>
										</xsl:variable>
										<xsl:value-of select="string-length(substring-before($i_source, $i_term))" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
							<xsl:with-param name="stop">
								<xsl:choose>
									<xsl:when test="boolean($stop)">
										<xsl:value-of select="$stop" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="string-length($i_source) - string-length(substring-after(substring-after(substring-after($i_source, $i_term), ' '), ' '))" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="search">
							<xsl:with-param name="source" select="$source" />
							<xsl:with-param name="terms" select="$new_terms" />
							<xsl:with-param name="start" select="$start" />
							<xsl:with-param name="stop" select="$stop" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>