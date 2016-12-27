<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl	= "http://www.w3.org/1999/XSL/Transform"
	xmlns:xs	= "http://www.w3.org/2001/XMLSchema" 
	xmlns:ds	= "http://www.dita-semia.org"
	exclude-result-prefixes="#all">

	<xsl:param name="numDelimiter" 			as="xs:string" select="' '"/>
	<xsl:param name="tmpUriSuffix" 			as="xs:string" select="'.tmp'"/>
	<xsl:param name="chapterPrefixFormat" 	as="xs:string" select="'Chapter $:'"/>
	<xsl:param name="appendixPrefixFormat" 	as="xs:string" select="'Appendix $:'"/>


	<xsl:variable name="CLASS_TOPIC"		as="xs:string"	select="' topic/topic '"/>
	<xsl:variable name="CLASS_LINK"			as="xs:string"	select="' topic/link '"/>
	<xsl:variable name="CLASS_FIG"			as="xs:string"	select="' topic/fig '"/>
	<xsl:variable name="CLASS_TABLE"		as="xs:string"	select="' topic/table '"/>
	<xsl:variable name="CLASS_TITLE"		as="xs:string"	select="' topic/title '"/>
	
	<xsl:variable name="CLASS_TOPICREF"		as="xs:string"	select="' map/topicref '"/>
	
	<xsl:variable name="CLASS_FRONTMATTER"	as="xs:string"	select="' bookmap/frontmatter '"/>
	<xsl:variable name="CLASS_CHAPTER"		as="xs:string"	select="' bookmap/chapter '"/>
	<xsl:variable name="CLASS_APPENDIX"		as="xs:string"	select="' bookmap/appendix '"/>
	<xsl:variable name="CLASS_BACKMATTER"	as="xs:string"	select="' bookmap/backmatter '"/>
	
	
	<xsl:include href="collectCounts.xsl"/>
	<xsl:include href="getTopicTitlePrefix.xsl"/>
	<xsl:include href="processTopic.xsl"/>
	
	
	<xsl:key name="map-id" 		match="*[topicmeta/@resourceid]" 						use="topicmeta/@resourceid"/>
	<xsl:key name="map-uri" 	match="*[contains(@class, ' map/topicref ')][@href]" 	use="resolve-uri(@href, base-uri(.))"/>
	
	<xsl:key name="enumerableByClass" 
		match	= "*[contains(@class, ' topic/fig ')][*[contains(@class, ' topic/title ')]] | *[contains(@class, ' topic/table ')][*[contains(@class, ' topic/title ')]]"
		use		= "tokenize(@class, ' ')"/>


	
	<xsl:template match="/">
		<xsl:variable name="mapWithCounts" as="document-node()">
			<xsl:document>
				<xsl:apply-templates select="node()" mode="CollectCounts"/>
			</xsl:document>
		</xsl:variable>
		<xsl:apply-templates select="$mapWithCounts/node()">
			<xsl:with-param name="rootMap" select="$mapWithCounts" 	tunnel="yes"/>
			<!--<xsl:with-param name="baseUri" select="base-uri(.)" 	tunnel="yes"/>-->
		</xsl:apply-templates>
	</xsl:template>
	
	
	<!-- default template -->
	<xsl:template match="attribute() | node()">
		<xsl:copy>
			<xsl:apply-templates select="attribute() | node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="@ds:* | @xml:base">
		<!-- remove -->
	</xsl:template>
	
	
	<xsl:template match="*[contains(@class, $CLASS_FRONTMATTER)]" priority="2">
		<xsl:next-match>
			<xsl:with-param name="rootClass" 	select="$CLASS_FRONTMATTER" tunnel="yes"/>
			<xsl:with-param name="numRootNode" 	select="." 					tunnel="yes"/>
		</xsl:next-match>
	</xsl:template>
	
	<xsl:template match="*[contains(@class, $CLASS_CHAPTER)]" priority="2">
		<xsl:next-match>
			<xsl:with-param name="rootClass"	select="$CLASS_CHAPTER" tunnel="yes"/>
			<xsl:with-param name="numRootNode" 	select="." 				tunnel="yes"/>
			<xsl:with-param name="rootNum" as="xs:integer" tunnel="yes">
				<xsl:apply-templates select="." mode="GetTopicNum"/>
			</xsl:with-param>
		</xsl:next-match>
	</xsl:template>
	
	<xsl:template match="*[contains(@class, $CLASS_APPENDIX)]" priority="2">
		<xsl:next-match>
			<xsl:with-param name="rootClass" 	select="$CLASS_APPENDIX" 	tunnel="yes"/>
			<xsl:with-param name="numRootNode" 	select="." 					tunnel="yes"/>
			<xsl:with-param name="rootNum" as="xs:integer" tunnel="yes">
				<xsl:apply-templates select="." mode="GetTopicNum"/>
			</xsl:with-param>
		</xsl:next-match>
	</xsl:template>
	
	<xsl:template match="*[contains(@class, $CLASS_BACKMATTER)]" priority="2">
		<xsl:next-match>
			<xsl:with-param name="rootClass" 	select="$CLASS_BACKMATTER" 	tunnel="yes"/>
			<xsl:with-param name="numRootNode"	select="." 					tunnel="yes"/>
		</xsl:next-match>
	</xsl:template>
	
	
	<xsl:template match="*[contains(@class, $CLASS_TOPICREF)][string(@href) != '']">
		<xsl:param name="rootMap"		as="document-node()" 	tunnel="yes"/>
		<xsl:param name="numRootNode"	as="node()?" 			tunnel="yes" select="$rootMap"/>
		
		<xsl:variable name="refUri" as="xs:anyURI" 			select="resolve-uri(@href, base-uri(.))"/>
		<xsl:variable name="refDoc"	as="document-node()?"	select="if (doc-available($refUri)) then doc($refUri) else ()"/>
		<xsl:if test="exists($refDoc)">
			<xsl:message>processing topic <xsl:value-of select="$refUri"/></xsl:message>
			<xsl:result-document href="{$refUri}{$tmpUriSuffix}" method="xml" indent="no">
				<xsl:variable name="numNodes" as="element()*" select="(preceding::* | ancestor::*) intersect $numRootNode/descendant-or-self::*"/>
				<!--<xsl:message select="xs:integer(sum($numNodes/@ds:figCount))"/>-->
				<xsl:apply-templates select="$refDoc" mode="ProcessTopic">
					<xsl:with-param name="figCount" 	select="xs:integer(sum($numNodes/@ds:figCount))" 	tunnel="yes"/>
					<xsl:with-param name="tableCount"	select="xs:integer(sum($numNodes/@ds:tableCount))" 	tunnel="yes"/>
				</xsl:apply-templates>
			</xsl:result-document>
		</xsl:if>
		
		<xsl:next-match/>
	</xsl:template>
	
	
	
	<xsl:template match="*[contains(@class, $CLASS_TOPICREF)]/*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ') or contains(@class, ' map/linktext ')]">
		<xsl:copy>
			<xsl:apply-templates select="attribute()" mode="#current"/>
			
			<xsl:apply-templates select="parent::*/parent::*" mode="GetTopicTitlePrefix"/>
			
			<xsl:apply-templates select="node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*[contains(@class, $CLASS_TOPICREF)]/@navtitle">
		<xsl:attribute name="{name()}">
			<xsl:apply-templates select="parent::*" mode="GetTopicTitlePrefix"/>
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>
	
</xsl:stylesheet>