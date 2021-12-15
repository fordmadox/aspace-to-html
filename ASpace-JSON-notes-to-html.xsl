<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:j="http://www.w3.org/2005/xpath-functions"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:output method="html" version="5" encoding="UTF-8" indent="true"/>
    
    <xsl:import href="ASpace-text-to-html.xsl"/>
    <xsl:include href="ASpace-configurations.xsl"/>
       
    <!--step one: load JSON
        
        step two: convert notes array to XML (removing any unpublished notes/subnotes)
                everything in this file will need to be added to the java code if not handled via XSLT
                the logic is provided at the end of this file, in a long comment.
        
        step three: convert XML to HTML
            (will also need to convert string to XML for each string conversion process possibly.)
     -->
  
    <!-- change to notes-original or notes-cleaned for testing -->
    <xsl:template match="/" name="xsl:initial-template">
        <xsl:copy-of select="$notes-html"/>
    </xsl:template>
    
    <xsl:template match="@*|node()" mode="clean-xml">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/> 
        </xsl:copy>
    </xsl:template>
    
    <!-- a little trickery that deserves documentation + testing -->
    <xsl:template match="text()[parent::*[@key='content']]" mode="clean-xml">
        <xsl:for-each select="tokenize(., '\n\n')">
            <xsl:choose>
                <xsl:when test="normalize-space()">
                    <p>
                        <!-- should add a try/catch here in case the string cannot be parsed as an xml fragment... -->
                        <xsl:copy-of select="normalize-space() => parse-xml-fragment()"/>
                    </p>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template> 
    
    <xsl:template match="text()[not(parent::*[@key='content'])]" mode="clean-xml">
        <xsl:copy-of select="parse-xml-fragment(.)"/>
    </xsl:template> 
    
    <!-- filter out any primary notes or subnotes that are unpublished -->
    <xsl:template match="j:map[j:boolean[@key='publish']='false']" priority="2" mode="clean-xml"/>
   



    <!-- the following mode=html templates are invoked during the second part of the transformation pipeline. -->
    <xsl:template match="j:array[@key='notes']" mode="html">
        <div class="lux-ml">
            <xsl:apply-templates select="node()" mode="#current"/>
        </div>
    </xsl:template>
    
    <xsl:template match="j:string[@key=('jsonmodel_type', 'persistent_id', 'type')]
        | j:boolean[@key='publish']
        | j:map[@key='rights_restriction']" mode="html"/>
    
    <xsl:template match="j:array[@key='content'][j:string]" mode="html">
        <xsl:apply-templates select="j:string" mode="#current">
            <xsl:with-param name="element" select="'p'"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="j:array[@key='items'][j:string]" mode="html">
        <ul>
            <xsl:apply-templates select="j:string" mode="#current">
                <xsl:with-param name="element" select="'li'"/>
            </xsl:apply-templates>
        </ul>
    </xsl:template>
    
    <xsl:template match="j:array[@key='items'][j:map/j:string[@key='jsonmodel_type']='note_index_item']" mode="html">
        <dl>
            <xsl:apply-templates select="j:map" mode="html-index"/>
        </dl>
    </xsl:template>
    
    <xsl:template match="j:map" mode="html-index">
        <dt data-type="{j:string[@key='type']}">
           <xsl:apply-templates select="j:string[@key='value']" mode="html"/> 
        </dt>
        <dd data-link="{j:string[@key='reference']}">
            <xsl:apply-templates select="j:string[@key='reference_text']" mode="html"/> 
        </dd>
    </xsl:template>
  
    <xsl:template match="j:map[j:string[@key='jsonmodel_type']=('note_singlepart', 'note_multipart', 'note_bibliography', 'note_index')]" mode="html">
        <!-- split out note_bibliography if that requires separte processing (e.g. if the list items should have a different class, or be wrapped in cite elements, but probably fine to treat generically -->
        <div data-type="{(j:string[@key='type'], j:string[@key='jsonmodel_type'] => substring-after('_'))[1]}">
            <!-- no order in JSON, so we have to force the label values to appear first (i.e. the bit before the comma) -->
            <xsl:apply-templates select="j:string[@key='label'], node() except j:string[@key='label']" mode="#current"/> 
        </div>
    </xsl:template>
    
    <xsl:template match="j:map[j:string[@key='jsonmodel_type']='note_orderedlist']" mode="html">
        <xsl:variable name="element" select="if (j:string[@key='enumeration']) then 'ol' else 'ul'"/>
        <section>
            <xsl:apply-templates select="j:string[@key='title']" mode="#current"/>
            <xsl:element name="{$element}">
                <xsl:apply-templates select="j:string[@key='enumeration']" mode="#current"/>
                <xsl:apply-templates select="j:array[@key='items']/j:string" mode="#current">
                    <xsl:with-param name="element" select="'li'"/>
                </xsl:apply-templates>
            </xsl:element>
        </section>
    </xsl:template>
        
    <xsl:template match="j:map[j:string[@key='jsonmodel_type']='note_definedlist']" mode="html">
        <section>
            <xsl:apply-templates select="j:string[@key='title']" mode="#current"/>
            <dl>
                <xsl:apply-templates select="j:array[@key='items']/j:map" mode="html-dl"/>
            </dl>
        </section>
    </xsl:template>
    
    <xsl:template match="j:map" mode="html-dl">
        <dt>
            <xsl:apply-templates select="j:string[@key='label']" mode="#current"/>  
        </dt>
        <dd>
            <xsl:apply-templates select="j:string[@key='value']" mode="#current"/>
        </dd>
    </xsl:template>
    
    <xsl:template match="j:map[j:string[@key='jsonmodel_type']='note_chronology']" mode="html">
        <!-- note:  place is not available until we upgrade ASpace. we just have dates and events currently. --> 
        <table>
            <xsl:apply-templates select="j:string[@key='title']" mode="html-chronology"/>
            <tr>
                <th>Date</th>
                <!-- <th>Place</th> -->
                <th>Event(s)</th>
            </tr>
            <xsl:apply-templates select="j:array[@key='items']" mode="html-chronology"/>
        </table>
    </xsl:template>
    
    <xsl:template match="j:array[@key='items']" mode="html-chronology">
        <!-- ASpace events can be completely empty, since every value is optional.  to combat empty rows, we'll only map those maps that have something to display, like so-->
        <xsl:apply-templates select="j:map[descendant::j:string]" mode="html-chronology"/>
    </xsl:template>
    
    <xsl:template match="j:map" mode="html-chronology">
        <tr>
            <td>
                <xsl:apply-templates select="j:string[@key='event_date']" mode="html"/>
            </td>
            <!-- 
           <td>
               <xsl:apply-templates select="j:string[@key='event_place']" mode="html"/>
           </td>
            -->
            <td>
                <xsl:choose>
                    <xsl:when test="j:array[@key='events']/j:string[2]">
                        <ul>
                            <xsl:apply-templates select="j:array[@key='events']/j:string" mode="html">
                                <xsl:with-param name="element" select="'li'"/>
                            </xsl:apply-templates>
                        </ul>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="j:array[@key='events']/j:string" mode="html"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
      
    <xsl:template match="j:string[@key='enumeration']" mode="html">
        <xsl:attribute name="type" select="map:get($aspace-list-enumeration, .)"/>
    </xsl:template>
    
    <xsl:template match="j:string[@key=('title', 'label')]" mode="html">
        <!-- should use an hN element, but we don't know yet what level the heading would be at.
            alternative option would be aria-label attribute on the list.
            fow now, using section to group.  but will change as needed. -->
        <b><xsl:apply-templates mode="#current"/></b>
    </xsl:template>
    
    <xsl:template match="j:string[@key='title']" mode="html-chronology">
        <caption><xsl:apply-templates mode="html"/></caption>
    </xsl:template>
    
    <!-- or update so that note_text is always p, and j:string with no key is always li.  that should be the result either way, i think.-->
    <xsl:template match="j:string[not(@key)]" mode="html">
        <xsl:param name="element"/>
        <xsl:choose>
            <xsl:when test="$element">
                <xsl:element name="{$element}">
                    <xsl:apply-templates select="@*|node()" mode="#current"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="@*|node()" mode="#current"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
   
</xsl:stylesheet>
