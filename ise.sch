<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <title>Schematron for the Internet Shakespeare Editions</title>
    
    <ns prefix="sch" uri="http://purl.oclc.org/dsdl/schematron"/>
    <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
    <ns prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>
    <ns prefix="hcmc" uri="http://hcmc.uvic.ca/ns"/>
    <ns prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>
    
    <pattern>
        <rule context="tei:TEI">
            <let name="id" value="@xml:id"/>
            <let name="docName" value="substring-before(document-uri(/), '.xml')"/>
            <assert test="ends-with($docName, $id)"> ERROR: Document xml:id (<value-of select="$id"
            />) does not match the document file name (<value-of select="$docName"/>). </assert>
        </rule>
    </pattern>
    
    <!--Linking rules-->
    
    <pattern>
        <rule context="tei:change">
            <assert test="starts-with(@who, 'pers:') or starts-with(@who,'org:')">ERROR: @who attributes should point to a
                person in the personography or an organization in the orgography.</assert>
        </rule>
    </pattern>
    
    <!--Bibl Rules-->
    
    <pattern>
        <rule context="tei:bibl[@corresp]">
            <let name="correspTokens" value="tokenize(@corresp,'\s+')"/>
            <assert test="every $n in $correspTokens satisfies (matches($n,'^((gb)|(estc)|(wsb)|(mol))'))">
                ERROR: @corresp pointers need to point to a recommend resource using a standardized prefix: Google Books (gb), ESTC (estc), World Shakespeare Bibliography (wsb), or MoEML (mol).
            </assert>
        </rule>
    </pattern>
    
    
    <pattern>
        <!--This is just a warning, since it could be valid, but it likely isn't.-->
        <rule context="tei:bibl[ancestor::tei:TEI/@xml:id='BIBL1']/tei:title" role="warning">
            <assert test="not(ends-with(., '.'))">
                HINT: Final periods usually belong outside title tags. Are you sure this final period is actually part of the title?
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="tei:title[ancestor::tei:TEI/@xml:id='BIBL1']">
            <assert test="not(matches(., '(^\s)|(\s$)'))">
                ERROR: Titles do not begin with spaces. Please remove empty spaces from the beginning and end of title elements. (<value-of select="ancestor::tei:TEI/@xml:id"/>)
            </assert>
        </rule>
    </pattern>
    
    
    <pattern>
        <rule context="tei:title[ancestor::tei:TEI/@xml:id='BIBL1'] | tei:titlePart[ancestor::tei:TEI/@xml:id='BIBL1']">
            <assert test="string-length(normalize-space(.)) gt 0">
                ERROR: Title elements must not be empty. (
                <value-of select="ancestor::tei:TEI/@xml:id"/>
                )
            </assert>
        </rule>
    </pattern>
    
    <!--In-text rules-->
    
    <!--This one's a doozy, at present. Uncomment once these have been more or less fixed-->
    <!--<pattern>
        <rule context="tei:*[text()][not(self::tei:code or self::tei:tag or ancestor-or-self::tei:quote or ancestor-or-self::tei:revisionDesc or ancestor-or-self::tei:l or ancestor-or-self::tei:rendition)]">
            <assert test="not(matches(string-join(text(),''), '[&quot;&#x201c;&#x201d;]'))">
                ERROR: Quotation mark characters are not permitted. Use &lt;quote&gt;, &lt;title level="a"&gt;, &lt;mentioned&gt; or &lt;soCalled&gt; instead. (<value-of select="ancestor::tei:TEI/@xml:id"/>)
            </assert>
        </rule>
    </pattern>-->
    
    <!--Rules for change element-->
    
    <pattern>
        <rule context="tei:change[parent::tei:revisionDesc]">
            <assert
                test="not(following-sibling::tei:change[xs:date(@when) > xs:date(current()/@when)])"
                > ERROR: The order of &lt;changes&gt; elements in the &lt;revisionDesc&gt; in this
                file is not correct. Later changes should always come first. (<value-of select="ancestor::tei:TEI/@xml:id"/>) </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule
            context="tei:taxonomy[@xml:id = 'iseRespTaxonomy']/tei:category[starts-with(@corresp, 'marc:')]">
            <assert test="string-length(normalize-space(tei:catDesc/tei:gloss[@type = 'marc'])) gt 0"
                > ERROR: All categories that point to the LOC has a have an associated gloss. (<value-of select="ancestor::tei:TEI/@xml:id"/>)
            </assert>
        </rule>
    </pattern>
    
    <!--Apparatus rules-->
    
    <pattern>
        <rule context="tei:TEI[.//catRef/@target = 'idt:idtApparatus']//tei:span">
            <assert test="tei:term"> ERROR: Annotation missing required element "term". </assert>
            <assert test="count(tei:term) = 1"> ERROR: All annotations
                should only have one term. (<value-of select="ancestor::tei:TEI/@xml:id"/>)</assert>
        </rule>
    </pattern>
    
    <let name="appPattern" value="'^tln:\d+(\.\d+)?(\|\d+)?$'"/>
    
    <pattern>
        <rule context="tei:span[@from] | tei:app[@from]">
            <assert test="matches(@from, $appPattern) or starts-with(@from,'#')"> ERROR: All @from pointers should point to
                one TLN with an optional flag for choosing instance of the lemma (e.g. tln:77.1|2) or point to a local anchor. (<value-of select="ancestor::tei:TEI/@xml:id"/>)
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="tei:span[@to] | tei:app[@to]">
            <assert test="matches(@to, $appPattern) or starts-with(@to,'#')"> ERROR: All @to pointers should point to one
                TLN with an optional flag for choosing instance of the lemma (e.g. tln:77.1|2) or point to a local anchor. (<value-of select="ancestor::tei:TEI/@xml:id"/>)
            </assert>
        </rule>
    </pattern>
    
    
    <pattern>
        <rule context="tei:catRef[@target = 'idt:idtApparatus']">
            <assert test="preceding::tei:fileDesc/tei:notesStmt/tei:relatedItem"> ERROR: All apparatus documents must
                explicitly reference an associated text in the &lt;notesStmt&gt;/&lt;relatedItem&gt;
                element in the teiHeader. (<value-of select="ancestor::tei:TEI/@xml:id"/>)</assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="tei:TEI[.//catRef/@target = 'idt:idtApparatus']//tei:term">
            <assert test="string-length(normalize-space(string-join(text(), ''))) gt 0"> ERROR:
                Annotation terms need to have textual content. (<value-of select="ancestor::tei:TEI/@xml:id"/>)</assert>
            
        </rule>
    </pattern>
    
    <pattern>
        <rule context="tei:TEI[.//catRef/@target = 'idt:idtApparatus']//tei:term">
            <assert test="matches(., '^\s|\s$')">term must not have leading or trailing whitespace. (<value-of select="ancestor::tei:TEI/@xml:id"/>)</assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="tei:TEI[.//catRef/@target = 'idt:idtApparatus']//tei:lem">
            <assert test="string-length(normalize-space(string-join(text(), ''))) gt 0"> ERROR:
                Lemmas need to have textual content. (<value-of select="ancestor::tei:TEI/@xml:id"/>)</assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="tei:TEI[.//catRef/@target = 'idt:idtApparatus']//tei:lem">
            <assert test="matches(., '^\s|\s$')">lem must not have leading or trailing whitespace (<value-of select="ancestor::tei:TEI/@xml:id"/>)</assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="tei:lem | tei:rdg">
            <assert test="not(matches(., '\.\s*\.\s*\.|&#x2026;'))"> ERROR: Do not use ellipses to
                note elisions in the text. Using the &lt;gap&gt; element instead. (<value-of select="ancestor::tei:TEI/@xml:id"/>)</assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="tei:lem | tei:rdg">
            <assert test="not(matches(., '/'))"> ERROR: Do not use forward slashes to
                denote line breaks. Using the &lt;lb/&gt; element instead. (<value-of select="ancestor::tei:TEI/@xml:id"/>) </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="tei:TEI[.//catRef/@target = 'idt:idtApparatus']//tei:note">
            <assert test="@type = 'marginal'"> ERROR: Do not use marginal
                notes in annotations. (<value-of select="ancestor::tei:TEI/@xml:id"/>) </assert>
        </rule>
    </pattern>
    
    <!--Not every note, but annotations-->
    <pattern>
        <rule context="tei:TEI[.//catRef/@target = 'idt:idtApparatus']//tei:span/tei:note">
            <assert test="@type"> ERROR: All annotative notes need to be appropriately typed. (<value-of select="ancestor::tei:TEI/@xml:id"/>)
            </assert>
        </rule>
    </pattern>
    
    <!--Make sure every document has 3 processing instructions: RNG + Relaxng, RNG + Schematron (embedded), SCH + schematron-->
    
    <pattern>
        <rule context="tei:TEI">
            <assert test="count(preceding::processing-instruction())=3" sqf:fix="add-PI">
                ERROR: All TEI documents need three processing instructions (RNG+RNG, RNG+SCH, SCH+SCH) (<value-of select="@xml:id"/>)
            </assert>
            <sqf:fix id="add-PI">
                <sqf:description>
                    <sqf:title>Adds Processing instructions</sqf:title>
                </sqf:description>
                <sqf:delete match="preceding::processing-instruction()"/>
                <sqf:add match="." position="before">
                    <xsl:processing-instruction name="xml-model">href="../sch/ise.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction><xsl:text>&#x0a;</xsl:text>
                    <xsl:processing-instruction name="xml-model">href="../sch/ise.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction><xsl:text>&#x0a;</xsl:text>
                    <xsl:processing-instruction name="xml-model">href="../sch/ise.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction><xsl:text>&#x0a;</xsl:text>
                </sqf:add>
            </sqf:fix>
        </rule>
    </pattern>
    
</schema>
