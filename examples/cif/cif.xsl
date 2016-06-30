<?xml version="1.0" encoding="UTF-8"?>
<!--
    Example XSLT file to process a CIF file and produce SciData formatted JSON-LD
    Example files found at http://www.crystallography.net
    In order to process a file supply the 'id' paramteter to the XSLT processor along with an empty XML document
    i.e.  providing id=1000118 will process the file at http://www.crystallography.net/cod/1000118.cif
    In this example some example symmetry, cell, journal and chemical CIF file dictionary terms have been included
    This file would need to be expanded significantly to cover even all the core CIF dictionary terms
    Stuart Chalk June 22, 2016
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs" version="2.0">
	<!-- http://www.crystallography.net/cod/<id>.cif -->
	<xsl:param name="id"/>
	<xsl:variable name="url" select="concat('http://www.crystallography.net/cod/',$id,'.cif')"/>
	<xsl:variable name="cif" select="unparsed-text($url)" as="xs:string"/>
	<xsl:output method="text"/>
	<!-- Main processing -->
	<xsl:template match="/">
	    <xsl:variable name="apos">'</xsl:variable>
	    <xsl:variable name="lines" select="tokenize($cif,'\n_')"/>
		<xsl:variable name="vars">
			<xsl:for-each select="$lines">
				<xsl:variable name="lastchar" select="substring(.,string-length(.))"/>
				<xsl:variable name="line">
					<xsl:choose>
						<xsl:when test="$lastchar='&#10;'">
							<xsl:value-of select="substring(.,1,(string-length(.)-1))"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="replace(.,'\nloop_','')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
			    <xsl:variable name="chunks" select="count(tokenize($line,'\n'))"/>
				<xsl:variable name="pos" select="position()"/>
			    <xsl:if test="contains(.,'loop_')">
					<var>
						<row><xsl:value-of select="position()"/></row>
						<loop>yes</loop>
					</var>
				</xsl:if>
				<xsl:choose>
				    <xsl:when test="contains($line,'#$Revision:')">
				        <xsl:analyze-string select="$line" regex="\s+(\d{{6}})\s+">
				            <xsl:matching-substring>
				                <revision><xsl:value-of select="regex-group(1)"/></revision>
				            </xsl:matching-substring>
				        </xsl:analyze-string>
				    </xsl:when>
				    <xsl:when test="contains($line,'#')"/>
					<xsl:when test="contains($line,'&#10;')">
						<xsl:variable name="parts" select="tokenize($line,'\n')"/>
						<var>
							<row><xsl:value-of select="position()"/></row>
						    <name><xsl:value-of select="$parts[1]"/></name>
						    <cols>
						        <xsl:choose>
						            <xsl:when test="contains($parts[2],$apos)">1</xsl:when>
						            <xsl:otherwise>
						                <xsl:value-of select="count(tokenize($parts[2],' '))"/>
						            </xsl:otherwise>
						        </xsl:choose>
						    </cols>
						    <xsl:choose>
						            <xsl:when test="$parts[2]=';'">
						                <value>
						                    <xsl:for-each select="3 to (count($parts)-1)">
						                        <xsl:variable name="p" select="."/>
						                        <xsl:value-of select="$parts[$p]"/>
						                        <xsl:if test="position() != last()"> </xsl:if>
						                    </xsl:for-each>
						                </value>
						            </xsl:when>
						            <xsl:otherwise>
						                <values>
						                      <xsl:for-each select="2 to count($parts)">
						                          <xsl:variable name="i" select="."/>
						                          <line><xsl:value-of select="$parts[$i]"/></line>
						                      </xsl:for-each>
						                </values>
  						        </xsl:otherwise>
					       </xsl:choose>
					   </var>
					</xsl:when>
				    <xsl:when test="not(contains($line,'&#10;')) and contains($line,$apos)">
				        <xsl:variable name="parts" select="tokenize($line,' ''')"/>
				        <xsl:variable name="cols">
				            <xsl:choose>
				                <xsl:when test="contains($parts[2],$apos)">1</xsl:when>
				                <xsl:otherwise>
				                    <xsl:value-of select="count(tokenize($parts[2],' '))"/>
				                </xsl:otherwise>
				            </xsl:choose>
				        </xsl:variable>
				        <var>
				            <row><xsl:value-of select="position()"/></row>
				            <name><xsl:value-of select="replace($parts[1],' ','')"/></name>
				            <value><xsl:value-of select="replace($parts[2],$apos,'')"/></value>		
				        </var>
				    </xsl:when>
				    <xsl:when test="not(contains($line,'&#10;')) and contains($line,' ')">
					    <xsl:variable name="parts" select="tokenize($line,'\s+')"/>
					    <xsl:variable name="cols">
					       <xsl:choose>
					           <xsl:when test="contains($parts[2],$apos)">1</xsl:when>
					           <xsl:otherwise>
					               <xsl:value-of select="count(tokenize($parts[2],' '))"/>
					           </xsl:otherwise>
					       </xsl:choose>
					    </xsl:variable>
					    <var>
						    <row><xsl:value-of select="position()"/></row>
						    <name><xsl:value-of select="$parts[1]"/></name>
					        <value><xsl:value-of select="$parts[2]"/></value>		
						</var>
					</xsl:when>
				    <xsl:when test="not(contains($line,'&#10;')) and not(contains($line,' '))">
				        <var>
				        	<row><xsl:value-of select="position()"/></row>
				            <name><xsl:value-of select="$line"/></name>
				        </var>
				    </xsl:when>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
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
	    <xsl:value-of select="concat('{&quot;@base&quot;: &quot;http://www.crystallography.net/cod/',normalize-space($id),'.cif/&quot;}')"/>
	    ],
	    "@id": "",
	    "uid": "scidata:example:cif:<xsl:value-of select="$id"/>",
	    <xsl:variable name="title" select="replace($vars/var/value[../name/text()='publ_section_title'],';','')"/>
	    "title": "<xsl:value-of select="$title"/>",
	    "description": "Crystallographic Information File of <xsl:value-of select="$vars/var/value[../name/text()='chemical_name_systematic']"/>",
	    "publisher": "Crystallography Open Database (COD)",
	    "author": [
	    <xsl:variable name="aus" select="$vars/var/values[../name/text()='publ_author_name']"/>
	    <xsl:for-each select="$aus/line">
	        {
	            "@id": "author/<xsl:value-of select="position()"/>/",
	            "@type": "dc:creator",
	            "name": "<xsl:value-of select="replace(.,$apos,'')"/>"
	        }
	        <xsl:if test="position() != last()">,</xsl:if>
	    </xsl:for-each>
	    ],
	    "version": <xsl:value-of select="$vars/revision"/>,
	    "keywords": ["CIF File","Crystal Structure"],
	    "permalink": "http://stuchalk.github.io/scidata/example/cif.<xsl:value-of select="$id"/>.jsonld",
	    "related": [
	    "http://www.crystallography.net/cod/<xsl:value-of select="$id"/>.html"
	    ],
	    "scidata": {
	       "@id": "scidata/",
	       "system": {
	           "@id": "system/",
	           "aspects": [
	               {
	                   "@id": "chemical/1/",
	                   "@type": "sci:chemical",
	                   "chemical_name_systematic": "<xsl:value-of select="$vars/var/value[../name/text()='chemical_name_systematic']"/>",
	                   "chemical_formula_structural": "<xsl:value-of select="$vars/var/value[../name/text()='chemical_formula_structural']"/>",
	                   "chemical_formula_sum": "<xsl:value-of select="$vars/var/value[../name/text()='chemical_formula_sum']"/>"
	               },
	               {
	                   "@id": "chemicalsystem/1/",
	                   "@type": "sci:chemicalsystem",
	                   <xsl:variable name="ox" select="$vars/var[name/text()='atom_type_oxidation_number']"/>
	                   <xsl:variable name="oxcols" select="$ox/cols"/>
	                   <xsl:variable name="data" select="$ox/values"/>
	                   <xsl:variable name="oxstart" select="$ox/row - $oxcols"/>
	                   "atoms": [
	                   <xsl:for-each select="$data/line">
                           {
                           "@id": "atom/<xsl:value-of select="position()"/>/",
	                       "source": "chemical/1/",
	                       <xsl:variable name="vals" select="tokenize(.,' ')"/>	                      
	                       <xsl:for-each select="$vals">
	                           <xsl:variable name="i" select="$oxstart+position()"/>
	                           "<xsl:value-of select="$vars/var/name[../row/text()=$i]"/>": "<xsl:value-of select="."/>"
	                           <xsl:if test="position() != last()">,</xsl:if>
	                       </xsl:for-each>
	                       }
	                       <xsl:if test="position() != last()">,</xsl:if>
	                   </xsl:for-each>
	                   ]
	               }
	           ]
	       },
	       "dataset": {
	           "@id": "dataset/1/",
	           "datagroup": [
	               {
	                   "@id": "datagroup/1/",
	                   "@type": "sci:datagroup",
	                   "name": "space group",
	                   "url": "http://www.iucr.org/__data/iucr/cifdic_html/1/cif_core.dic/Cspace_group.html",
	                   "datapoints": [
	                       "datapoint/1/"
	                   ]
	               }, 
	               {
	                   "@id": "datagroup/2/",
	                   "@type": "sci:datagroup",
	                   "name": "symmetry",
	                   "url": "http://www.iucr.org/__data/iucr/cifdic_html/1/cif_core.dic/Csymmetry.html",
	                   "datapoints": [
	                       "datapoint/2/",
	                       "datapoint/3/",
	                       "datapoint/4/",
	                       "datapoint/5/",
	                       "datapoint/6/"
	                   ]
	               },
	               {
	                   "@id": "datagroup/3/",
	                   "@type": "sci:datagroup",
	                   "name": "cell",
	                   "url": "http://www.iucr.org/__data/iucr/cifdic_html/1/cif_core.dic/Ccell.html",
	                   "datapoints": [
	                       "datapoint/7/",
	                       "datapoint/8/",
	                       "datapoint/9/",
	                       "datapoint/10/",
	                       "datapoint/11/",
	                       "datapoint/12/",
	                       "datapoint/13/",
	                       "datapoint/14/"
	                   ]
	               }
	           ],
	           "datapoint": [
	               {
	                   "@id": "datapoint/1/",
	                   "@type": "sci:datapoint",
	                   "url": "http://www.iucr.org/__data/iucr/cifdic_html/1/cif_core.dic/Ispace_group_IT_number.html",
	                   "quantity": "space group descriptor",
	                   "property": "space_group_IT_number",
	                   "value": {
	                       "@id": "datapoint/1/value/",
	                       "@type": "sci:value",
	                       "text": "<xsl:value-of select="$vars/var/value[../name/text()='space_group_IT_number']"/>"
	                   }
	               },
	               {
	                   "@id": "datapoint/2/",
	                   "@type": "sci:datapoint",
	                   "url": "http://www.iucr.org/__data/iucr/cifdic_html/1/cif_core.dic/Isymmetry_cell_setting.html",
	                   "quantity": "symmetry descriptor",
	                   "property": "symmetry_cell_setting",
	                   "value": {
	                       "@id": "datapoint/2/value/",
	                       "@type": "sci:value",
	                       "text": "<xsl:value-of select="$vars/var/value[../name/text()='symmetry_cell_setting']"/>"
	                   }
	               },
	               {
	                   "@id": "datapoint/3/",
	                   "@type": "sci:datapoint",
	                   "url": "http://www.iucr.org/__data/iucr/cifdic_html/1/cif_core.dic/Isymmetry_Int_Tables_number.html",
	                   "quantity": "symmetry descriptor",
	                   "property": "symmetry_Int_Tables_number",
	                   "value": {
	                       "@id": "datapoint/3/value/",
	                       "@type": "sci:value",
	                       "text": "<xsl:value-of select="$vars/var/value[../name/text()='symmetry_Int_Tables_number']"/>"
	                   }
	               },
	               {
	                   "@id": "datapoint/4/",
	                   "@type": "sci:datapoint",
	                   "url": "http://www.iucr.org/__data/iucr/cifdic_html/1/cif_core.dic/Isymmetry_space_group_name_Hall.html",
	                   "quantity": "symmetry descriptor",
	                   "property": "symmetry_space_group_name_Hall",
	                   "value": {
	                       "@id": "datapoint/4/value/",
	                       "@type": "sci:value",
	                       "text": "<xsl:value-of select="$vars/var/value[../name/text()='symmetry_space_group_name_Hall']"/>"
	                   }
	               },
	               {
	                   "@id": "datapoint/5/",
	                   "@type": "sci:datapoint",
	                   "url": "http://www.iucr.org/__data/iucr/cifdic_html/1/cif_core.dic/Isymmetry_space_group_name_H-M.html",
	                   "quantity": "symmetry descriptor",
	                   "property": "symmetry_space_group_name_H-M",
	                   "value": {
	                       "@id": "datapoint/5/value/",
	                       "@type": "sci:value",
	                       "text": "<xsl:value-of select="$vars/var/value[../name/text()='symmetry_space_group_name_H-M']"/>"
	                   }
	               },
	               {
	                   "@id": "datapoint/6/",
	                   "@type": "sci:datapoint",
	                   "url": "http://www.iucr.org/__data/iucr/cifdic_html/1/cif_core.dic/Isymmetry_equiv_pos_as_xyz.html",
	                   "quantity": "symmetry descriptor",
	                   "property": "symmetry_equiv_pos_as_xyz",
	                   "valuearray": {
	                       "@id": "datapoint/6/valuearray/",
	                       "@type": "sci:valuearray",
	                       "textarray": [
	                               <xsl:variable name="xyz" select="$vars/var/values[../name/text()='symmetry_equiv_pos_as_xyz']"/>
	                               <xsl:for-each select="$xyz/line">
	                               "<xsl:value-of select="."/>"
	                               <xsl:if test="position() != last()">,</xsl:if>
	                               </xsl:for-each>
	                       ]
	                   }
	               },
	               {
	                   "@id": "datapoint/7/",
	                   "@type": "sci:datapoint",
	                   "url": "http://www.iucr.org/__data/iucr/cifdic_html/1/cif_core.dic/Icell_angle_.html",
	                   "quantity": "plain angle",
	                   "property": "cell_angle_alpha",
	                   "value": {
	                       "@id": "datapoint/7/value/",
	                       "@type": "sci:value",
	                       <xsl:variable name="val" select="$vars/var/value[../name/text()='cell_angle_alpha']"/>
	                       <xsl:choose>
	                           <xsl:when test="contains($val,'(')">
	                               <xsl:variable name="p" select="tokenize($val,'(')"/>
	                               <xsl:variable name="dp" select="tokenize($p[1],'\.')"/>    
	                               "number": <xsl:value-of select="$p[1]"/>,
	                               "error": 0.<xsl:for-each select="1 to string-length($dp[2])">0</xsl:for-each><xsl:value-of select="replace($p[2],'\)','')"/>
	                           </xsl:when>
	                           <xsl:otherwise>
	                           "number": <xsl:value-of select="$val"/>
	                           </xsl:otherwise>
	                       </xsl:choose>,
	                       "unitref": "qudt:DegreeAngle"
	                   }
	               },
	               {
	                   "@id": "datapoint/8/",
	                   "@type": "sci:datapoint",
	                   "url": "http://www.iucr.org/__data/iucr/cifdic_html/1/cif_core.dic/Icell_angle_.html",
	                   "quantity": "plain angle",
	                   "property": "cell_angle_beta",
	                   "value": {
	                       "@id": "datapoint/8/value/",
	                       "@type": "sci:value",
	                       <xsl:variable name="val" select="$vars/var/value[../name/text()='cell_angle_beta']"/>
	                       <xsl:choose>
	                           <xsl:when test="contains($val,'(')">
	                               <xsl:variable name="p" select="tokenize($val,'\(')"/>
	                               <xsl:variable name="dp" select="tokenize($p[1],'\.')"/>    
	                               "number": <xsl:value-of select="$p[1]"/>,
	                               "error": 0.<xsl:for-each select="1 to string-length($dp[2])">0</xsl:for-each><xsl:value-of select="replace($p[2],'\)','')"/>
	                           </xsl:when>
	                           <xsl:otherwise>
	                               "number": <xsl:value-of select="$val"/>
	                           </xsl:otherwise>
	                       </xsl:choose>,
	                       "unitref": "qudt:DegreeAngle"
	                   }
	               },
   	               {
	                   "@id": "datapoint/9/",
	                   "@type": "sci:datapoint",
	                   "url": "http://www.iucr.org/__data/iucr/cifdic_html/1/cif_core.dic/Icell_angle_.html",
	                   "quantity": "plain angle",
	                   "property": "cell_angle_gamma",
	                   "value": {
	                       "@id": "datapoint/9/value/",
	                       "@type": "sci:value",
	                       <xsl:variable name="val" select="$vars/var/value[../name/text()='cell_angle_gamma']"/>
	                       <xsl:choose>
	                           <xsl:when test="contains($val,'(')">
	                               <xsl:variable name="p" select="tokenize($val,'\(')"/>
	                               <xsl:variable name="dp" select="tokenize($p[1],'\.')"/>    
	                               "number": <xsl:value-of select="$p[1]"/>,
	                               "error": 0.<xsl:for-each select="1 to string-length($dp[2])">0</xsl:for-each><xsl:value-of select="replace($p[2],'\)','')"/>
	                           </xsl:when>
	                           <xsl:otherwise>
	                               "number": <xsl:value-of select="$val"/>
	                           </xsl:otherwise>
	                       </xsl:choose>,
	                       "unitref": "qudt:DegreeAngle"
	                   }
	               },
	               {
	                   "@id": "datapoint/10/",
	                   "@type": "sci:datapoint",
	                   "url": "http://www.iucr.org/__data/iucr/cifdic_html/1/cif_core.dic/Icell_formula_units_Z.html",
	                   "quantity": "count",
	                   "property": "cell_formula_units_Z",
	                   "value": {
	                       "@id": "datapoint/10/value/",
	                       "@type": "sci:value",
	                       <xsl:variable name="val" select="$vars/var/value[../name/text()='cell_formula_units_Z']"/>
	                       <xsl:choose>
	                           <xsl:when test="contains($val,'(')">
	                               <xsl:variable name="p" select="tokenize($val,'(')"/>
	                               <xsl:variable name="dp" select="tokenize($p[1],'\.')"/>    
	                               "number": <xsl:value-of select="$p[1]"/>,
	                               "error": 0.<xsl:for-each select="1 to string-length($dp[2])">0</xsl:for-each><xsl:value-of select="replace($p[2],'\)','')"/>
	                           </xsl:when>
	                           <xsl:otherwise>
	                               "number": <xsl:value-of select="$val"/>
	                           </xsl:otherwise>
	                       </xsl:choose>
	                   }
	               },
	               {
	                   "@id": "datapoint/11/",
	                   "@type": "sci:datapoint",
	                   "url": "http://www.iucr.org/__data/iucr/cifdic_html/1/cif_core.dic/Icell_length_.html",
	                   "quantity": "length",
	                   "property": "cell_length_a",
	                   "value": {
	                       "@id": "datapoint/11/value/",
	                       "@type": "sci:value",
	                       <xsl:variable name="val" select="$vars/var/value[../name/text()='cell_length_a']"/>
	                       <xsl:choose>
	                           <xsl:when test="contains($val,'(')">
	                               <xsl:variable name="p" select="tokenize($val,'\(')"/>
	                               <xsl:variable name="dp" select="tokenize($p[1],'\.')"/>    
	                               "number": <xsl:value-of select="$p[1]"/>,
	                               "error": 0.<xsl:for-each select="1 to string-length($dp[2])">0</xsl:for-each><xsl:value-of select="replace($p[2],'\)','')"/>
	                           </xsl:when>
	                           <xsl:otherwise>
	                               "number": <xsl:value-of select="$val"/>
	                           </xsl:otherwise>
	                       </xsl:choose>,
	                       "unitref": "qudt:Angstrom"
	                   }
	               },
	               {
	                   "@id": "datapoint/12/",
	                   "@type": "sci:datapoint",
	                   "url": "http://www.iucr.org/__data/iucr/cifdic_html/1/cif_core.dic/Icell_length_.html",
	                   "quantity": "length",
	                   "property": "cell_length_b",
	                   "value": {
	                       "@id": "datapoint/12/value/",
	                       "@type": "sci:value",
	                       <xsl:variable name="val" select="$vars/var/value[../name/text()='cell_length_b']"/>
	                       <xsl:choose>
	                           <xsl:when test="contains($val,'(')">
	                               <xsl:variable name="p" select="tokenize($val,'\(')"/>
	                               <xsl:variable name="dp" select="tokenize($p[1],'\.')"/>    
	                               "number": <xsl:value-of select="$p[1]"/>,
	                               "error": 0.<xsl:for-each select="1 to string-length($dp[2])">0</xsl:for-each><xsl:value-of select="replace($p[2],'\)','')"/>
	                           </xsl:when>
	                           <xsl:otherwise>
	                           "number": <xsl:value-of select="$val"/>
	                           </xsl:otherwise>
	                       </xsl:choose>,
	                       "unitref": "qudt:Angstrom"
	                   }
	               },
	               {
	                   "@id": "datapoint/13/",
	                   "@type": "sci:datapoint",
	                   "url": "http://www.iucr.org/__data/iucr/cifdic_html/1/cif_core.dic/Icell_length_.html",
	                   "quantity": "length",
	                   "property": "cell_length_c",
	                   "value": {
	                       "@id": "datapoint/13/value/",
	                       "@type": "sci:value",
	                       <xsl:variable name="val" select="$vars/var/value[../name/text()='cell_length_c']"/>
	                       <xsl:choose>
	                           <xsl:when test="contains($val,'(')">
	                               <xsl:variable name="p" select="tokenize($val,'\(')"/>
	                               <xsl:variable name="dp" select="tokenize($p[1],'\.')"/>    
	                               "number": <xsl:value-of select="$p[1]"/>,
	                               "error": 0.<xsl:for-each select="1 to string-length($dp[2])">0</xsl:for-each><xsl:value-of select="replace($p[2],'\)','')"/>
	                           </xsl:when>
	                           <xsl:otherwise>
	                               "number": <xsl:value-of select="$val"/>
	                           </xsl:otherwise>
	                       </xsl:choose>,
	                       "unitref": "qudt:Angstrom"
	                   }
	               },
	               {
	                   "@id": "datapoint/14/",
	                   "@type": "sci:datapoint",
	                   "url": "http://www.iucr.org/__data/iucr/cifdic_html/1/cif_core.dic/Icell_volume.html",
	                   "quantity": "length",
	                   "property": "cell_volume",
	                   "value": {
	                       "@id": "datapoint/14/value/",
	                       "@type": "sci:value",
	                       <xsl:variable name="val" select="$vars/var/value[../name/text()='cell_volume']"/>
	                       <xsl:choose>
	                           <xsl:when test="contains($val,'(')">
 	                               <xsl:variable name="p" select="tokenize($val,'\(')"/>
	                               <xsl:variable name="dp" select="tokenize($p[1],'\.')"/>    
	                               "number": <xsl:value-of select="$p[1]"/>,
	                               "error": 0.
	                               <xsl:for-each select="1 to string-length($dp[1])">0</xsl:for-each>
	                               <xsl:value-of select="replace($p[2],'\)','')"/>
	                           </xsl:when>
	                           <xsl:otherwise>
	                               "number": <xsl:value-of select="$val"/>
	                           </xsl:otherwise>
	                       </xsl:choose>,
	                       "unitref": "qudt:CubicAngstrom"
	                   }
	               }
	    	   ]
	        }
	    },
	    "references": [{
	       "@id": "reference/1/",
	       "@type": "dc:source",
			<xsl:variable name="j" select="$vars/var/value[../name/text()='journal_name_full']"/>
	       <xsl:variable name="y" select="$vars/var/value[../name/text()='journal_year']"/>
	       <xsl:variable name="f" select="$vars/var/value[../name/text()='journal_page_first']"/>
	       <xsl:variable name="l" select="$vars/var/value[../name/text()='journal_page_last']"/>
	       <xsl:variable name="v" select="$vars/var/value[../name/text()='journal_volume']"/>
	       "citation": "<xsl:value-of select="concat($j,' ',$y,' Vol ',$v,' ',$f,'-',$l)"/>",
	       "reftype": "journal article",
	       "doi": "<xsl:value-of select="$vars/var/value[../name/text()='journal_paper_doi']"/>",
	       "url": "http://dx.doi.org/<xsl:value-of select="$vars/var/value[../name/text()='journal_paper_doi']"/>"
	    }]
	}
	</xsl:template>
</xsl:stylesheet>