<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<xsl:param name="filter"><![CDATA[555]]></xsl:param>
	<xsl:param name="language"><![CDATA[A]]></xsl:param>
	<xsl:param name="displaytext"><![CDATA[1]]></xsl:param>
	<xsl:param name="linkfallback"><![CDATA[1]]></xsl:param>
	<xsl:param name="searchterms"><![CDATA[]]></xsl:param>
	<xsl:param name="exclusionlist"><![CDATA[]]></xsl:param>

	<xsl:variable name="processes" select="document('../data/sprostamm.xml')" />
	<xsl:variable name="processes_unique" select="document('../data/sproverw.xml')" />
	<xsl:variable name="processtypes" select="document('../data/prozessart.xml')" />
	<xsl:variable name="translations_doc" select="document('../data/translations.xml')" />
	<xsl:variable name="translations" select="$translations_doc/rs/r[language=$language]" />
	<xsl:variable name="usermap_global" select="document('../data/htprostammuserfieldvalues.xml')" />
	<xsl:variable name="usermap_local" select="document('../data/htproverwuserfieldvalues.xml')" />
	<xsl:variable name="usermap" select="$usermap_global | $usermap_local" />
	<xsl:variable name="history_map" select="document('../data/htprostammhistorie.xml')" />
	<xsl:variable name="criteria_map_global" select="document('../data/htprostammkriterienart.xml')" />
	<xsl:variable name="criteria_map_local" select="document('../data/htproverwkriterienart.xml')" />
	<xsl:variable name="criteria_map" select="$criteria_map_global | $criteria_map_local" />
	<xsl:variable name="participation_global" select="document('../data/htprostammberstamm.xml')" />
	<xsl:variable name="participation_local" select="document('../data/htproverwberstamm.xml')" />
	<xsl:variable name="participation" select="$participation_global | $participation_local" />
	<xsl:variable name="participation_types" select="document('../data/beteiligungsart.xml')" />
	<xsl:variable name="assignedinfo_global" select="document('../data/htprostammdatstamm.xml')" />
	<xsl:variable name="assignedinfo_local" select="document('../data/htproverwdatstamm.xml')" />
	<xsl:variable name="assignedinfo" select="$assignedinfo_global | $assignedinfo_local" />
	<xsl:variable name="assignedinfo_types" select="document('../data/usagetypes.xml')" />
	<xsl:variable name="areas" select="document('../data/sberstamm.xml')" />
	<xsl:variable name="areatypes" select="document('../data/berstammart.xml')" />
	<xsl:variable name="information" select="document('../data/sdatstamm.xml')" />
	<xsl:variable name="information_unique" select="document('../data/sdatverw.xml')" />
	<xsl:variable name="informationtypes" select="document('../data/dokumentenart.xml')" />
	<xsl:variable name="bcps_global" select="document('../data/prostammpotentiale.xml')" />
	<xsl:variable name="bcps_local" select="document('../data/proverwpotentiale.xml')" />
	<xsl:variable name="bcps_types" select="document('../data/bcptypes.xml')" />
	<xsl:variable name="bcps_measures_global_map" select="document('../data/htprostammpotentialemeasures.xml')" />
	<xsl:variable name="bcps_measures_local_map" select="document('../data/htproverwpotentialemeasures.xml')" />
	<xsl:variable name="bcps_measures" select="document('../data/measures.xml')" />
	<xsl:variable name="bcps_measures_states" select="document('../data/measurestates.xml')" />
	<xsl:variable name="kpis" select="document('../data/kpis.xml')" />
	<xsl:variable name="kpis_types" select="document('../data/kpitypes.xml')" />
	<xsl:variable name="kpis_global" select="document('../data/htprostammkpis.xml')" />
	<xsl:variable name="kpis_local" select="document('../data/htproverwkpis.xml')" />
	<xsl:variable name="kpis_values_global" select="document('../data/htprostammkpisvalues.xml')" />
	<xsl:variable name="kpis_values_local" select="document('../data/htproverwkpisvalues.xml')" />
	<xsl:variable name="units" select="document('../data/units.xml')" />
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
		<xsl:value-of select="$processes/rs/r[id=$filter]/id" />
		<xsl:value-of select="$processes_unique/rs/r[uniqueid=$filter]/stammid" />
	</xsl:variable>

	<xsl:variable name="uid">
		<xsl:variable name="uid_temp" select="$processes_unique/rs/r[uniqueid=$filter]/uniqueid" />
		<xsl:choose>
			<xsl:when test="not(boolean(string-length($uid_temp)))">
				<xsl:text><![CDATA[n/a]]></xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$uid_temp" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:key name="references_duplicates" match="r[not(not(uniqueid)) and not(not(dateiid)) and not(not(stammid)) and not(not(nummer)) and not(not(xpos)) and not(not(ypos))]" use="concat(stammid, '_', dateiid)" />

	<xsl:include href="../xslt/intermediate_helper.xslt" />
	<xsl:include href="../xslt/intermediate_properties_shared.xslt" />

	<xsl:template match="/">
		<xsl:element name="data">
			<xsl:element name="general">
				<xsl:apply-templates select="$processes/rs/r[id=$gid]" mode="general" />
			</xsl:element>
			<xsl:element name="userfields">
				<xsl:apply-templates select="$processes/rs/r[id=$gid]" mode="userfields">
					<xsl:with-param name="gid" select="$gid" />
					<xsl:with-param name="uid" select="$uid" />
					<xsl:with-param name="language" select="$language" />
					<xsl:with-param name="translations" select="$translations" />
					<xsl:with-param name="usermap" select="$usermap" />
				</xsl:apply-templates>
			</xsl:element>
			<xsl:element name="history">
				<xsl:apply-templates select="$processes/rs/r[id=$gid]" mode="history">
					<xsl:with-param name="gid" select="$gid" />
					<xsl:with-param name="uid" select="$uid" />
					<xsl:with-param name="language" select="$language" />
					<xsl:with-param name="translations" select="$translations" />
					<xsl:with-param name="history_map" select="$history_map" />
					<xsl:with-param name="areas" select="$areas" />
					<xsl:with-param name="displaytext" select="$displaytext" />
				</xsl:apply-templates>
			</xsl:element>
			<xsl:element name="criteria">
				<xsl:apply-templates select="$processes/rs/r[id=$gid]" mode="criteria">
					<xsl:with-param name="gid" select="$gid" />
					<xsl:with-param name="uid" select="$uid" />
					<xsl:with-param name="language" select="$language" />
					<xsl:with-param name="translations" select="$translations" />
					<xsl:with-param name="criteria_map" select="$criteria_map" />
				</xsl:apply-templates>
			</xsl:element>
			<xsl:element name="participants">
				<xsl:apply-templates select="$processes/rs/r[id=$gid]" mode="participation" />
			</xsl:element>
			<xsl:element name="information">
				<xsl:apply-templates select="$processes/rs/r[id=$gid]" mode="assignedinfo" />
			</xsl:element>
			<xsl:element name="references">
				<xsl:apply-templates select="$processes/rs/r[id=$gid]" mode="references" />
			</xsl:element>
			<xsl:element name="bcps">
				<xsl:apply-templates select="$processes/rs/r[id=$gid]" mode="bcps" />
			</xsl:element>
			<xsl:element name="kpis">
				<xsl:apply-templates select="$processes/rs/r[id=$gid]" mode="kpis" />
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
							<xsl:with-param name="table"><![CDATA[SProStamm]]></xsl:with-param>
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
							<xsl:with-param name="table"><![CDATA[SProStamm]]></xsl:with-param>
							<xsl:with-param name="language" select="$language" />
							<xsl:with-param name="translations" select="$translations" />
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:value-of select="$value" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="tr">
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[processtype]]></xsl:attribute>
					<xsl:text><![CDATA[Process Type]]></xsl:text>
				</xsl:element>
				<xsl:element name="td">
					<xsl:variable name="typeid">
						<xsl:value-of select="prozessartid" />
					</xsl:variable>
					<xsl:variable name="value">
						<xsl:apply-templates select="$processtypes/rs/r[id=$typeid]/art_a" mode="translate">
							<xsl:with-param name="record" select="$typeid" />
							<xsl:with-param name="column"><![CDATA[Art]]></xsl:with-param>
							<xsl:with-param name="table"><![CDATA[ProzessArt]]></xsl:with-param>
							<xsl:with-param name="language" select="$language" />
							<xsl:with-param name="translations" select="$translations" />
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:value-of select="$value" />
				</xsl:element>
			</xsl:element>
			<xsl:variable name="comment_g">
				<xsl:variable name="value">
					<xsl:apply-templates select="anmerkung" mode="translate">
						<xsl:with-param name="fallback" />
						<xsl:with-param name="record" select="id" />
						<xsl:with-param name="column"><![CDATA[Anmerkung]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[SProStamm]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:variable>
			<xsl:variable name="comment_l">
				<xsl:variable name="value">
					<xsl:apply-templates select="$processes_unique/rs/r[uniqueid=$uid]/anmerkung" mode="translate">
						<xsl:with-param name="fallback" />
						<xsl:with-param name="record" select="$uid" />
						<xsl:with-param name="column"><![CDATA[Anmerkung]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[SProVerw]]></xsl:with-param>
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
				<xsl:apply-templates select="$processes_unique/rs/r[stammid=$id and not(uniqueid=$uid)]" mode="search">
					<xsl:with-param name="terms" select="$searchterms" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="participation">
		<xsl:element name="table">
			<xsl:attribute name="class"><![CDATA[propTable sortable]]></xsl:attribute>
			<xsl:element name="tr">
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[area]]></xsl:attribute>
					<xsl:text><![CDATA[Area]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[participation]]></xsl:attribute>
					<xsl:text><![CDATA[Participation Type]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[areatype]]></xsl:attribute>
					<xsl:text><![CDATA[Area Type]]></xsl:text>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="$participation/rs/r[fromid=$gid or uniquefromid=$uid]" mode="participation_rows" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="participation_rows">
		<xsl:variable name="fieldid" select="toid" />
		<xsl:variable name="typeid" select="$areas/rs/r[id=$fieldid]/art" />
		<xsl:variable name="participationid" select="beteiligungsid" />
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
					<xsl:choose>
						<xsl:when test="not(boolean(number($displaytext)))">
							<xsl:apply-templates select="$participation_types/rs/r[id=$participationid]/kurzzeichen_a" mode="translate">
								<xsl:with-param name="record" select="$participationid" />
								<xsl:with-param name="column"><![CDATA[Kurzzeichen]]></xsl:with-param>
								<xsl:with-param name="table"><![CDATA[BeteiligungsArt]]></xsl:with-param>
								<xsl:with-param name="language" select="$language" />
								<xsl:with-param name="translations" select="$translations" />
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="$participation_types/rs/r[id=$participationid]/beteiligung_a" mode="translate">
								<xsl:with-param name="record" select="$participationid" />
								<xsl:with-param name="column"><![CDATA[Beteiligung]]></xsl:with-param>
								<xsl:with-param name="table"><![CDATA[BeteiligungsArt]]></xsl:with-param>
								<xsl:with-param name="language" select="$language" />
								<xsl:with-param name="translations" select="$translations" />
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="$value" />
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

	<xsl:template match="r" mode="assignedinfo">
		<xsl:element name="table">
			<xsl:attribute name="class"><![CDATA[propTable sortable]]></xsl:attribute>
			<xsl:element name="tr">
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[informationobject]]></xsl:attribute>
					<xsl:text><![CDATA[Information]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[link]]></xsl:attribute>
					<xsl:text><![CDATA[Link]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[usagetype]]></xsl:attribute>
					<xsl:text><![CDATA[Usage Type]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[informationtype]]></xsl:attribute>
					<xsl:text><![CDATA[Information Type]]></xsl:text>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="$information_unique/rs/r[(fromid=$uid and string-length(toid) = 0) or (string-length(fromid) = 0 and toid=$uid)] | $assignedinfo/rs/r[fromid=$gid or uniquefromid=$uid]" mode="assignedinfo_rows" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="assignedinfo_rows">
		<xsl:variable name="fieldid" select="toid" />
		<xsl:variable name="infoid" select="stammid" />
		<xsl:variable name="sid" select="$information/rs/r[id=$fieldid or id=$infoid]/id" />
		<xsl:variable name="usagetypeid" select="usagetypeid" />
		<xsl:variable name="typeid" select="$information/rs/r[id=$sid]/dokumentenartid" />
		<xsl:element name="tr">
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:choose>
						<xsl:when test="not(boolean(number($displaytext)))">
							<xsl:apply-templates select="$information/rs/r[id=$sid]/bezeichnung_a" mode="translate">
								<xsl:with-param name="record" select="$sid" />
								<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
								<xsl:with-param name="table"><![CDATA[SDatStamm]]></xsl:with-param>
								<xsl:with-param name="language" select="$language" />
								<xsl:with-param name="translations" select="$translations" />
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="$information/rs/r[id=$sid]/beschreibung" mode="translate">
								<xsl:with-param name="record" select="$sid" />
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
						<xsl:value-of select="$sid" />
						<xsl:text><![CDATA[', 'globalInformationTree'); return false;]]></xsl:text>
					</xsl:attribute>
					<xsl:value-of select="$value" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="td">
				<xsl:variable name="document">
					<xsl:apply-templates select="$information/rs/r[id=$sid]/dokument" mode="translate">
						<xsl:with-param name="fallback" select="boolean(number($linkfallback))" />
						<xsl:with-param name="record" select="$fieldid" />
						<xsl:with-param name="column"><![CDATA[Dokument]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[SDatStamm]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:if test="string-length($document) > 0">
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
				</xsl:if>
			</xsl:element>
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:choose>
						<xsl:when test="$usagetypeid">
							<xsl:apply-templates select="$assignedinfo_types/rs/r[id=$usagetypeid]/name_a" mode="translate">
								<xsl:with-param name="record" select="$usagetypeid" />
								<xsl:with-param name="column"><![CDATA[Name]]></xsl:with-param>
								<xsl:with-param name="table"><![CDATA[UsageTypes]]></xsl:with-param>
								<xsl:with-param name="language" select="$language" />
								<xsl:with-param name="translations" select="$translations" />
							</xsl:apply-templates>
						</xsl:when>
						<xsl:when test="string-length(fromid) > 0 and string-length(toid) = 0">
							<xsl:element name="span">
								<xsl:attribute name="id"><![CDATA[output]]></xsl:attribute>
								<xsl:text><![CDATA[Output]]></xsl:text>
							</xsl:element>
						</xsl:when>
						<xsl:when test="string-length(fromid) = 0 and string-length(toid) > 0">
							<xsl:element name="span">
								<xsl:attribute name="id"><![CDATA[input]]></xsl:attribute>
								<xsl:text><![CDATA[Input]]></xsl:text>
							</xsl:element>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:element>
			<xsl:element name="td">
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
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="references">
		<xsl:element name="table">
			<xsl:attribute name="class"><![CDATA[propTable sortable]]></xsl:attribute>
			<xsl:element name="tr">
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[graphic]]></xsl:attribute>
					<xsl:attribute name="class"><![CDATA[sorted_desc]]></xsl:attribute>
					<xsl:text><![CDATA[Graphic]]></xsl:text>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="$processes_unique/rs/r[stammid = $gid and generate-id() = generate-id(key('references_duplicates', concat(stammid, '_', dateiid)))]" mode="references_rows" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="references_rows">
		<xsl:variable name="fieldid" select="dateiid" />
		<xsl:if test="not(contains($exclusions_complete, concat('|', $fieldid, '|')))">
			<xsl:element name="tr">
				<xsl:element name="td">
					<xsl:variable name="value">
						<xsl:choose>
							<xsl:when test="not(boolean(number($displaytext)))">
								<xsl:apply-templates select="$processes/rs/r[id=$fieldid]/bezeichnung_a" mode="translate">
									<xsl:with-param name="record" select="$fieldid" />
									<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
									<xsl:with-param name="table"><![CDATA[SProStamm]]></xsl:with-param>
									<xsl:with-param name="language" select="$language" />
									<xsl:with-param name="translations" select="$translations" />
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="$processes/rs/r[id=$fieldid]/beschreibung" mode="translate">
									<xsl:with-param name="record" select="$fieldid" />
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
							<xsl:value-of select="$fieldid" />
							<xsl:text><![CDATA[', 'globalProcessTree', true, undefined, undefined, ']]></xsl:text>
							<xsl:value-of select="uniqueid"/>
							<xsl:text><![CDATA['); WebModel.UI.PropertyWindow.close(); return false;]]></xsl:text>
						</xsl:attribute>
						<xsl:value-of select="$value" />
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="r" mode="bcps">
		<xsl:element name="table">
			<xsl:attribute name="class"><![CDATA[propTable sortable]]></xsl:attribute>
			<xsl:element name="tr">
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[situation]]></xsl:attribute>
					<xsl:text><![CDATA[Situation]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[effect]]></xsl:attribute>
					<xsl:text><![CDATA[Effect]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[rpz]]></xsl:attribute>
					<xsl:text><![CDATA[RPN]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[measures]]></xsl:attribute>
					<xsl:text><![CDATA[Measures]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[type]]></xsl:attribute>
					<xsl:text><![CDATA[Type]]></xsl:text>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="$bcps_global/rs/r[stammid=$gid] | $bcps_local/rs/r[uniqueid=$uid]" mode="bcps_rows" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="bcps_rows">
		<xsl:variable name="global" select="not(uniqueid)" />
		<xsl:variable name="table">
			<xsl:choose>
				<xsl:when test="$global"><![CDATA[ProStammPotentiale]]></xsl:when>
				<xsl:otherwise><![CDATA[ProVerwPotentiale]]></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="tr">
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:apply-templates select="situation" mode="translate">
						<xsl:with-param name="record" select="id" />
						<xsl:with-param name="column"><![CDATA[Situation]]></xsl:with-param>
						<xsl:with-param name="table" select="$table" />
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:element>
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:apply-templates select="auswirkung" mode="translate">
						<xsl:with-param name="record" select="id" />
						<xsl:with-param name="column"><![CDATA[Auswirkung]]></xsl:with-param>
						<xsl:with-param name="table" select="$table" />
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:element>
			<xsl:element name="td">
				<xsl:variable name ="rpz" select="number(number(translate(detectability, ',', '.')) * number(translate(occurrence, ',', '.')) * number(translate(severity, ',', '.')))" />
				<xsl:if test="boolean(number($rpz))">
					<xsl:value-of select="$rpz" />
				</xsl:if>
			</xsl:element>
			<xsl:element name="td">
				<xsl:variable name="id" select="id" />
				<xsl:choose>
					<xsl:when test="$global">
						<xsl:apply-templates select="$bcps_measures_global_map/rs/r[fromid=$id]" mode="bcp_measures" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$bcps_measures_local_map/rs/r[fromid=$id]" mode="bcp_measures" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="td">
				<xsl:variable name="id" select="typeid" />
				<xsl:variable name="value">
					<xsl:apply-templates select="$bcps_types/rs/r[id=$id]/name_a" mode="translate">
						<xsl:with-param name="record" select="id" />
						<xsl:with-param name="column"><![CDATA[Name]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[BCPTypes]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="bcp_measures">
		<xsl:variable name="measureid" select="toid" />
		<xsl:element name="table">
			<xsl:attribute name="class"><![CDATA[propTable]]></xsl:attribute>
			<xsl:element name="caption">
				<xsl:if test="position() > 1">
					<xsl:attribute name="class"><![CDATA[para]]></xsl:attribute>
				</xsl:if>
				<xsl:variable name="value">
					<xsl:apply-templates select="$bcps_measures/rs/r[id=$measureid]/measure" mode="translate">
						<xsl:with-param name="record" select="$measureid" />
						<xsl:with-param name="column"><![CDATA[Measure]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[Measures]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:element>
			<xsl:element name="tr">
				<xsl:element name="td">
					<xsl:attribute name="id"><![CDATA[status]]></xsl:attribute>
					<xsl:text><![CDATA[Status]]></xsl:text>
				</xsl:element>
				<xsl:element name="td">
					<xsl:variable name="id" select="$bcps_measures/rs/r[id=$measureid]/stateid" />
					<xsl:variable name="value">
						<xsl:apply-templates select="$bcps_measures_states/rs/r[id=$id]/name_a" mode="translate">
							<xsl:with-param name="record" select="$id" />
							<xsl:with-param name="column"><![CDATA[Name]]></xsl:with-param>
							<xsl:with-param name="table"><![CDATA[MeasureStates]]></xsl:with-param>
							<xsl:with-param name="language" select="$language" />
							<xsl:with-param name="translations" select="$translations" />
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:value-of select="$value" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="tr">
				<xsl:element name="td">
					<xsl:attribute name="id"><![CDATA[responsible]]></xsl:attribute>
					<xsl:text><![CDATA[Responsible]]></xsl:text>
				</xsl:element>
				<xsl:element name="td">
					<xsl:variable name="id" select="$bcps_measures/rs/r[id=$measureid]/responsibleid" />
					<xsl:variable name="value">
						<xsl:choose>
							<xsl:when test="not(boolean(number($displaytext)))">
								<xsl:apply-templates select="$areas/rs/r[id=$id]/bezeichnung_a" mode="translate">
									<xsl:with-param name="record" select="$id" />
									<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
									<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
									<xsl:with-param name="language" select="$language" />
									<xsl:with-param name="translations" select="$translations" />
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="$areas/rs/r[id=$id]/beschreibung" mode="translate">
									<xsl:with-param name="record" select="$id" />
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
							<xsl:value-of select="$id" />
							<xsl:text><![CDATA[', 'globalAreaTree'); return false;]]></xsl:text>
						</xsl:attribute>
						<xsl:value-of select="$value" />
					</xsl:element>
				</xsl:element>
			</xsl:element>
			<xsl:element name="tr">
				<xsl:element name="ts">
					<xsl:attribute name="id"><![CDATA[duedate]]></xsl:attribute>
					<xsl:text><![CDATA[Due Date]]></xsl:text>
				</xsl:element>
				<xsl:element name="td">
					<xsl:attribute name="class"><![CDATA[timestamp]]></xsl:attribute>
					<xsl:value-of select="$bcps_measures/rs/r[id=$measureid]/duedate" />
				</xsl:element>
			</xsl:element>
			<xsl:if test="boolean(completed)">
				<xsl:element name="tr">
					<xsl:element name="td">
						<xsl:attribute name="id"><![CDATA[completiondate]]></xsl:attribute>
						<xsl:text><![CDATA[Completion Date]]></xsl:text>
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class"><![CDATA[timestamp]]></xsl:attribute>
						<xsl:value-of select="$bcps_measures/rs/r[id=$measureid]/completiondate" />
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="kpis">
		<xsl:element name="table">
			<xsl:attribute name="class"><![CDATA[propTable sortable]]></xsl:attribute>
			<xsl:element name="tr">
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[kpi]]></xsl:attribute>
					<xsl:text><![CDATA[KPI]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[value]]></xsl:attribute>
					<xsl:text><![CDATA[Value]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[unit]]></xsl:attribute>
					<xsl:text><![CDATA[Unit]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[date]]></xsl:attribute>
					<xsl:text><![CDATA[Date]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[responsible]]></xsl:attribute>
					<xsl:text><![CDATA[Responsible]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[link]]></xsl:attribute>
					<xsl:text><![CDATA[Link]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[comment]]></xsl:attribute>
					<xsl:text><![CDATA[Commment]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[type]]></xsl:attribute>
					<xsl:text><![CDATA[Type]]></xsl:text>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="$kpis_global/rs/r[fromid=$gid] | $kpis_local/rs/r[fromid=$uid]" mode="kpis_rows">
				<xsl:with-param name="uuid" select="$uid" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="kpis_rows">
		<xsl:param name="uuid" />
		<xsl:variable name="global" select="not($uuid=fromid)" />
		<xsl:variable name="kid" select="toid" />
		<xsl:variable name="vid" select="id" />
		<xsl:element name="tr">
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:apply-templates select="$kpis/rs/r[id=$kid]/name_a" mode="translate">
						<xsl:with-param name="record" select="$kid" />
						<xsl:with-param name="column"><![CDATA[Name]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[KPIs]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:element>
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:choose>
						<xsl:when test="$global">
							<xsl:apply-templates select="$kpis_values_global/rs/r[kid=$vid]" mode="kpis_values">
								<xsl:sort select="currentvaluedate" order="descending" />
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="$kpis_values_local/rs/r[kid=$vid]" mode="kpis_values">
								<xsl:sort select="currentvaluedate" order="descending" />
							</xsl:apply-templates>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:attribute name="class">
					<xsl:choose>
						<xsl:when test="boolean(number($kpis/rs/r[id=$kid]/higherisbetter)) and number(translate($value, ',', '.')) > number(translate(targetvalue, ',', '.')) and string-length(targetvalue) > 0"><![CDATA[green]]></xsl:when>
						<xsl:when test="not(boolean(number($kpis/rs/r[id=$kid]/higherisbetter))) and number(translate($value, ',', '.')) &lt; number(translate(targetvalue, ',', '.')) and string-length(targetvalue) > 0"><![CDATA[green]]></xsl:when>
						<xsl:when test="not($value = targetvalue) and string-length(targetvalue) > 0"><![CDATA[red]]></xsl:when>
					</xsl:choose>
				</xsl:attribute>
				<xsl:value-of select="$value" />
				<xsl:if test="string-length(targetvalue) > 0">
					<xsl:text><![CDATA[/]]></xsl:text>
					<xsl:value-of select="targetvalue" />
				</xsl:if>
			</xsl:element>
			<xsl:element name="td">
				<xsl:variable name="id" select="$kpis/rs/r[id=$kid]/unitid" />
				<xsl:variable name="value">
					<xsl:apply-templates select="$units/rs/r[id=$id]/name_a" mode="translate">
						<xsl:with-param name="record" select="$kid" />
						<xsl:with-param name="column"><![CDATA[Name]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[Units]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:element>
			<xsl:element name="td">
				<xsl:attribute name="class"><![CDATA[timestamp]]></xsl:attribute>
				<xsl:choose>
					<xsl:when test="$global">
						<xsl:apply-templates select="$kpis_values_global/rs/r[kid=$vid]" mode="kpis_values">
							<xsl:with-param name="date" select="true()" />
							<xsl:sort select="currentvaluedate" order="descending" />
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$kpis_values_local/rs/r[kid=$vid]" mode="kpis_values">
							<xsl:with-param name="date" select="true()" />
							<xsl:sort select="currentvaluedate" order="descending" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="td">
				<xsl:variable name="id" select="responsibleid" />
				<xsl:variable name="value">
					<xsl:choose>
						<xsl:when test="not(boolean(number($displaytext)))">
							<xsl:apply-templates select="$areas/rs/r[id=$id]/bezeichnung_a" mode="translate">
								<xsl:with-param name="record" select="$id" />
								<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
								<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
								<xsl:with-param name="language" select="$language" />
								<xsl:with-param name="translations" select="$translations" />
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="$areas/rs/r[id=$id]/beschreibung" mode="translate">
								<xsl:with-param name="record" select="$id" />
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
						<xsl:value-of select="$id" />
						<xsl:text><![CDATA[', 'globalAreaTree'); return false;]]></xsl:text>
					</xsl:attribute>
					<xsl:value-of select="$value" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="td">
				<xsl:variable name="table">
					<xsl:choose>
						<xsl:when test="$global"><![CDATA[HTProStammKPIs]]></xsl:when>
						<xsl:otherwise><![CDATA[HTProVerwKPIs]]></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="hyperlink">
					<xsl:apply-templates select="hyperlink" mode="translate">
						<xsl:with-param name="fallback" select="boolean(number($linkfallback))" />
						<xsl:with-param name="record" select="id" />
						<xsl:with-param name="column"><![CDATA[Hyperlink]]></xsl:with-param>
						<xsl:with-param name="table" select="$table" />
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:if test="string-length($hyperlink) > 0">
					<xsl:variable name="display">
						<xsl:call-template name="substring-after-last">
							<xsl:with-param name="string" select="translate($hyperlink, '\', '/')" />
							<xsl:with-param name="search" select="'/'" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:element name="a">
						<xsl:attribute name="href">
							<xsl:value-of select="$hyperlink" />
						</xsl:attribute>
						<xsl:attribute name="onclick"><![CDATA[WebModel.UI.navigateURI(window.event || event);]]></xsl:attribute>
						<xsl:attribute name="target"><![CDATA[_blank]]></xsl:attribute>
						<xsl:value-of select="$display" />
					</xsl:element>
				</xsl:if>
			</xsl:element>
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:apply-templates select="$kpis/rs/r[id=$kid]/remark" mode="translate">
						<xsl:with-param name="record" select="$kid" />
						<xsl:with-param name="column"><![CDATA[Remark]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[KPIs]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:element>
			<xsl:element name="td">
				<xsl:variable name="id" select="$kpis/rs/r[id=$kid]/typeid" />
				<xsl:variable name="value">
					<xsl:apply-templates select="$kpis_types/rs/r[id=$id]/name_a" mode="translate">
						<xsl:with-param name="record" select="$kid" />
						<xsl:with-param name="column"><![CDATA[Name]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[KPITypes]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="kpis_values">
		<xsl:param name="date" />
		<xsl:if test="position() = 1">
			<xsl:choose>
				<xsl:when test="$date">
					<xsl:value-of select="currentvaluedate" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="currentvalue" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
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
				<xsl:with-param name="table"><![CDATA[SProVerw]]></xsl:with-param>
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
									<xsl:text><![CDATA[', 'globalProcessTree', false, true); return false;]]></xsl:text>
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