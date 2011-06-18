<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
            xmlns:svrl="http://purl.oclc.org/dsdl/svrl" 
            version="1.0">
<xsl:output method="text"/>

  <xsl:template match="*|node()">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="svrl:failed-assert|                      
                       svrl:successful-report">
    <xsl:text>FAILURE: </xsl:text>
    <xsl:value-of select="local-name(.)"/>
    <xsl:text>: </xsl:text>
    <xsl:value-of select="normalize-space(svrl:text/text())"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
</xsl:stylesheet>
