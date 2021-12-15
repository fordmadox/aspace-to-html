<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="xlink"
    version="1.0">
    <!--
    when used as a standalone transformation, will need to be called on any JSON string field that has XML-like content
    and content arrays at the notes level:
    
    top-level:
      title (string)
      display string (string) *** if used instead of title ***
      
    notes:
       notes / label (string)
       notes / subnotes / content (string)
       or array of strings (e.g. items, in a list)
    -->
    
    <!-- in order to map @target attributes,
        we'd need to implement a search.  should that be done via the ASpace API, MarkLogic API, MetadataCloud, what???
        -->
    
    <!-- 
        render=
        altrender, bold, bolddoublequote, bolditalic, boldsinglequote, boldsmcaps, boldunderline, doublequote, italic, nonproport, singlequote, smcaps, sub, super, underline
        
        nonproport => monospace font.  since "tt" is a deprecated HTML element, this would also need to be handled with CSS.  map if LUX provides the optoin; otherwise, just continue to ignore it.
        -->

    <xsl:template match="abbr | blockquote | p | table | thead | tbody" mode="html">
       <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="html"/>
       </xsl:copy>
    </xsl:template>

    <xsl:template match="emph" mode="html">
        <em>
            <xsl:apply-templates select="@* | node()" mode="html"/>
        </em>
    </xsl:template>

    <xsl:template match="lb" mode="html">
        <br/>
    </xsl:template>
    
    <xsl:template match="ptr" mode="html">
        <xsl:message terminate="no">Fix this, please.</xsl:message>
    </xsl:template>

    <xsl:template match="ref" mode="html">
        <a>
            <xsl:apply-templates select="@* | node()" mode="html"/>
        </a>
    </xsl:template>

    <xsl:template match="title" mode="html" priority="2">
        <cite>
            <xsl:apply-templates select="@* | node()" mode="html"/>
        </cite>
    </xsl:template>
    
    <xsl:template match="table/head">
        <caption>
            <xsl:apply-templates select="@* | node()" mode="html"/>
        </caption>
    </xsl:template>
    
    <xsl:template match="row">
        <tr>
            <xsl:apply-templates select="@* | node()" mode="html"/>
        </tr>
    </xsl:template>
    
    <xsl:template match="entry">
        <td>
            <xsl:apply-templates select="@* | node()" mode="html"/>
        </td>
    </xsl:template>  
    
    <!-- also add the xlink options, or will that be handled by the java code?
        add the xlink part to the ASpace JSON transform for completeness of testing (regardless of if that's used), though
        -->
    <xsl:template match="@expan | @linktitle" mode="html">
        <xsl:attribute name="title">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@title | @href | @xlink:href | @xlink:title" mode="html">
        <xsl:attribute name="{local-name()}">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@render[. = 'smcaps'] | @altrender[. = 'smcaps']" mode="html">
        <xsl:attribute name="style">
            <xsl:value-of select="'font-variant: small-caps;'"/>
        </xsl:attribute>
    </xsl:template>
    
    <!-- just adding extra element-wrapped support for generic elements.  if "title", it should just wind up with "cite" for now.
    once we know what classes we can use with LUX, we should switch out the HTML elements for those -->
     
    <xsl:template match="*[@render[. = 'bold']] | *[@altrender[. = 'bold']]" mode="html">
        <strong>
            <xsl:apply-templates mode="html"/>
        </strong>
    </xsl:template>

    <xsl:template match="*[@render[. = 'bolddoublequote']] | *[@altrender[. = 'bolddoublequote']]" mode="html">
        <strong>"<xsl:apply-templates mode="html"/>"</strong>
    </xsl:template>

    <xsl:template match="*[@render[. = 'boldsinglequote']] | *[@altrender[. = 'boldsinglequote']]" mode="html">
        <strong>'<xsl:apply-templates mode="html"/>'</strong>
    </xsl:template>

    <xsl:template match="*[@render[. = 'bolditalic']] | *[@altrender[. = 'bolditalic']]" mode="html">
        <strong>
            <em>
                <xsl:apply-templates mode="html"/>
            </em>
        </strong>
    </xsl:template>

    <xsl:template match="*[@render[. = 'boldsmcaps']] | *[@altrender[. = 'boldsmcaps']]" mode="html">
        <strong style="font-variant: small-caps;">
            <xsl:apply-templates mode="html"/>
        </strong>
    </xsl:template>

    <xsl:template match="*[@render[. = 'boldunderline']] | *[@altrender[. = 'boldunderline']]" mode="html">
        <strong>
            <span class="underline">
                <xsl:apply-templates mode="html"/>
            </span>
        </strong>
    </xsl:template>

    <xsl:template match="*[@render[. = 'doublequote']] | *[@altrender[. = 'doublequote']]" mode="html">
        "<xsl:apply-templates mode="html"/>" 
    </xsl:template>

    <xsl:template match="*[@render[. = 'italic']] | *[@altrender[. = 'italic']]" mode="html">
       <em>
           <xsl:apply-templates mode="html"/>
       </em>
    </xsl:template>

    <xsl:template match="*[@render[. = 'singlequote']] | *[@altrender[. = 'singlequote']]" mode="html">
        '<xsl:apply-templates mode="html"/>'
    </xsl:template>

    <xsl:template match="*[@render[. = 'sub']] | *[@altrender[. = 'sub']]" mode="html">
        <sub>
            <xsl:apply-templates mode="html"/>
        </sub>
    </xsl:template>

    <xsl:template match="*[@render[. = 'super']] | *[@altrender[. = 'super']]" mode="html">
        <sup>
            <xsl:apply-templates mode="html"/>
        </sup>
    </xsl:template>

    <xsl:template match="*[@render[. = 'underline']] | *[@altrender[. = 'underline']]" mode="html">
        <span class="underline">
            <xsl:apply-templates mode="html"/>
        </span>
    </xsl:template>
    
    <!-- should we include a catch all (converting to span/class=?), in case folks add invalid content, or we include other types of notes like "finding_aid_note"
        , which could have other elements such as ead:num.
        something like.... (but different, since this picks up the 'p' tags i add to the cleaned-xml, and we want to preserve those.
        
        probably not needed, since we really just want to preserve formatting and links... but it's an option. 
        
    <xsl:template match="*[not(namespace-uri())]" mode="html" priority="0.5">
        <span class="{local-name()}">
            <xsl:apply-templates select="@*|node()" mode="html"/>
        </span>
    </xsl:template
    -->

</xsl:stylesheet>
