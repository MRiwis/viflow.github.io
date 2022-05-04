<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<xsl:param name="filter"><![CDATA[34]]></xsl:param>
	<xsl:param name="language"><![CDATA[A]]></xsl:param>
	<xsl:param name="displaytext"><![CDATA[1]]></xsl:param>
	<xsl:param name="linkfallback"><![CDATA[0]]></xsl:param>
	<xsl:param name="searchterms"><![CDATA[]]></xsl:param>
	<xsl:param name="exclusionlist"><![CDATA[]]></xsl:param>

	<xsl:variable name="areas" select="document('../data/sberstamm.xml')" />
	<xsl:variable name="areas_unique" select="document('../data/sberverw.xml')" />
	<xsl:variable name="areatypes" select="document('../data/berstammart.xml')" />
	<xsl:variable name="translations_doc" select="document('../data/translations.xml')" />
	<xsl:variable name="translations" select="$translations_doc/rs/r[language=$language]" />
	<xsl:variable name="usermap_global" select="document('../data/htberstammuserfieldvalues.xml')" />
	<xsl:variable name="usermap_local" select="document('../data/htberverwuserfieldvalues.xml')" />
	<xsl:variable name="usermap" select="$usermap_global | $usermap_local" />
	<xsl:variable name="history_map" select="document('../data/htberstammhistorie.xml')" />
	<xsl:variable name="distribution" select="document('../data/htdatstammberstamm.xml')" />
	<xsl:variable name="information" select="document('../data/sdatstamm.xml')" />
	<xsl:variable name="informationtypes" select="document('../data/dokumentenart.xml')" />
	<xsl:variable name="processes" select="document('../data/sprostamm.xml')" />
	<xsl:variable name="processes_unique" select="document('../data/sproverw.xml')" />
	<xsl:variable name="participation_global" select="document('../data/htprostammberstamm.xml')" />
	<xsl:variable name="participation_local" select="document('../data/htproverwberstamm.xml')" />
	<xsl:variable name="participation" select="$participation_global | $participation_local" />
	<xsl:variable name="participation_types" select="document('../data/beteiligungsart.xml')" />
	<xsl:variable name="assignments" select="document('../data/htberstammberstamm.xml')" />
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
		<xsl:value-of select="$areas/rs/r[id=$filter]/id" />
		<xsl:value-of select="$areas_unique/rs/r[uniqueid=$filter]/stammid" />
	</xsl:variable>

	<xsl:variable name="uid">
		<xsl:value-of select="$areas_unique/rs/r[uniqueid=$filter]/uniqueid" />
	</xsl:variable>

	<xsl:include href="../xslt/intermediate_helper.xslt" />
	<xsl:include href="../xslt/intermediate_properties_shared.xslt" />

	<xsl:template match="/">
		<xsl:element name="data">
			<xsl:element name="general">
				<xsl:apply-templates select="$areas/rs/r[id=$gid]" mode="general" />
			</xsl:element>
			<xsl:element name="userfields">
				<xsl:apply-templates select="$areas/rs/r[id=$gid]" mode="userfields">
					<xsl:with-param name="gid" select="$gid" />
					<xsl:with-param name="uid" select="$uid" />
					<xsl:with-param name="language" select="$language" />
					<xsl:with-param name="translations" select="$translations" />
					<xsl:with-param name="usermap" select="$usermap" />
				</xsl:apply-templates>
			</xsl:element>
			<xsl:element name="history">
				<xsl:apply-templates select="$areas/rs/r[id=$gid]" mode="history">
					<xsl:with-param name="gid" select="$gid" />
					<xsl:with-param name="uid" select="$uid" />
					<xsl:with-param name="language" select="$language" />
					<xsl:with-param name="translations" select="$translations" />
					<xsl:with-param name="history_map" select="$history_map" />
				</xsl:apply-templates>
			</xsl:element>
			<xsl:element name="distribution">
				<xsl:apply-templates select="$areas/rs/r[id=$gid]" mode="distribution" />
			</xsl:element>
			<xsl:element name="references">
				<xsl:apply-templates select="$areas/rs/r[id=$gid]" mode="references" />
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
							<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
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
							<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
							<xsl:with-param name="language" select="$language" />
							<xsl:with-param name="translations" select="$translations" />
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:value-of select="$value" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="tr">
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[areatype]]></xsl:attribute>
					<xsl:text><![CDATA[Area Type]]></xsl:text>
				</xsl:element>
				<xsl:element name="td">
					<xsl:variable name="typeid">
						<xsl:value-of select="art" />
					</xsl:variable>
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
			<xsl:variable name="email">
				<xsl:apply-templates select="email" mode="translate">
					<xsl:with-param name="fallback" select="boolean(number($linkfallback))" />
					<xsl:with-param name="record" select="id" />
					<xsl:with-param name="column"><![CDATA[EMail]]></xsl:with-param>
					<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
					<xsl:with-param name="language" select="$language" />
					<xsl:with-param name="translations" select="$translations" />
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:if test="string-length($email) > 0">
				<xsl:element name="tr">
					<xsl:element name="th">
						<xsl:attribute name="id"><![CDATA[email]]></xsl:attribute>
						<xsl:text><![CDATA[E-Mail]]></xsl:text>
					</xsl:element>
					<xsl:element name="td">
						<xsl:element name="a">
							<xsl:attribute name="href">
								<xsl:text><![CDATA[mailto:]]></xsl:text>
								<xsl:value-of select="translate($email, ', ', '; ')" />
							</xsl:attribute>
							<xsl:value-of select="$email" />
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
						<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:variable>
			<xsl:variable name="comment_l">
				<xsl:variable name="value">
					<xsl:apply-templates select="$areas_unique/rs/r[uniqueid=$uid]/anmerkung" mode="translate">
						<xsl:with-param name="fallback" />
						<xsl:with-param name="record" select="$uid" />
						<xsl:with-param name="column"><![CDATA[Anmerkung]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[SBerVerw]]></xsl:with-param>
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
				<xsl:apply-templates select="$areas_unique/rs/r[stammid=$id and not(uniqueid=$uid)]" mode="search">
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
					<xsl:attribute name="id"><![CDATA[informationobject]]></xsl:attribute>
					<xsl:text><![CDATA[Information]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[link]]></xsl:attribute>
					<xsl:text><![CDATA[Link]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[informationtype]]></xsl:attribute>
					<xsl:text><![CDATA[Information Type]]></xsl:text>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="$distribution/rs/r[toid=$gid]" mode="distribution_rows" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="distribution_rows">
		<xsl:variable name="fieldid" select="fromid" />
		<xsl:variable name="typeid" select="$information/rs/r[id=$fieldid]/dokumentenartid" />
		<xsl:element name="tr">
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:choose>
						<xsl:when test="not(boolean(number($displaytext)))">
							<xsl:apply-templates select="$information/rs/r[id=$fieldid]/bezeichnung_a" mode="translate">
								<xsl:with-param name="record" select="$fieldid" />
								<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
								<xsl:with-param name="table"><![CDATA[SDatStamm]]></xsl:with-param>
								<xsl:with-param name="language" select="$language" />
								<xsl:with-param name="translations" select="$translations" />
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="$information/rs/r[id=$fieldid]/beschreibung" mode="translate">
								<xsl:with-param name="record" select="$fieldid" />
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
						<xsl:value-of select="$fieldid" />
						<xsl:text><![CDATA[', 'globalInformationTree'); return false;]]></xsl:text>
					</xsl:attribute>
					<xsl:value-of select="$value" />
				</xsl:element>
			</xsl:element>
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:apply-templates select="$information/rs/r[id=$fieldid]/dokument" mode="translate">
						<xsl:with-param name="fallback" select="boolean(number($linkfallback))" />
						<xsl:with-param name="record" select="$typeid" />
						<xsl:with-param name="column"><![CDATA[Dokument]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[SDatStamm]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:if test="string-length($value) > 0">
					<xsl:variable name="display">
						<xsl:call-template name="substring-after-last">
							<xsl:with-param name="string" select="translate($value, '\', '/')" />
							<xsl:with-param name="search" select="'/'" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:element name="a">
						<xsl:attribute name="href">
							<xsl:value-of select="$value" />
						</xsl:attribute>
						<xsl:attribute name="onclick"><![CDATA[WebModel.UI.navigateURI(window.event || event);]]></xsl:attribute>
						<xsl:attribute name="target"><![CDATA[_blank]]></xsl:attribute>
						<xsl:value-of select="$display" />
					</xsl:element>
				</xsl:if>
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

			<xsl:variable name="refdata">
				<xsl:apply-templates select="$areas_unique/rs/r[stammid=$gid] | $participation/rs/r[toid=$gid]" mode="references_rows" />
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
						<xsl:attribute name="id"><![CDATA[participation]]></xsl:attribute>
						<xsl:text><![CDATA[Participation Type]]></xsl:text>
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
						<xsl:attribute name="id"><![CDATA[area]]></xsl:attribute>
						<xsl:attribute name="class"><![CDATA[sorted_desc]]></xsl:attribute>
						<xsl:text><![CDATA[Area]]></xsl:text>
					</xsl:element>
					<xsl:element name="th">
						<xsl:if test="string-length($refdata) > 0">
							<xsl:attribute name="style"><![CDATA[padding-top: 1.5em;]]></xsl:attribute>
						</xsl:if>
						<xsl:attribute name="id"><![CDATA[areatype]]></xsl:attribute>
						<xsl:attribute name="class"><![CDATA[sorted_desc]]></xsl:attribute>
						<xsl:text><![CDATA[Area Type]]></xsl:text>
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
		<xsl:variable name="participationid" select="beteiligungsid" />
		<xsl:variable name="shapeid">
			<xsl:choose>
				<xsl:when test="$participationid">
					<xsl:value-of select="uniquefromid"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="$areas_unique/rs/r[dateiid=$graphicid and stammid=$gid]/uniqueid">
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
					<xsl:if test="$participationid">
						<xsl:variable name="subvalue">
							<xsl:choose>
								<xsl:when test="not(boolean(number($displaytext)))">
									<xsl:apply-templates select="$processes/rs/r[id=$activityid]/bezeichnung_a" mode="translate">
										<xsl:with-param name="record" select="$activityid" />
										<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
										<xsl:with-param name="table"><![CDATA[SProStamm]]></xsl:with-param>
										<xsl:with-param name="language" select="$language" />
										<xsl:with-param name="translations" select="$translations" />
									</xsl:apply-templates>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="$processes/rs/r[id=$activityid]/beschreibung" mode="translate">
										<xsl:with-param name="record" select="$activityid" />
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
									<xsl:when test="boolean(number($activityid)) or not(not(uniqueid))">
										<xsl:value-of select="$fieldid" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$graphicid" />
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text><![CDATA[', 'globalProcessTree', false); return false;]]></xsl:text>
							</xsl:attribute>
							<xsl:choose>
								<xsl:when test="boolean(number($activityid)) or not(not(uniqueid))">
									<xsl:value-of select="$subvalue" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$value" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:if>
				</xsl:element>
				<xsl:element name="td">
					<xsl:variable name="subvalue">
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
					<xsl:value-of select="$subvalue" />
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
			<xsl:value-of select="$areas/rs/r[id=$id]/art" />
		</xsl:variable>
		<xsl:element name="tr">
			<xsl:element name="td">
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
				<xsl:variable name="value">
					<xsl:apply-templates select="$areatypes/rs/r[id=$type]/art_a" mode="translate">
						<xsl:with-param name="record" select="$type" />
						<xsl:with-param name="column"><![CDATA[Art]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[BerStammArt]]></xsl:with-param>
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

	<xsl:template match="r" mode="search">
		<xsl:param name="start" />
		<xsl:param name="stop" />
		<xsl:param name="terms" />
		<xsl:param name="source">
			<xsl:apply-templates select="anmerkung" mode="translate">
				<xsl:with-param name="fallback" />
				<xsl:with-param name="record" select="$uid" />
				<xsl:with-param name="column"><![CDATA[Anmerkung]]></xsl:with-param>
				<xsl:with-param name="table"><![CDATA[SBerVerw]]></xsl:with-param>
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
									<xsl:text><![CDATA[', 'globalAreaTree', false, true); return false;]]></xsl:text>
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