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

	<xsl:template match="*[contains(@class, $CLASS_TOPICREF)][ds:isTopicrefRelevant(.)]" mode="CollectCounts">
		<xsl:variable name="refUri" as="xs:anyURI?"			select="if (@href) then resolve-uri(@href, base-uri(.)) else ()"/>
		<xsl:variable name="refDoc"	as="document-node()?"	select="if (doc-available($refUri)) then doc($refUri) else ()"/>
		<xsl:copy>
			<xsl:if test="exists($refDoc)">
				<!-- Count the elements that need to be numbered cross-topic and add it as attributes to the topicref element. -->
				<xsl:attribute name="ds:figCount" 		select="count(key('enumerableByClass', $CS_FIG, 			$refDoc))"/>
				<xsl:attribute name="ds:tableCount" 	select="count(key('enumerableByClass', $CS_TABLE, 			$refDoc))"/>
				<xsl:attribute name="ds:equationCount" 	select="count(key('enumerableByClass', $CS_EQUATION_BLOCK, 	$refDoc))"/>
			</xsl:if>
			<xsl:apply-templates select="attribute() | node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="/*" mode="CollectCounts">
		<xsl:copy>
			<!-- add xml:base attribute so that base-uri() on the resulting resolved map returns the orginal url -->
			<xsl:attribute name="xml:base" select="base-uri(.)"/>
			<xsl:apply-templates select="attribute() | node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
