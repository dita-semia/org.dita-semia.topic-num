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
		<xsl:param name="rootMap"		as="document-node()" 	tunnel="yes"/>
		
		<xsl:copy>
			<xsl:apply-templates select="attribute()" mode="#current"/>
			
			<xsl:variable name="uri" as="xs:string?" select="string(resolve-uri(parent::*/@href, base-uri(.)))"/>
			<xsl:apply-templates select="ds:getTopicInMapByUri($uri, $rootMap)" mode="GetTopicTitlePrefix"/>
			
			<xsl:apply-templates select="node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="*[contains(@class, $CLASS_XREF)][matches(@href, '^.*#.*$')]/processing-instruction(ditaot)[. = 'gentext']" mode="ProcessTopic">
		
		<xsl:next-match/>
		
		<xsl:variable name="refNode" as="element()?">
			<xsl:call-template name="getRefNode">
				<xsl:with-param name="href" select="parent::*/@href"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($refNode/@class, $CLASS_TOPIC)">
				<xsl:apply-templates select="$refNode" mode="GetTopicTitlePrefix"/>
			</xsl:when>
			<xsl:when test="contains($refNode/@class, $CLASS_FIG)">
				<xsl:call-template name="GetNumerableTitlePrefix">
					<xsl:with-param name="node"		select="$refNode/*[contains(@class, ' topic/title ')]"/>
					<xsl:with-param name="keyClass" select="$CS_FIG"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($refNode/@class, $CLASS_TABLE)">
				<xsl:call-template name="GetNumerableTitlePrefix">
					<xsl:with-param name="node"		select="$refNode/*[contains(@class, ' topic/title ')]"/>
					<xsl:with-param name="keyClass" select="$CS_TABLE"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($refNode/@class, $CLASS_EQUATION_BLOCK)">
				<xsl:call-template name="GetNumerableTitlePrefix">
					<xsl:with-param name="node" 	select="$refNode/*[contains(@class, ' equation-d/equation-number ')]"/>
					<xsl:with-param name="keyClass" select="$CS_EQUATION_BLOCK"/>
				</xsl:call-template>
				<xsl:variable name="equationNumber" 		as="xs:string" select="string($refNode/*[contains(@class, ' equation-d/equation-number ')])"/>
				<xsl:if test="exists($equationNumber != '') and empty(parent::*/text())">
					<!-- add content of equation-number as well since DITA-OT didn't add it to the link. -->
					<xsl:value-of select="$equationNumber"/>
				</xsl:if>
				
			</xsl:when>
		</xsl:choose>
		
		<!--<xsl:message>xref-uri: <xsl:value-of select="$uri"/></xsl:message>-->
		<!--<xsl:message>
			<xsl:apply-templates select="ds:getTopicInMapByUri($uri, $rootMap)" mode="GetTopicTitlePrefix"/>	
		</xsl:message>-->
	</xsl:template>
	
	<xsl:template name="getRefNode" as="element()?">
		<xsl:param name="href" as="attribute()"/>
		
		<xsl:variable name="refUri" 	as="xs:anyURI?" 		select="resolve-uri(substring-before($href, '#'), base-uri($href))"/>
		<xsl:variable name="refFile"	as="document-node()?"	select="if (doc-available($refUri)) then doc($refUri) else ()"/>
		<xsl:if test="$refFile">
			<xsl:variable name="splitId" 	as="xs:string+" select="tokenize(substring-after($href, '#'), '/')"/>
			<xsl:variable name="topicId"	as="xs:string"	select="$splitId[1]"/>
			<xsl:variable name="subTopicId"	as="xs:string?"	select="$splitId[2]"/>
			
			<xsl:variable name="refTopic" as="element()" select="key('id', $topicId, $refFile)"/>
			<xsl:choose>
				<xsl:when test="empty($refTopic)">
					<!-- abort -->
				</xsl:when>
				<xsl:when test="$subTopicId">
					<xsl:sequence select="key('id', $subTopicId, $refTopic)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$refTopic"/>
				</xsl:otherwise>
			</xsl:choose>	
		</xsl:if>
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
	
	<xsl:template match="*[contains(@class, $CLASS_EQUATION_BLOCK)]/*[contains(@class, $CLASS_EQUATION_NUMBER)]" mode="ProcessTopic">
		<xsl:copy>
			<xsl:apply-templates select="attribute()" mode="#current"/>
			
			<xsl:call-template name="GetNumerableTitlePrefix">
				<xsl:with-param name="keyClass" select="'equation-d/equation-block'"/> <!-- don't use $CLASS_EQUATION here since it has spaces -->
			</xsl:call-template>
			
			<xsl:apply-templates select="node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- 
		Template: GetNumerableTitlePrefix
		
		returns the prefix for a tilte of an element with cross-topic numbering 
	-->
	<xsl:template name="GetNumerableTitlePrefix" as="node()?">
		<xsl:param name="node"			as="element()?"	select="."/>
		<xsl:param name="keyClass" 		as="xs:string"/>
		<xsl:param name="rootMap"		as="document-node()" 	tunnel="yes"/>
		
		
		<xsl:variable name="numRootNodeInMap" as="element()?">
			<!-- The element within the root map that wraps the elements with same consecutive numbering (e.g. chapter) -->
			<xsl:apply-templates select="$node" mode="GetNumRootNode"/>
		</xsl:variable>
		<xsl:variable name="numRootClass" 	as="xs:string?" select="$numRootNodeInMap/@class"/>
		<xsl:variable name="topicInMap"		as="element()?"	select="key('map-uri', base-uri(.), $rootMap)[1]"/>

		<xsl:variable name="precCount" 	as="xs:integer">
			<!-- The number of numerable elements of the current type in preceding topics within the num-root -->
			<xsl:variable name="numNodesInMap" as="element()*" select="($topicInMap/preceding::* | $topicInMap/ancestor::*) intersect $numRootNodeInMap/descendant-or-self::*"/>

			<xsl:choose>
				<xsl:when test="$keyClass = $CS_FIG">
					<xsl:sequence select="xs:integer(sum($numNodesInMap/@ds:figCount))"/>
				</xsl:when>
				<xsl:when test="$keyClass = $CS_TABLE">
					<xsl:sequence select="xs:integer(sum($numNodesInMap/@ds:tableCount))"/>
				</xsl:when>
				<xsl:when test="$keyClass = $CS_EQUATION_BLOCK">
					<xsl:sequence select="xs:integer(sum($numNodesInMap/@ds:equationCount))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="0"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="localNum" 	as="xs:integer" 	select="count(key('enumerableByClass', $keyClass, $node/ancestor::document-node())[. &lt;&lt; $node])"/>
		<!-- the number within this topic -->
		
		<xsl:variable name="fullNum" 	as="xs:integer" 	select="$precCount + $localNum"/>
		<!-- the actual number is simple the sum of preceding elements and the local number -->

		<xsl:variable name="numStr" as="xs:string*">
			<!-- 
				Create the acutal string based on static prefix and the individual number.
				The format of the numbering depends on the type of num-root element.
			-->
			<xsl:variable name="prefixFormat" as="xs:string" 
					select="if ($keyClass = $CS_FIG) then $figurePrefix 
							else if ($keyClass = $CS_TABLE) then $tablePrefix 
							else $equationPrefix"/>
			<xsl:variable name="num" as="xs:string?">
				<xsl:choose>
					<xsl:when test="contains($numRootClass, $CLASS_FRONTMATTER)"/>
					<xsl:when test="contains($numRootClass, $CLASS_BACKMATTER)"/>
					<xsl:when test="contains($numRootClass, $CLASS_APPENDIX)">
						<xsl:variable name="rootNum" as="xs:integer">
							<xsl:apply-templates select="$numRootNodeInMap" mode="GetTopicNum"/>
						</xsl:variable>
						<xsl:number value="($rootNum, $fullNum)" format="A-1"/>
					</xsl:when>
					<xsl:when test="contains($numRootClass, $CLASS_CHAPTER) or contains($numRootClass, $CLASS_TOPICREF)">
						<xsl:variable name="rootNum" as="xs:integer">
							<xsl:apply-templates select="$numRootNodeInMap" mode="GetTopicNum"/>
						</xsl:variable>
						<xsl:number value="($rootNum, $fullNum)" format="1-1"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:number value="$fullNum" format="1"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="$num">
				<xsl:sequence select="replace($prefixFormat, '\$', $num)"/>
			</xsl:if>
		</xsl:variable>
		
		<!--<xsl:message select="$numRootClass"/>
		<xsl:message select="$numStr"/>-->

		<xsl:sequence select="ds:getNumPrefix(string-join($numStr, ' '))"/>
	</xsl:template>
	

</xsl:stylesheet>
