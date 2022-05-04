<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="utf-8" />

	<xsl:template name="substring-after-last">
		<xsl:param name="string" select="''" />
		<xsl:param name="search" select="''" />
		<xsl:choose>
			<xsl:when test="substring($string, string-length($string), 1) = $search">
				<xsl:call-template name="substring-after-last">
					<xsl:with-param name="string" select="substring($string, 0, string-length($string))" />
					<xsl:with-param name="search" select="$search" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="string-length($string) = 0 or string-length($search) = 0 or not(contains($string, $search))">
				<xsl:value-of select="$string" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="substring-after-last">
					<xsl:with-param name="string" select="substring-after($string, $search)" />
					<xsl:with-param name="search" select="$search" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="substring-before-last">
		<xsl:param name="string" select="''" />
		<xsl:param name="search" select="''" />
		<xsl:param name="origin" select="$string" />
		<xsl:choose>
			<xsl:when test="substring($string, string-length($string), 1) = $search">
				<xsl:call-template name="substring-before-last">
					<xsl:with-param name="string" select="substring($string, 0, string-length($string))" />
					<xsl:with-param name="search" select="$search" />
					<xsl:with-param name="origin" select="$origin" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="string-length($string) = 0 or string-length($search) = 0 or not(contains($string, $search))">
				<xsl:value-of select="substring($origin, 0, string-length($origin) - string-length($string))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="substring-before-last">
					<xsl:with-param name="string" select="substring-after($string, $search)" />
					<xsl:with-param name="search" select="$search" />
					<xsl:with-param name="origin" select="$origin" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="replace">
		<xsl:param name="string" select="''" />
		<xsl:param name="search" select="''" />
		<xsl:param name="replacement" select="''" />
		<xsl:choose>
			<xsl:when test="not(contains($string, $search))">
				<xsl:value-of select="$string" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="replace">
					<xsl:with-param name="string">
						<xsl:value-of select="substring-before($string, $search)" />
						<xsl:value-of select="$replacement" />
						<xsl:value-of select="substring-after($string, $search)" />
					</xsl:with-param>
					<xsl:with-param name="search" select="$search" />
					<xsl:with-param name="replacement" select="$replacement" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="translate">
		<xsl:param name="translations" />
		<xsl:param name="language" />
		<xsl:param name="table" />
		<xsl:param name="record" />
		<xsl:param name="column" />
		<xsl:param name="fallback"><![CDATA[1]]></xsl:param>
		<xsl:variable name="field_value" select="translate($column, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" />
		<xsl:variable name="translated_value">
			<xsl:if test="not($language='A')">
				<xsl:value-of select="$translations[table=$table and column=$column and record=$record and language=$language]/value" />
			</xsl:if>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length($translated_value) = 0 and (boolean($fallback) or $language='A')">
				<xsl:value-of select="." />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$translated_value" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="toLowerCase">
		<xsl:param name="string" />
		<xsl:value-of select="translate($string, 'ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜÉÈÊÀÁÂÒÓÔÙÚÛÇÅÏÕÑŒ', 'abcdefghijklmnopqrstuvwxyzäöüéèêàáâòóôùúûçåïõñœ')"/>
	</xsl:template>

	<xsl:template name="getExclusions" match="r|id" mode="getExclusions">
		<xsl:param name="structure" />
		<xsl:choose>
			<xsl:when test="name(.) = 'id'">
				<xsl:variable name="id" select="." />
				<xsl:value-of select="concat('|', $id, '|')" />
				<xsl:apply-templates select="$structure/rs/r[dateiid=$id]" mode="getExclusions" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="id" select="stammid" />
				<xsl:value-of select="concat('|', $id, '|')" />
				<xsl:apply-templates select="../r[dateiid=$id]" mode="getExclusions" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>