<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">
	<xsl:output method="xml" encoding="utf-8" indent="no" />

	<!-- http://www.google.de/intl/de/help/basics.html for search basics -->

	<xsl:param name="displaytext"><![CDATA[1]]></xsl:param>
	<xsl:param name="linkfallback"><![CDATA[0]]></xsl:param>
	<xsl:param name="query"><![CDATA[]]></xsl:param>
	<xsl:param name="filter"><![CDATA[]]></xsl:param>
	<xsl:param name="renferencedareasonly"><![CDATA[0]]></xsl:param>
	<xsl:param name="renferencedinfosonly"><![CDATA[0]]></xsl:param>

	<xsl:variable name="areas" select="document('../data/sberstamm.xml')" />
	<xsl:variable name="information" select="document('../data/sdatstamm.xml')" />
	<xsl:variable name="processes" select="document('../data/sprostamm.xml')" />

	<xsl:include href="../xslt/intermediate_helper.xslt" />

	<xsl:variable name="crawlquery">
		<xsl:call-template name="toLowerCase">
			<xsl:with-param name="string" select="string($query)" />
		</xsl:call-template>
	</xsl:variable>

	<xsl:template name="crawl">
		<xsl:param name="source" />
		<xsl:param name="terms" />
		<xsl:param name="weight" select="0" />
		<xsl:choose>
			<xsl:when test="string-length($terms) = 0">
				<xsl:value-of select="$weight" />
			</xsl:when>
			<xsl:when test="starts-with($terms, ' ')">
				<xsl:call-template name="crawl">
					<xsl:with-param name="source" select="$source" />
					<xsl:with-param name="terms" select="substring-after($terms, ' ')" />
				</xsl:call-template>
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
				<xsl:choose>
					<xsl:when test="contains($source, $term) and string-length($term) > 0">
						<xsl:call-template name="crawl">
							<xsl:with-param name="source" select="$source" />
							<xsl:with-param name="terms" select="string($new_terms)" />
							<xsl:with-param name="weight">
								<xsl:variable name="count">
									<xsl:call-template name="crawl_count">
										<xsl:with-param name="source" select="$source" />
										<xsl:with-param name="term" select="string($term)" />
									</xsl:call-template>
								</xsl:variable>
								<xsl:value-of select="number($count) + number($weight)" />
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="crawl_count">
		<xsl:param name="source" />
		<xsl:param name="term" />
		<xsl:param name="count" select="0" />
		<xsl:choose>
			<xsl:when test="string-length($source) > 0 and contains($source, $term)">
				<xsl:variable name="relevance">
					<xsl:choose>
						<!-- word equal to term -->
						<xsl:when test="contains($source, concat(' ', $term, ' '))">
							<xsl:text><![CDATA[4]]></xsl:text>
						</xsl:when>

						<!-- word starts with term -->
						<xsl:when test="contains($source, concat(' ', $term))">
							<xsl:text><![CDATA[3]]></xsl:text>
						</xsl:when>

						<!-- word ends with term -->
						<xsl:when test="contains($source, concat($term, ' '))">
							<xsl:text><![CDATA[2]]></xsl:text>
						</xsl:when>

						<!-- word contains term -->
						<xsl:otherwise>
							<xsl:text><![CDATA[1]]></xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:call-template name="crawl_count">
					<xsl:with-param name="source" select="substring-after($source, $term)" />
					<xsl:with-param name="term" select="$term" />
					<xsl:with-param name="count" select="number($count) + number($relevance)" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$count" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="/">
		<xsl:element name="table">
			<xsl:attribute name="class"><![CDATA[propTable sortable]]></xsl:attribute>
			<xsl:element name="tr">
				<xsl:element name="th">
					<xsl:attribute name="id"><![CDATA[weight]]></xsl:attribute>
					<xsl:attribute name="class"><![CDATA[sorted_asc]]></xsl:attribute>
					<xsl:text><![CDATA[Weighting]]></xsl:text>
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
			</xsl:element>

			<xsl:apply-templates select="/i/o" mode="search" />
		</xsl:element>
	</xsl:template>

	<xsl:template match="o" mode="search">
		<xsl:variable name="text">
			<xsl:call-template name="toLowerCase">
				<xsl:with-param name="string" select="string(text())" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="matches">
			<xsl:call-template name="crawl">
				<xsl:with-param name="terms" select="string($crawlquery)" />
				<xsl:with-param name="source" select="string($text)" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:if test="number($matches) > 0">
			<xsl:element name="tr">
				<xsl:attribute name="id">
					<xsl:value-of select="@i" />
				</xsl:attribute>
				<xsl:attribute name="filter">
					<xsl:value-of select="@t" />
				</xsl:attribute>
				<xsl:element name="td">
					<xsl:value-of select="format-number($matches, '0000000000')" />
				</xsl:element>
				<xsl:element name="td">
					<xsl:variable name="table">
						<xsl:choose>
							<xsl:when test="@t = 'a'">
								<xsl:text><![CDATA[SBerStamm]]></xsl:text>
							</xsl:when>
							<xsl:when test="@t = 'i'">
								<xsl:text><![CDATA[SDatStamm]]></xsl:text>
							</xsl:when>
							<xsl:when test="@t = 'p'">
								<xsl:text><![CDATA[SProStamm]]></xsl:text>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="type">
						<xsl:value-of select="translate(@t, 'aip', 'AIP') "/>
					</xsl:variable>
					<xsl:variable name="image">
						<xsl:variable name="id" select="@i" />
						<xsl:choose>
							<xsl:when test="@t = 'p'">
								<xsl:variable name="o" select="$processes/rs/r[id = $id]" />
								<xsl:choose>
									<xsl:when test="$o/typ='V' and not(string-length($o/blob) > 0)">
										<xsl:text><![CDATA[./images/ui/decision.png]]></xsl:text>
									</xsl:when>
									<xsl:when test="$o/typ='V' and string-length($o/blob) > 0">
										<xsl:text><![CDATA[./images/ui/decisions.png]]></xsl:text>
									</xsl:when>
									<xsl:when test="$o/typ='P' and not(string-length($o/blob) > 0)">
										<xsl:text><![CDATA[./images/ui/process.png]]></xsl:text>
									</xsl:when>
									<xsl:when test="$o/typ='P' and string-length($o/blob) > 0">
										<xsl:text><![CDATA[./images/ui/processes.png]]></xsl:text>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="@t = 'i'">
								<xsl:variable name="o" select="$information/rs/r[id = $id]" />
								<xsl:choose>
									<xsl:when test="string-length($o/dokument) > 0">
										<xsl:text><![CDATA[./images/ui/information_link.png]]></xsl:text>
									</xsl:when>
									<xsl:when test="not(string-length($o/dokument) > 0)">
										<xsl:text><![CDATA[./images/ui/information.png]]></xsl:text>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="@t = 'a'">
								<xsl:text><![CDATA[./images/ui/area.png]]></xsl:text>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:element name="a">
						<xsl:attribute name="href">
							<xsl:value-of select="$type" />
							<xsl:text><![CDATA[-]]></xsl:text>
							<xsl:value-of select="@i" />
						</xsl:attribute>
						<xsl:attribute name="onmouseup">
							<xsl:text><![CDATA[WebModel.Search.OnResultNavigate(window.event || event)]]></xsl:text>
						</xsl:attribute>
						<xsl:attribute name="ontouchend">
							<xsl:text><![CDATA[WebModel.Search.OnResultNavigate(window.event || event)]]></xsl:text>
						</xsl:attribute>
						<xsl:attribute name="onclick">
							<xsl:text><![CDATA[WebModel.Common.Helper.cancelEvent(window.event || event)]]></xsl:text>
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
							<xsl:value-of select="@i" />
						</xsl:attribute>
						<xsl:attribute name="class">
							<xsl:text><![CDATA[underline]]></xsl:text>
						</xsl:attribute>
						<xsl:attribute name="onmouseup">
							<xsl:text><![CDATA[WebModel.Search.OnResultNavigate(window.event || event)]]></xsl:text>
						</xsl:attribute>
						<xsl:attribute name="ontouchend">
							<xsl:text><![CDATA[WebModel.Search.OnResultNavigate(window.event || event)]]></xsl:text>
						</xsl:attribute>
						<xsl:attribute name="onclick">
							<xsl:text><![CDATA[WebModel.Common.Helper.cancelEvent(window.event || event)]]></xsl:text>
						</xsl:attribute>
						<xsl:value-of select="@c" />
					</xsl:element>
				</xsl:element>
				<xsl:element name="td">
					<xsl:variable name="value">
						<xsl:choose>
							<xsl:when test="@t = 'a'">
								<xsl:text><![CDATA[Area]]></xsl:text>
							</xsl:when>
							<xsl:when test="@t = 'i'">
								<xsl:text><![CDATA[Information]]></xsl:text>
							</xsl:when>
							<xsl:when test="@t = 'p'">
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
			</xsl:element>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>