<?xml version="1.0" encoding="UTF-8"?>
<!--
    Example XSLT file to process a PubChem XML download and produce SciData formatted JSON-LD
    Example file found at https://pubchem.ncbi.nlm.nih.gov/rest/pug/assay/aid/243494/
    Stuart Chalk June 22, 2016
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:pc="http://www.ncbi.nlm.nih.gov" exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output method="text"/>
    <xsl:variable name="desc" select="//pc:PC-AssayDescription"/>
    <xsl:variable name="res" select="//pc:PC-AssayResults"/>
    <xsl:variable name="aid" select="$desc//pc:PC-ID_id"/>
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
    <xsl:variable name="base" select="concat('http://pubchem.ncbi.nlm.nih.gov/bioassay/',normalize-space($aid),'/')"/>
    <!-- Main processing -->
    <xsl:template match="/">
        <xsl:text>
        {
        "@context": [
            "https://stuchalk.github.io/scidata/contexts/scidata.jsonld",
            {
                "sci": "http://stuchalk.github.io/scidata/ontology/scidata.owl#",
                "tgt": "http://stuchalk.github.io/scidata/ontology/target/target.owl#",
                "qudt": "http://www.qudt.org/qudt/owl/1.0.0/unit.owl#",
                "obo": "http://purl.obolibrary.org/obo/",
                "dc": "http://purl.org/dc/terms/",
                "xsd": "http://www.w3.org/2001/XMLSchema#"
            },
        </xsl:text>
        { "@base": "<xsl:value-of select="$base"/>" }
        <xsl:text>
        ],
        "@id": "",
        </xsl:text>
        "uid": "scidata:example:pubchem:<xsl:value-of select="$aid"/>",
        "title": "<xsl:value-of select="$desc/pc:PC-AssayDescription_name"/>",
        "description": "<xsl:value-of select="$desc//pc:PC-AssayDescription_description_E"/>",
        "publisher": "<xsl:value-of select="$desc//pc:PC-DBTracking_name"/>",
    	"version": <xsl:value-of select="$version"/>,
        "keywords": ["bioassay"],
        "permalink": "http://stuchalk.github.io/scidata/example/pubchem/AID_<xsl:value-of select="$aid"/>_full.jsonld",
        "related": [
        "https://pubchem.ncbi.nlm.nih.gov/rest/pug/assay/aid/<xsl:value-of select="$aid"/>",
    	<xsl:if test="$desc//pc:PC-XRefData">
    		<xsl:for-each select="$desc//pc:PC-XRefData">
    			<xsl:choose>
    				<xsl:when test="pc:PC-XRefData_pmid">
    					<xsl:value-of select="concat('&quot;http://www.ncbi.nlm.nih.gov/pubmed/',normalize-space(pc:PC-XRefData_pmid),'&quot;')"/>
    				</xsl:when>
    				<xsl:when test="pc:PC-XRefData_protein-gi">
    					"http://www.ncbi.nlm.nih.gov/protein/<xsl:value-of select="pc:PC-XRefData_protein-gi"/>"
    				</xsl:when>
    				<xsl:when test="pc:PC-XRefData_taxonomy">
    					"http://www.uniprot.org/taxonomy/<xsl:value-of select="pc:PC-XRefData_taxonomy"/>"
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
            "@type": "sci:scientificData",
            "methodology": {
                "@id": "methodology/",
                "@type": "sci:methodology",
                "aspects": [
                    {
                        "@id": "assay/1/",
                        "url": "<xsl:value-of select="replace($desc//pc:PC-AssayDescription_assay-group_E,'PMID: ','http://www.ncbi.nlm.nih.gov/pubmed/')"/>"
                        <xsl:if test="$desc//pc:PC-CategorizedComment">,
                            <xsl:for-each select="$desc//pc:PC-CategorizedComment">
                                <xsl:if test="pc:PC-CategorizedComment_title='Assay Type'">
                                    "type": { "@value": "<xsl:value-of select="normalize-space(pc:PC-CategorizedComment_comment)"/>", "@type": "dc:type" }
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
                    }
                ]
             },
            "system": {
                "@id": "system/",
                "@type": "sci:methodology",
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
    						"url": "http://www.ncbi.nlm.nih.gov/protein/<xsl:value-of select="pc:PC-AssayTargetInfo_mol-id"/>"
    						</xsl:if>
    						<xsl:if test="pc:PC-AssayTargetInfo_molecule-type">,
    						"type": { "@value": "<xsl:value-of select="pc:PC-AssayTargetInfo_molecule-type/@value"/>", "@type": "dc:type" }
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
    					    "@type": "sci:organism",
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
    					       "@type": "sci:substance",
    					       "url": "http://pubchem.ncbi.nlm.nih.gov/substance/<xsl:value-of select="."/>"
    						}
    						<xsl:if test="position() != last()">,</xsl:if>
    					</xsl:for-each>
    				</xsl:if>
                ]
             },
            "dataset": {
                "@id": "dataset/",
                "@type": "sci:dataset",
                <xsl:variable name="resmeta" select="$desc//pc:PC-AssayDescription_results"/>
    			"datagroup": [
    			<xsl:for-each select="$res">
    				{
    				<xsl:variable name="dg" select="concat('datagroup/',position(),'/')"/>
    				"@id": "<xsl:value-of select="$dg"/>",
    				"@type": "sci:datagroup",
    				"scope": "substance/<xsl:value-of select="position()"/>/",
    				"outcome": "<xsl:value-of select="pc:PC-AssayResults_outcome/@value"/>",
    				"datapoint": [
    				<xsl:for-each select="pc:PC-AssayResults_data/pc:PC-AssayData">
    						{
    						<xsl:variable name="dp" select="concat($dg,'datapoint/',position(),'/')"/>
    						<xsl:variable name="tid" select="pc:PC-AssayData_tid"/>
    						<xsl:variable name="meta" select="$desc//*[pc:PC-ResultType_tid=$tid]"/>
    						"@id": "<xsl:value-of select="$dp"/>",
    						"@type": "sci:datapoint",
    						"quantity": "descriptor",
    						"property": "<xsl:value-of select="$meta/pc:PC-ResultType_name"/>",
    						"value": {
    							"@id": "<xsl:value-of select="$dp"/>value",
    							"@type": "sci:value",
    							<xsl:choose>
    								<xsl:when test="$meta/pc:PC-ResultType_type[@value='string']">
    									"text": "<xsl:value-of select="normalize-space(pc:PC-AssayData_value/pc:PC-AssayData_value_sval)"/>"
    								</xsl:when>
    								<xsl:when test="$meta/pc:PC-ResultType_type[@value='float']">
    									"number": <xsl:value-of select="normalize-space(pc:PC-AssayData_value/pc:PC-AssayData_value_fval)"/>
    									<xsl:if test="$meta/pc:PC-ResultType_sunit">,
    										"unit": "<xsl:value-of select="$meta/pc:PC-ResultType_sunit"/>"
    									</xsl:if>
    								</xsl:when>
    							</xsl:choose>
    							}
    						}
    						<xsl:if test="position() != last()">,</xsl:if>
    					</xsl:for-each>
    					]
    				}
    				<xsl:if test="position() != last()">,</xsl:if>
    			</xsl:for-each>
    			]
    			}
            }
        }
    </xsl:template>
</xsl:stylesheet>