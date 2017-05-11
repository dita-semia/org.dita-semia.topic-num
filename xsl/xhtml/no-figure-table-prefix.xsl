<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl	= "http://www.w3.org/1999/XSL/Transform"
	xmlns:xs	= "http://www.w3.org/2001/XMLSchema" 
	xmlns:ds	= "http://www.dita-semia.org"
	exclude-result-prefixes="#all">
	
	<!-- hide the additional fig-title-label -->
	
	<xsl:template name="place-fig-lbl">
		<xsl:param name="stringName"/>
		<!--<!-\- Number of fig/title's including this one -\->
		<xsl:variable name="fig-count-actual" select="count(preceding::*[contains(@class, ' topic/fig ')]/*[contains(@class, ' topic/title ')])+1"/>
		<xsl:variable name="ancestorlang">
			<xsl:call-template name="getLowerCaseLang"/>
		</xsl:variable>-->
		<xsl:choose>
			<!-- title -or- title & desc -->
			<xsl:when test="*[contains(@class, ' topic/title ')]">
				<span class="figcap">
					<!--<span class="fig-\-title-label">
						<xsl:choose>      <!-\- Hungarian: "1. Figure " -\->
							<xsl:when test="$ancestorlang = ('hu', 'hu-hu')">
								<xsl:value-of select="$fig-count-actual"/>
								<xsl:text>. </xsl:text>
								<xsl:call-template name="getVariable">
									<xsl:with-param name="id" select="'Figure'"/>
								</xsl:call-template>
								<xsl:text> </xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="getVariable">
									<xsl:with-param name="id" select="'Figure'"/>
								</xsl:call-template>
								<xsl:text> </xsl:text>
								<xsl:value-of select="$fig-count-actual"/>
								<xsl:text>. </xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</span>-->
					<xsl:apply-templates select="*[contains(@class, ' topic/title ')]" mode="figtitle"/>
					<xsl:if test="*[contains(@class, ' topic/desc ')]">
						<xsl:text>. </xsl:text>
					</xsl:if>
				</span>
				<xsl:for-each select="*[contains(@class, ' topic/desc ')]">
					<span class="figdesc">
						<xsl:call-template name="commonattributes"/>
						<xsl:apply-templates select="." mode="figdesc"/>
					</span>
				</xsl:for-each>
			</xsl:when>
			<!-- desc -->
			<xsl:when test="*[contains(@class, ' topic/desc ')]">
				<xsl:for-each select="*[contains(@class, ' topic/desc ')]">
					<span class="figdesc">
						<xsl:call-template name="commonattributes"/>
						<xsl:apply-templates select="." mode="figdesc"/>
					</span>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- hide the additional table-title-label -->
	
	<xsl:template name="place-tbl-lbl">
		<xsl:param name="stringName"/>
		<!--<!-\- Number of table/title's before this one -\->
		<xsl:variable name="tbl-count-actual" select="count(preceding::*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/title ')])+1"/>
		
		<!-\- normally: "Table 1. " -\->
		<xsl:variable name="ancestorlang">
			<xsl:call-template name="getLowerCaseLang"/>
		</xsl:variable>-->
		
		<xsl:choose>
			<!-- title -or- title & desc -->
			<xsl:when test="*[contains(@class, ' topic/title ')]">
				<caption>
					<span class="tablecap">
						<!--<span class="table-\-title-label">
							<!-\- TODO language specific processing should be done with string variables -\->
							<xsl:choose>     <!-\- Hungarian: "1. Table " -\->
								<xsl:when test="$ancestorlang = ('hu', 'hu-hu')">
									<xsl:value-of select="$tbl-count-actual"/>
									<xsl:text>. </xsl:text>
									<xsl:call-template name="getVariable">
										<xsl:with-param name="id" select="'Table'"/>
									</xsl:call-template>
									<xsl:text> </xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="getVariable">
										<xsl:with-param name="id" select="'Table'"/>
									</xsl:call-template>
									<xsl:text> </xsl:text>
									<xsl:value-of select="$tbl-count-actual"/>
									<xsl:text>. </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</span>-->
						<xsl:apply-templates select="*[contains(@class, ' topic/title ')]" mode="tabletitle"/>
						<xsl:if test="*[contains(@class, ' topic/desc ')]">
							<xsl:text>. </xsl:text>
						</xsl:if>
					</span>
					<xsl:for-each select="*[contains(@class, ' topic/desc ')]">
						<span class="tabledesc">
							<xsl:call-template name="commonattributes"/>
							<xsl:apply-templates select="." mode="tabledesc"/>
						</span>
					</xsl:for-each>
				</caption>
			</xsl:when>
			<!-- desc -->
			<xsl:when test="*[contains(@class, ' topic/desc ')]">
				<xsl:for-each select="*[contains(@class, ' topic/desc ')]">
					<span class="tabledesc">
						<xsl:call-template name="commonattributes"/>
						<xsl:apply-templates select="." mode="tabledesc"/>
					</span>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
