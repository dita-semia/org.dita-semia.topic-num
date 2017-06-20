<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl	= "http://www.w3.org/1999/XSL/Transform"
	xmlns:xs	= "http://www.w3.org/2001/XMLSchema" 
	xmlns:ds	= "http://www.dita-semia.org"
	exclude-result-prefixes="#all">
	
	<!-- default template -->
	<xsl:template match="attribute() | node()" mode="CollectCounts">
		<xsl:copy>
			<xsl:apply-templates select="attribute() | node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[contains(@class, $CLASS_TOPICREF)][string(@href) != '']" mode="CollectCounts">
		<xsl:variable name="refUri" as="xs:anyURI" 			select="resolve-uri(@href, base-uri(.))"/>
		<xsl:variable name="refDoc"	as="document-node()?"	select="if (doc-available($refUri)) then doc($refUri) else ()"/>
		<xsl:copy>
			<xsl:attribute name="ds:figCount" 		select="count(key('enumerableByClass', $CS_FIG, 			$refDoc))"/>
			<xsl:attribute name="ds:tableCount" 	select="count(key('enumerableByClass', $CS_TABLE, 			$refDoc))"/>
			<xsl:attribute name="ds:equationCount" 	select="count(key('enumerableByClass', $CS_EQUATION_BLOCK, 	$refDoc))"/>
			<xsl:apply-templates select="attribute() | node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="/*" mode="CollectCounts">
		<xsl:copy>
			<xsl:attribute name="xml:base" select="base-uri(.)"/>
			<xsl:apply-templates select="attribute() | node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
