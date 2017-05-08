<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl	= "http://www.w3.org/1999/XSL/Transform"
	xmlns:xs	= "http://www.w3.org/2001/XMLSchema" 
	xmlns:ds	= "http://www.dita-semia.org"
	exclude-result-prefixes="#all">

	
	<!-- mode: GetNumRootNode -->
		
	<xsl:template match="*[contains(@class, $CLASS_FRONTMATTER) or 
							contains(@class, $CLASS_CHAPTER) or 
							contains(@class, $CLASS_APPENDIX) or 
							contains(@class, $CLASS_BACKMATTER)]" mode="GetNumRootNode" as="node()?" priority="2">
		<xsl:sequence select="."/>
	</xsl:template>
	
	<xsl:template match="document-node()" mode="GetNumRootNode" as="node()?">
		<xsl:sequence select="."/>
	</xsl:template>
	
	<xsl:template match="*[contains(@class, $CLASS_TOPIC)][empty(parent::*)]" mode="GetNumRootNode" as="node()?">
		<xsl:param name="rootMap"		as="document-node()" 	tunnel="yes"/>
		<xsl:apply-templates select="key('map-uri', base-uri(.), $rootMap)[1]" mode="#current"/>
	</xsl:template>

	<xsl:template match="*" mode="GetNumRootNode" as="node()?">
		<xsl:apply-templates select="parent::*" mode="#current"/>
	</xsl:template>
	
</xsl:stylesheet>
