<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<xsl:param name="language"><![CDATA[A]]></xsl:param>
	<xsl:param name="renferencedonly"><![CDATA[0]]></xsl:param>
	<xsl:param name="exclusionlist"><![CDATA[]]></xsl:param>

	<xsl:variable name="informationtypes" select="document('../data/dokumentenart.xml')" />
	<xsl:variable name="information" select="document('../data/sdatstamm.xml')" />
	<xsl:variable name="informationtree" select="document('../data/htdatstammdatstamm.xml')" />
	<xsl:variable name="informationuuids" select="document('../data/sdatverw.xml')" />
	<xsl:variable name="areauuids" select="document('../data/sberverw.xml')" />
	<xsl:variable name="participation_refs_global" select="document('../data/htprostammberstamm.xml')" />
	<xsl:variable name="participation_refs_local" select="document('../data/htproverwberstamm.xml')" />
	<xsl:variable name="translations_doc" select="document('../data/translations.xml')" />
	<xsl:variable name="translations" select="$translations_doc/rs/r[language=$language and (table='SDatStamm' or table='DokumentenArt') and (column='Beschreibung' or column='Bezeichnung' or column='Art')]" />
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

	<xsl:include href="../xslt/intermediate_helper.xslt" />
	<xsl:include href="../xslt/intermediate_tree_shared.xslt" />

	<xsl:template match="/">
		<xsl:element name="tree">
			<xsl:attribute name="id">
				<xsl:text><![CDATA[information]]></xsl:text>
			</xsl:attribute>

			<!-- begin: special processing type "other" -->
			<xsl:variable name="isReferenced">
				<xsl:apply-templates select="$information/rs/r[dokumentenartid='']" mode="isReferenced" />
			</xsl:variable>
			<xsl:if test="boolean(number($isReferenced))">
				<xsl:element name="item">
					<xsl:element name="id">
						<xsl:text><![CDATA[0]]></xsl:text>
					</xsl:element>
					<xsl:element name="parents" />
					<xsl:element name="name">
						<xsl:text><![CDATA[ZZZZZZZZZZZZZZZZZZZZZZZZ - Order Last!]]></xsl:text>
					</xsl:element>
					<xsl:element name="shapetext">
						<xsl:text><![CDATA[ZZZZZZZZZZZZZZZZZZZZZZZZ - Order Last!]]></xsl:text>
					</xsl:element>
					<xsl:element name="image">
						<xsl:text><![CDATA[./images/ui/informationtype.png]]></xsl:text>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- end: special processing type "other" -->

			<xsl:apply-templates select="$informationtypes/rs/r" mode="appendNode">
				<xsl:sort select="art_a" order="ascending" />
			</xsl:apply-templates>
			<xsl:apply-templates select="$information/rs/r" mode="appendNode">
				<xsl:sort select="bezeichnung_a" order="ascending" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r[not(not(dokumentenartid))]" mode="appendNode">
		<xsl:variable name="id" select="id" />
		<xsl:variable name="typeid" select="dokumentenartid" />
		<xsl:variable name="isReferenced">
			<xsl:call-template name="isReferenced">
				<xsl:with-param name="information" select="." />
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="boolean(number($isReferenced))">
			<xsl:element name="item">
				<xsl:element name="id">
					<xsl:value-of select="$id" />
				</xsl:element>
				<xsl:element name="parents">
					<xsl:apply-templates select="$informationuuids/rs/r[stammid=$id]" mode="unique" />
					<xsl:element name="parent">
						<xsl:attribute name="id">
							<xsl:choose>
								<xsl:when test="string-length(dokumentenartid) > 0">
									<!-- UInt32.MaxVal: 0xFFFFFFFF -->
									<xsl:text><![CDATA[4294967295]]></xsl:text>
									<xsl:value-of select="dokumentenartid" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:text><![CDATA[0]]></xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</xsl:element>
					<xsl:apply-templates select="$informationtree/rs/r[toid=$id]" mode="appendStructure">
						<xsl:sort select="fromid" order="ascending" />
					</xsl:apply-templates>
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
	</xsl:template>

	<xsl:template match="r[not(not(uniqueid))]" mode="unique">
		<xsl:element name="parent">
			<xsl:attribute name="id">
				<!-- UInt64.MaxVal: 0xFFFFFFFFFFFFFFFF -->
				<xsl:text><![CDATA[18446744073709551615]]></xsl:text>
			</xsl:attribute>
			<xsl:attribute name="uuid">
				<xsl:value-of select="uniqueid" />
			</xsl:attribute>
		</xsl:element>
	</xsl:template>

	<xsl:template match="r[not(dokumentenartid)]" mode="appendNode">
		<xsl:variable name="typeid" select="id" />
		<xsl:variable name="isReferenced">
			<xsl:apply-templates select="$information/rs/r[dokumentenartid=$typeid]" mode="isReferenced" />
		</xsl:variable>
		<xsl:if test="boolean(number($isReferenced))">
			<xsl:apply-templates select="$informationtypes/rs/r[id=$typeid]" mode="appendTypes">
				<xsl:sort select="art_a" order="ascending" />
				<xsl:with-param name="language" select="$language" />
				<xsl:with-param name="translations" select="$translations[table='DokumentenArt']" />
				<xsl:with-param name="image" select="'./images/ui/informationtype.png'" />
			</xsl:apply-templates>
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