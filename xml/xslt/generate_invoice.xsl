<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" exclude-result-prefixes="xs" version="2.0">


    <xsl:import href="pages.xslt"/>
    <!--<xsl:import href="meta.xslt"/>
    <xsl:import href="toc.xslt"/>
    <xsl:import href="structure.xslt"/>
    <xsl:import href="att-set.xslt"/>
    <xsl:import href="block.xslt"/>
    <xsl:import href="findings.xslt"/>
    <xsl:import href="auto.xsl"/>
    <xsl:import href="table.xslt"/>
    <xsl:import href="lists.xslt"/>
    <xsl:import href="inline.xslt"/>
    <xsl:import href="graphics.xslt"/>
    <xsl:import href="generic.xslt"/>
    <xsl:import href="numbering.xslt"/>
    <xsl:import href="waiver.xslt"/>-->
    
    <xsl:include href="styles_inv.xslt"/>
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>


    <!-- ****** AUTO_NUMBERING_FORMAT:	value of the <xsl:number> element used for auto numbering -->
    <!--<xsl:param name="AUTO_NUMBERING_FORMAT" select="'1.1.1'"/>-->
    <xsl:param name="INVOICE_NO">
        <xsl:choose>
            <xsl:when test="/invoice/@invoice_no">
                <xsl:value-of select="/invoice/@invoice_no"/>
            </xsl:when>
            <xsl:otherwise>00/000</xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <xsl:param name="DATE">
        <xsl:choose>
            <xsl:when test="/invoice/@date">
                <xsl:value-of select="format-date(/invoice/@date, '[MNn] [D1], [Y]', 'en', (), ())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="format-date(current-date(), '[MNn] [D1], [Y]', 'en', (), ())"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <!-- ROOT -->
    <xsl:template match="/offerte">
        <!-- Invoice is generated straight from offerte -->
        <fo:root>
            <xsl:call-template name="layout-master-set-invoice"/>
            <xsl:call-template name="Content"/>
      </fo:root>
    </xsl:template>

    <xsl:template match="/invoice">
        <!-- Invoice is generated from custom invoice xml -->
        <fo:root>
            <xsl:call-template name="layout-master-set-invoice"/>
            <xsl:call-template name="Content"/>
        </fo:root>
    </xsl:template>
    
    <!-- CONTENT -->
    <xsl:template name="invoice_from_offerte">
        <xsl:variable name="fee" select="/offerte/meta/pentestinfo/fee * 1"/>
        <xsl:variable name="vat" select="$fee div 100 * 21"/>
        <xsl:variable name="denomination">
            <xsl:choose>
                <xsl:when test="/offerte/meta/pentestinfo/fee/@denomination = 'euro'">€</xsl:when>
                <xsl:when test="/offerte/meta/pentestinfo/fee/@denomination = 'dollar'">$</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="invoiceStart">
            <xsl:with-param name="INVOICE_NO" select="$INVOICE_NO"/>
            <xsl:with-param name="DATE" select="$DATE"/>
        </xsl:call-template>
        <fo:block>
            <fo:table width="100%" table-layout="fixed" xsl:use-attribute-sets="big-space-below table-shading">
                <fo:table-column column-width="proportional-column-width(90)"/>
                <fo:table-column column-width="proportional-column-width(10)"/>
                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell xsl:use-attribute-sets="td">
                            <fo:block><xsl:value-of select="/offerte/meta/pentestinfo/duration"/>-day&#160;<xsl:value-of select="/offerte/meta/offered_service_short"/>&#160;<xsl:value-of select="/offerte/meta/permission_parties/client/short_name"/></fo:block>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="td align-right">
                            <fo:block xsl:use-attribute-sets="p"><xsl:value-of select="$denomination"/>&#160;<xsl:number value="$fee" grouping-separator="," grouping-size="3"/>.--</fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row>
                        <fo:table-cell xsl:use-attribute-sets="td">
                            <fo:block>VAT 21%</fo:block>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="td align-right">
                            <fo:block xsl:use-attribute-sets="p"><xsl:value-of select="$denomination"/>&#160;<xsl:number value="$vat" grouping-separator="," grouping-size="3"/>.--</fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row xsl:use-attribute-sets="border-top bold">
                        <fo:table-cell xsl:use-attribute-sets="td">
                            <fo:block>Total amount to be paid</fo:block>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="td align-right">
                            <fo:block xsl:use-attribute-sets="p"><xsl:value-of select="$denomination"/>&#160;<xsl:number value="$vat + $fee" grouping-separator="," grouping-size="3"/>.--</fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
        <xsl:call-template name="invoiceEnd">
            <xsl:with-param name="INVOICE_NO" select="$INVOICE_NO"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="custom_invoice">
        <xsl:variable name="denomination">
            <xsl:choose>
                <xsl:when test="/invoice/@denomination = 'euro'">€</xsl:when>
                <xsl:when test="/invoice/@denomination = 'dollar'">$</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="invoiceStart">
            <xsl:with-param name="INVOICE_NO" select="$INVOICE_NO"/>
            <xsl:with-param name="DATE" select="$DATE"/>
        </xsl:call-template>
        <fo:block>
            <fo:table width="100%" table-layout="fixed" xsl:use-attribute-sets="big-space-below table-shading">
                <fo:table-column column-width="proportional-column-width(90)"/>
                <fo:table-column column-width="proportional-column-width(10)"/>
                <fo:table-body>
                    <xsl:for-each select="servicesdelivered/service">
                        <xsl:variable name="fee" select="fee * 1"/>
                        <fo:table-row>
                            <fo:table-cell xsl:use-attribute-sets="td">
                                <fo:block><xsl:value-of select="description"/></fo:block>
                            </fo:table-cell>
                            <fo:table-cell xsl:use-attribute-sets="td align-right">
                                <fo:block xsl:use-attribute-sets="p"><xsl:value-of select="$denomination"/>&#160;<xsl:number value="$fee" grouping-separator="," grouping-size="3"/>.--</fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </xsl:for-each>
                    <xsl:if test="additionalcosts">
                        <fo:table-row>
                            <fo:table-cell xsl:use-attribute-sets="td padding-top">
                                <fo:block xsl:use-attribute-sets="bold">Additional Expenses</fo:block>
                            </fo:table-cell>
                            <fo:table-cell xsl:use-attribute-sets="td align-right padding-top">
                                <fo:block xsl:use-attribute-sets="p">&#160;</fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </xsl:if>
                    <xsl:for-each select="additionalcosts/cost">
                        <xsl:variable name="fee" select="fee * 1"/>
                        <fo:table-row>
                            <fo:table-cell xsl:use-attribute-sets="td" padding-left="8mm">
                                <fo:block><xsl:value-of select="description"/></fo:block>
                            </fo:table-cell>
                            <fo:table-cell xsl:use-attribute-sets="td align-right">
                                <fo:block xsl:use-attribute-sets="p"><xsl:value-of select="$denomination"/>&#160;<xsl:number value="$fee" grouping-separator="," grouping-size="3"/>.--</fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </xsl:for-each>
                    <!-- TODO -->
                    <xsl:for-each-group select="servicesdelivered/service | additionalcosts/cost" group-by="fee/@vat[.='yes']">
                        <xsl:variable name="vat">
                            <xsl:value-of select="sum(current-group()/fee) div 100 * 21" />
                        </xsl:variable>
                        <xsl:variable name="total">
                            <xsl:value-of select="sum(current-group()/fee) + $vat" />
                        </xsl:variable>
                        <fo:table-row>
                            <fo:table-cell xsl:use-attribute-sets="td padding-top">
                               <fo:block>VAT 21%</fo:block>
                           </fo:table-cell>
                            <fo:table-cell xsl:use-attribute-sets="td align-right padding-top">
                               <fo:block xsl:use-attribute-sets="p"><xsl:value-of select="$denomination"/>&#160;<xsl:number value="$vat" grouping-separator="," grouping-size="3"/>.--</fo:block>
                           </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row xsl:use-attribute-sets="border-top bold">
                           <fo:table-cell xsl:use-attribute-sets="td">
                               <fo:block>Total amount to be paid</fo:block>
                            </fo:table-cell>
                            <fo:table-cell xsl:use-attribute-sets="td align-right">
                              <fo:block xsl:use-attribute-sets="p"><xsl:value-of select="$denomination"/>&#160;<xsl:number value="$total" grouping-separator="," grouping-size="3"/>.--</fo:block>
                            </fo:table-cell>
                         </fo:table-row>
                    </xsl:for-each-group>
                </fo:table-body>
            </fo:table>
        </fo:block>
        <xsl:call-template name="invoiceEnd">
            <xsl:with-param name="INVOICE_NO" select="$INVOICE_NO"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template name="invoiceStart">
        <xsl:param name="INVOICE_NO"/>
        <xsl:param name="DATE"/>
        <fo:block xsl:use-attribute-sets="title-0">Invoice nr. <xsl:value-of select="$INVOICE_NO"
            /></fo:block>
        <fo:block>
            <fo:block>
                <xsl:value-of select="/*/meta//client/full_name"/>
            </fo:block>
            <fo:block>
                <xsl:if test="/*/meta//client/invoice_rep">T.a.v. <xsl:value-of
                        select="/offerte/meta/permission_parties/client/invoice_rep"/></xsl:if>
            </fo:block>
            <fo:block>
                <xsl:value-of select="/*/meta//client/address"/>
            </fo:block>
            <fo:block><xsl:value-of select="/*/meta//client/postal_code"/>&#160;<xsl:value-of
                    select="/*/meta//client/city"/></fo:block>
            <fo:block>
                <xsl:value-of select="/*/meta//client/country"/>
            </fo:block>
            <fo:block>
                <xsl:if test="/*/meta//client/invoice_mail">
                    <xsl:value-of select="/*/meta//client/invoice_mail"/>
                </xsl:if>
            </fo:block>
        </fo:block>
        <fo:block xsl:use-attribute-sets="p big-space-below" text-align="right">
            <xsl:value-of select="$DATE"/>
        </fo:block>
        <fo:block xsl:use-attribute-sets="title-2">Services Delivered</fo:block>
    </xsl:template>

<xsl:template name="invoiceEnd">
    <xsl:param name="INVOICE_NO"/>
    <fo:block xsl:use-attribute-sets="big-space-below"><xsl:value-of
        select="/*/meta/company/full_name"/> donates > 90% of its entire profits to
        charity.</fo:block>
    <fo:block xsl:use-attribute-sets="big-space-below">Please be so kind to pay within 30 days
        by money transfer, to the following account:</fo:block>
    
    <fo:block xsl:use-attribute-sets="big-space-below" margin-left="1.3cm">
        <fo:block>
            <xsl:value-of select="/*/meta/company/full_name"/>
        </fo:block>
        <fo:block>IBAN: <xsl:value-of select="/*/meta/company/iban"/></fo:block>
        <fo:block>Reference: <xsl:value-of select="$INVOICE_NO"/></fo:block>
    </fo:block>
    
    <fo:block>Kind regards,</fo:block>
    <fo:block>your dedicated team at</fo:block>
    <fo:block font-style="italic">
        <xsl:value-of select="/*/meta/company/full_name"/>
    </fo:block>
</xsl:template>
    
    <!-- overrules for pages.xslt -->
    <xsl:template name="Content">
        <fo:page-sequence master-reference="Invoice">
            <xsl:call-template name="page_header"/>
            <xsl:call-template name="page_footer"/>
            <fo:flow flow-name="region-body" xsl:use-attribute-sets="DefaultFont">
                <fo:block>
                    <xsl:choose>
                        <xsl:when test="self::offerte">
                            <xsl:call-template name="invoice_from_offerte"/>
                        </xsl:when>
                        <xsl:when test="self::invoice">
                            <xsl:call-template name="custom_invoice"/>
                        </xsl:when>
                    </xsl:choose>
                </fo:block>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>
    
    <xsl:template name="page_header">
        <fo:static-content flow-name="region-before" xsl:use-attribute-sets="HeaderFont">
            <fo:block>
            <fo:table width="100%" table-layout="fixed">
                <fo:table-column column-width="proportional-column-width(40)"/>
                <fo:table-column column-width="proportional-column-width(20)"/>
                <fo:table-column column-width="proportional-column-width(40)"/>
                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell text-align="right" display-align="after" padding-bottom="5mm">
                            <fo:block xsl:use-attribute-sets="TinyFont">
                                <fo:block xsl:use-attribute-sets="bold orange-text"><xsl:value-of select="/*/meta/company/full_name"/></fo:block>
                                <fo:block><xsl:value-of select="/*/meta/company/address"/></fo:block>
                                <fo:block><xsl:value-of select="/*/meta/company/postal_code"/>&#160;<xsl:value-of select="/*/meta/company/city"/></fo:block>
                                <fo:block><xsl:value-of select="/*/meta/company/country"/></fo:block>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell text-align="center">
                            <fo:block><fo:external-graphic xsl:use-attribute-sets="logo"/></fo:block>
                        </fo:table-cell>
                        <fo:table-cell display-align="after" padding-bottom="5mm">
                            <fo:block xsl:use-attribute-sets="TinyFont">
                                <fo:block xsl:use-attribute-sets="bold orange-text"><xsl:value-of select="/*/meta/company/website"/></fo:block>
                                <fo:block><xsl:value-of select="/*/meta/company/email"/></fo:block>
                                <fo:block>Chamber of Commerce <xsl:value-of select="/*/meta/company/coc"/></fo:block>
                                <fo:block>VAT number <xsl:value-of select="/*/meta/company/vat_no"/></fo:block>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
        </fo:static-content>
    </xsl:template>
    
    <xsl:template name="page_footer">
        <fo:static-content flow-name="region-after" xsl:use-attribute-sets="FooterFont">
            <fo:block xsl:use-attribute-sets="footer">
                <fo:inline xsl:use-attribute-sets="TinyFont orange-text">Please keep digital unless absolutely required. Read the (unique) terms and conditions of Radically Open Security at: https://radicallyopensecurity.com/TermsandConditions.pdf</fo:inline>
            </fo:block>
        </fo:static-content>
    </xsl:template>
</xsl:stylesheet>

