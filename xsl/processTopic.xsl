<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl	= "http://www.w3.org/1999/XSL/Transform"
	xmlns:xs	= "http://www.w3.org/2001/XMLSchema" 
	xmlns:ds	= "http://www.dita-semia.org"
	exclude-result-prefixes="#all">
	
	<!-- default template -->
	<xsl:template match="attribute() | node()" mode="ProcessTopic">
		<xsl:copy>
			<xsl:apply-templates select="attribute() | node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="*[contains(@class, $CLASS_TOPIC)]/*[contains(@class, $CLASS_TITLE)]" mode="ProcessTopic">
		<xsl:copy>
			<xsl:apply-templates select="attribute()" mode="#current"/>
			
			<xsl:apply-templates select="parent::*" mode="GetTopicTitlePrefix"/>
			
			<xsl:apply-templates select="node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="*[contains(@class, $CLASS_LINK)][@href]/*[contains(@class, ' topic/linktext ')]" mode="ProcessTopic">
		<xsl:copy>
			<xsl:apply-templates select="attribute()" mode="#current"/>
			
			<xsl:apply-templates select="parent::*" mode="GetTopicTitlePrefix"/>
			
			<xsl:apply-templates select="node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="*[contains(@class, $CLASS_FIG)]/*[contains(@class, $CLASS_TITLE)]" mode="ProcessTopic">
		<xsl:copy>
			<xsl:apply-templates select="attribute()" mode="#current"/>
			
			<xsl:call-template name="GetNumerableTitlePrefix">
				<xsl:with-param name="keyClass" select="'topic/fig'"/>	<!-- don't use $CLASS_FIG here since it has spaces -->
			</xsl:call-template>
			
			<xsl:apply-templates select="node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="*[contains(@class, $CLASS_TABLE)]/*[contains(@class, $CLASS_TITLE)]" mode="ProcessTopic">
		<xsl:copy>
			<xsl:apply-templates select="attribute()" mode="#current"/>
			
			<xsl:call-template name="GetNumerableTitlePrefix">
				<xsl:with-param name="keyClass" select="'topic/table'"/>	<!-- don't use $CLASS_TABLE here since it has spaces -->
			</xsl:call-template>
			
			<xsl:apply-templates select="node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	
	<xsl:template name="GetNumerableTitlePrefix" as="xs:string?">
		<xsl:param name="keyClass" 		as="xs:string"/>
		<xsl:param name="rootClass" 	as="xs:string?" 		tunnel="yes"/>
		<xsl:param name="rootNum" 		as="xs:integer?" 		tunnel="yes"/>
		<xsl:param name="rootMap" 		as="document-node()" 	tunnel="yes"/>
		<xsl:param name="figCount" 		as="xs:integer?" 		tunnel="yes"/>
		<xsl:param name="tableCount" 	as="xs:integer?" 		tunnel="yes"/>
		
		<!--<xsl:message>-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-</xsl:message>
		<xsl:message select="key('enumerableByClass', $keyClass)[. &lt;&lt; current()]/title/text()"/>
		<xsl:message select="current()"/>
		<xsl:message>-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-</xsl:message>-->
		<xsl:variable name="precCount" 	as="xs:integer" 	select="if ($keyClass = 'topic/fig') then $figCount else $tableCount"/>
		<xsl:variable name="localNum" 	as="xs:integer" 	select="count(key('enumerableByClass', $keyClass)[. &lt;&lt; current()])"/>
		<xsl:variable name="num" 		as="xs:integer" 	select="$precCount + $localNum"/>

		<xsl:variable name="numStr" as="xs:string?">
			<xsl:choose>
				<xsl:when test="$rootClass = $CLASS_FRONTMATTER"/>
				<xsl:when test="$rootClass = $CLASS_BACKMATTER"/>
				<xsl:when test="$rootClass = $CLASS_APPENDIX">
					<xsl:number value="($rootNum, $num)" format="A-1"/>
				</xsl:when>
				<xsl:when test="$rootClass = $CLASS_CHAPTER">
					<xsl:number value="($rootNum, $num)" format="1-1"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:number value="$num" format="1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:sequence select="ds:getNumPrefix($numStr)"/>
	</xsl:template>
	

</xsl:stylesheet>
