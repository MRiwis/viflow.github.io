<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<!-- example history ids: 1, 1075, 1129, 1127, 1125, 1123, ... -->

	<xsl:param name="language"><![CDATA[A]]></xsl:param>
	<xsl:param name="displaytext"><![CDATA[0]]></xsl:param>
	<xsl:param name="linkfallback"><![CDATA[0]]></xsl:param>
	<xsl:param name="filter"><![CDATA[0]]></xsl:param>
	<xsl:param name="page"><![CDATA[0]]></xsl:param>
	<xsl:param name="maxentries"><![CDATA[25]]></xsl:param>
	<xsl:param name="renferencedareasonly"><![CDATA[0]]></xsl:param>
	<xsl:param name="renferencedinfosonly"><![CDATA[0]]></xsl:param>
	<xsl:param name="exclusionlist"><![CDATA[]]></xsl:param>

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
	<xsl:variable name="processes_range" select="$processes/rs/r[number(erstelldatum) >= number($filter)]" />
	<xsl:variable name="processtypes" select="document('../data/prozessart.xml')" />
	<xsl:variable name="history" select="document('../data/historie.xml')" />
	<xsl:variable name="history_map_processes" select="document('../data/htprostammhistorie.xml')" />
	<xsl:variable name="history_map_information" select="document('../data/htdatstammhistorie.xml')" />
	<xsl:variable name="history_map_areas" select="document('../data/htberstammhistorie.xml')" />
	<xsl:variable name="history_range" select="$history/rs/r[number(aenderungsdatum) >= number($filter)]" />
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
		<xsl:element name="table">
			<xsl:attribute name="class"><![CDATA[propTable sortable]]></xsl:attribute>
			<xsl:if test="number($page) = 0">
				<xsl:attribute name="perloadentries">
					<xsl:value-of select="$maxentries" />
				</xsl:attribute>
				<xsl:element name="tr">
					<xsl:element name="th">
						<xsl:attribute name="id"><![CDATA[changed]]></xsl:attribute>
						<xsl:attribute name="class"><![CDATA[sorted_asc]]></xsl:attribute>
						<xsl:text><![CDATA[Changed]]></xsl:text>
					</xsl:element>
					<xsl:element name="th">
						<xsl:attribute name="id"><![CDATA[object]]></xsl:attribute>
						<xsl:attribute name="class"><![CDATA[sorted_desc]]></xsl:attribute>
						<xsl:text><![CDATA[Object]]></xsl:text>
					</xsl:element>
					<xsl:element name="th">
						<xsl:attribute name="id"><![CDATA[type]]></xsl:attribute>
						<xsl:text><![CDATA[Type]]></xsl:text>
					</xsl:element>
					<xsl:element name="th">
						<xsl:attribute name="id"><![CDATA[change]]></xsl:attribute>
						<xsl:text><![CDATA[Change]]></xsl:text>
					</xsl:element>
					<xsl:element name="th">
						<xsl:attribute name="id"><![CDATA[version]]></xsl:attribute>
						<xsl:text><![CDATA[Version]]></xsl:text>
					</xsl:element>
					<xsl:element name="th">
						<xsl:attribute name="id"><![CDATA[details]]></xsl:attribute>
						<xsl:text><![CDATA[Details]]></xsl:text>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:apply-templates select="$history_range" mode="history">
				<xsl:sort select="aenderungsdatum|erstelldatum" order="descending" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="history">
		<xsl:variable name="hid" select="id" />
		<xsl:variable name="fid" select="fromid" />
		<xsl:variable name="tid" select="toid" />
		<xsl:if test="position() > (number($page) * number($maxentries)) and position() &lt;= ((number($page) * number($maxentries)) + number($maxentries))">
			<xsl:choose>
				<xsl:when test="not(not(typ)) and not(count($history_map_processes/rs/r[fromid=$hid]) > 0)">
					<xsl:apply-templates select="." mode="history_details" />
				</xsl:when>
				<xsl:when test="not(typ) and count($history_map_processes/rs/r[toid=$hid]) > 0">
					<xsl:variable name="oid" select="$history_map_processes/rs/r[toid=$hid]/fromid" />
					<xsl:apply-templates select="$processes/rs/r[id = $oid]" mode="history_details">
						<xsl:with-param name="history" select="." />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="not(typ) and count($history_map_information/rs/r[toid=$hid]) > 0">
					<xsl:variable name="oid" select="$history_map_information/rs/r[toid=$hid]/fromid" />
					<xsl:apply-templates select="$information/rs/r[id = $oid]" mode="history_details">
						<xsl:with-param name="history" select="." />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="not(typ) and count($history_map_areas/rs/r[toid=$hid]) > 0">
					<xsl:variable name="oid" select="$history_map_areas/rs/r[toid=$hid]/fromid" />
					<xsl:apply-templates select="$areas/rs/r[id = $oid]" mode="history_details">
						<xsl:with-param name="history" select="." />
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="r" mode="history_details">
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
		<xsl:if test="string-length($excluded) = 0">
			<xsl:element name="tr">
				<xsl:attribute name="id">
					<xsl:value-of select="id" />
				</xsl:attribute>
				<xsl:element name="td">
					<xsl:attribute name="class"><![CDATA[timestamp]]></xsl:attribute>
					<xsl:choose>
						<xsl:when test="not(not($history))">
							<xsl:value-of select="$history/aenderungsdatum" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="erstelldatum" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:element name="td">
					<xsl:variable name="table">
						<xsl:choose>
							<xsl:when test=".. = $areas/rs">
								<xsl:text><![CDATA[SBerStamm]]></xsl:text>
							</xsl:when>
							<xsl:when test=".. = $information/rs">
								<xsl:text><![CDATA[SDatStamm]]></xsl:text>
							</xsl:when>
							<xsl:when test=".. = $processes/rs">
								<xsl:text><![CDATA[SProStamm]]></xsl:text>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="type">
						<xsl:choose>
							<xsl:when test=".. = $areas/rs">
								<xsl:text><![CDATA[A]]></xsl:text>
							</xsl:when>
							<xsl:when test=".. = $information/rs">
								<xsl:text><![CDATA[I]]></xsl:text>
							</xsl:when>
							<xsl:when test=".. = $processes/rs">
								<xsl:text><![CDATA[P]]></xsl:text>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="image">
						<xsl:choose>
							<xsl:when test=".. = $processes/rs and typ='V' and string-length(blob) > 0">
								<xsl:text><![CDATA[./images/ui/decisions.png]]></xsl:text>
							</xsl:when>
							<xsl:when test=".. = $processes/rs and typ='V' and not(string-length(blob) > 0)">
								<xsl:text><![CDATA[./images/ui/decision.png]]></xsl:text>
							</xsl:when>
							<xsl:when test=".. = $processes/rs and typ='P' and string-length(blob) > 0">
								<xsl:text><![CDATA[./images/ui/processes.png]]></xsl:text>
							</xsl:when>
							<xsl:when test=".. = $processes/rs and typ='P' and not(string-length(blob) > 0)">
								<xsl:text><![CDATA[./images/ui/process.png]]></xsl:text>
							</xsl:when>
							<xsl:when test=".. = $information/rs and string-length(dokument) > 0">
								<xsl:text><![CDATA[./images/ui/information_link.png]]></xsl:text>
							</xsl:when>
							<xsl:when test=".. = $information/rs and not(string-length(dokument) > 0)">
								<xsl:text><![CDATA[./images/ui/information.png]]></xsl:text>
							</xsl:when>
							<xsl:when test=".. = $areas/rs">
								<xsl:text><![CDATA[./images/ui/area.png]]></xsl:text>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="value">
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
					<xsl:element name="a">
						<xsl:attribute name="href">
							<xsl:value-of select="$type" />
							<xsl:text><![CDATA[-]]></xsl:text>
							<xsl:value-of select="id" />
						</xsl:attribute>
						<xsl:attribute name="onclick">
							<xsl:text><![CDATA[WebModel.UI.ChangesWindow.OnChangeClick(window.event || event); return false;]]></xsl:text>
						</xsl:attribute>
						<xsl:element name="img">
							<xsl:attribute name="src">
								<xsl:value-of select="$image" />
							</xsl:attribute>
						</xsl:element>
					</xsl:element>
					<xsl:element name="a">
						<xsl:attribute name="href">
							<xsl:value-of select="$type" />
							<xsl:text><![CDATA[-]]></xsl:text>
							<xsl:value-of select="id" />
						</xsl:attribute>
						<xsl:attribute name="class">
							<xsl:text><![CDATA[underline]]></xsl:text>
						</xsl:attribute>
						<xsl:attribute name="onclick">
							<xsl:text><![CDATA[WebModel.UI.ChangesWindow.OnChangeClick(window.event || event); return false;]]></xsl:text>
						</xsl:attribute>
						<xsl:value-of select="$value" />
					</xsl:element>
				</xsl:element>
				<xsl:element name="td">
					<xsl:variable name="value">
						<xsl:choose>
							<xsl:when test=".. = $areas/rs">
								<xsl:text><![CDATA[Area]]></xsl:text>
							</xsl:when>
							<xsl:when test=".. = $information/rs">
								<xsl:text><![CDATA[Information]]></xsl:text>
							</xsl:when>
							<xsl:when test=".. = $processes/rs">
								<xsl:text><![CDATA[Process]]></xsl:text>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:attribute name="id">
						<xsl:call-template name="toLowerCase">
							<xsl:with-param name="string" select="$value" />
						</xsl:call-template>
						<xsl:text><![CDATA[.]]></xsl:text>
						<xsl:value-of select="position()" />
					</xsl:attribute>
					<xsl:value-of select="$value" />
				</xsl:element>
				<xsl:element name="td">
					<xsl:if test="not(not($history))">
						<xsl:variable name="value">
							<xsl:apply-templates select="$history/aenderung" mode="translate">
								<xsl:with-param name="fallback" />
								<xsl:with-param name="record" select="$history/id" />
								<xsl:with-param name="column"><![CDATA[Aenderung]]></xsl:with-param>
								<xsl:with-param name="table"><![CDATA[Historie]]></xsl:with-param>
								<xsl:with-param name="language" select="$language" />
								<xsl:with-param name="translations" select="$translations" />
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:value-of select="$value" />
					</xsl:if>
				</xsl:element>
				<xsl:element name="td">
					<xsl:if test="not(not($history))">
						<xsl:value-of select="$history/version" />
					</xsl:if>
				</xsl:element>
				<xsl:element name="td">
					<xsl:if test="not(not($history))">
						<xsl:variable name="value">
							<xsl:apply-templates select="$history/details" mode="translate">
								<xsl:with-param name="fallback" />
								<xsl:with-param name="record" select="$history/id" />
								<xsl:with-param name="column"><![CDATA[Details]]></xsl:with-param>
								<xsl:with-param name="table"><![CDATA[Historie]]></xsl:with-param>
								<xsl:with-param name="language" select="$language" />
								<xsl:with-param name="translations" select="$translations" />
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:value-of select="$value" />
					</xsl:if>
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
</xsl:stylesheet>