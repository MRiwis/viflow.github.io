<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl" xmlns:ms="urn:schemas-microsoft-com:xslt" xmlns:js="urn:my-scripts-js">
	<xsl:output method="xml" encoding="utf-8" />

	<xsl:param name="language"><![CDATA[2]]></xsl:param>
	<xsl:param name="displaytext"><![CDATA[1]]></xsl:param>
	<xsl:param name="linkfallback"><![CDATA[0]]></xsl:param>
	<xsl:param name="renferencedareasonly"><![CDATA[0]]></xsl:param>
	<xsl:param name="renferencedinfosonly"><![CDATA[0]]></xsl:param>
	<xsl:param name="exclusionlist"><![CDATA[]]></xsl:param>

	<xsl:variable name="definitions" select="document('../data/benutzerundsprachen.xml')" />
	<xsl:variable name="currentdblanguage" select="document('../data/spracheumschalten.xml')/rs/r/aktsprache" />
	<xsl:variable name="translations_doc" select="document('../data/translations.xml')" />
	<xsl:variable name="translations" select="$translations_doc/rs/r[language=$language and (table='SProStamm' or table='SDatStamm' or table='SBerStamm' or table='Historie') and (column='Beschreibung' or column='Bezeichnung' or column='Aenderung' or column='Details')]" />
	<xsl:variable name="areas" select="document('../data/sberstamm.xml')" />
	<xsl:variable name="areauuids" select="document('../data/sberverw.xml')" />
	<xsl:variable name="areatypes" select="document('../data/berstammart.xml')" />
	<xsl:variable name="participation_refs_global" select="document('../data/htprostammberstamm.xml')" />
	<xsl:variable name="participation_refs_local" select="document('../data/htproverwberstamm.xml')" />
	<xsl:variable name="information" select="document('../data/sdatstamm.xml')" />
	<xsl:variable name="informationuuids" select="document('../data/sdatverw.xml')" />
	<xsl:variable name="informationtypes" select="document('../data/dokumentenart.xml')" />
	<xsl:variable name="assignment_refs_global" select="document('../data/htprostammdatstamm.xml')" />
	<xsl:variable name="assignment_refs_local" select="document('../data/htproverwdatstamm.xml')" />
	<xsl:variable name="processes" select="document('../data/sprostamm.xml')" />
	<xsl:variable name="processes_structure" select="document('../data/sproverw.xml')" />
	<xsl:variable name="processtypes" select="document('../data/prozessart.xml')" />
	<xsl:variable name="history" select="document('../data/historie.xml')" />
	<xsl:variable name="history_map_processes" select="document('../data/htprostammhistorie.xml')" />
	<xsl:variable name="history_map_information" select="document('../data/htdatstammhistorie.xml')" />
	<xsl:variable name="history_map_areas" select="document('../data/htberstammhistorie.xml')" />
	<xsl:variable name="history_range" select="$history/rs/r" />
	<xsl:variable name="exclusions" select="document('../data/exclusions.xml')" />
	<xsl:variable name="exclusions_complete">
		<xsl:choose>
			<xsl:when test="string-length($exclusionlist) > 0">
				<xsl:value-of select="$exclusionlist" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$exclusions/exclusions/id" mode="getExclusions">
					<xsl:with-param name="structure" select="$processes_structure" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:include href="../xslt/intermediate_helper.xslt" />

	<ms:script language="JavaScript" implements-prefix="js">
		<![CDATA[
			function getDateFromDouble(myDate)
			{
			 var epoch = new Date(1899,11,30);
			 var msPerDay = 8.64e7;

			 var n = myDate;
			 var days = Math.floor(n)
			 var dec = n - Math.floor(n);

				if (n < 0 && dec) {
					n = Math.floor(n) - dec;
				}

				var dt = new Date(n * msPerDay + epoch.getTime());

				return dt.toGMTString();
			}
		]]>
	</ms:script>

	<xsl:template match="/">
		<xsl:element name="rss">
			<xsl:attribute name="version"><![CDATA[2.0]]></xsl:attribute>
			<xsl:element name="channel">
				<xsl:variable name="sortedhistory">
					<xsl:apply-templates select="$history/rs/r" mode="sorted_history">
						<xsl:sort order="descending" select="aenderungsdatum" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:variable name="date">
					<xsl:value-of select="number(msxsl:node-set($sortedhistory)[1]/r/aenderungsdatum)"/>
				</xsl:variable>
				<xsl:element name="title"><![CDATA[viflow WebModel History]]></xsl:element>
				<xsl:element name="description"><![CDATA[Provides viflow WebModel History viewable via RSS.]]></xsl:element>
				<xsl:element name="language">
					<xsl:value-of select="$definitions/rs/r[id=4]/*[not(local-name()='id') and $currentdblanguage]" />
				</xsl:element>
				<xsl:element name="link">
					<xsl:text><![CDATA[../rss/]]></xsl:text>
					<xsl:value-of select="$language" />
					<xsl:text><![CDATA[.xml]]></xsl:text>
				</xsl:element>
				<xsl:apply-templates select="$history_range" mode="items">
					<xsl:sort select="aenderungsdatum" order="descending" />
				</xsl:apply-templates>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="items">
		<xsl:variable name="hid" select="id" />
		<xsl:variable name="fid" select="fromid" />
		<xsl:variable name="tid" select="toid" />
		<xsl:choose>
			<xsl:when test="count($history_map_processes/rs/r[toid=$hid]) > 0">
				<xsl:variable name="oid" select="$history_map_processes/rs/r[toid=$hid]/fromid" />
				<xsl:apply-templates select="$processes/rs/r[id = $oid]" mode="item_details">
					<xsl:with-param name="history" select="." />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="count($history_map_information/rs/r[toid=$hid]) > 0">
				<xsl:variable name="oid" select="$history_map_information/rs/r[toid=$hid]/fromid" />
				<xsl:apply-templates select="$information/rs/r[id = $oid]" mode="item_details">
					<xsl:with-param name="history" select="." />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="count($history_map_areas/rs/r[toid=$hid]) > 0">
				<xsl:variable name="oid" select="$history_map_areas/rs/r[toid=$hid]/fromid" />
				<xsl:apply-templates select="$areas/rs/r[id = $oid]" mode="item_details">
					<xsl:with-param name="history" select="." />
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="r" mode="item_details">
		<xsl:param name="history" />
		<xsl:variable name="excluded">
			<xsl:choose>
				<xsl:when test=".. = $processes/rs and contains($exclusions_complete, concat('|', id, '|'))">
					<xsl:text><![CDATA[excluded]]></xsl:text>
				</xsl:when>
				<xsl:when test=".. = $information/rs">
					<xsl:variable name="isReferenced">
						<xsl:call-template name="isReferencedInformation">
							<xsl:with-param name="information" select="." />
						</xsl:call-template>
					</xsl:variable>
					<xsl:if test="not(boolean(number($isReferenced)))">
						<xsl:text><![CDATA[excluded]]></xsl:text>
					</xsl:if>
				</xsl:when>
				<xsl:when test=".. = $areas/rs">
					<xsl:variable name="isReferenced">
						<xsl:call-template name="isReferencedArea">
							<xsl:with-param name="area" select="." />
						</xsl:call-template>
					</xsl:variable>
					<xsl:if test="not(boolean(number($isReferenced)))">
						<xsl:text><![CDATA[excluded]]></xsl:text>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="type">
			<xsl:choose>
				<xsl:when test=".. = $processes/rs">
					<xsl:text><![CDATA[P]]></xsl:text>
				</xsl:when>
				<xsl:when test=".. = $information/rs">
					<xsl:text><![CDATA[I]]></xsl:text>
				</xsl:when>
				<xsl:when test=".. = $areas/rs">
					<xsl:text><![CDATA[A]]></xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($excluded) = 0">
			<xsl:element name="item">
				<xsl:element name="title">
					<xsl:variable name="value">
						<xsl:variable name="table">
							<xsl:choose>
								<xsl:when test="$type = 'A'">
									<xsl:text><![CDATA[SBerStamm]]></xsl:text>
								</xsl:when>
								<xsl:when test="$type = 'I'">
									<xsl:text><![CDATA[SDatStamm]]></xsl:text>
								</xsl:when>
								<xsl:when test="$type = 'P'">
									<xsl:text><![CDATA[SProStamm]]></xsl:text>
								</xsl:when>
							</xsl:choose>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="not(boolean(number($displaytext)))">
								<xsl:apply-templates select="bezeichnung_a" mode="translate">
									<xsl:with-param name="record" select="id" />
									<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
									<xsl:with-param name="table" select="$table" />
									<xsl:with-param name="language" select="$language" />
									<xsl:with-param name="translations" select="$translations" />
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="beschreibung" mode="translate">
									<xsl:with-param name="record" select="id" />
									<xsl:with-param name="column"><![CDATA[Beschreibung]]></xsl:with-param>
									<xsl:with-param name="table" select="$table" />
									<xsl:with-param name="language" select="$language" />
									<xsl:with-param name="translations" select="$translations" />
								</xsl:apply-templates>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<!-- Uncomment if really needed! -->
					<!--<xsl:value-of select="$type" />
					<xsl:text> – </xsl:text>-->
					<xsl:value-of select="$value"/>
					<xsl:text>: </xsl:text>
					<xsl:variable name="change">
						<xsl:apply-templates select="$history/aenderung" mode="translate">
							<xsl:with-param name="record" select="$history/id" />
							<xsl:with-param name="column"><![CDATA[Aenderung]]></xsl:with-param>
							<xsl:with-param name="table"><![CDATA[Historie]]></xsl:with-param>
							<xsl:with-param name="language" select="$language" />
							<xsl:with-param name="translations" select="$translations" />
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:value-of select="$change" />
				</xsl:element>
				<xsl:element name="link">
					<xsl:value-of select="concat('../index.html?objectid=', id, '&amp;typeflag=', translate($type, 'PIA', 'pia'))" />
				</xsl:element>
				<xsl:element name="guid">
					<xsl:value-of select="number($history/aenderungsdatum)" />
				</xsl:element>
				<xsl:element name="pubDate">
					<xsl:variable name="date" select="number($history/aenderungsdatum)" />
					<xsl:value-of select="js:getDateFromDouble($date)" />
				</xsl:element>
				<xsl:element name="description">
					<xsl:variable name="details">
						<xsl:apply-templates select="$history/details" mode="translate">
							<xsl:with-param name="record" select="$history/id" />
							<xsl:with-param name="column"><![CDATA[Details]]></xsl:with-param>
							<xsl:with-param name="table"><![CDATA[Historie]]></xsl:with-param>
							<xsl:with-param name="language" select="$language" />
							<xsl:with-param name="translations" select="$translations" />
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:value-of select="$details" />
				</xsl:element>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template name="isReferencedArea" match="r" mode="isReferenced">
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
			<xsl:when test="number($renferencedareasonly) = 0">
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
				<xsl:variable name="pid" select="$processes_structure/rs/r[uniqueid=$uuid]/stammid" />
				<xsl:if test="not(contains($exclusions_complete, concat('|', $pid, '|')))">
					<xsl:value-of select="1" />
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="isReferencedInformation" match="r" mode="isReferenced">
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
			<xsl:when test="number($renferencedinfosonly) = 0">
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
				<xsl:variable name="pid" select="$processes_structure/rs/r[uniqueid=$uuid]/stammid" />
				<xsl:if test="not(contains($exclusions_complete, concat('|', $pid, '|')))">
					<xsl:value-of select="1" />
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@* | node()" />
</xsl:stylesheet>