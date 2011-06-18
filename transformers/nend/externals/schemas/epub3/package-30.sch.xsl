<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
<xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


<!--PROLOG-->
<xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>

   <!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
<xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
<xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters--><xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
<xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="" schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="http://www.idpf.org/2007/opf" prefix="opf"/>
         <svrl:ns-prefix-in-attribute-values uri="http://purl.org/dc/elements/1.1/" prefix="dc"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">opf.uid</xsl:attribute>
            <xsl:attribute name="name">opf.uid</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M2"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">opf.itemref</xsl:attribute>
            <xsl:attribute name="name">opf.itemref</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M3"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">opf.fallback.ref</xsl:attribute>
            <xsl:attribute name="name">opf.fallback.ref</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M4"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">opf.media.overlay</xsl:attribute>
            <xsl:attribute name="name">opf.media.overlay</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M5"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">opf.media.overlay.metadata</xsl:attribute>
            <xsl:attribute name="name">opf.media.overlay.metadata</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M6"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">opf.bindings.handler</xsl:attribute>
            <xsl:attribute name="name">opf.bindings.handler</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M7"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">opf.toc.ncx</xsl:attribute>
            <xsl:attribute name="name">opf.toc.ncx</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">opf.dc.identifier.override</xsl:attribute>
            <xsl:attribute name="name">opf.dc.identifier.override</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">opf.dc.title.override</xsl:attribute>
            <xsl:attribute name="name">opf.dc.title.override</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">opf.dc.language.override</xsl:attribute>
            <xsl:attribute name="name">opf.dc.language.override</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M11"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">opf.scheme-datatype</xsl:attribute>
            <xsl:attribute name="name">opf.scheme-datatype</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M12"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">opf.nav</xsl:attribute>
            <xsl:attribute name="name">opf.nav</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M13"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">opf.cover-image</xsl:attribute>
            <xsl:attribute name="name">opf.cover-image</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M14"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">id-unique</xsl:attribute>
            <xsl:attribute name="name">id-unique</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M15"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->


<!--PATTERN opf.uid-->


	<!--RULE -->
<xsl:template match="opf:package[@unique-identifier]" priority="1000" mode="M2">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="opf:package[@unique-identifier]"/>
      <xsl:variable name="uid" select="./@unique-identifier"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="/opf:package/opf:metadata/dc:identifier[@id = $uid]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="/opf:package/opf:metadata/dc:identifier[@id = $uid]">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>package element unique-identifier attribute does not resolve to a dc:identifier element (given reference was '<xsl:text/>
                  <xsl:value-of select="$uid"/>
                  <xsl:text/>')</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M2"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M2"/>
   <xsl:template match="@*|node()" priority="-2" mode="M2">
      <xsl:apply-templates select="*" mode="M2"/>
   </xsl:template>

   <!--PATTERN opf.itemref-->


	<!--RULE -->
<xsl:template match="opf:spine/opf:itemref[@idref]" priority="1000" mode="M3">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="opf:spine/opf:itemref[@idref]"/>
      <xsl:variable name="ref" select="./@idref"/>
      <xsl:variable name="item" select="//opf:manifest/opf:item[@id = $ref]"/>
      <xsl:variable name="item-media-type" select="$item/@media-type"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$item"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$item">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>itemref element idref attribute does not resolve to a manifest item element</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M3"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M3"/>
   <xsl:template match="@*|node()" priority="-2" mode="M3">
      <xsl:apply-templates select="*" mode="M3"/>
   </xsl:template>

   <!--PATTERN opf.fallback.ref-->


	<!--RULE -->
<xsl:template match="opf:item[@fallback]" priority="1000" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="opf:item[@fallback]"/>
      <xsl:variable name="ref" select="./@fallback"/>
      <xsl:variable name="item" select="/opf:package/opf:manifest/opf:item[@id = $ref]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$item and $item/@id != ./@id"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$item and $item/@id != ./@id">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>manifest item element fallback attribute must resolve to another manifest item (given reference was '<xsl:text/>
                  <xsl:value-of select="$ref"/>
                  <xsl:text/>')</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M4"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M4"/>
   <xsl:template match="@*|node()" priority="-2" mode="M4">
      <xsl:apply-templates select="*" mode="M4"/>
   </xsl:template>

   <!--PATTERN opf.media.overlay-->


	<!--RULE -->
<xsl:template match="opf:item[@media-overlay]" priority="1000" mode="M5">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="opf:item[@media-overlay]"/>
      <xsl:variable name="ref" select="./@media-overlay"/>
      <xsl:variable name="item" select="//opf:manifest/opf:item[@id = $ref]"/>
      <xsl:variable name="item-media-type" select="$item/@media-type"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$item-media-type = 'application/smil+xml'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$item-media-type = 'application/smil+xml'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>media overlay items must be of the 'application/smil+xml' type (given type was '<xsl:text/>
                  <xsl:value-of select="$item-media-type"/>
                  <xsl:text/>')</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M5"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M5"/>
   <xsl:template match="@*|node()" priority="-2" mode="M5">
      <xsl:apply-templates select="*" mode="M5"/>
   </xsl:template>

   <!--PATTERN opf.media.overlay.metadata-->


	<!--RULE -->
<xsl:template match="opf:manifest[opf:item[@media-overlay]]" priority="1001" mode="M6">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="opf:manifest[opf:item[@media-overlay]]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="//opf:meta[@property='media:duration' and not (@about)]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//opf:meta[@property='media:duration' and not (@about)]">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>global media:duration meta element not set</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="opf:manifest/opf:item[@media-overlay]" priority="1000" mode="M6">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="opf:manifest/opf:item[@media-overlay]"/>
      <xsl:variable name="mo-idref" select="@media-overlay"/>
      <xsl:variable name="mo-item" select="//opf:item[@id = $mo-idref]"/>
      <xsl:variable name="mo-item-id" select="$mo-item/@id"/>
      <xsl:variable name="mo-item-uri" select="concat('#', $mo-item-id)"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="//opf:meta[@property='media:duration' and @about = $mo-item-uri ]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//opf:meta[@property='media:duration' and @about = $mo-item-uri ]">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>item media:duration meta element not set (expecting: meta property='media:duration' about='<xsl:text/>
                  <xsl:value-of select="$mo-item-uri"/>
                  <xsl:text/>')</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M6"/>
   <xsl:template match="@*|node()" priority="-2" mode="M6">
      <xsl:apply-templates select="*" mode="M6"/>
   </xsl:template>

   <!--PATTERN opf.bindings.handler-->


	<!--RULE -->
<xsl:template match="opf:bindings/opf:mediaType" priority="1000" mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="opf:bindings/opf:mediaType"/>
      <xsl:variable name="ref" select="./@handler"/>
      <xsl:variable name="item" select="//opf:manifest/opf:item[@id = $ref]"/>
      <xsl:variable name="item-media-type" select="$item/@media-type"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$item-media-type = 'application/xhtml+xml'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$item-media-type = 'application/xhtml+xml'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>manifest items referenced from the handler attribute of a bindings mediaType element must be of the 'application/xhtml+xml' type (given type was '<xsl:text/>
                  <xsl:value-of select="$item-media-type"/>
                  <xsl:text/>')</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>

   <!--PATTERN opf.toc.ncx-->


	<!--RULE -->
<xsl:template match="opf:spine[@toc]" priority="1000" mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="opf:spine[@toc]"/>
      <xsl:variable name="ref" select="./@toc"/>
      <xsl:variable name="item" select="/opf:package/opf:manifest/opf:item[@id = $ref]"/>
      <xsl:variable name="item-media-type" select="$item/@media-type"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$item-media-type = 'application/x-dtbncx+xml'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$item-media-type = 'application/x-dtbncx+xml'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>spine element toc attribute must reference the NCX manifest item (referenced media type was '<xsl:text/>
                  <xsl:value-of select="$item-media-type"/>
                  <xsl:text/>')</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*" mode="M8"/>
   </xsl:template>

   <!--PATTERN opf.dc.identifier.override-->


	<!--RULE -->
<xsl:template match="/opf:package/opf:metadata/dc:identifier[@opf:override]" priority="1000"
                 mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/opf:package/opf:metadata/dc:identifier[@opf:override]"/>
      <xsl:variable name="ref" select="./@opf:override"/>
      <xsl:variable name="meta" select="/opf:package/opf:metadata/opf:meta[@id = $ref]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$meta/@property = 'dcterms:identifier'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$meta/@property = 'dcterms:identifier'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>opf:override attribute on a <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element must resolve to a meta element with the equivalent dcterms property (given property was <xsl:text/>
                  <xsl:value-of select="$meta/@property"/>
                  <xsl:text/>)</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>

   <!--PATTERN opf.dc.title.override-->


	<!--RULE -->
<xsl:template match="/opf:package/opf:metadata/dc:title[@opf:override]" priority="1000"
                 mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/opf:package/opf:metadata/dc:title[@opf:override]"/>
      <xsl:variable name="ref" select="./@opf:override"/>
      <xsl:variable name="meta" select="/opf:package/opf:metadata/opf:meta[@id = $ref]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$meta/@property = 'dcterms:title'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$meta/@property = 'dcterms:title'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>opf:override attribute on a <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element must resolve to a meta element with the equivalent dcterms property (given property was <xsl:text/>
                  <xsl:value-of select="$meta/@property"/>
                  <xsl:text/>)</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>

   <!--PATTERN opf.dc.language.override-->


	<!--RULE -->
<xsl:template match="/opf:package/opf:metadata/dc:language[@opf:override]" priority="1000"
                 mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/opf:package/opf:metadata/dc:language[@opf:override]"/>
      <xsl:variable name="ref" select="./@opf:override"/>
      <xsl:variable name="meta" select="/opf:package/opf:metadata/opf:meta[@id = $ref]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$meta/@property = 'dcterms:language'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$meta/@property = 'dcterms:language'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>opf:override attribute on a <xsl:text/>
                  <xsl:value-of select="name(.)"/>
                  <xsl:text/> element must resolve to a meta element with the equivalent dcterms property (given property was <xsl:text/>
                  <xsl:value-of select="$meta/@property"/>
                  <xsl:text/>)</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>

   <!--PATTERN opf.scheme-datatype-->


	<!--RULE -->
<xsl:template match="opf:meta[@property='scheme']" priority="1000" mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="opf:meta[@property='scheme']"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@datatype"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@datatype">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>scheme property must include a datatype attribute.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@datatype='xsd:anyURI' or @datatype='xsd:string'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@datatype='xsd:anyURI' or @datatype='xsd:string'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>scheme property datatype must of the type 'xsd:string' or 'xsd:anyURI'.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>

   <!--PATTERN opf.nav-->


	<!--RULE -->
<xsl:template match="opf:manifest" priority="1001" mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="opf:manifest"/>
      <xsl:variable name="item"
                    select="//opf:manifest/opf:item[@properties and (some $token in tokenize(@properties,' ') satisfies (normalize-space($token) eq 'nav'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($item) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($item) = 1">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Exactly one manifest item must declare the 'nav' property (number of 'nav' items: <xsl:text/>
                  <xsl:value-of select="count($item)"/>
                  <xsl:text/>).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="opf:manifest/opf:item[@properties and (some $token in tokenize(@properties,' ') satisfies (normalize-space($token) eq 'nav'))]"
                 priority="1000"
                 mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="opf:manifest/opf:item[@properties and (some $token in tokenize(@properties,' ') satisfies (normalize-space($token) eq 'nav'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="@media-type = 'application/xhtml+xml'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@media-type = 'application/xhtml+xml'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The manifest item representing the Navigation Document must be of the 'application/xhtml+xml' type (given type was '<xsl:text/>
                  <xsl:value-of select="@media-type"/>
                  <xsl:text/>')</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>

   <!--PATTERN opf.cover-image-->


	<!--RULE -->
<xsl:template match="opf:manifest" priority="1000" mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="opf:manifest"/>
      <xsl:variable name="item"
                    select="//opf:manifest/opf:item[@properties and (some $token in tokenize(@properties,' ') satisfies (normalize-space($token) eq 'cover-image'))]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($item) &lt; 2"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($item) &lt; 2">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Multiple occurrences of the 'cover-image' property (number of 'cover-image' items: <xsl:text/>
                  <xsl:value-of select="count($item)"/>
                  <xsl:text/>).</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>

   <!--PATTERN id-unique-->
<xsl:variable name="id-set" select="//*[@id]"/>

	  <!--RULE -->
<xsl:template match="*[@id]" priority="1000" mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="*[@id]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count($id-set[@id = current()/@id]) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count($id-set[@id = current()/@id]) = 1">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Duplicate ID '<xsl:text/>
                  <xsl:value-of select="current()/@id"/>
                  <xsl:text/>'</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
</xsl:stylesheet>