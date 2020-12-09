<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl	= "http://www.w3.org/1999/XSL/Transform"
	xmlns:xs	= "http://www.w3.org/2001/XMLSchema" 
	xmlns:ds	= "http://www.dita-semia.org"
	exclude-result-prefixes="#all">
	
	<!--

		Architecture:
		
		The processing occurs in two steps:
		1. Transform the root map file into a local variable:
			- All references to sub maps are resolved inplace.
			- To all references to topics the number of figures, tables and equation blocks within the referenced topic is added as attributes
			  This is done so that the numbering of these elements per chapter can be done with good performance in the next step.
		2. Process each each referenced topic and add the number pefix to the titles.
		   The result is stored in a temporal file which will be renamed to the original lame by a following ant step.
		
	-->	

	<xsl:param name="numDelimiter" 				as="xs:string" select="' '"/>
	<xsl:param name="tmpUriSuffix" 				as="xs:string" select="'.tmp'"/>
	<xsl:param name="chapterPrefixFormat" 		as="xs:string" select="'Chapter $:'"/>
	<xsl:param name="appendixPrefixFormat" 		as="xs:string" select="'Appendix $:'"/>
	<xsl:param name="figurePrefix" 				as="xs:string" select="'Figure $:'"/>
	<xsl:param name="tablePrefix" 				as="xs:string" select="'Table $:'"/>
	<xsl:param name="equationPrefix" 			as="xs:string" select="'Equation $: '"/>


	<xsl:variable name="CLASS_TOPIC"			as="xs:string"	select="' topic/topic '"/>
	<xsl:variable name="CLASS_LINK"				as="xs:string"	select="' topic/link '"/>
	<xsl:variable name="CLASS_XREF"				as="xs:string"	select="' topic/xref '"/>
	<xsl:variable name="CLASS_FIG"				as="xs:string"	select="' topic/fig '"/>
	<xsl:variable name="CLASS_TABLE"			as="xs:string"	select="' topic/table '"/>
	<xsl:variable name="CLASS_TITLE"			as="xs:string"	select="' topic/title '"/>
	<xsl:variable name="CLASS_EQUATION_BLOCK" 	as="xs:string" 	select="' equation-d/equation-block '"/>
	<xsl:variable name="CLASS_EQUATION_NUMBER" 	as="xs:string" 	select="' equation-d/equation-number '"/>

	<xsl:variable name="CLASS_MAP"				as="xs:string"	select="' map/map '"/>
	<xsl:variable name="CLASS_TOPICREF"			as="xs:string"	select="' map/topicref '"/>
	<xsl:variable name="CLASS_RELTABLE"			as="xs:string"	select="' map/reltable '"/>

	<xsl:variable name="CLASS_TOPICGROUP"		as="xs:string"	select="' mapgroup-d/topicgroup '"/>
	<xsl:variable name="CLASS_TOPICHEAD"		as="xs:string"	select="' mapgroup-d/topichead '"/>
	
	<xsl:variable name="CLASS_FRONTMATTER"		as="xs:string"	select="' bookmap/frontmatter '"/>
	<xsl:variable name="CLASS_CHAPTER"			as="xs:string"	select="' bookmap/chapter '"/>
	<xsl:variable name="CLASS_APPENDIX"			as="xs:string"	select="' bookmap/appendix '"/>
	<xsl:variable name="CLASS_BACKMATTER"		as="xs:string"	select="' bookmap/backmatter '"/>
	
	
	<xsl:variable name="CS_FIG"					as="xs:string"	select="'topic/fig'"/>
	<xsl:variable name="CS_TABLE"				as="xs:string"	select="'topic/table'"/>
	<xsl:variable name="CS_EQUATION_BLOCK" 		as="xs:string" 	select="'equation-d/equation-block'"/>
	
	<xsl:include href="collectCounts.xsl"/>
	<xsl:include href="getNumRootNode.xsl"/>
	<xsl:include href="getTopicTitlePrefix.xsl"/>
	<xsl:include href="processTopic.xsl"/>
	
	
	<xsl:key name="map-id" 		match="*[topicmeta/@resourceid]" 						use="topicmeta/@resourceid"/>
	<xsl:key name="map-uri" 	match="*[contains(@class, ' map/topicref ')][@href]" 	use="resolve-uri(replace(@href, '#.*$', ''), base-uri(.))"/>
	<xsl:key name="id" 			match="*[@id]"												use="@id"/>
	
	<xsl:key name="enumerableByClass" 
		match	= "*[contains(@class, $CLASS_FIG)][*[contains(@class, $CLASS_TITLE)]] | 
					*[contains(@class, $CLASS_TABLE)][*[contains(@class, $CLASS_TITLE)]] | 
					*[contains(@class, $CLASS_EQUATION_BLOCK)][*[contains(@class, $CLASS_EQUATION_NUMBER)]]"
		use		= "tokenize(@class, ' ')"/>


	
	<xsl:template match="/">
		<!--<xsl:apply-templates select="//*[@href = 'group-child-D.dita']" mode="GetLocalTopicNum"/>-->
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
	
	
	
	<xsl:template match="*[contains(@class, $CLASS_TOPICREF)][ds:isTopicrefRelevant(.)][not(ancestor::*/@chunk = 'to-content')]">
		
		<!-- don't process referenced topic when
				- they are not relevant
				- or they are sub-topics of a topic chunked to content (= sub-topics are embedded into same file) 
		-->
		
		<xsl:variable name="numRootNode"	as="node()?">
			<xsl:apply-templates select="." mode="GetNumRootNode"/>
		</xsl:variable>
		
		<xsl:variable name="hrefFile"	as="xs:string"			select="replace(@href, '#.*$', '')"/>	<!-- ignore id -->
		<xsl:variable name="refUri" 	as="xs:anyURI" 			select="resolve-uri($hrefFile, base-uri(.))"/>
		<xsl:variable name="refDoc"		as="document-node()?"	select="if (doc-available($refUri)) then doc($refUri) else ()"/>
		<xsl:choose>
			<xsl:when test="exists($refDoc)">
				<xsl:message>processing topic <xsl:value-of select="$refUri"/></xsl:message>
				<xsl:result-document href="{$refUri}{$tmpUriSuffix}" method="xml" indent="no">
					<xsl:apply-templates select="$refDoc" mode="ProcessTopic"/>
				</xsl:result-document>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>WARNING: could not process referenced file '<xsl:value-of select="$refUri"/>'</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
		
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
	
	<xsl:function name="ds:isTopicrefRelevant" as="xs:boolean">
		<xsl:param name="topicref" as="element()"/>
		
		<!-- 
			ignore:
				- not referencing anything
				- processing-role "resource-only'
				- html format
				- references within reltable
		-->
		
		<xsl:sequence select="(string($topicref/@href) != '') 
				and not($topicref/@processing-role = 'resource-only') 
				and not($topicref/@format = 'html')
				and not($topicref/ancestor::*[contains(@class, $CLASS_RELTABLE)])"/>
	</xsl:function>
	
</xsl:stylesheet>
