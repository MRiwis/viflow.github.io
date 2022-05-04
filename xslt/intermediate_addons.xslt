<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:vca="http://www.vicon.biz/schemas/ViFlow/2011/AddOn.xsd">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<xsl:template match="/">
		<xsl:element name="addons">
			<xsl:apply-templates select="/settings/AddOns/AddOn" />
			<xsl:apply-templates select="/vca:addon" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="*" />

	<xsl:template match="AddOn">
		<xsl:element name="addon">
			<xsl:attribute name="url">
				<xsl:value-of select="@url" />
			</xsl:attribute>
		</xsl:element>
	</xsl:template>

	<xsl:template match="vca:addon">
		<xsl:if test="not(vca:replacePropertyTab='[None]')">
			<xsl:element name="addon">
				<xsl:attribute name="id">
					<xsl:value-of select="vca:guid" />
				</xsl:attribute>
				<xsl:attribute name="name">
					<xsl:value-of select="vca:name" />
				</xsl:attribute>
				<xsl:attribute name="replace">
					<xsl:variable name="replace" select="vca:replacePropertyTab" />
					<xsl:choose>
						<xsl:when test="$replace='ProcessType' or $replace='InformationCriteria'">
							<xsl:text><![CDATA[tab_criteria]]></xsl:text>
						</xsl:when>
						<xsl:when test="$replace='UserFields'">
							<xsl:text><![CDATA[tab_userfields]]></xsl:text>
						</xsl:when>
						<xsl:when test="$replace='History'">
							<xsl:text><![CDATA[tab_history]]></xsl:text>
						</xsl:when>
						<xsl:when test="$replace='References'">
							<xsl:text><![CDATA[tab_references]]></xsl:text>
						</xsl:when>
						<xsl:when test="$replace='ProcessParticipants'">
							<xsl:text><![CDATA[tab_participants]]></xsl:text>
						</xsl:when>
						<xsl:when test="$replace='ProcessInformation'">
							<xsl:text><![CDATA[tab_information]]></xsl:text>
						</xsl:when>
						<xsl:when test="$replace='ProcessKPI'">
							<xsl:text><![CDATA[tab_kpis]]></xsl:text>
						</xsl:when>
						<xsl:when test="$replace='ProcessBCP'">
							<xsl:text><![CDATA[tab_bcps]]></xsl:text>
						</xsl:when>
						<xsl:when test="$replace='Distribution' or $replace='InformationDistribution'">
							<xsl:text><![CDATA[tab_distribution]]></xsl:text>
						</xsl:when>
						<xsl:when test="$replace='InformationManagement'">
							<xsl:text><![CDATA[tab_management]]></xsl:text>
						</xsl:when>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="cmd">
					<xsl:value-of select="vca:command" />
				</xsl:attribute>
			</xsl:element>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>