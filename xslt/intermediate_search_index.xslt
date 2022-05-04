<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl" xmlns:ms="urn:schemas-microsoft-com:xslt" xmlns:js="urn:my-scripts-js">
	<xsl:output method="xml" encoding="utf-8" indent="yes" />

	<!-- http://www.google.de/intl/de/help/basics.html for search basics -->

	<xsl:param name="language"><![CDATA[A]]></xsl:param>
	<xsl:param name="displaytext"><![CDATA[1]]></xsl:param>
	<xsl:param name="linkfallback"><![CDATA[0]]></xsl:param>
	<xsl:param name="renferencedareasonly"><![CDATA[0]]></xsl:param>
	<xsl:param name="renferencedinfosonly"><![CDATA[0]]></xsl:param>
	<xsl:param name="exclusionlist"><![CDATA[]]></xsl:param>

	<xsl:variable name="translations_doc" select="document('../data/translations.xml')" />
	<xsl:variable name="translations" select="$translations_doc/rs/r[language=$language and (table='SProStamm' or table='SDatStamm' or table='SBerStamm' or table='BerStammArt' or table='DokumentenArt' or table='ProzessArt') and (column='Beschreibung' or column='Bezeichnung' or column='Anmerkung' or column='EMail' or column='Dokument' or column='Art')]" />
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

	<xsl:template match="/">
		<xsl:element name="i">
			<xsl:apply-templates select="$processes/rs/r | $information/rs/r | $areas/rs/r" mode="getIndexData" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="getIndexData">
		<xsl:variable name="id" select="id" />
		<xsl:choose>
			<xsl:when test=".. = $areas/rs">
				<xsl:variable name="isReferenced">
					<xsl:call-template name="isReferencedArea">
						<xsl:with-param name="area" select="." />
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="boolean(number($isReferenced))">
					<xsl:element name="o">
						<xsl:attribute name="t"><![CDATA[a]]></xsl:attribute>
						<xsl:attribute name="i">
							<xsl:value-of select="$id" />
						</xsl:attribute>
						<xsl:attribute name="c">
							<xsl:choose>
								<xsl:when test="not(boolean(number($displaytext)))">
									<xsl:apply-templates select="bezeichnung_a" mode="translate">
										<xsl:with-param name="record" select="id" />
										<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
										<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
										<xsl:with-param name="language" select="$language" />
										<xsl:with-param name="translations" select="$translations" />
									</xsl:apply-templates>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="beschreibung" mode="translate">
										<xsl:with-param name="record" select="id" />
										<xsl:with-param name="column"><![CDATA[Beschreibung]]></xsl:with-param>
										<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
										<xsl:with-param name="language" select="$language" />
										<xsl:with-param name="translations" select="$translations" />
									</xsl:apply-templates>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:variable name="text">
							<xsl:apply-templates select=".|$areauuids/rs/r[stammid=$id]" mode="general">
								<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:call-template name="replace">
							<xsl:with-param name="string" select="$text" />
							<xsl:with-param name="search" select="'&amp;#13;&amp;#10;'" />
							<xsl:with-param name="replacement" select="' '" />
						</xsl:call-template>
					</xsl:element>
				</xsl:if>
			</xsl:when>
			<xsl:when test=".. = $information/rs">
				<xsl:variable name="isReferenced">
					<xsl:call-template name="isReferencedInformation">
						<xsl:with-param name="information" select="." />
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="boolean(number($isReferenced))">
					<xsl:element name="o">
						<xsl:attribute name="t"><![CDATA[i]]></xsl:attribute>
						<xsl:attribute name="i">
							<xsl:value-of select="$id" />
						</xsl:attribute>
						<xsl:attribute name="c">
							<xsl:choose>
								<xsl:when test="not(boolean(number($displaytext)))">
									<xsl:apply-templates select="bezeichnung_a" mode="translate">
										<xsl:with-param name="record" select="id" />
										<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
										<xsl:with-param name="table"><![CDATA[SDatStamm]]></xsl:with-param>
										<xsl:with-param name="language" select="$language" />
										<xsl:with-param name="translations" select="$translations" />
									</xsl:apply-templates>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="beschreibung" mode="translate">
										<xsl:with-param name="record" select="id" />
										<xsl:with-param name="column"><![CDATA[Beschreibung]]></xsl:with-param>
										<xsl:with-param name="table"><![CDATA[SDatStamm]]></xsl:with-param>
										<xsl:with-param name="language" select="$language" />
										<xsl:with-param name="translations" select="$translations" />
									</xsl:apply-templates>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:variable name="text">
							<xsl:apply-templates select=".|$informationuuids/rs/r[stammid=$id]" mode="general">
								<xsl:with-param name="table"><![CDATA[SDatStamm]]></xsl:with-param>
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:value-of select="normalize-space($text)" />
					</xsl:element>
				</xsl:if>
			</xsl:when>
			<xsl:when test=".. = $processes/rs">
				<xsl:if test="not(contains($exclusions_complete, concat('|', id, '|')))">
					<xsl:element name="o">
						<xsl:attribute name="t"><![CDATA[p]]></xsl:attribute>
						<xsl:attribute name="i">
							<xsl:value-of select="$id" />
						</xsl:attribute>
						<xsl:attribute name="c">
							<xsl:choose>
								<xsl:when test="not(boolean(number($displaytext)))">
									<xsl:apply-templates select="bezeichnung_a" mode="translate">
										<xsl:with-param name="record" select="id" />
										<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
										<xsl:with-param name="table"><![CDATA[SProStamm]]></xsl:with-param>
										<xsl:with-param name="language" select="$language" />
										<xsl:with-param name="translations" select="$translations" />
									</xsl:apply-templates>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="beschreibung" mode="translate">
										<xsl:with-param name="record" select="id" />
										<xsl:with-param name="column"><![CDATA[Beschreibung]]></xsl:with-param>
										<xsl:with-param name="table"><![CDATA[SProStamm]]></xsl:with-param>
										<xsl:with-param name="language" select="$language" />
										<xsl:with-param name="translations" select="$translations" />
									</xsl:apply-templates>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>

						<xsl:variable name="text">
							<xsl:apply-templates select=".|$processes_structure/rs/r[stammid=$id]" mode="general">
								<xsl:with-param name="table"><![CDATA[SProStamm]]></xsl:with-param>
							</xsl:apply-templates>
						</xsl:variable>

						<xsl:value-of select="normalize-space($text)" />
					</xsl:element>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="r" mode="general">
		<xsl:param name="table" />

		<xsl:if test="not(not(bezeichnung_a))">
			<xsl:apply-templates select="bezeichnung_a" mode="translate">
				<xsl:with-param name="record" select="id" />
				<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
				<xsl:with-param name="table" select="$table" />
				<xsl:with-param name="language" select="$language" />
				<xsl:with-param name="translations" select="$translations" />
			</xsl:apply-templates>
			<xsl:text><![CDATA[ ]]></xsl:text>
		</xsl:if>

		<xsl:if test="not(not(beschreibung))">
			<xsl:apply-templates select="beschreibung" mode="translate">
				<xsl:with-param name="record" select="id" />
				<xsl:with-param name="column"><![CDATA[Beschreibung]]></xsl:with-param>
				<xsl:with-param name="table" select="$table" />
				<xsl:with-param name="language" select="$language" />
				<xsl:with-param name="translations" select="$translations" />
			</xsl:apply-templates>
			<xsl:text><![CDATA[ ]]></xsl:text>
		</xsl:if>

		<xsl:if test="not(not(anmerkung))">
			<xsl:apply-templates select="anmerkung" mode="translate">
				<xsl:with-param name="record" select="id" />
				<xsl:with-param name="column"><![CDATA[Anmerkung]]></xsl:with-param>
				<xsl:with-param name="table" select="$table" />
				<xsl:with-param name="language" select="$language" />
				<xsl:with-param name="translations" select="$translations" />
				<xsl:with-param name="fallback" />
			</xsl:apply-templates>
			<xsl:text><![CDATA[ ]]></xsl:text>
		</xsl:if>

		<xsl:if test="not(not(email))">
			<xsl:apply-templates select="email" mode="translate">
				<xsl:with-param name="record" select="id" />
				<xsl:with-param name="column"><![CDATA[EMail]]></xsl:with-param>
				<xsl:with-param name="table" select="$table" />
				<xsl:with-param name="language" select="$language" />
				<xsl:with-param name="translations" select="$translations" />
				<xsl:with-param name="fallback" select="boolean(number($linkfallback))" />
			</xsl:apply-templates>
			<xsl:text><![CDATA[ ]]></xsl:text>
		</xsl:if>

		<xsl:if test="not(not(dokument))">
			<xsl:apply-templates select="dokument" mode="translate">
				<xsl:with-param name="record" select="id" />
				<xsl:with-param name="column"><![CDATA[Dokument]]></xsl:with-param>
				<xsl:with-param name="table" select="$table" />
				<xsl:with-param name="language" select="$language" />
				<xsl:with-param name="translations" select="$translations" />
				<xsl:with-param name="fallback" select="boolean(number($linkfallback))" />
			</xsl:apply-templates>
			<xsl:text><![CDATA[ ]]></xsl:text>
		</xsl:if>

		<xsl:variable name="typeid">
			<xsl:value-of select="art | dokumentenartid | prozessartid" />
		</xsl:variable>

		<xsl:choose>
			<xsl:when test=".. = $areas/rs">
				<xsl:apply-templates select="$areatypes/rs/r[id=$typeid]/art_a" mode="translate">
					<xsl:with-param name="record" select="$typeid" />
					<xsl:with-param name="column"><![CDATA[Art]]></xsl:with-param>
					<xsl:with-param name="table"><![CDATA[BerStammArt]]></xsl:with-param>
					<xsl:with-param name="language" select="$language" />
					<xsl:with-param name="translations" select="$translations" />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test=".. = $information/rs">
				<xsl:apply-templates select="$informationtypes/rs/r[id=$typeid]/art_a" mode="translate">
					<xsl:with-param name="record" select="$typeid" />
					<xsl:with-param name="column"><![CDATA[Art]]></xsl:with-param>
					<xsl:with-param name="table"><![CDATA[DokumentenArt]]></xsl:with-param>
					<xsl:with-param name="language" select="$language" />
					<xsl:with-param name="translations" select="$translations" />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test=".. = $processes/rs">
				<xsl:apply-templates select="$processtypes/rs/r[id=$typeid]/art_a" mode="translate">
					<xsl:with-param name="record" select="$typeid" />
					<xsl:with-param name="column"><![CDATA[Art]]></xsl:with-param>
					<xsl:with-param name="table"><![CDATA[ProzessArt]]></xsl:with-param>
					<xsl:with-param name="language" select="$language" />
					<xsl:with-param name="translations" select="$translations" />
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
		<xsl:text><![CDATA[ ]]></xsl:text>
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
</xsl:stylesheet>