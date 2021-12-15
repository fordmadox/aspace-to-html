<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:j="http://www.w3.org/2005/xpath-functions"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:param name="input">
        <!-- default value included for testing -->
        <xsl:value-of select="'json/resource_11711.json'"/>
    </xsl:param>
    
    <xsl:variable name="xml" select="unparsed-text($input) => json-to-xml()"/>
    
    <xsl:variable name="notes-original">
        <xsl:copy-of select="$xml/j:map/j:array[@key='notes']"/>
    </xsl:variable>
    
    <xsl:variable name="notes-cleaned">
        <xsl:apply-templates select="$notes-original" mode="clean-xml"/>
    </xsl:variable>
    
    <xsl:variable name="notes-html">
        <xsl:apply-templates select="$notes-cleaned" mode="html"/>
    </xsl:variable>
    
    <!-- 
      See: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/ol
      (should use list-style-type in CSS instead.... just not sure how these should be classed for LUX since there are no style guides yet
      ... so using the type attribute, since there's a one-to-one mapping for those from ASpace to HTML)
a for lowercase letters
A for uppercase letters
i for lowercase Roman numerals
I for uppercase Roman numerals
1 for numbers (default; so, could remove from the mapping. keeping it in for clarity for now.)
 -->
    <xsl:variable name="aspace-list-enumeration" select="map{'arabic': '1', 'loweralpha': 'a', 'upperalpha': 'A', 'lowerroman': 'i', 'upperroman': 'I'}"/>
    
    
    
    <!--      
      Notes (both the note level and subnote level have publish options. if either has publish = false, then don't map that level)
        
        this mapping does NOT include notes that could be attached to Agents, Subjects, or Rights subrecords currently. 
      
      note_singlepart:
        notes (array) / content (array) / (string)   
        
      note_multipart:
        notes (array) / label (string)
        notes (array) / subnotes (array)
        
       multipart subnotes array children have one of four types:
       
        note_text:
             notes (array) / subnotes (array) / "jsonmodel_type": "note_text", content (string)
        
        note_orderedlist: 
            notes (array) / subnotes (array) / "jsonmodel_type": "note_orderedlist", title (string)
            notes (array) / subnotes (array) / "jsonmodel_type": "note_orderedlist", enumeration (string, closed list of values)
            notes (array) / subnotes (array) / "jsonmodel_type": "note_orderedlist", items (array) / (string)
        
        note_definedlist:
            notes (array) / subnotes (array) / "jsonmodel_type": "note_definedlist", title (string)
            notes (array) / subnotes (array) / "jsonmodel_type": "note_definedlist", items (array)
            notes (array) / subnotes (array) / "jsonmodel_type": "note_definedlist", items (array) / label (string)  *required*
            notes (array) / subnotes (array) / "jsonmodel_type": "note_definedlist", items (array) / value (string)  *required*
                               
        note_chronology:
            notes (array) / subnotes (array) / "jsonmodel_type": "note_chronology", title (string)
            notes (array) / subnotes (array) / "jsonmodel_type": "note_chronology", items (array)
            notes (array) / subnotes (array) / "jsonmodel_type": "note_chronology", items (array) / event_date (string)
            notes (array) / subnotes (array) / "jsonmodel_type": "note_chronology", items (array) / event_place (string)   ** ASpace 3 only **   
            notes (array) / subnotes (array) / "jsonmodel_type": "note_chronology", items (array) / events (array) / (string) 
       
      
      
      note_bibliography
        notes (array) / "jsonmodel_type": "note_bibliography", label (string)
        notes (array) / "jsonmodel_type": "note_bibliography", content (array)   // so, similar to note_singlepart
        notes (array) / "jsonmodel_type": "note_bibliography", items (array)

      
      note_index
        notes (array) / "jsonmodel_type": "note_index", label (string)
        notes (array) / "jsonmodel_type": "note_index", content (array)   // so, similar to note_singlepart
        notes (array) / "jsonmodel_type": "note_index", items (array / map)
        notes (array) / "jsonmodel_type": "note_index", items (array / map) / "jsonmodel_type": "note_index_item", value (string)
        notes (array) / "jsonmodel_type": "note_index", items (array / map) / "jsonmodel_type": "note_index_item", type (closed list... cpf... e.g. corporate_entity)
        notes (array) / "jsonmodel_type": "note_index", items (array / map) / "jsonmodel_type": "note_index_item", reference (string, but some internal link)   *** optional + might not be a link? ***
        notes (array) / "jsonmodel_type": "note_index", items (array / map) / "jsonmodel_type": "note_index_item", reference_text (string)
              
   -->

</xsl:stylesheet>
