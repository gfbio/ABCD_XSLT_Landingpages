<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:abcd="http://www.tdwg.org/schemas/abcd/2.06" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="/">
		<xsl:for-each select="abcd:DataSets">
		<html>
		<head>
			<title>ABCD Landingpage for <xsl:value-of select="abcd:DataSets/abcd:DataSet/abcd:Metadata/abcd:Description/abcd:Representation/abcd:Title"/></title>
			<style>
				td{
					vertical-align:top;
					padding-left: 20px;
					padding-bottom: 20px;
				}
				ul{
					margin:0px;
					padding:0px;
					padding-left: 15px;
				}
				.scroll-box{
					max-height:600px;
					overflow:auto;
				}
			</style>
		</head>
		<body>
		<xsl:for-each select="abcd:DataSet">
		<div class="dataset">
		<h2>ABCD Landingpage for <xsl:value-of select="abcd:Metadata/abcd:Description/abcd:Representation/abcd:Title"/></h2>
		<p><xsl:value-of select="abcd:Metadata/abcd:Description/abcd:Representation/abcd:Details"/></p>
		<table>
<!-- 	-->	

		<xsl:if test="abcd:TechnicalContacts/abcd:TechnicalContact">		
		<tr>
		<td><b>Technical Contact<xsl:if test="count(abcd:TechnicalContacts/abcd:TechnicalContact) gt 1">s</xsl:if></b></td>
		<td><ul>
		<xsl:for-each select="abcd:TechnicalContacts/abcd:TechnicalContact">
			<li>
				<xsl:value-of select="abcd:Name"/><xsl:if test="abcd:Email"> (<a><xsl:attribute name="href">mailto:<xsl:value-of select="abcd:Email"/></xsl:attribute><xsl:value-of select="abcd:Email"/></a>)</xsl:if>
			</li>
		</xsl:for-each>
		</ul>
		</td>	
		</tr>
		</xsl:if>
		
		<xsl:if test="abcd:ContentContacts/abcd:ContentContact">
		<tr>
		<td><b>Content Contact<xsl:if test="count(abcd:ContentContacts/abcd:ContentContact) gt 1">s</xsl:if></b></td>
		<td><ul><xsl:for-each select="abcd:ContentContacts/abcd:ContentContact">
							<li>
								<xsl:value-of select="abcd:Name"/><xsl:if test="abcd:Email"> (<a><xsl:attribute name="href">mailto:<xsl:value-of select="abcd:Email"/></xsl:attribute><xsl:value-of select="abcd:Email"/></a>)</xsl:if>
							</li>
						</xsl:for-each></ul></td>
		</tr>
		</xsl:if>
		
		<xsl:if test="abcd:Metadata/abcd:Owners/abcd:Owner">
		<tr>
		<td><b>Owner<xsl:if test="count(abcd:Metadata/abcd:Owners/abcd:Owner) gt 1">s</xsl:if></b></td>
		<td><ul>
		<xsl:for-each select="abcd:Metadata/abcd:Owners/abcd:Owner[not(abcd:Person) and abcd:Organisation]">
			<li class="org">
				<xsl:choose>
					<xsl:when test="abcd:URIs/abcd:URL">
						<a><xsl:attribute name="href"><xsl:value-of select="abcd:URIs/abcd:URL[1]"/></xsl:attribute><xsl:value-of select="abcd:Organisation/abcd:Name/abcd:Representation/abcd:Text"/><xsl:if test="abcd:Organisation/abcd:Name/abcd:Representation/abcd:Abbreviation"> (<xsl:value-of select="abcd:Organisation/abcd:Name/abcd:Representation/abcd:Abbreviation"/>)</xsl:if></a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="abcd:Organisation/abcd:Name/abcd:Representation/abcd:Text"/><xsl:if test="abcd:Organisation/abcd:Name/abcd:Representation/abcd:Abbreviation"> (<xsl:value-of select="abcd:Organisation/abcd:Name/abcd:Representation/abcd:Abbreviation"/>)</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</li>
		</xsl:for-each>
		<xsl:for-each select="abcd:Metadata/abcd:Owners/abcd:Owner[abcd:Person]">
			<li class="pers">
				<xsl:value-of select="abcd:Person/abcd:FullName"/><xsl:if test="abcd:Roles/abcd:Role"> (<xsl:value-of select="fn:replace(fn:string-join(abcd:Roles/abcd:Role,', '),', $','')"/>)<xsl:if test="abcd:Organisation/abcd:Name/abcd:Representation/abcd:Text">, <xsl:value-of select="abcd:Organisation/abcd:Name/abcd:Representation/abcd:Text"/></xsl:if></xsl:if>
			</li>
		</xsl:for-each>
		</ul>
		</td>	
		</tr>
		</xsl:if>
		
		<xsl:if test="abcd:Metadata/abcd:RevisionData/abcd:DateModified">
		<tr>
		<td><b>Last Modified</b></td>
		<td><xsl:value-of select="abcd:Metadata/abcd:RevisionData/abcd:DateModified"/></td>	
		</tr>
		</xsl:if>
		
				
		<xsl:if test="abcd:Units/abcd:Unit/abcd:RecordBasis">
		<tr>
		<td><b>Record Basis</b></td>
		<td><ul>
		<xsl:for-each select="distinct-values(abcd:Units/abcd:Unit/abcd:RecordBasis/text())">
			<xsl:sort select="."/>
			<li>
				<xsl:value-of select="."/>
			</li>
		</xsl:for-each>
		</ul>
		</td>	
		</tr>
		</xsl:if>
		
		<tr>
		<td><b>Size</b></td>
		<td><xsl:value-of select="count(abcd:Units/abcd:Unit)"/> unit<xsl:if test="count(abcd:Units/abcd:Unit) != 1">s</xsl:if></td>	
		</tr>
		
		<tr>
		<td><b>Multimedia Objects</b></td>
		<td><xsl:value-of select="count(abcd:Units/abcd:Unit/abcd:MultiMediaObjects/abcd:MultiMediaObject)"/> object<xsl:if test="count(abcd:Units/abcd:Unit/abcd:MultiMediaObjects/abcd:MultiMediaObject) != 1">s</xsl:if></td>	
		</tr>
		
		<xsl:if test="abcd:Units/abcd:Unit/abcd:Identifications/abcd:Identification/abcd:Result/abcd:TaxonIdentified/abcd:ScientificName/abcd:FullScientificNameString">
		<tr>
		<td><b>Taxonomic Scope</b></td>
		<td><div class="scroll-box"><ul>
		<xsl:for-each select="distinct-values(abcd:Units/abcd:Unit/abcd:Identifications/abcd:Identification/abcd:Result/abcd:TaxonIdentified/abcd:ScientificName/abcd:FullScientificNameString/text())">
			<xsl:sort select="."/>
			<li>
				<xsl:value-of select="."/>
			</li>
		</xsl:for-each>
		</ul></div>
		</td>	
		</tr>
		</xsl:if>
	
		
		<xsl:if test="abcd:Units/abcd:Unit/abcd:Gathering/abcd:Country">
		<tr>
		<td><b>Geographic Scope: Countries</b></td>
		<td><ul>
		<xsl:variable name="units" select='abcd:Units' />
		<xsl:for-each select="distinct-values($units/abcd:Unit/abcd:Gathering/abcd:Country/abcd:ISO3166Code)">
			<xsl:sort select="."/>
			<li>
				<xsl:value-of select="."/><xsl:variable name="isocode" select='.' /> <xsl:if test="$units/abcd:Unit/abcd:Gathering/abcd:Country/abcd:ISO3166Code[./text() eq $isocode]/../abcd:Name"> (<xsl:value-of select="replace(string-join(distinct-values($units/abcd:Unit/abcd:Gathering/abcd:Country/abcd:ISO3166Code[./text() eq $isocode]/../abcd:Name/text()),', '),', $','')"/>)</xsl:if>
			</li>
		</xsl:for-each>
		</ul>
		</td>	
		</tr>
		</xsl:if>
		
		<xsl:if test="abcd:Units/abcd:Unit/abcd:Gathering/abcd:SiteCoordinateSets/abcd:SiteCoordinates/abcd:CoordinatesLatLong">
		<tr>
		<td><b>Geographic Scope: Coordinates</b></td>
		<td>
		<span class="north">N: <xsl:value-of select="max(abcd:Units/abcd:Unit/abcd:Gathering/abcd:SiteCoordinateSets/abcd:SiteCoordinates/abcd:CoordinatesLatLong/abcd:LatitudeDecimal[./text() != '0']/string())" /></span><br />
		<span class="west">W: <xsl:value-of select="min(abcd:Units/abcd:Unit/abcd:Gathering/abcd:SiteCoordinateSets/abcd:SiteCoordinates/abcd:CoordinatesLatLong/abcd:LongitudeDecimal[./text() != '0']/string())" /></span>
		<span class="east">E: <xsl:value-of select="max(abcd:Units/abcd:Unit/abcd:Gathering/abcd:SiteCoordinateSets/abcd:SiteCoordinates/abcd:CoordinatesLatLong/abcd:LongitudeDecimal[./text() != '0']/string())" /></span><br />
		<span class="south">S: <xsl:value-of select="min(abcd:Units/abcd:Unit/abcd:Gathering/abcd:SiteCoordinateSets/abcd:SiteCoordinates/abcd:CoordinatesLatLong/abcd:LatitudeDecimal[./text() != '0']/string())" /></span>
		</td>	
		</tr>
		</xsl:if>
				
		<xsl:if test="count(abcd:Units/abcd:Unit/abcd:Gathering/abcd:DateTime/abcd:ISODateTimeBegin[./text() != '0'])+count(abcd:Units/abcd:Unit/abcd:Gathering/abcd:DateTime/abcd:ISODateTimeEnd[./text() != '0']) gt 0">
		<tr>
		<td><b>Temporal Scope</b></td>
		<td><xsl:value-of select="min((abcd:Units/abcd:Unit/abcd:Gathering/abcd:DateTime/abcd:ISODateTimeBegin[./text() != '0']/string(), abcd:Units/abcd:Unit/abcd:Gathering/abcd:DateTime/abcd:ISODateTimeEnd[./text() != '0']/string()))"/> &#x2012; <xsl:value-of select="max((abcd:Units/abcd:Unit/abcd:Gathering/abcd:DateTime/abcd:ISODateTimeBegin[./text() != '0']/string(), abcd:Units/abcd:Unit/abcd:Gathering/abcd:DateTime/abcd:ISODateTimeEnd[./text() != '0']/string()))"/></td>	
		</tr>
		</xsl:if>
		
		<tr>
		<td><b>Units</b></td>
		<td><div class="scroll-box"><ul>
		<xsl:for-each select="abcd:Units/abcd:Unit">
			<li><xsl:choose>
				<xsl:when test="abcd:RecordURI">
					<a><xsl:attribute name="href"><xsl:value-of select="abcd:RecordURI/text()"/></xsl:attribute><xsl:value-of select="abcd:UnitID"/> [<xsl:value-of select="abcd:Identifications/abcd:Identification/abcd:Result/abcd:TaxonIdentified/abcd:ScientificName/abcd:FullScientificNameString"/>]</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="abcd:UnitID"/> [<xsl:value-of select="abcd:Identifications/abcd:Identification/abcd:Result/abcd:TaxonIdentified/abcd:ScientificName/abcd:FullScientificNameString"/>]
				</xsl:otherwise>
			</xsl:choose></li>
		</xsl:for-each>
		</ul></div>
		</td>	
		</tr>
			
		</table>
		</div>
		</xsl:for-each>			
		</body>
		</html>
		</xsl:for-each>	
	</xsl:template>
</xsl:stylesheet>
