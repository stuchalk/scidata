<?xml version="1.0" encoding="UTF-8"?>
<!--
    Example XSLT file to process a DDB HTML page and produce SciData formatted JSON-LD
    Example file found at http://www.ddbst.com/en/EED/PCP/SFT_C3.php
    In order to process the HTML it needed to be corrected using PHP Tidy
    (http://php.net/manual/en/book.tidy.php) as the HTML was not valid HTML 5.
    Stuart Chalk June 22, 2016
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	version="2.0">
	<!-- http://www.ddbst.com/en/EED/PCP/SFT_C3.php -->
	<xsl:output method="text"/>
	<xsl:variable name="meta" select="//meta"/>
	<xsl:variable name="body" select="//body"/>
	<xsl:variable name="t" select="tokenize($body/h1,' of ')"/>
	<xsl:variable name="prop" select="$t[1]"/>
	<xsl:variable name="id" select="$t[2]"/>
	<xsl:variable name="chem" select="$body/table[1]/tbody"/>
	<xsl:variable name="data" select="$body/table[3]/tbody"/>
	<xsl:variable name="refs" select="$body/table[4]/tbody"/>
	<xsl:variable name="path" select="document-uri(/)"/>
	<xsl:variable name="file" select="tokenize($path, '/')[last()]"/>
	
	<!-- Main processing -->
	<xsl:template match="/">
		<xsl:text>
        {
        "@context": [
            "https://stuchalk.github.io/scidata/contexts/scidata.jsonld",
            {
                "sci": "http://stuchalk.github.io/scidata/ontology/scidata.owl#",
                "qudt": "http://www.qudt.org/qudt/owl/1.0.0/unit.owl#",
                "obo": "http://purl.obolibrary.org/obo/",
                "dc": "http://purl.org/dc/terms/",
                "xsd": "http://www.w3.org/2001/XMLSchema#"
            },
        </xsl:text>
		{ "@base": "http://www.ddbst.com/en/EED/PCP/<xsl:value-of select="replace($file,'html','php')"/>/" }
		],
		"@id": "",
		"uid": "scidata:example:ddb:<xsl:value-of select="lower-case($id)"/>",
		"title": "<xsl:value-of select="$body/h1"/>",
		"description": "<xsl:value-of select="$meta[@name='description']/@content"/>",
		"publisher": "<xsl:value-of select="$meta[@name='author']/@content"/>",
		"keywords": ["DDB","<xsl:value-of select="$id"/>","<xsl:value-of select="$prop"/>"],
		"permalink": "http://stuchalk.github.io/scidata/example/ddb/ddb.jsonld",
		"related": [
		"http://www.ddbst.com/en/EED/PCP/<xsl:value-of select="replace($file,'html','php')"/>"
		],
		"scidata": {
			"@id": "scidata/",
			"@type": "sci:scientificData",
			"system": {
				"@id": "system/",
				"@type": "sci:system",
				"facets": [
					<xsl:variable name="cols" select="$chem/tr[1]/th"/>
					<xsl:for-each select="$chem/tr">
						<xsl:if test="position()>1">
							{
								"@id": "compound/<xsl:value-of select="position()-1"/>/",
								"@type": "sci:compound",
								<xsl:for-each select="td">
									<xsl:variable name="i" select="position()"/>
									<xsl:variable name="label">
									<xsl:choose>
										<xsl:when test="$cols[$i]='Name'">name</xsl:when>
										<xsl:when test="$cols[$i]='CAS Registry Number'">casrn</xsl:when>
										<xsl:when test="$cols[$i]='Molar Mass'">molweight</xsl:when>
										<xsl:when test="$cols[$i]='Formula'">formula</xsl:when>
									</xsl:choose>
									</xsl:variable>
									"<xsl:value-of select="$label"/>": "<xsl:value-of select="."/>"
									<xsl:if test="$i != last()">,</xsl:if>
								</xsl:for-each>
							}
						</xsl:if>
						<xsl:if test="position() != last() and position() != 1">,</xsl:if>
					</xsl:for-each>,
					<!-- Conditions -->
					<xsl:variable name="temps" select="distinct-values($data/tr/td[1][.!=''])"/>
					<xsl:variable name="ps" select="distinct-values($data/tr/td[2][.!=''])"/>
	   <xsl:variable name="ps" select="distinct-values($data/tr/td[2][.!=''])"/>
	   <xsl:for-each select="$temps">
					{
						<xsl:variable name="t" select="."/>
						"@id": "condition/<xsl:value-of select="position()"/>/",
						"@type": "sci:condition",
						"scope": "chemical/1/",
						"quantity": "temperature",
						"property": "System temperature",
						"value": {
							"@id": "condition/<xsl:value-of select="position()"/>/value/",
							"@type": "sci:value",
							"number": <xsl:value-of select="number($t)"/>,
							"unitref": "qudt:Kelvin"
						}
					}
					<xsl:if test="position() != last()">,</xsl:if>
					</xsl:for-each>
					,
					<xsl:for-each select="$ps">
					{
						<xsl:variable name="p" select="."/>
						"@id": "condition/<xsl:value-of select="position()+count($temps)"/>/",
						"@type": "sci:condition",
						"scope": "chemical/1/",
						"quantity": "pressure",
						"property": "System pressure",
						"value": {
						"@id": "condition/<xsl:value-of select="position()"/>/value/",
							"@type": "sci:value",
							"number": <xsl:value-of select="number($p)"/>,
							"unitref": "qudt:KiloPascal"
						}
					}
					<xsl:if test="position() != last()">,</xsl:if>
					</xsl:for-each>
				]
			},
			"dataset": [{
				"@id": "dataset/1/",
				"@type": "sci:dataset",
				"scope": "compound/1/",
				"datagroup": [
				<xsl:variable name="refids" select="distinct-values($data/tr/td[5])"/>
				<xsl:for-each select="$refids">
					{
					<xsl:variable name="refid" select="."/>
					"@id": "datagroup/<xsl:value-of select="position()"/>/",
					"@type": "sci:datagroup",
					"reference": "reference/<xsl:value-of select="$refid"/>/",
					"datapoints": [
						<xsl:for-each select="$data/tr/td[3][../td[5]=$refid]">
							"datapoint/<xsl:value-of select="count(../preceding-sibling::node())"/>/"
							<xsl:if test="position() != last()">,</xsl:if>
						</xsl:for-each>
						]
					}
					<xsl:if test="position() != last()">,</xsl:if>
				</xsl:for-each>
				],
				"datapoint": [
				<xsl:for-each select="$data/tr">
					<xsl:if test="position()>1">
					{
						<xsl:variable name="pos" select="position()-1"/>
						"@id": "datapoint/<xsl:value-of select="$pos"/>/",
						"@type": "sci:datapoint",
						"quantity": "force",
						"property": "<xsl:value-of select="$prop"/>",
						"conditions": [
							<xsl:variable name="t" select="td[1]/text()"/>
							<xsl:for-each select="$temps">
								<xsl:if test=".=$t">
									"condition/<xsl:value-of select="position()"/>/"
								</xsl:if>
							</xsl:for-each>
							<xsl:variable name="p" select="td[2]/text()"/>
							<xsl:for-each select="$ps">
								<xsl:if test=".=$p">,
									"condition/<xsl:value-of select="position()+count($temps)"/>/"
								</xsl:if>
						</xsl:for-each>
						],
						"value": {
							"@id": "datapoint/<xsl:value-of select="$pos"/>/value/",
							"@type": "sci:value",
							"number": <xsl:value-of select="td[3]"/>,
							"unitref": "qudt:MilliNewtonPerMeter"
						}
					}
					</xsl:if>
					<xsl:if test="position() != last() and position() != 1">,</xsl:if>
				</xsl:for-each>
				]
			}]
		},
		"references": [
			<xsl:for-each select="$refs/tr">
				<xsl:if test="position()>1">
					{
						"@id": "reference/<xsl:value-of select="td[1]"/>/",
						"@type": "dc:source",
						"citation": "<xsl:value-of select="replace(replace(td[2],'\n',' '),'\s+',' ')"/>"
					}
					<xsl:if test="position() != last()">,</xsl:if>
				</xsl:if>
			</xsl:for-each>
		]
		}
	</xsl:template>
</xsl:stylesheet>