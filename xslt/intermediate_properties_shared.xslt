<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<xsl:variable name="userfields" select="document('../data/userfielddefinitions.xml')" />
	<xsl:variable name="uservalues" select="document('../data/userfieldvalues.xml')" />
	<xsl:variable name="usertypes" select="document('../data/userfieldtypes.xml')" />
	<xsl:variable name="history" select="document('../data/historie.xml')" />
	<xsl:variable name="criteria" select="document('../data/kriterienart.xml')" />

	<xsl:template match="r" mode="userfields">
		<xsl:param name="gid" />
		<xsl:param name="uid" />
		<xsl:param name="language" />
		<xsl:param name="translations" />
		<xsl:param name="usermap"  />
		<xsl:element name="table">
			<xsl:attribute name="class"><![CDATA[propTable sortable hideEmpty]]></xsl:attribute>
			<xsl:element name="tr">
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[userfieldname]]></xsl:attribute>
					<xsl:text><![CDATA[Caption]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[userfieldvalue]]></xsl:attribute>
					<xsl:text><![CDATA[Value]]></xsl:text>
				</xsl:element>
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[userfieldtype]]></xsl:attribute>
					<xsl:text><![CDATA[Type]]></xsl:text>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="$usermap/rs/r[fromid=$gid or fromid=$uid]" mode="userfields_rows">
				<xsl:with-param name="language" select="$language" />
				<xsl:with-param name="translations" select="$translations" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="userfields_rows">
		<xsl:param name="language" />
		<xsl:param name="translations" />
		<xsl:variable name="fieldid" select="toid" />
		<xsl:variable name="defid" select="$uservalues/rs/r[id=$fieldid]/fieldid" />
		<xsl:variable name="typeid" select="$userfields/rs/r[id=$defid]/typeid" />
		<xsl:element name="tr">
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:apply-templates select="$userfields/rs/r[id=$defid]/name_a" mode="translate">
						<xsl:with-param name="fallback" />
						<xsl:with-param name="record" select="$defid" />
						<xsl:with-param name="column"><![CDATA[Name]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[UserFieldDefinitions]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:element>
			<xsl:element name="td">
				<xsl:choose>

					<!-- date value -->
					<xsl:when test="$userfields/rs/r[id=$defid]/datatype=8">
						<xsl:attribute name="class"><![CDATA[timestamp]]></xsl:attribute>
						<xsl:value-of select="$uservalues/rs/r[id=$fieldid]/numericvalue" />
					</xsl:when>

					<!-- numeric value -->
					<xsl:when test="$userfields/rs/r[id=$defid]/datatype=7">
						<xsl:value-of select="$uservalues/rs/r[id=$fieldid]/numericvalue" />
					</xsl:when>

					<!-- multi-line value -->
					<xsl:when test="$userfields/rs/r[id=$defid]/datatype=12">
						<xsl:attribute name="class"><![CDATA[multiline]]></xsl:attribute>
						<xsl:variable name="value">
							<xsl:apply-templates select="$uservalues/rs/r[id=$fieldid]/textvalue" mode="translate">
								<xsl:with-param name="fallback" />
								<xsl:with-param name="record" select="$fieldid" />
								<xsl:with-param name="column"><![CDATA[TextValue]]></xsl:with-param>
								<xsl:with-param name="table"><![CDATA[UserFieldValues]]></xsl:with-param>
								<xsl:with-param name="language" select="$language" />
								<xsl:with-param name="translations" select="$translations" />
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:value-of select="$value" />
					</xsl:when>

					<!-- text value -->
					<xsl:otherwise>
						<xsl:variable name="value">
							<xsl:apply-templates select="$uservalues/rs/r[id=$fieldid]/textvalue" mode="translate">
								<xsl:with-param name="fallback" />
								<xsl:with-param name="record" select="$fieldid" />
								<xsl:with-param name="column"><![CDATA[TextValue]]></xsl:with-param>
								<xsl:with-param name="table"><![CDATA[UserFieldValues]]></xsl:with-param>
								<xsl:with-param name="language" select="$language" />
								<xsl:with-param name="translations" select="$translations" />
							</xsl:apply-templates>
						</xsl:variable>
						<xsl:value-of select="$value" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:apply-templates select="$usertypes/rs/r[id=$typeid]/name_a" mode="translate">
						<xsl:with-param name="fallback" />
						<xsl:with-param name="record" select="$typeid" />
						<xsl:with-param name="column"><![CDATA[Name]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[UserFieldTypes]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="history">
		<xsl:param name="version" select="boolean(false)" />
		<xsl:param name="gid" />
		<xsl:param name="uid" />
		<xsl:param name="language" />
		<xsl:param name="translations" />
		<xsl:param name="history_map" />
		<xsl:param name="areas" />
		<xsl:param name="displaytext" />
		<xsl:element name="table">
			<xsl:attribute name="class"><![CDATA[propTable]]></xsl:attribute>
			<xsl:variable name="modellerid" select="modellerid" />
			<xsl:variable name="verifiedid" select="prueferid" />
			<xsl:variable name="approvalid" select="freigeberid" />
			<xsl:variable name="responsibleid" select="responsibleid" />
			<xsl:if test="string-length($modellerid) > 0">
				<xsl:element name="tr">
					<xsl:element name="th">
						<xsl:attribute name="id"><![CDATA[modelled]]></xsl:attribute>
						<xsl:text><![CDATA[Modelled]]></xsl:text>
					</xsl:element>
					<xsl:variable name="value">
						<xsl:choose>
							<xsl:when test="not(boolean(number($displaytext)))">
								<xsl:apply-templates select="$areas/rs/r[id=$modellerid]/bezeichnung_a" mode="translate">
									<xsl:with-param name="record" select="$modellerid" />
									<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
									<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
									<xsl:with-param name="language" select="$language" />
									<xsl:with-param name="translations" select="$translations" />
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="$areas/rs/r[id=$modellerid]/beschreibung" mode="translate">
									<xsl:with-param name="record" select="$modellerid" />
									<xsl:with-param name="column"><![CDATA[Beschreibung]]></xsl:with-param>
									<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
									<xsl:with-param name="language" select="$language" />
									<xsl:with-param name="translations" select="$translations" />
								</xsl:apply-templates>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:element name="td">
						<xsl:element name="a">
							<xsl:attribute name="href">
								<xsl:text><![CDATA[#]]></xsl:text>
							</xsl:attribute>
							<xsl:attribute name="onclick">
								<xsl:text><![CDATA[WebModel.navigate(']]></xsl:text>
								<xsl:value-of select="$modellerid" />
								<xsl:text><![CDATA[', 'globalAreaTree'); return false;]]></xsl:text>
							</xsl:attribute>
							<xsl:value-of select="$value" />
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length($verifiedid) > 0">
				<xsl:element name="tr">
					<xsl:element name="th">
						<xsl:attribute name="id"><![CDATA[verified]]></xsl:attribute>
						<xsl:text><![CDATA[Verified]]></xsl:text>
					</xsl:element>
					<xsl:variable name="value">
						<xsl:choose>
							<xsl:when test="not(boolean(number($displaytext)))">
								<xsl:apply-templates select="$areas/rs/r[id=$verifiedid]/bezeichnung_a" mode="translate">
									<xsl:with-param name="record" select="$verifiedid" />
									<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
									<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
									<xsl:with-param name="language" select="$language" />
									<xsl:with-param name="translations" select="$translations" />
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="$areas/rs/r[id=$verifiedid]/beschreibung" mode="translate">
									<xsl:with-param name="record" select="$verifiedid" />
									<xsl:with-param name="column"><![CDATA[Beschreibung]]></xsl:with-param>
									<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
									<xsl:with-param name="language" select="$language" />
									<xsl:with-param name="translations" select="$translations" />
								</xsl:apply-templates>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:element name="td">
						<xsl:element name="a">
							<xsl:attribute name="href">
								<xsl:text><![CDATA[#]]></xsl:text>
							</xsl:attribute>
							<xsl:attribute name="onclick">
								<xsl:text><![CDATA[WebModel.navigate(']]></xsl:text>
								<xsl:value-of select="$verifiedid" />
								<xsl:text><![CDATA[', 'globalAreaTree'); return false;]]></xsl:text>
							</xsl:attribute>
							<xsl:value-of select="$value" />
						</xsl:element>
						<xsl:if test="string-length(pruefdatum) > 0">
							<xsl:text><![CDATA[ (]]></xsl:text>
							<xsl:element name="span">
								<xsl:attribute name="class"><![CDATA[timestamp]]></xsl:attribute>
								<xsl:value-of select="pruefdatum" />
							</xsl:element>
							<xsl:text><![CDATA[)]]></xsl:text>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length($approvalid) > 0">
				<xsl:element name="tr">
					<xsl:element name="th">
						<xsl:attribute name="id"><![CDATA[approved]]></xsl:attribute>
						<xsl:text><![CDATA[Approved]]></xsl:text>
					</xsl:element>
					<xsl:element name="td">
						<xsl:variable name="value">
							<xsl:choose>
								<xsl:when test="not(boolean(number($displaytext)))">
									<xsl:apply-templates select="$areas/rs/r[id=$approvalid]/bezeichnung_a" mode="translate">
										<xsl:with-param name="record" select="$approvalid" />
										<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
										<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
										<xsl:with-param name="language" select="$language" />
										<xsl:with-param name="translations" select="$translations" />
									</xsl:apply-templates>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="$areas/rs/r[id=$approvalid]/beschreibung" mode="translate">
										<xsl:with-param name="record" select="$approvalid" />
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
								<xsl:value-of select="$approvalid" />
								<xsl:text><![CDATA[', 'globalAreaTree'); return false;]]></xsl:text>
							</xsl:attribute>
							<xsl:value-of select="$value" />
						</xsl:element>
						<xsl:if test="string-length(freigabedatum) > 0">
							<xsl:text><![CDATA[ (]]></xsl:text>
							<xsl:element name="span">
								<xsl:attribute name="class"><![CDATA[timestamp]]></xsl:attribute>
								<xsl:value-of select="freigabedatum" />
							</xsl:element>
							<xsl:text><![CDATA[)]]></xsl:text>
						</xsl:if>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length($responsibleid) > 0">
				<xsl:element name="tr">
					<xsl:element name="th">
						<xsl:attribute name="id"><![CDATA[responsible]]></xsl:attribute>
						<xsl:text><![CDATA[Responsible]]></xsl:text>
					</xsl:element>
					<xsl:element name="td">
						<xsl:variable name="value">
							<xsl:choose>
								<xsl:when test="not(boolean(number($displaytext)))">
									<xsl:apply-templates select="$areas/rs/r[id=$responsibleid]/bezeichnung_a" mode="translate">
										<xsl:with-param name="record" select="$responsibleid" />
										<xsl:with-param name="column"><![CDATA[Bezeichnung]]></xsl:with-param>
										<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
										<xsl:with-param name="language" select="$language" />
										<xsl:with-param name="translations" select="$translations" />
									</xsl:apply-templates>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="$areas/rs/r[id=$responsibleid]/beschreibung" mode="translate">
										<xsl:with-param name="record" select="$responsibleid" />
										<xsl:with-param name="column"><![CDATA[Beschreibung]]></xsl:with-param>
										<xsl:with-param name="table"><![CDATA[SBerStamm]]></xsl:with-param>
										<xsl:with-param name="language" select="$language" />
										<xsl:with-param name="translations" select="$translations" />
									</xsl:apply-templates>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:value-of select="$value" />
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>
		<xsl:element name="table">
			<xsl:attribute name="class"><![CDATA[propTable sortable]]></xsl:attribute>
			<xsl:element name="tr">
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[changed]]></xsl:attribute>
					<xsl:attribute name="class"><![CDATA[sorted_asc]]></xsl:attribute>
					<xsl:text><![CDATA[Changed]]></xsl:text>
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
			<xsl:apply-templates select="$history_map/rs/r[fromid=$gid]" mode="history_rows">
				<xsl:with-param name="version" select="$version" />
				<xsl:with-param name="language" select="$language" />
				<xsl:with-param name="translations" select="$translations" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="history_rows">
		<xsl:param name="version" select="boolean(false)" />
		<xsl:param name="language" />
		<xsl:param name="translations" />
		<xsl:variable name="fieldid" select="toid" />
		<xsl:element name="tr">
			<xsl:element name="td">
				<xsl:attribute name="class"><![CDATA[timestamp]]></xsl:attribute>
				<xsl:value-of select="$history/rs/r[id=$fieldid]/aenderungsdatum" />
			</xsl:element>
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:apply-templates select="$history/rs/r[id=$fieldid]/aenderung" mode="translate">
						<xsl:with-param name="fallback" />
						<xsl:with-param name="record" select="$fieldid" />
						<xsl:with-param name="column"><![CDATA[Aenderung]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[Historie]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:element>
			<xsl:element name="td">
				<xsl:value-of select="$history/rs/r[id=$fieldid]/version" />
			</xsl:element>
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:apply-templates select="$history/rs/r[id=$fieldid]/details" mode="translate">
						<xsl:with-param name="fallback" />
						<xsl:with-param name="record" select="$fieldid" />
						<xsl:with-param name="column"><![CDATA[Details]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[Historie]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="criteria">
		<xsl:param name="gid" />
		<xsl:param name="uid" />
		<xsl:param name="language" />
		<xsl:param name="translations" />
		<xsl:param name="criteria_map" />
		<xsl:element name="table">
			<xsl:attribute name="class"><![CDATA[propTable sortable]]></xsl:attribute>
			<xsl:element name="tr">
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[criteriaheader]]></xsl:attribute>
					<xsl:attribute name="class"><![CDATA[sorted_desc]]></xsl:attribute>
					<xsl:text><![CDATA[Criteria]]></xsl:text>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="$criteria_map/rs/r[fromid=$gid or fromid=$uid]" mode="criteria_rows">
				<xsl:with-param name="language" select="$language" />
				<xsl:with-param name="translations" select="$translations" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r" mode="criteria_rows">
		<xsl:param name="language" />
		<xsl:param name="translations" />
		<xsl:variable name="fieldid" select="toid" />
		<xsl:element name="tr">
			<xsl:element name="td">
				<xsl:variable name="value">
					<xsl:apply-templates select="$criteria/rs/r[id=$fieldid]/art_a" mode="translate">
						<xsl:with-param name="fallback" />
						<xsl:with-param name="record" select="$fieldid" />
						<xsl:with-param name="column"><![CDATA[Art]]></xsl:with-param>
						<xsl:with-param name="table"><![CDATA[KriterienArt]]></xsl:with-param>
						<xsl:with-param name="language" select="$language" />
						<xsl:with-param name="translations" select="$translations" />
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:value-of select="$value" />
			</xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>