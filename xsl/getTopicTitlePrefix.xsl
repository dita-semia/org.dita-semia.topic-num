<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl	= "http://www.w3.org/1999/XSL/Transform"
	xmlns:xs	= "http://www.w3.org/2001/XMLSchema" 
	xmlns:ds	= "http://www.dita-semia.org"
	exclude-result-prefixes="#all">

	
	<!-- mode: GetTopicTitlePrefix -->
	
	<xsl:template match="*" mode="GetTopicTitlePrefix" as="xs:string?">
		<xsl:param name="rootClass" as="xs:string?" tunnel="yes"/>
			
		<xsl:variable name="numLst" as="xs:integer*">
			<xsl:apply-templates select="." mode="GetTopicNum"/>
		</xsl:variable>
		
		<xsl:variable name="numStr" as="xs:string?">
			<xsl:choose>
				<xsl:when test="$rootClass = $CLASS_FRONTMATTER"/>
				<xsl:when test="$rootClass = $CLASS_BACKMATTER"/>
				<xsl:when test="($rootClass = $CLASS_APPENDIX) and (count($numLst) = 1) and ($appendixPrefixFormat != '')">
					<xsl:variable name="num" as="xs:string?">
						<xsl:number value="$numLst" format="A.1"/>
					</xsl:variable>
					<xsl:sequence select="replace($appendixPrefixFormat, '\$', $num)"/>
				</xsl:when>
				<xsl:when test="$rootClass = $CLASS_APPENDIX">
					<xsl:number value="$numLst" format="A.1"/>
				</xsl:when>
				<xsl:when test="($rootClass = $CLASS_CHAPTER) and (count($numLst) = 1) and ($chapterPrefixFormat != '')">
					<xsl:variable name="num" as="xs:string?">
						<xsl:number value="$numLst" format="1.1"/>
					</xsl:variable>
					<xsl:sequence select="replace($chapterPrefixFormat, '\$', $num)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:number value="$numLst" format="1.1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:sequence select="ds:getNumPrefix($numStr)"/>
	</xsl:template>
	
	
	
	<!-- mode: GetTopicNum -->
	
	<xsl:template match="*[contains(@class, $CLASS_CHAPTER)]" mode="GetTopicNum" as="xs:integer*" priority="2">
		<xsl:sequence select="count(preceding-sibling::*[contains(@class, $CLASS_CHAPTER)]) + 1"/>
	</xsl:template>

	<xsl:template match="*[contains(@class, $CLASS_APPENDIX)]" mode="GetTopicNum" as="xs:integer*" priority="2">
		<xsl:sequence select="count(preceding-sibling::*[contains(@class, $CLASS_APPENDIX)]) + 1"/>
	</xsl:template>
	
	<xsl:template match="*[contains(@class, $CLASS_TOPICREF)]" mode="GetTopicNum" as="xs:integer*">
		<xsl:apply-templates select="parent::*" mode="#current"/>
		<xsl:sequence select="count(preceding-sibling::*[contains(@class, $CLASS_TOPICREF)]) + 1"/>
	</xsl:template>
	
	<xsl:template match="*[contains(@class, $CLASS_TOPIC)][contains(parent::*/@class, $CLASS_TOPIC)]" mode="GetTopicNum" as="xs:integer*" priority="2">
		<xsl:apply-templates select="parent::*" mode="#current"/>
		<xsl:sequence select="count(preceding-sibling::*[contains(@class, $CLASS_TOPIC)]) + 1"/>
	</xsl:template>
	
	<xsl:template match="*[contains(@class, $CLASS_TOPIC)]" mode="GetTopicNum" as="xs:integer*">
		<xsl:param name="rootMap" as="document-node()" tunnel="yes"/>
		<xsl:apply-templates select="key('map-uri', base-uri(.), $rootMap)[1]" mode="#current"/>
	</xsl:template>
	
	<xsl:template match="*[contains(@class, $CLASS_LINK)]" mode="GetTopicNum" as="xs:integer*">
		<xsl:param name="rootMap" as="document-node()" tunnel="yes"/>
		<xsl:variable name="refUri" 	as="xs:string?"	select="string(resolve-uri(parent::*/@href, base-uri(.)))"/>
		<xsl:apply-templates select="key('map-uri', $refUri, $rootMap)[1]" mode="#current"/>
	</xsl:template>
	
	<xsl:template match="node()" mode="GetTopicNum">
		<!-- default: abort recursion -->
	</xsl:template>
		
	
	
	<!-- utility functions -->
	
	<xsl:function name="ds:getNumPrefix" as="xs:string?">
		<xsl:param name="num" as="xs:string?"/>
		
		<xsl:if test="string($num)!= ''">
			<xsl:sequence select="concat($num, $numDelimiter)"/>
		</xsl:if>
	</xsl:function>

</xsl:stylesheet>
