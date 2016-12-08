<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl		= "http://www.w3.org/1999/XSL/Transform"
	xmlns:xs		= "http://www.w3.org/2001/XMLSchema" 
	xmlns:ds		= "http://www.dita-semia.org"
	exclude-result-prefixes="#all">
	
	<xsl:variable name="CLASS_TOPICREF"		as="xs:string"	select="' map/topicref '"/>
	<xsl:variable name="CLASS_FRONTMATTER"	as="xs:string"	select="' bookmap/frontmatter '"/>
	<xsl:variable name="CLASS_BACKMATTER"	as="xs:string"	select="' bookmap/backmatter '"/>
	<xsl:variable name="CLASS_APPENDIX"		as="xs:string"	select="' bookmap/appendix '"/>
	
		
	<xsl:function name="ds:getTopicRefNum" as="xs:string?">
		<xsl:param name="topicRef" as="element()?"/>
		
		<xsl:for-each select="$topicRef">	<!-- set context to topicref -->
			<xsl:choose>
				<!--<xsl:when test="parent::opentopic:map and contains(@class, ' bookmap/bookmap ')"/>-->
				<xsl:when test="ancestor-or-self::*[contains(@class, $CLASS_FRONTMATTER) or contains(@class, $CLASS_BACKMATTER)]"/>
				<xsl:when test="ancestor-or-self::*[contains(@class, ' bookmap/appendix ')]">
					<xsl:number
						count="*[contains(@class, $CLASS_TOPICREF)][ancestor-or-self::*[contains(@class, ' bookmap/appendix ')]] "
						format="A.1.1" level="multiple"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:number
						count="*[contains(@class, $CLASS_TOPICREF)] [not(ancestor-or-self::*[contains(@class, $CLASS_FRONTMATTER)])]"
						format="1.1" level="multiple"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:function>
	
</xsl:stylesheet>
