<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl	= "http://www.w3.org/1999/XSL/Transform"
	xmlns:xs	= "http://www.w3.org/2001/XMLSchema" 
	xmlns:ds	= "http://www.dita-semia.org"
	exclude-result-prefixes="#all">
	
	
	<xsl:variable name="CLASS_TOPIC"		as="xs:string"	select="' topic/topic '"/>
	
	
	<xsl:include href="getTopicRefNum.xsl"/>
	
	
	<xsl:param name="ditaMapFile" as="xs:string"/>
	
	<xsl:variable name="map" as="document-node()?" select="doc(concat('file:///', $ditaMapFile))"/>
	
	
	<xsl:key name="map-id" 		match="*[topicmeta/@resourceid]" 						use="topicmeta/@resourceid"/>
	<xsl:key name="map-uri" 	match="*[contains(@class, ' map/topicref ')][@href]" 	use="resolve-uri(@href, base-uri(.))"/>


	<!-- default template -->
	<xsl:template match="attribute() | node()">
		<xsl:copy>
			<xsl:apply-templates select="attribute() | node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="*[contains(@class, ' topic/topic ')]/*[contains(@class, ' topic/title ')]">
		<xsl:copy>
			<xsl:apply-templates select="attribute()" mode="#current"/>

			<xsl:variable name="topicNum"	as="xs:string?" select="ds:getTopicNum(parent::*)"/>
			<xsl:if test="exists($topicNum)">
				<xsl:sequence select="$topicNum"/>
				<xsl:text> </xsl:text>
			</xsl:if>

			<xsl:apply-templates select="node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="*[contains(@class, ' topic/link ')][@href]/*[contains(@class, ' topic/linktext ')]">
		<xsl:copy>
			<xsl:apply-templates select="attribute()" mode="#current"/>
			
			<xsl:variable name="uri" 	as="xs:string?"	select="string(resolve-uri(parent::*/@href, base-uri(.)))"/>
			<xsl:variable name="topicNum"	as="xs:string?" select="ds:getTopicRefNum(key('map-uri', $uri, $map)[1])"/>
			<xsl:if test="exists($topicNum)">
				<xsl:sequence select="$topicNum"/>
				<xsl:text> </xsl:text>
			</xsl:if>
			
			<xsl:apply-templates select="node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	
	<xsl:function name="ds:getTopicNum" as="xs:string?">
		<xsl:param name="topic" as="element()?"/>
		
		<xsl:choose>
			<xsl:when test="contains($topic/parent::*/@class, $CLASS_TOPIC)">
				<xsl:variable name="parentTopicNum"	as="xs:string?" select="ds:getTopicNum($topic/parent::*)"/>
				<xsl:variable name="thisTopicPos"	as="xs:string" 	select="string(count($topic/preceding-sibling::*[contains(@class, $CLASS_TOPIC)]) + 1)"/>
				<xsl:sequence select="string-join(($parentTopicNum, $thisTopicPos), '.')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="ds:getTopicRefNum(key('map-id', $topic/@id, $map)[1])"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

</xsl:stylesheet>
