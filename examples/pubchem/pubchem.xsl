<?xml version="1.0" encoding="UTF-8"?>
<!--
    Example XSLT file to process a PubChem XML download and produce SciData formatted JSON-LD
    Example file found at https://pubchem.ncbi.nlm.nih.gov/rest/pug/assay/aid/243494/
    Stuart Chalk December 15, 2020 v2
    Stuart Chalk June 22, 2016 v1
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:pc="http://www.ncbi.nlm.nih.gov" exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output method="text"/>
    <xsl:variable name="ref" select="//pc:PC-AssayDescription_comment"/>
    <xsl:variable name="desc" select="//pc:PC-AssayDescription"/>
    <xsl:variable name="res" select="//pc:PC-AssayResults"/>
    <xsl:variable name="aid" select="$desc//pc:PC-ID_id"/>
    <xsl:variable name="results">
        <xsl:for-each select="$desc//pc:PC-AssayDescription_results/pc:PC-ResultType">
            <xsl:element name="tid">
                <xsl:attribute name="number"><xsl:value-of select="pc:PC-ResultType_tid"/></xsl:attribute>
                <xsl:attribute name="format"><xsl:value-of select="pc:PC-ResultType_type/@value"/></xsl:attribute>
                <xsl:value-of select="pc:PC-ResultType_name"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="data">
        <xsl:for-each select="$res/pc:PC-AssayResults_data">
            <datum>
                <xsl:for-each select="pc:PC-AssayData">
                    <xsl:element name="tid">
                        <xsl:attribute name="number"><xsl:value-of select="pc:PC-AssayData_tid"/></xsl:attribute>
                        <xsl:value-of select="pc:PC-AssayData_value/pc:PC-AssayData_value_sval"/><xsl:value-of select="pc:PC-AssayData_value/pc:PC-AssayData_value_fval"/>
                    </xsl:element>
                </xsl:for-each>
            </datum>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="version">
    	<xsl:choose>
    		<xsl:when test="$desc//pc:PC-AssayDescription_revision">
    			<xsl:value-of select="$desc//pc:PC-AssayDescription_revision"/>
    		</xsl:when>
    		<xsl:otherwise>1</xsl:otherwise>
    	</xsl:choose>
    </xsl:variable>
	<xsl:variable name="path" select="document-uri(/)"/>
    <xsl:variable name="file" select="tokenize($path, '/')[last()]"/>
    <xsl:variable name="id" select="tokenize($file, '\.')[position() = 1]"/>
    <xsl:variable name="base" select="concat('https://pubchem.ncbi.nlm.nih.gov/bioassay/',normalize-space($aid),'/')"/>
    <!-- Main processing -->
    <xsl:template match="/">
        <xsl:text>
        {
        "@context": [
            "https://stuchalk.github.io/scidata/contexts/scidata.jsonld",
            {
                "sdo": "https://stuchalk.github.io/scidata/ontology/scidata.owl#",
                "tgt": "https://stuchalk.github.io/scidata/ontology/target.owl#",
                "qudt": "https://qudt.org/vocab/unit/",
                "obo": "http://purl.obolibrary.org/obo/",
                "dct": "http://purl.org/dc/terms/",
                "xsd": "http://www.w3.org/2001/XMLSchema#"
            },
        </xsl:text>
        { "@base": "<xsl:value-of select="$base"/>" }
        ],
        "@id": "<xsl:value-of select="$base"/>",
        "generatedAt": "<xsl:value-of select="current-dateTime()"/>",
        "version": <xsl:value-of select="$version"/>,
        "@graph": {
        "@id": "<xsl:value-of select="$base"/>",
            "@type": "sdo:scientificData",
            "uid": "example_pubchem_<xsl:value-of select="$aid"/>",
            "title": "<xsl:value-of select="$desc/pc:PC-AssayDescription_name"/>",
            "description": "<xsl:value-of select="$desc//pc:PC-AssayDescription_description_E"/>",
            "publisher": "<xsl:value-of select="$desc//pc:PC-DBTracking_name"/>",
    	    "keywords": ["bioassay"],
            "permalink": "https://stuchalk.github.io/scidata/examples/pubchem/AID_<xsl:value-of select="$aid"/>_full.jsonld",
            "related": [
            "https://pubchem.ncbi.nlm.nih.gov/rest/pug/assay/aid/<xsl:value-of select="$aid"/>",
    	   <xsl:if test="$desc//pc:PC-XRefData">
    		<xsl:for-each select="$desc//pc:PC-XRefData">
    			<xsl:choose>
    				<xsl:when test="pc:PC-XRefData_pmid">
    					<xsl:value-of select="concat('&quot;https://www.ncbi.nlm.nih.gov/pubmed/',normalize-space(pc:PC-XRefData_pmid),'&quot;')"/>
    				</xsl:when>
    				<xsl:when test="pc:PC-XRefData_protein-gi">
    					"https://www.ncbi.nlm.nih.gov/protein/<xsl:value-of select="pc:PC-XRefData_protein-gi"/>"
    				</xsl:when>
    				<xsl:when test="pc:PC-XRefData_taxonomy">
    					"https://www.uniprot.org/taxonomy/<xsl:value-of select="pc:PC-XRefData_taxonomy"/>"
    				</xsl:when>
    				<xsl:when test="pc:PC-XRefData_dburl">
    					"<xsl:value-of select="pc:PC-XRefData_dburl"/>"
    				</xsl:when>
    				<xsl:when test="pc:PC-XRefData_asurl">
    					"<xsl:value-of select="pc:PC-XRefData_asurl"/>"
    				</xsl:when>
    			</xsl:choose>
    			<xsl:if test="position() != last()">,</xsl:if>
    		</xsl:for-each>
    	</xsl:if>
            ],
            "scidata": {
                "@id": "scidata/",
                "@type": "sdo:scientificData",
                "methodology": {
                    "@id": "methodology/",
                    "@type": "sdo:methodology",
                    "aspects": [{
                        "@id": "assay/1/",
                        "@type": "sdo:assay",
                        "url": "<xsl:value-of select="replace($desc//pc:PC-AssayDescription_assay-group_E,'PMID: ','https://www.ncbi.nlm.nih.gov/pubmed/')"/>"
                        <xsl:if test="$desc//pc:PC-CategorizedComment">,
                            <xsl:for-each select="$desc//pc:PC-CategorizedComment">
                                <xsl:if test="pc:PC-CategorizedComment_title='Assay Type'">
                                    "type": { "@value": "<xsl:value-of select="normalize-space(pc:PC-CategorizedComment_comment)"/>", "@type": "dct:type" }
                                </xsl:if>
                                <xsl:if test="pc:PC-CategorizedComment_title='Assay Data Source'">
                                    "source": "<xsl:value-of select="normalize-space(pc:PC-CategorizedComment_comment)"/>"
                                </xsl:if>
                                <xsl:if test="pc:PC-CategorizedComment_title='Target Type'">
                                    "target": "<xsl:value-of select="normalize-space(pc:PC-CategorizedComment_comment)"/>"
                                </xsl:if>
                                <xsl:if test="position() != last()">,</xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                    }]
                },
                "system": {
                    "@id": "system/",
                    "@type": "sdo:system",
                    "facets": [
    				<xsl:variable name="t" select="$desc//pc:PC-AssayTargetInfo"/>
    				<xsl:if test="$t">
    					<xsl:for-each select="$t">
    					{
    						"@id": "target/<xsl:value-of select="position()"/>/",
    					    "@type": "tgt:target"
    					    <xsl:if test="pc:PC-AssayTargetInfo_name">,
    						"name": "<xsl:value-of select="pc:PC-AssayTargetInfo_name"/>"
    						</xsl:if>
    						<xsl:if test="pc:PC-AssayTargetInfo_mol-id">,
    							"url": "https://www.ncbi.nlm.nih.gov/protein/<xsl:value-of select="normalize-space(pc:PC-AssayTargetInfo_mol-id)"/>"
    						</xsl:if>
    						<xsl:if test="pc:PC-AssayTargetInfo_molecule-type">,
    						"type": "<xsl:value-of select="pc:PC-AssayTargetInfo_molecule-type/@value"/>"
    						</xsl:if>
    						<xsl:if test="pc:PC-AssayTargetInfo_organism">,
    						"organism": "organism/<xsl:value-of select="position()"/>/"
    						</xsl:if>
    					}<xsl:if test="position() != last()">,</xsl:if>
    					</xsl:for-each>
    				</xsl:if>
    				<xsl:variable name="o" select="$t//pc:PC-AssayTargetInfo_organism"/>
    				<xsl:if test="$o">,
    					<xsl:for-each select="$o">
    						{
    						"@id": "organism/<xsl:value-of select="position()"/>/",
    					    "@type": "sdo:organism",
    					    <xsl:for-each select="pc:BioSource//pc:Dbtag">
    							<xsl:choose>
    								<xsl:when test="pc:Dbtag_db='taxon'">
    									"url": "http://www.uniprot.org/taxonomy/<xsl:value-of select="normalize-space(pc:Dbtag_tag)"/>"
    								</xsl:when>
    								<xsl:otherwise>
    									"<xsl:value-of select="pc:Dbtag_db"/>": "<xsl:value-of select="normalize-space(pc:Dbtag_tag)"/>"
    								</xsl:otherwise>
    							</xsl:choose>
    							<xsl:if test="position() != last()">,</xsl:if>
    						</xsl:for-each>
    						<xsl:if test="pc:BioSource//pc:Org-ref_orgname">,
    							"name": "<xsl:value-of select="pc:BioSource//pc:BinomialOrgName_genus"/>"
    						</xsl:if>
    						}
    					</xsl:for-each>
    				</xsl:if>
    				<xsl:variable name="s" select="$res//pc:PC-AssayResults_sid"/>
    				<xsl:if test="$s">,
    					<xsl:for-each select="$s">
    						{
    						   "@id": "substance/<xsl:value-of select="position()"/>/",
    					       "@type": "sdo:substance",
    					       "url": "https://pubchem.ncbi.nlm.nih.gov/substance/<xsl:value-of select="."/>"
    						}
    						<xsl:if test="position() != last()">,</xsl:if>
    					</xsl:for-each>
    				</xsl:if>
                    ]
                },
                "dataset": {
                    "@id": "dataset/",
                    "@type": "sdo:dataset",
                    <xsl:variable name="resmeta" select="$desc//pc:PC-AssayDescription_results"/>
    			     "datagroup": [
    			         <xsl:for-each select="$res">
    				{
    				<xsl:variable name="dg" select="concat('datagroup/',position(),'/')"/>
    				"@id": "<xsl:value-of select="$dg"/>",
    				"@type": "sdo:datagroup",
    				"scope#": "substance/<xsl:value-of select="position()"/>/",
    				"datapoints": [
    				<xsl:if test="$data">
    				    <xsl:for-each select="$data/datum">
    				        <xsl:variable name="datum" select="."/>
    				        <xsl:variable name="pos" select="position()"/>
    				        <xsl:variable name="dp" select="concat($dg,'datapoint/',$pos,'/')"/>
    				        {
    						"@id": "<xsl:value-of select="$dp"/>",
    						"@type": "sdo:datapoint",
    						"quantity": "<xsl:value-of select="$datum/tid[1]/text()"/>",
    				    	"outcome": "<xsl:value-of select="concat($res/pc:PC-AssayResults_outcome/@value,' ',$res/pc:PC-AssayResults_outcome)"/>",
    				        "value": {
    							"@id": "<xsl:value-of select="$dp"/>value/",
    							"@type": "sdo:value",
    							<xsl:for-each select="$results/tid[position()>1]">
    							    <xsl:variable name="tid" select="."/>
    							    <xsl:choose>
    							        <xsl:when test=".='Standard Relation'">
    							            "equality": "<xsl:value-of select="$datum/tid[@number=$tid/@number]"/>"
    							        </xsl:when>
    							        <xsl:when test=".='Standard Value'">
    							            "number": "<xsl:value-of select="$datum/tid[@number=$tid/@number]"/>"
    							        </xsl:when>
    							        <xsl:when test=".='Standard Units'">
    							            "unit": "<xsl:value-of select="$datum/tid[@number=$tid/@number]"/>"
    							        </xsl:when>
    							    </xsl:choose>
    							    <xsl:if test="position() != last()">,</xsl:if>
    							</xsl:for-each>
    							}
    						}
    						<xsl:if test="position() != last()">,</xsl:if>
    				    </xsl:for-each>
    					</xsl:if>
    					]
    				}
    				<xsl:if test="position() != last()">,</xsl:if>
    			</xsl:for-each>
    			         ]
    			    }
                }
            },
        <xsl:if test="$ref/pc:PC-AssayDescription_comment_E">
            "sources": [{
            "@id": "source/1/",
            "@type": "sdo:source",
            "type": "journal article",
            <xsl:variable name="citation">
                <xsl:for-each select="$ref/pc:PC-AssayDescription_comment_E">
                        <xsl:choose>
                            <xsl:when test="contains(.,'Journal:')">
                                <xsl:value-of select="replace(.,'Journal: ','')"/> 
                            </xsl:when>
                            <xsl:when test="contains(.,'Year:')">
                                <xsl:value-of select="concat(' (',replace(.,'Year: ',''))"/>)
                            </xsl:when>
                            <xsl:when test="contains(.,'Volume:')">
                                <xsl:value-of select="concat(' ',replace(.,'Volume: ',''),', ')"/>
                            </xsl:when>
                            <xsl:when test="contains(.,'First Page:')">
                                <xsl:value-of select="replace(.,'First Page: ','')"/>
                            </xsl:when>
                            <xsl:when test="contains(.,'Last Page:')">
                                <xsl:value-of select="concat('-',replace(.,'Last Page: ',''))"/>
                            </xsl:when>
                        </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="doi">
                <xsl:for-each select="$ref/pc:PC-AssayDescription_comment_E">
                    <xsl:choose>
                        <xsl:when test="contains(.,'DOI:')">
                            <xsl:value-of select="replace(.,'DOI: ','')"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            "citation": "<xsl:value-of select="normalize-space($citation)"/>",
            "doi": "<xsl:value-of select="$doi"/>"
            },{
          "@id": "source/2/",
          "@type": "sdo:source",
          "type": "database",
          "name": "PubChem @ the US National Library of Medicine",
          "url": "https://pubchem.ncbi.nlm.nih.gov/bioassay/<xsl:value-of select="$aid"/>"
            }]
            ,
            "rights": [{
            "@id": "rights/1/",
            "@type": "sdo:rights",
            "holder": "US National Library of Medicine",
            "license": "https://creativecommons.org/licenses/by-sa/4.0/"
            }]
        </xsl:if>
        }
    </xsl:template>
</xsl:stylesheet>