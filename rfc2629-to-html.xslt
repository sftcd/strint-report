<!--
Script to convert from RFC 2629 mark-up to HTML4.

This script is an almost generic converter, except for the following:

  - It inserts some comments for the template system of the workshop's Web site
  - It omits the title

It does not add any CSS styling to the HTML, but it does generate some
CLASS attributes to make styling easier, as follows:

  - Sections become <div class=section>
  - Generated section numbers are enclosed in <span class=secno>
  - Figures become <div class=figure> (with src) or class=display (with text)
  - The preamble of a figure with an image (src attribute) is placed
    after the image and the postamble to create a caption
  - The postamble of a figure with an image is enclosed in <span
    class=credit>
  - The preamble and postamble do not change place if the artwork is ASCII art
  - The document name, number, category, etc, are in a <dl class=meta>
  - A list with style=letters becomes <ul class=letters>
  - A cref becomes <span class=issue>
  - A texttable with its pre- and postamble are enclosed in <div class=table>
  - The ToC is a <ul> in a <div class=section id=toc>
  - The authors' addresses are in a <div class=section id=authors>
  - The abstract is in a <div class=section id=abstract>
  - The status is in a <div class=section id=status>
  - The copyright is in a <div class=section id=copyright>

See the comments below for features that are not yet handled ("ToDo")

Copyright © 2014 World Wide Web Consortium
See http://www.w3.org/Consortium/Legal/2002/copyright-software-20021231

Created: 19 March 2014
Author: Bert Bos <bert@w3.org>
-->

<x:stylesheet
    version="1.0"
    xmlns:x="http://www.w3.org/1999/XSL/Transform"
    xmlns:s="http://exslt.org/strings"
    xmlns:d="http://exslt.org/dates-and-times">

  <x:output omit-xml-declaration="yes" method="html" encoding="utf-8"
	    version="4.0" doctype-public="-//W3C//DTD HTML 4.01//EN" />

  <x:strip-space elements="*" />
  <x:preserve-space elements="artwork" />

  <x:param name="tocdepth">
    <x:call-template name="parse-pi">
      <x:with-param name="nodes" select="//processing-instruction('rfc')"/>
      <x:with-param name="name">tocdepth</x:with-param>
      <x:with-param name="default">99</x:with-param>
    </x:call-template>
  </x:param>

  <x:param name="toc">
    <x:call-template name="parse-pi">
      <x:with-param name="nodes" select="//processing-instruction('rfc')"/>
      <x:with-param name="name">toc</x:with-param>
      <x:with-param name="default">no</x:with-param>
    </x:call-template>
  </x:param>

  <x:param name="comments">
    <x:call-template name="parse-pi">
      <x:with-param name="nodes" select="//processing-instruction('rfc')"/>
      <x:with-param name="name">comments</x:with-param>
      <x:with-param name="default">no</x:with-param>
    </x:call-template>
  </x:param>

  <x:variable name="ietfbase">http://tools.ietf.org/html/</x:variable>

  <x:variable name="year">
    <x:choose>
      <x:when test="/rfc/front/date/@year">
	<x:value-of select="/rfc/front/date/@year"/>
      </x:when>
      <x:when test="function-available('d:year')">
	<x:value-of select="d:year()"/>
      </x:when>
      <x:otherwise>
	YYYY
      </x:otherwise>
    </x:choose>
  </x:variable>

  <x:variable name="month">
    <x:choose>
      <x:when test="/rfc/front/date/@month">
	<x:value-of select="/rfc/front/date/@month"/>
      </x:when>
      <x:when test="function-available('d:month-name')">
	<x:value-of select="d:month-name()"/>
      </x:when>
      <x:otherwise>
	MMM
      </x:otherwise>
    </x:choose>
  </x:variable>

  <x:variable name="day">
    <x:choose>
      <x:when test="/rfc/front/date/@day">
	<x:value-of select="/rfc/front/date/@day"/>
      </x:when>
      <x:when test="function-available('d:day-in-month')">
	<x:value-of select="d:day-in-month()"/>
      </x:when>
      <x:otherwise>
	DD
      </x:otherwise>
    </x:choose>
  </x:variable>

  <x:template match="rfc">
    <!-- ToDo: @consensus, @iprExtract, @submissionType, area -->
    <x:element name="html">
      <x:attribute name="lang">
	<x:choose>
	  <x:when test="@xml:lang"><x:value-of select="@xml:lang"/></x:when>
	  <x:otherwise>en</x:otherwise>
	</x:choose>
      </x:attribute>
      <x:element name="head">
	<x:element name="title">
	  <x:comment>include title.inc</x:comment>
	  <x:text> - report/papers</x:text>
	</x:element>
	<x:comment>include head.inc</x:comment>
	<x:call-template name="keywords"/>
      </x:element>
      <x:element name="body">
	<x:comment>include top.inc</x:comment>
	<x:comment>include twitter.inc</x:comment>
	<x:comment>include hostbox.inc</x:comment>
	<x:element name="dl">
	  <x:attribute name="class">meta</x:attribute>
	  <x:apply-templates select="workgroup"/>
	  <x:apply-templates select="@number"/>
	  <x:apply-templates select="@docName"/>
	  <x:apply-templates select="@obsoletes"/>
	  <x:apply-templates select="@updates"/>
	  <x:apply-templates select="@category"/>
	  <x:apply-templates select="@seriesNo"/>
	  <x:apply-templates select="front/date"/>
	</x:element>
	<x:apply-templates select="front/abstract"/>
	<x:apply-templates select="front/note"/>
	<x:call-template name="status">
	  <x:with-param name="category" select="@category"/>
	</x:call-template>
	<x:call-template name="copyright">
	  <x:with-param name="ipr" select="@ipr"/>
	  <x:with-param name="submissionType" select="@submissionType"/>
	</x:call-template>
	<x:call-template name="toc"/>
	<x:apply-templates select="middle"/>
	<x:apply-templates select="back"/>
	<!-- ToDo: index -->
	<x:element name="div">
	  <x:attribute name="class">section</x:attribute>
	  <x:attribute name="id">authors</x:attribute>
	  <x:element name="h2"><x:text>Authors' addresses</x:text></x:element>
	  <x:apply-templates select="front/author"/>
	</x:element>
	<x:comment>include footer.inc</x:comment>
      </x:element>
    </x:element>
  </x:template>

  <x:template match="workgroup">
    <x:element name="dt"><x:text>Working group</x:text></x:element>
    <x:element name="dd"><x:apply-templates select="workgroup"/></x:element>
  </x:template>

  <x:template match="/rfc/@number">
    <x:element name="dt"><x:text>Request for Comments</x:text></x:element>
    <x:element name="dd">
      <x:call-template name="ietflink">
	<x:with-param name="name" select="concat('rfc', .)"/>
	<x:with-param name="anchor" select="."/>
      </x:call-template>
    </x:element>
  </x:template>

  <x:template match="/rfc/@docName">
    <x:if test="not(../@number)">
      <x:element name="dt"><x:text>Internet-Draft</x:text></x:element>
      <x:element name="dd">
	<x:call-template name="ietflink">
	  <x:with-param name="name" select="."/>
	  <x:with-param name="anchor" select="."/>
	</x:call-template>
      </x:element>
    </x:if>
  </x:template>

  <x:template match="/rfc/@obsoletes">
    <x:if test=".!=''">
      <x:element name="dt"><x:text>Obsoletes</x:text></x:element>
      <x:element name="dd">
	<x:call-template name="rfc-list">
	  <x:with-param name="s" select="normalize-space(.)"/>
	</x:call-template>
	<x:if test="not(../@number)"><x:text> (if approved)</x:text></x:if>
      </x:element>
    </x:if>
  </x:template>

  <x:template match="/rfc/@updates">
    <x:if test=".!=''">
      <x:element name="dt"><x:text>Updates</x:text></x:element>
      <x:element name="dd">
	<x:call-template name="rfc-list">
	  <x:with-param name="s" select="normalize-space(.)"/>
	</x:call-template>
	<x:if test="not(../@number)"><x:text> (if approved)</x:text></x:if>
      </x:element>
    </x:if>
  </x:template>

  <x:template match="/rfc/@category">
    <x:element name="dt">
      <x:choose>
	<x:when test="not(../@number)">
	  <x:text>Intended status</x:text>
	</x:when>
	<x:otherwise>
	  <x:text>Category</x:text>
	</x:otherwise>
      </x:choose>
    </x:element>
    <x:element name="dd">
      <x:choose>
	<x:when test=".='std'"><x:text>Standards Track</x:text></x:when>
	<x:when test=".='bcp'"><x:text>Best Current Practice</x:text></x:when>
	<x:when test=".='exp'"><x:text>Experimental</x:text></x:when>
	<x:when test=".='historic'"><x:text>Historic</x:text></x:when>
	<x:when test=".='info'"><x:text>Informational</x:text></x:when>
	<x:otherwise><x:text>Unknown</x:text></x:otherwise>
      </x:choose>
    </x:element>
  </x:template>

  <x:template match="/rfc/front/date">
    <x:element name="dt"><x:text>Date</x:text></x:element>
    <x:element name="dd">
      <x:value-of select="$day"/>
      <x:text> </x:text>
      <x:value-of select="$month"/>
      <x:text> </x:text>
      <x:value-of select="$year"/>
    </x:element>
    <x:element name="dt"><x:text>Expires</x:text></x:element>
    <x:element name="dd">
      <x:call-template name="expires">
	<x:with-param name="day" select="$day"/>
	<x:with-param name="month" select="$month"/>
	<x:with-param name="year" select="$year"/>
      </x:call-template>
    </x:element>
  </x:template>

  <x:template match="/rfc/@seriesNo">
    <x:choose>
      <x:when test="../@category='std'">
	<x:element name="dt"><x:text>STD</x:text></x:element>
	<x:element name="dd"><x:value-of select="."/></x:element>
      </x:when>
      <x:when test="../@category='bcp'">
	<x:element name="dt"><x:text>BCP</x:text></x:element>
	<x:element name="dd"><x:value-of select="."/></x:element>
      </x:when>
      <x:when test="../@category='info'">
	<x:element name="dt"><x:text>FYI</x:text></x:element>
	<x:element name="dd"><x:value-of select="."/></x:element>
      </x:when>
    </x:choose>
  </x:template>

  <x:template match="author">
    <x:element name="address">
      <x:choose>
	<x:when test="address/uri">
	  <x:element name="a">
	    <x:attribute name="href">
	      <x:value-of select="address/uri"/>
	    </x:attribute>
	    <x:call-template name="name"/>
	  </x:element>
	</x:when>
	<x:otherwise>
	  <x:call-template name="name"/>
	</x:otherwise>
      </x:choose>
      <x:if test="@role">
	<x:text>, </x:text>
	<x:value-of select="@role"/>
      </x:if>
      <x:apply-templates/>
    </x:element>
  </x:template>

  <x:template match="organization">
    <x:element name="br"/>
    <x:choose>
      <x:when test="@abbrev">
	<x:element name="abbr">
	  <x:attribute name="title"><x:value-of select="."/></x:attribute>
	  <x:value-of select="@abbrev"/>
	</x:element>
      </x:when>
      <x:otherwise>
	<x:apply-templates/>
      </x:otherwise>
    </x:choose>
  </x:template>

  <x:template match="street|region|country">
    <x:element name="br"/>
    <x:apply-templates/>
  </x:template>

  <x:template match="city|code">
    <x:choose>
      <x:when test="preceding-sibling::city|preceding-sibling::code">
	<x:text> </x:text>
      </x:when>
      <x:otherwise>
	<x:element name="br"/>
      </x:otherwise>
    </x:choose>
    <x:apply-templates/>
  </x:template>

  <x:template match="phone">
    <x:element name="br"/>
    <x:text>Tel: </x:text>
    <x:apply-templates/>
  </x:template>

  <x:template match="facsimile">
    <x:element name="br"/>
    <x:text>Fax: </x:text>
    <x:apply-templates/>
  </x:template>

  <x:template match="email">
    <x:element name="br"/>
    <x:element name="a">
      <x:attribute name="href">
	<x:text>mailto:</x:text>
	<x:value-of select="."/>
      </x:attribute>
      <x:text>&lt;</x:text>
      <x:apply-templates/>
      <x:text>&gt;</x:text>
    </x:element>
  </x:template>

  <x:template match="date">
    <x:if test="@day">
      <x:value-of select="@day"/>
      <x:text> </x:text>
    </x:if>
    <x:if test="@month">
      <x:value-of select="@month"/>
      <x:text> </x:text>
    </x:if>
    <x:value-of select="@year"/>
  </x:template>

  <x:template match="abstract">
    <x:element name="div">
      <x:attribute name="class">section</x:attribute>
      <x:attribute name="id">abstract</x:attribute>
      <x:element name="h2"><x:text>Abstract</x:text></x:element>
      <x:apply-templates/>
    </x:element>
  </x:template>

  <x:template match="note">
    <x:element name="div">
      <x:attribute name="class">section note</x:attribute>
      <x:element name="h2">
	<x:text>Note: </x:text>
	<x:value-of select="@title"/>
      </x:element>
      <x:apply-templates/>
    </x:element>
  </x:template>

  <x:template match="section">
    <x:element name="div">
      <x:call-template name="add-id"/>
      <x:attribute name="class">section</x:attribute>
      <x:attribute name="id"><x:call-template name="get-id"/></x:attribute>
      <x:element name="h{count(ancestor::section)+2}">
	<x:call-template name="secno"/>
	<x:value-of select="@title"/>
      </x:element>
      <x:apply-templates/>
    </x:element>
  </x:template>

  <!-- ToDo: @title, @align, @width, @height, @alt -->
  <x:template match="figure">
    <x:element name="div">
      <x:call-template name="add-id"/>
      <x:choose>
	<x:when test="./artwork/@src">
	  <x:attribute name="class">figure</x:attribute>
	  <x:apply-templates select="./artwork" />
	  <x:apply-templates select="./preamble" />
	  <!-- If artwork has @src, then assume postamble is the credits -->
	</x:when>
	<x:otherwise>
	  <x:attribute name="class">display</x:attribute>
	  <x:apply-templates />
	</x:otherwise>
      </x:choose>
    </x:element>
  </x:template>

  <x:template match="preamble">
    <x:element name="p"><x:apply-templates/></x:element>
  </x:template>

  <!-- ToDo: @name, @type, @align, @width, @height -->
  <x:template match="artwork">
    <x:choose>
      <x:when test="@src">
	<x:element name="p">
	  <x:element name="img">
	    <x:attribute name="src"><x:value-of select="@src"/></x:attribute>
	    <x:attribute name="alt"><x:value-of select="@alt"/></x:attribute>
	  </x:element>
	  <x:apply-templates select="following-sibling::postamble" mode="credits"/>
	</x:element>
      </x:when>
      <x:otherwise>
	<x:element name="pre">
	  <x:apply-templates/>
	</x:element>
      </x:otherwise>
    </x:choose>
  </x:template>

  <x:template mode="credits" match="postamble">
    <x:element name="span">
      <x:attribute name="class">credit</x:attribute>
      <x:apply-templates/>
    </x:element>
  </x:template>

  <x:template match="postamble">
    <x:element name="p"><x:apply-templates/></x:element>
  </x:template>

  <!-- ToDo: @style=format... -->

  <x:template match="list[@style='empty' or not(@style)]">
    <x:element name="blockquote">
      <x:call-template name="maybe-parent-id"/>
      <x:apply-templates/>
    </x:element>
  </x:template>

  <x:template match="list[@style='hanging']">
    <x:element name="dl">
      <x:call-template name="maybe-parent-id"/>
      <x:apply-templates/>
    </x:element>
  </x:template>

  <x:template match="list[@style='numbers']">
    <x:element name="ol">
      <x:call-template name="maybe-parent-id"/>
      <x:apply-templates/>
    </x:element>
  </x:template>

  <!-- ToDo: handle @counter -->

  <x:template match="list[@style='letters']">
    <x:element name="ol">
      <x:attribute name="class">letters</x:attribute>
      <x:call-template name="maybe-parent-id"/>
      <x:apply-templates/>
    </x:element>
  </x:template>

  <x:template match="list[@style='symbols']">
    <x:element name="ul">
      <x:call-template name="maybe-parent-id"/>
      <x:apply-templates/>
    </x:element>
  </x:template>

  <x:template match="t">
    <x:apply-templates mode="t-as-paragraph" select="."/>
  </x:template>

  <x:template mode="t-as-paragraph" match="t">
    <x:variable name="g">
      <x:apply-templates select="./node()[1]" mode="t"/>
    </x:variable>
    <x:if test="$g != ''">
      <x:element name="p">
	<x:call-template name="maybe-id"/>
	<x:copy-of select="$g"/>
      </x:element>
    </x:if>
    <x:for-each select="list">
      <x:apply-templates select="."/>
      <x:variable name="h">
	<x:apply-templates select="following-sibling::node()[1]" mode="t"/>
      </x:variable>
      <x:if test="$h != ''">	<!-- There is a non-empty node in $h -->
	<x:comment><x:value-of select="$h"/></x:comment>
	<x:element name="p"><x:copy-of select="$h"/></x:element>
      </x:if>
    </x:for-each>
  </x:template>

  <!-- In mode t, iterate over siblings until the next list element -->
  <x:template mode="t" match="list">
  </x:template>

  <x:template mode="t" match="node()">
    <x:apply-templates select="."/>
    <x:apply-templates select="following-sibling::node()[1]" mode="t"/>
  </x:template>

  <x:template match="list/t">
    <x:element name="li">
      <x:call-template name="maybe-id"/>
      <x:apply-templates/>
    </x:element>
  </x:template>

  <x:template match="list[@style='hanging']/t">
    <x:element name="dt">
      <x:call-template name="maybe-id"/>
      <x:value-of select="@hangText"/>
    </x:element>
    <x:element name="dd">
      <x:apply-templates/>
    </x:element>
  </x:template>

  <x:template match="list[@style='empty' or not(@style)]/t">
    <x:apply-templates mode="t-as-paragraph" select="."/>
  </x:template>

  <x:template match="eref">
    <x:element name="a">
      <x:attribute name="href"><x:value-of select="@target"/></x:attribute>
      <x:apply-templates/>
    </x:element>
  </x:template>

  <x:template match="spanx">
    <x:element name="em"><x:apply-templates/></x:element>
  </x:template>

  <x:template match="spanx[@style='strong']">
    <x:element name="strong"><x:apply-templates/></x:element>
  </x:template>

  <x:template match="spanx[@style='verb']">
    <x:element name="code"><x:apply-templates/></x:element>
  </x:template>

  <x:template match="xref">
    <x:variable name="t"><x:value-of select="@target"/></x:variable>
    <x:if test="not(//@anchor=$t)">
      <x:message terminate="no"
	>No anchor found for <x:value-of select="@target"/></x:message>
    </x:if>
    <x:element name="a">
      <x:attribute name="href">#<x:value-of select="$t"/></x:attribute>
      <x:if test="@pageno='true'">
	<x:attribute name="class">pageno</x:attribute>
      </x:if>
      <x:choose>
	<x:when test="./*|./text()">
	  <x:apply-templates/>
	</x:when>
	<x:when test="@format='counter' and //section[@anchor=$t]">
	  <x:apply-templates select="//section[@anchor=$t]" mode="secno-only"/>
	</x:when>
	<x:when test="@format='title' and //section[@anchor=$t]">
	  <x:value-of select="//section[@anchor=$t]/@title"/>
	</x:when>
	<x:when test="@format='none'">
	</x:when>
	<x:when test="(@format='default' or not(@format))
		      and //section[@anchor=$t]">
	  <x:apply-templates select="//section[@anchor=$t]" mode="secno-only"/>
	  <x:text>, “</x:text>
	  <x:value-of select="//section[@anchor=$t]/@title"/>
	  <x:text>,”</x:text>
	</x:when>
	<x:otherwise>
	  <x:text>[</x:text><x:value-of select="$t"/><x:text>]</x:text>
	</x:otherwise>
      </x:choose>
    </x:element>
  </x:template>

  <x:template match="cref">
    <!-- ToDo: handle PI inline=no -->
    <x:if test="$comments = 'yes'">
      <x:element name="span">
	<x:attribute name="class">issue</x:attribute>
	<x:if test="@anchor">
	  <x:attribute name="id"><x:value-of select="@anchor"/></x:attribute>
	</x:if>
	<x:text>[</x:text>
	<x:if test="@source">
	  <x:value-of select="@source"/>
	  <x:text>: </x:text>
	</x:if>
	<x:apply-templates/>
	<x:text>]</x:text>
      </x:element>
    </x:if>
  </x:template>

  <!-- ToDo: vspace -->

  <x:template match="texttable">
    <x:element name="div">
      <x:attribute name="class">table</x:attribute>
      <x:call-template name="maybe-id"/>
      <x:apply-templates select="./preamble"/>
      <x:element name="table">
        <!-- ToDo: @style -->
	<x:if test="@title and not(@suppress-title='true')">
	  <x:element name="caption"><x:value-of select="@title"/></x:element>
	</x:if>
	<x:element name="thead">
	  <x:element name="tr">
	    <x:apply-templates select="./ttcol"/>
	  </x:element>
	</x:element>
	<x:variable name="n" select="count(./ttcol)"/>
	<x:element name="tbody">
	  <x:for-each select="c[count(preceding-sibling::c) mod $n = 0]">
	    <x:element name="tr">
	      <x:apply-templates select="."/>
	    </x:element>
	  </x:for-each>
	</x:element>
      </x:element>
      <x:apply-templates select="./postamble"/>
    </x:element>
  </x:template>

  <x:template match="ttcol">
    <x:element name="th"><x:apply-templates/></x:element>
  </x:template>

  <x:template match="c">
    <!-- Process one row's worth of c elements -->
    <x:variable name="ncols" select="count(preceding-sibling::ttcol)"/>
    <x:variable name="ncells" select="count(preceding-sibling::c)"/>
    <x:variable name="align" select="../ttcol[$ncells mod $ncols + 1]/@align"/>
    <x:element name="td">
      <x:if test="$align">
	<x:attribute name="align"><x:value-of select="$align"/></x:attribute>
      </x:if>
      <x:apply-templates/>
    </x:element>
    <x:if test="$ncells mod $ncols &lt; $ncols - 1">
      <x:apply-templates select="following-sibling::c[1]"/>
    </x:if>
  </x:template>

  <!-- ToDo: sort references if PI sortrefs="yes" -->

  <x:template match="references">
    <x:element name="div">
      <x:attribute name="class">section</x:attribute>
      <x:call-template name="add-id"/>
      <x:element name="h2">
	<x:call-template name="secno"/>
	<x:choose>
	  <x:when test="@title"><x:value-of select="@title"/></x:when>
	  <x:otherwise><x:text>References</x:text></x:otherwise>
	</x:choose>
      </x:element>
      <x:element name="dl">
	<x:apply-templates/>
      </x:element>
    </x:element>
  </x:template>

  <x:template match="reference">
    <x:element name="dt">
      <x:call-template name="add-id"/>
      <x:text>[</x:text>
      <x:value-of select="@anchor"/>
      <x:text>]</x:text>
    </x:element>
    <x:element name="dd">
      <x:apply-templates select="front/author"/>
      <x:apply-templates select="front/title"/>
      <x:apply-templates select="front/date"/>
      <x:text>. </x:text>
      <x:apply-templates select="seriesInfo"/>
      <x:apply-templates select="format"/>
      <x:apply-templates select="annotation"/>
    </x:element>
  </x:template>

  <x:template match="reference/front/author">
    <x:call-template name="name"/>
    <x:text>, </x:text>
  </x:template>

  <x:template match="reference/front/title">
    <x:element name="a">
      <x:if test="ancestor::reference[@target]">
	<x:attribute name="href">
	  <x:value-of select="ancestor::reference/@target"/>
	</x:attribute>
      </x:if>
      <x:element name="em">
	<x:apply-templates/>
	<x:text>.</x:text>
      </x:element>
    </x:element>
    <x:text> </x:text>
  </x:template>

  <x:template match="reference/seriesInfo">
    <x:value-of select="@name"/>
    <x:text> </x:text>
    <x:value-of select="@value"/>
    <x:text>. </x:text>
  </x:template>

  <x:template match="reference/format">
    <x:element name="a">
      <x:if test="@target">
	<x:attribute name="href"><x:value-of select="@target"/></x:attribute>
      </x:if>
      <x:value-of select="@type"/>
    </x:element>
  </x:template>

  <x:template match="annotation">
    <x:text> </x:text>
    <x:apply-templates/>
  </x:template>

  <!-- Subroutines -->

  <!-- maybe-parent-id = return an ID attr (to a list) if necessary -->
  <x:template name="maybe-parent-id">
    <x:if test="../@anchor
		and not(preceding-sibling::*)
		and not (preceding-sibling::text())">
      <x:attribute name="id"><x:value-of select="../@anchor"/></x:attribute>
    </x:if>
  </x:template>

  <!-- ietflink = return an A element linking to a named IETF document -->
  <x:template name="ietflink">
    <x:param name="name"/>
    <x:param name="anchor"/>
    <x:element name="a">
      <x:attribute name="href">
	<x:value-of select="concat($ietfbase, $name)"/>
      </x:attribute>
      <x:value-of select="$anchor"/>
    </x:element>
  </x:template>

  <!-- rfc-list = return a comma-separated list of links to RFC numbers -->
  <x:template name="rfc-list">
    <x:param name="s"/>
    <x:variable name="head" select="substring-before($s, ' ')"/>
    <x:variable name="tail" select="substring-after($s, ' ')"/>
    <x:choose>
      <x:when test="$head">
	<x:call-template name="ietflink">
	  <x:with-param name="name" select="concat('rfc', $head)"/>
	  <x:with-param name="anchor" select="$head"/>
	</x:call-template>
	<x:text>, </x:text>
	<x:call-template name="rfc-list">
	  <x:with-param name="s" select="$tail"/>
	</x:call-template>
      </x:when>
      <x:otherwise>
	<x:call-template name="ietflink">
	  <x:with-param name="name" select="concat('rfc', $s)"/>
	  <x:with-param name="anchor" select="$s"/>
	</x:call-template>
      </x:otherwise>
    </x:choose>
  </x:template>

  <!-- expires = return date six month after given date -->
  <x:template name="expires">
    <x:param name="day"/>
    <x:param name="month"/>
    <x:param name="year"/>
    <x:choose>
      <x:when test="$month='January'">
	<x:value-of select="$day"/>
	<x:text> July </x:text>
	<x:value-of select="$year"/>
      </x:when>
      <x:when test="$month='February'">
	<x:value-of select="$day"/>
	<x:text> August </x:text>
	<x:value-of select="$year"/>
      </x:when>
      <x:when test="$month='March'">
	<x:choose>
	  <x:when test="$day!=31">
	    <x:value-of select="$day"/>
	    <x:text> September </x:text>
	  </x:when>
	  <x:otherwise>
	    <x:text>1 October </x:text>
	  </x:otherwise>
	</x:choose>
	<x:value-of select="$year"/>
      </x:when>
      <x:when test="$month='April'">
	<x:value-of select='$day'/>
	<x:text> October </x:text>
	<x:value-of select="$year"/>
      </x:when>
      <x:when test="$month='May'">
	<x:choose>
	  <x:when test="$day!=31">
	    <x:value-of select='$day'/>
	    <x:text> November </x:text>
	  </x:when>
	  <x:otherwise>
	    <x:text>1 December </x:text>
	  </x:otherwise>
	</x:choose>
	<x:value-of select="$year"/>
      </x:when>
      <x:when test="$month='June'">
	<x:value-of select='$day'/>
	<x:text> December </x:text>
	<x:value-of select="$year+1"/>
      </x:when>
      <x:when test="$month='July'">
	<x:value-of select='$day'/>
	<x:text> January </x:text>
	<x:value-of select="$year+1"/>
      </x:when>
      <x:when test="$month='August'">
	<x:choose>
	  <x:when test="$day &lt; 29">
	    <x:value-of select='$day'/>
	    <x:text> February </x:text>
	  </x:when>
	  <x:otherwise>
	    <x:text>1 March </x:text>
	  </x:otherwise>
	</x:choose>
	<x:value-of select="$year+1"/>
      </x:when>
      <x:when test="$month='September'">
	<x:value-of select='$day'/>
	<x:text> March </x:text>
	<x:value-of select="$year+1"/>
      </x:when>
      <x:when test="$month='October'">
	<x:choose>
	  <x:when test="$day!=31">
	    <x:value-of select='$day'/>
	    <x:text> April </x:text>
	  </x:when>
	  <x:otherwise>
	    <x:text>1 May </x:text>
	  </x:otherwise>
	</x:choose>
	<x:value-of select="$year+1"/>
      </x:when>
      <x:when test="$month='November'">
	<x:value-of select='$day'/>
	<x:text> May </x:text>
	<x:value-of select="$year+1"/>
      </x:when>
      <x:when test="$month='December'">
	<x:choose>
	  <x:when test="$day!=31">
	    <x:value-of select='$day'/>
	    <x:text> June </x:text>
	  </x:when>
	  <x:otherwise>
	    <x:text>1 July </x:text>
	  </x:otherwise>
	</x:choose>
	<x:value-of select="$year+1"/>
      </x:when>
      <x:otherwise>
	<x:message terminate="yes">Unknown month name</x:message>
      </x:otherwise>
    </x:choose>
  </x:template>

  <!-- name = return either the full name or the intials and the surname -->
  <x:template name="name">
    <x:choose>
      <x:when test="@fullname">
	<x:value-of select="@fullname"/>
      </x:when>
      <x:otherwise>
	<x:value-of select="@initials"/>
	<x:text> </x:text>
	<x:value-of select="@surname"/>
      </x:otherwise>
    </x:choose>
  </x:template>

  <!-- status = return the status section -->
  <x:template name="status">
    <x:param name="category"/>
    <x:element name="div">
      <x:attribute name="class">section</x:attribute>
      <x:attribute name="id">status</x:attribute>
      <x:element name="h2">Status of This Memo</x:element>
      <x:choose>
	<x:when test="$category = 'info'">
	  <x:element name="p">
	    <x:text>This document is not an Internet Standards Track
	    specification; it is published for informational purposes.</x:text>
	  </x:element>
	</x:when>
	<x:otherwise>
	  <x:element name="p">
	    <x:text>[UNHANDLED CATEGORY]</x:text>
	  </x:element>
	</x:otherwise>
      </x:choose>
    </x:element>
  </x:template>

  <!-- copyright = return the copyright section -->
  <x:template name="copyright">
    <x:param name="ipr">trust200902</x:param>
    <x:param name="submissionType">IETF</x:param>
    <x:element name="div">
      <x:attribute name="class">section</x:attribute>
      <x:attribute name="id">copyright</x:attribute>
      <x:element name="h2">Copyright Notice</x:element>
      <x:choose>
	<x:when test="$ipr = 'trust200902'">
	  <x:element name="p"><x:text>Copyright © </x:text><x:value-of
	  select="$year"/><x:text> IETF Trust and the persons
	  identified as the document authors. All rights
	  reserved.</x:text></x:element>
	  <x:element name="p" ><x:text >This document is subject to
	  </x:text ><x:element name="a" ><x:attribute name="href"
	  >http://tools.ietf.org/html/bcp78</x:attribute ><x:text
	  >BCP 78</x:text ></x:element ><x:text > and the IETF Trust's
	  Legal Provisions Relating to IETF Documents (</x:text
	  ><x:element name="a" ><x:attribute name="href"
	  >http://trustee.ietf.org/license-info</x:attribute ><x:text
	  >http://trustee.ietf.org/license-info</x:text ></x:element
	  ><x:text >) in effect on the date of publication of this
	  document. Please review these documents carefully, as they
	  describe your rights and restrictions with respect to this
	  document.</x:text ><x:if test="$submissionType = 'IETF'"
	  ><x:text > Code Components extracted from this document must
	  include Simplified BSD License text as described in</x:text
	  ><x:element name="a" ><x:attribute name="href"
	  >http://tools.ietf.org/html/rfc6920#section-4</x:attribute
	  ><x:text >Section 4.e</x:text ></x:element ><x:text > of the
	  Trust Legal Provisions and are provided without warranty as
	  described in the Simplified BSD License.</x:text ></x:if
	  ></x:element>
	</x:when>
	<x:otherwise>
	  <x:element name="p"><x:text>[Copyright]</x:text></x:element>
	</x:otherwise>
      </x:choose>
    </x:element>
  </x:template>

  <!-- maybe-id = add an ID attribute if the element has an @anchor -->
  <x:template name="maybe-id">
    <x:if test="@anchor">
      <x:attribute name="id"><x:value-of select="@anchor"/></x:attribute>
    </x:if>
  </x:template>

  <!-- add-id = add an ID attribute -->
  <x:template name="add-id">
    <x:attribute name="id"><x:call-template name="get-id"/></x:attribute>
  </x:template>

  <!-- get-id = get value of @anchor or generate an ID -->
  <x:template name="get-id">
    <x:choose>
      <x:when test="@anchor"><x:value-of select="@anchor"/></x:when>
      <x:otherwise><x:value-of select="generate-id()"/></x:otherwise>
    </x:choose>
  </x:template>

  <!-- keywords = return a META element with all keywords -->
  <x:template name="keywords">
    <x:if test=".//keyword">
      <x:element name="meta">
	<x:attribute name="name">keywords</x:attribute>
	<x:attribute name="content">
	  <x:for-each select="front/keyword">
	    <x:value-of select="."/>
	    <x:text> </x:text>
	  </x:for-each>
	</x:attribute>
      </x:element>
    </x:if>
  </x:template>

  <!-- secno = return a SPAN with the calculated section number -->
  <x:template name="secno">
    <x:element name="span">
      <x:attribute name="class">secno</x:attribute>
      <x:call-template name="secno-content"/>
      <x:text>. </x:text>
    </x:element>
  </x:template>

  <!-- secno-content = return just the section number -->
  <x:template name="secno-content">
    <x:choose>
      <x:when test="self::references">
	<x:value-of select="count(/rfc/middle/section) + 1"/>
      </x:when>
      <x:when test="ancestor::back">
	<x:text>Appendix </x:text>
	<x:number level="multiple" format="A.1" count="section"/>
      </x:when>
      <x:otherwise>
	<x:number level="multiple" format="1.1" count="section"/>
      </x:otherwise>
    </x:choose>
  </x:template>

  <!-- toc = return a DIV.section with a ToC inside -->
  <x:template name="toc">
    <x:if test="$toc = 'yes' and $tocdepth > 0">
      <x:element name="div">
	<x:attribute name="class">section</x:attribute>
	<x:attribute name="id">toc</x:attribute>
	<x:element name="h2"><x:text>Table of contents</x:text></x:element>
	<x:element name="ul">
	  <x:apply-templates select="./middle/section" mode="toc">
	    <x:with-param name="depth" select="1"/>
	  </x:apply-templates>
	  <!-- Add link(s) to references -->
	  <x:for-each select="/rfc/back/references">
	    <x:element name="li">
	      <x:element name="a">
		<x:attribute name="href">
		  <x:text>#</x:text>
		  <x:call-template name="get-id"/>
		</x:attribute>
		<x:call-template name="secno"/>
		<x:choose>
		  <x:when test="@title"><x:value-of select="@title"/></x:when>
		  <x:otherwise><x:text>References</x:text></x:otherwise>
		</x:choose>
	      </x:element>
	    </x:element>
	  </x:for-each>
	  <x:apply-templates select="./back/section" mode="toc">
	    <x:with-param name="depth" select="1"/>
	  </x:apply-templates>
	  <!-- Add link to authors -->
	  <x:element name="li">
	    <x:element name="a">
	      <x:attribute name="href">#authors</x:attribute>
	      <x:text>Authors' addresses</x:text>
	    </x:element>
	  </x:element>
	</x:element>
      </x:element>
    </x:if>
  </x:template>

  <x:template mode="toc" match="section">
    <x:param name="depth"/>
    <x:if test="@toc != 'exclude'">
      <x:element name="li">
	<x:element name="a">
	  <x:attribute name="href">
	    <x:text>#</x:text>
	    <x:call-template name="get-id"/>
	  </x:attribute>
	  <x:call-template name="secno"/>
	    <x:value-of select="@title"/>
	    <x:if test="./section and $depth &lt; $tocdepth">
	      <x:element name="ul">
		<x:apply-templates select="./section" mode="toc">
		  <x:with-param name="depth" select="$depth + 1"/>
		</x:apply-templates>
	      </x:element>
	    </x:if>
	</x:element>
      </x:element>
    </x:if>
  </x:template>

  <x:template mode="secno-only" match="section">
    <x:call-template name="secno-content"/>
  </x:template>

  <!-- parse-pi = search the given nodes for a given pseudo-attribute -->
  <x:template name="parse-pi">
    <x:param name="nodes"/>   <!-- The PIs to search through -->
    <x:param name="name"/>    <!-- The pseudo-attr we're looking for -->
    <x:param name="default"/> <!-- Value if absent -->
    <x:choose>
      <x:when test="$nodes"> <!-- Still nodes to look at -->
	<x:variable name="h" select="normalize-space($nodes[1])"/>
	<x:variable name="n" select="normalize-space(substring-before($h, '='))"/>
	<x:choose>
	  <x:when test="$n = $name"> <!-- Found the name we're looking for -->
	    <x:variable name="v" select="normalize-space(substring-after($h, '='))"/>
	    <x:value-of select="substring($v, 2, string-length($v) - 2)"/>
	  </x:when>
	  <x:otherwise>	<!-- Not the name we're looking for, so recurse -->
	    <x:call-template name="parse-pi">
	      <x:with-param name="nodes" select="$nodes[position() != 1]"/>
	      <x:with-param name="name" select="$name"/>
	      <x:with-param name="default" select="$default"/>
	    </x:call-template>
	  </x:otherwise>
	</x:choose>
      </x:when>
      <x:otherwise> <!-- No more nodes to look at -->
	<x:value-of select="$default"/>
      </x:otherwise>
    </x:choose>
  </x:template>

</x:stylesheet>
