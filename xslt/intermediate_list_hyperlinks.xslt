<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<xsl:param name="filter"><![CDATA[{7C8BA66A-3F18-4C92-BFCC-AEEC705245C0}]]></xsl:param>
	<xsl:param name="language"><![CDATA[A]]></xsl:param>
	<xsl:param name="explicit"><![CDATA[]]></xsl:param>
	<xsl:param name="forcedetails"><![CDATA[0]]></xsl:param>
	<xsl:param name="exclusionlist"><![CDATA[]]></xsl:param>
	<xsl:param name="linkfallback"><![CDATA[0]]></xsl:param>
	<xsl:param name="displaytext"><![CDATA[0]]></xsl:param>

	<xsl:variable name="process_structure" select="document('../data/sproverw.xml')" />
	<xsl:variable name="process_info" select="document('../data/sprostamm.xml')" />
	<xsl:variable name="information_structure" select="document('../data/sdatverw.xml')" />
	<xsl:variable name="information_info" select="document('../data/sdatstamm.xml')" />
	<xsl:variable name="information_docs" select="$information_info/rs/r[string-length(dokument)>0 or contains($information_doc_translations, id)]" />
	<xsl:variable name="area_structure" select="document('../data/sberverw.xml')" />
	<xsl:variable name="area_info" select="document('../data/sberstamm.xml')" />
	<xsl:variable name="process_information_global" select="document('../data/htprostammdatstamm.xml')" />
	<xsl:variable name="process_information_local" select="document('../data/htproverwdatstamm.xml')" />
	<xsl:variable name="distribution" select="document('../data/htdatstammberstamm.xml')" />
	<xsl:variable name="connections" select="document('../data/additionalconnections.xml')" />
	<xsl:variable name="translations_doc" select="document('../data/translations.xml')" />
	<xsl:variable name="translations" select="$translations_doc/rs/r[language=$language and (table='SProStamm' or table='SDatStamm' or table='SBerStamm') and (column='Beschreibung' or column='Bezeichnung' or column='Dokument')]" />
	<xsl:variable name="information_doc_translations">
		<xsl:text><![CDATA[;]]></xsl:text>
		<xsl:apply-templates select="$translations_doc/rs/r[column='Dokument' and table='SDatStamm' and string-length(value) > 0]" mode="getLinkIDs" />
	</xsl:variable>
	<xsl:variable name="translate" select="boolean(not($language='A'))" />
	<xsl:variable name="exclusions" select="document('../data/exclusions.xml')" />
	<xsl:variable name="exclusions_complete">
		<xsl:choose>
			<xsl:when test="string-length($exclusionlist) > 0">
				<xsl:value-of select="$exclusionlist" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$exclusions/exclusions/id" mode="getExclusions">
					<xsl:with-param name="structure" select="$process_structure" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:include href="../xslt/intermediate_helper.xslt" />

	<xsl:template match="/">
		<xsl:element name="list">
			<xsl:attribute name="id">
				<xsl:text><![CDATA[hyperlinks]]></xsl:text>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="$explicit='P'">
					<xsl:apply-templates select="$process_info/rs/r[id=$filter]" mode="process">
						<xsl:with-param name="id" select="$filter" />
						<xsl:with-param name="uuid" select="$filter" />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="$explicit='I'">
					<xsl:apply-templates select="$information_info/rs/r[id=$filter]" mode="information">
						<xsl:with-param name="id" select="$filter" />
						<xsl:with-param name="uuid" select="$filter" />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="$explicit='A'">
					<xsl:apply-templates select="$area_info/rs/r[id=$filter]" mode="area">
						<xsl:with-param name="id" select="$filter" />
						<xsl:with-param name="uuid" select="$filter" />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="$process_structure/rs/r[uniqueid=$filter]" mode="process" />
					<xsl:apply-templates select="$information_structure/rs/r[uniqueid=$filter]" mode="information" />
					<xsl:apply-templates select="$area_structure/rs/r[uniqueid=$filter]" mode="area" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="process">
		<xsl:param name="id" select="stammid" />
		<xsl:param name="uuid" select="uniqueid" />
		<xsl:param name="parent" select="dateiid" />
		<xsl:param name="process" select="$process_info/rs/r[id=$id]" />
		<xsl:param name="graphic">
			<xsl:choose>
				<xsl:when test="boolean(number($forcedetails))">
					<xsl:value-of select="0" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="string-length($process/blob)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:variable name="isprocess" select="boolean($process/typ='P')" />
		<xsl:element name="item">
			<xsl:element name="id">
				<xsl:value-of select="$id" />
			</xsl:element>
			<xsl:element name="name">
				<xsl:variable name="value">
					<xsl:if test="$translate">
						<xsl:value-of select="$translations[table='SProStamm' and column='Beschreibung' and record=$id]/value" />
					</xsl:if>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length($value) = 0">
						<xsl:value-of select="$process/beschreibung" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$value" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="shapetext">
				<xsl:variable name="value">
					<xsl:if test="$translate">
						<xsl:value-of select="$translations[table='SProStamm' and column='Bezeichnung' and record=$id]/value" />
					</xsl:if>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length($value) = 0">
						<xsl:value-of select="$process/bezeichnung_a" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$value" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="image">
				<xsl:choose>
					<xsl:when test="not($isprocess) and boolean(number($graphic))">
						<xsl:text><![CDATA[./images/ui/decisions.png]]></xsl:text>
					</xsl:when>
					<xsl:when test="not($isprocess) and not(boolean(number($graphic)))">
						<xsl:text><![CDATA[./images/ui/decision.png]]></xsl:text>
					</xsl:when>
					<xsl:when test="$isprocess and boolean(number($graphic))">
						<xsl:text><![CDATA[./images/ui/processes.png]]></xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text><![CDATA[./images/ui/process.png]]></xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="uri">
				<xsl:value-of select="$uuid" />
			</xsl:element>
		</xsl:element>
		<xsl:variable name="p2i">
			<xsl:text>|</xsl:text>
			<xsl:apply-templates select="$process_information_local/rs/r[uniquefromid=$uuid] | $process_information_global/rs/r[fromid=$id]" mode="p2i" />
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="not(boolean(number($displaytext)))">
				<xsl:apply-templates select="$information_docs[contains($p2i, concat('|', id, '|'))]" mode="document">
					<xsl:sort select="bezeichnung_a" order="ascending" />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$information_docs[contains($p2i, concat('|', id, '|'))]" mode="document">
					<xsl:sort select="beschreibung" order="ascending" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="r" mode="p2i">
		<xsl:value-of select="toid" />
		<xsl:text>|</xsl:text>
	</xsl:template>

	<xsl:template match="r" mode="information">
		<xsl:param name="id" select="stammid" />
		<xsl:param name="uuid" select="uniqueid" />
		<xsl:param name="parent" select="dateiid" />
		<xsl:variable name="information" select="$information_info/rs/r[id=$id]" />
		<xsl:variable name="related_graphics" select="$process_structure/rs/r[stammid=$parent]" />
		<xsl:variable name="related_connectors" select="$information_structure/rs/r[stammid=$id]" />
		<xsl:element name="item">
			<xsl:element name="id">
				<xsl:value-of select="$id" />
			</xsl:element>
			<xsl:element name="name">
				<xsl:variable name="value">
					<xsl:if test="$translate">
						<xsl:value-of select="$translations[table='SDatStamm' and column='Beschreibung' and record=$id]/value" />
					</xsl:if>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length($value) = 0">
						<xsl:value-of select="$information/beschreibung" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$value" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="shapetext">
				<xsl:variable name="value">
					<xsl:if test="$translate">
						<xsl:value-of select="$translations[table='SDatStamm' and column='Bezeichnung' and record=$id]/value" />
					</xsl:if>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length($value) = 0">
						<xsl:value-of select="$information/bezeichnung_a" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$value" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="image">
				<xsl:choose>
					<xsl:when test="string-length($information/dokument)>0">
						<xsl:text><![CDATA[./images/ui/information_link.png]]></xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text><![CDATA[./images/ui/information.png]]></xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="uri">
				<xsl:value-of select="$uuid" />
			</xsl:element>
		</xsl:element>
		<xsl:if test="string-length(toid)=0">
			<xsl:apply-templates select="$related_connectors[string-length(fromid)=0 and string-length(toid)>0 and not(uniqueid=$uuid) and not(dateiid=$parent)]" mode="inputoutput">
				<xsl:with-param name="site" select="$parent" />
				<xsl:with-param name="related_graphics" select="$related_graphics" />
				<xsl:with-param name="related_connectors" select="$related_connectors" />
			</xsl:apply-templates>
		</xsl:if>
		<xsl:if test="string-length(fromid)=0">
			<xsl:apply-templates select="$related_connectors[string-length(fromid)>0 and string-length(toid)=0 and not(uniqueid=$uuid) and not(dateiid=$parent)]" mode="inputoutput">
				<xsl:with-param name="site" select="$parent" />
				<xsl:with-param name="related_graphics" select="$related_graphics" />
				<xsl:with-param name="related_connectors" select="$related_connectors" />
			</xsl:apply-templates>
		</xsl:if>
		<xsl:variable name="fromid" select="fromid" />
		<xsl:variable name="toid" select="toid" />
		<xsl:apply-templates select="$connections/rs/r[fromid=$fromid] | $connections/rs/r[toid=$toid]" mode="connections">
			<xsl:with-param name="input" select="string-length($toid)>0" />
			<xsl:with-param name="connectorid" select="stammid" />
		</xsl:apply-templates>
		<xsl:apply-templates select="$information[string-length(dokument)>0]" mode="document">
			<xsl:sort select="bezeichnung_a" order="ascending" />
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="r" mode="area">
		<xsl:param name="id" select="stammid" />
		<xsl:param name="uuid" select="uniqueid" />
		<xsl:param name="parent" select="dateiid" />
		<xsl:variable name="area" select="$area_info/rs/r[id=$id]" />
		<xsl:element name="item">
			<xsl:element name="id">
				<xsl:value-of select="$id" />
			</xsl:element>
			<xsl:element name="name">
				<xsl:variable name="value">
					<xsl:if test="$translate">
						<xsl:value-of select="$translations[table='SBerStamm' and column='Beschreibung' and record=$id]/value" />
					</xsl:if>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length($value) = 0">
						<xsl:value-of select="$area/beschreibung" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$value" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="shapetext">
				<xsl:variable name="value">
					<xsl:if test="$translate">
						<xsl:value-of select="$translations[table='SBerStamm' and column='Bezeichnung' and record=$id]/value" />
					</xsl:if>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="string-length($value) = 0">
						<xsl:value-of select="$area/bezeichnung_a" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$value" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="image">
				<xsl:text><![CDATA[./images/ui/area.png]]></xsl:text>
			</xsl:element>
			<xsl:element name="uri">
				<xsl:value-of select="$uuid" />
			</xsl:element>
		</xsl:element>
		<xsl:apply-templates select="$distribution/rs/r[toid=$id]" mode="distribution" />
	</xsl:template>

	<xsl:template match="r" mode="document">
		<xsl:variable name="id" select="id" />
		<xsl:variable name="document">
			<xsl:apply-templates select="dokument" mode="translate">
				<xsl:with-param name="fallback" select="boolean(number($linkfallback))" />
				<xsl:with-param name="record" select="$id" />
				<xsl:with-param name="column"><![CDATA[Dokument]]></xsl:with-param>
				<xsl:with-param name="table"><![CDATA[SDatStamm]]></xsl:with-param>
				<xsl:with-param name="language" select="$language" />
				<xsl:with-param name="translations" select="$translations" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:if test="string-length($document) > 0">
			<xsl:element name="item">
				<xsl:element name="id">
					<xsl:value-of select="$id" />
				</xsl:element>
				<xsl:element name="name">
					<xsl:variable name="value">
						<xsl:if test="$translate">
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
						<xsl:if test="$translate">
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
					<xsl:text><![CDATA[./images/filetypes/]]></xsl:text>
					<xsl:call-template name="substring-after-last">
						<xsl:with-param name="string" select="$document" />
						<xsl:with-param name="search" select="'.'" />
					</xsl:call-template>
					<xsl:text><![CDATA[.gif]]></xsl:text>
				</xsl:element>
				<xsl:element name="altimage">
					<xsl:text><![CDATA[./images/filetypes/link.gif]]></xsl:text>
				</xsl:element>
				<xsl:element name="uri">
					<xsl:value-of select="$document" />
				</xsl:element>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="r" mode="distribution">
		<xsl:variable name="id" select="fromid" />
		<xsl:apply-templates select="$information_info/rs/r[id=$id and string-length(dokument)>0]" mode="document">
			<xsl:sort select="bezeichnung_a" order="ascending" />
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="r" mode="inputoutput">
		<xsl:param name="related_graphics" />
		<xsl:param name="related_connectors" />
		<!-- stammid of connection site I -->
		<xsl:param name="site" />
		<xsl:param name="connectorid" />
		<xsl:variable name="uuid" select="toid|fromid" />
		<xsl:variable name="id" select="$process_structure/rs/r[uniqueid=$uuid]/stammid" />
		<!-- stammid of connection site II -->
		<xsl:variable name="parent" select="$process_structure/rs/r[uniqueid=$uuid]/dateiid" />
		<xsl:variable name="validconnection">
			<xsl:choose>
				<xsl:when test="boolean(number($site))">
					<xsl:variable name="validator_pig">
						<xsl:apply-templates select="$related_connectors" mode="processinteractionvalidation">
							<xsl:with-param name="fromid">
								<xsl:choose>
									<xsl:when test="string-length(toid)>0">
										<xsl:value-of select="$site" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$parent" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
							<xsl:with-param name="toid">
								<xsl:choose>
									<xsl:when test="string-length(toid)>0">
										<xsl:value-of select="$parent" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$site" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:variable name="validator_con">
						<xsl:if test="boolean(number($validator_pig))">
							<xsl:variable name="toid">
								<xsl:choose>
									<xsl:when test="string-length(toid)>0">
										<xsl:value-of select="toid" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$related_connectors[uniqueid=$filter]/toid" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="fromid">
								<xsl:choose>
									<xsl:when test="string-length(fromid)>0">
										<xsl:value-of select="fromid" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$related_connectors[uniqueid=$filter]/fromid" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="count($connections/rs/r[fromid=$fromid and toid=$toid]) > 0">
									<xsl:value-of select="0" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="1" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="boolean(number($validator_pig)) and boolean(number($validator_con))">
							<xsl:value-of select="1" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="0" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="stammid=$connectorid">
					<xsl:value-of select="1" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="0" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="direction">
			<xsl:choose>
				<xsl:when test="string-length(toid)>0">
					<xsl:text><![CDATA[→]]></xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text><![CDATA[←]]></xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="shapeuuid">
			<xsl:choose>
				<xsl:when test="string-length(toid)>0">
					<xsl:value-of select="toid" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="fromid" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="process" select="$process_info/rs/r[id=$id]" />
		<xsl:if test="not(contains($exclusions_complete, concat('|', $id, '|'))) and boolean(number($validconnection)) and string-length($id) > 0">
			<xsl:element name="item">
				<xsl:element name="id">
					<xsl:value-of select="$id" />
				</xsl:element>
				<xsl:element name="name">
					<xsl:value-of select="$direction" />
					<xsl:text><![CDATA[ ]]></xsl:text>
					<xsl:variable name="value">
						<xsl:if test="$translate">
							<xsl:value-of select="$translations[table='SProStamm' and column='Beschreibung' and record=$id]/value" />
						</xsl:if>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="string-length($value) = 0">
							<xsl:value-of select="$process/beschreibung" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$value" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text><![CDATA[ (]]></xsl:text>
					<xsl:variable name="value_g">
						<xsl:if test="$translate">
							<xsl:value-of select="$translations[table='SProStamm' and column='Beschreibung' and record=$parent]/value" />
						</xsl:if>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="string-length($value_g) = 0">
							<xsl:value-of select="$process_info/rs/r[id=$parent]/beschreibung" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$value_g" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text><![CDATA[)]]></xsl:text>
				</xsl:element>
				<xsl:element name="shapetext">
					<xsl:value-of select="$direction" />
					<xsl:text><![CDATA[ ]]></xsl:text>
					<xsl:variable name="value">
						<xsl:if test="$translate">
							<xsl:value-of select="$translations[table='SProStamm' and column='Bezeichnung' and record=$id]/value" />
						</xsl:if>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="string-length($value) = 0">
							<xsl:value-of select="$process/bezeichnung_a" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$value" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text><![CDATA[ (]]></xsl:text>
					<xsl:variable name="value_g">
						<xsl:if test="$translate">
							<xsl:value-of select="$translations[table='SProStamm' and column='Bezeichnung' and record=$parent]/value" />
						</xsl:if>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="string-length($value_g) = 0">
							<xsl:value-of select="$process_info/rs/r[id=$parent]/bezeichnung_a" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$value_g" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text><![CDATA[)]]></xsl:text>
				</xsl:element>
				<xsl:element name="image">
					<xsl:choose>
						<xsl:when test="$process/typ='V'">
							<xsl:text><![CDATA[./images/ui/decisions.png]]></xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text><![CDATA[./images/ui/processes.png]]></xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:element name="uri">
					<xsl:value-of select="$parent" />
				</xsl:element>
				<xsl:element name="shapeuuid">
					<xsl:value-of select="$shapeuuid" />
				</xsl:element>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="r" mode="connections">
		<xsl:param name="input" />
		<xsl:param name="connectorid" />
		<xsl:variable name="fromid" select="fromid" />
		<xsl:variable name="toid" select="toid" />
		<xsl:choose>
			<xsl:when test="$input">
				<xsl:apply-templates select="$information_structure/rs/r[fromid=$fromid and string-length(toid)=0]" mode="inputoutput">
					<xsl:with-param name="connectorid" select="$connectorid" />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$information_structure/rs/r[toid=$toid and string-length(fromid)=0]" mode="inputoutput">
					<xsl:with-param name="connectorid" select="$connectorid" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="r" mode="processinteractionvalidation">
		<xsl:param name="fromid" />
		<xsl:param name="toid" />
		<xsl:variable name="fromuuid">
			<xsl:value-of select="fromid" />
		</xsl:variable>
		<xsl:variable name="touuid">
			<xsl:value-of select="toid" />
		</xsl:variable>
		<xsl:variable name="flag">
			<xsl:if test="count($connections/rs/r[fromid=$fromuuid and toid=$touuid])=0">
				<xsl:if test="number($process_structure/rs/r[uniqueid=$fromuuid]/stammid)=number($fromid)">
					<xsl:if test="number($process_structure/rs/r[uniqueid=$touuid]/stammid)=number($toid)">
						<xsl:value-of select="number(1)" />
					</xsl:if>
				</xsl:if>
			</xsl:if>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="boolean(number($flag))">
				<xsl:text><![CDATA[1]]></xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text><![CDATA[0]]></xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="r" mode="getLinkIDs">
		<xsl:value-of select="record" />
		<xsl:text><![CDATA[;]]></xsl:text>
	</xsl:template>
</xsl:stylesheet>