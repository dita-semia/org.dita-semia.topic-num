<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl	= "http://www.w3.org/1999/XSL/Transform"
	xmlns:xs	= "http://www.w3.org/2001/XMLSchema" 
	xmlns:ds	= "http://www.dita-semia.org"
	exclude-result-prefixes="#all">


	<xsl:include href="getTopicRefNum.xsl"/>
	
	
	<!-- default template -->
	<xsl:template match="attribute() | node()">
		<xsl:copy>
			<xsl:apply-templates select="attribute() | node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="*[contains(@class, ' map/topicref ')]/*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ') or contains(@class, ' topic/linktext ')]">
		<xsl:copy>
			<xsl:apply-templates select="attribute()" mode="#current"/>

			<xsl:variable name="topicNum"	as="xs:string?" select="ds:getTopicRefNum(parent::*/parent::*)"/>
			<xsl:if test="exists($topicNum)">
				<xsl:sequence select="$topicNum"/>
				<xsl:text> </xsl:text>
			</xsl:if>
			
			<xsl:apply-templates select="node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
</xsl:stylesheet>
