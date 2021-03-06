<%@ page contentType="text/html;charset=UTF-8" import="au.org.ala.collectory.DataResource; au.org.ala.collectory.Institution" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.skin.layout}"/>
    <title><cl:pageTitle><g:fieldValue bean="${instance}" field="name"/></cl:pageTitle></title>
    <script type="text/javascript" language="javascript" src="https://www.google.com/jsapi"></script>
    <r:require modules="jquery, fancybox, jquery_jsonp, charts_plugin"/>
    <r:script type="text/javascript">
      biocacheServicesUrl = "${grailsApplication.config.biocacheServicesUrl}";
      biocacheWebappUrl = "${grailsApplication.config.biocacheUiURL}";
      loadLoggerStats = ${!grailsApplication.config.disableLoggerLinks.toBoolean()};
      $(document).ready(function () {
        $("a#lsid").fancybox({
            'hideOnContentClick': false,
            'titleShow': false,
            'autoDimensions': false,
            'width': 600,
            'height': 180
        });
        $("a.current").fancybox({
            'hideOnContentClick': false,
            'titleShow': false,
            'titlePosition': 'inside',
            'autoDimensions': true,
            'width': 300
        });
      });
    </r:script>
</head>

<body>
<div id="content">
    <div class="row">
            <div class="col-md-8">
                <cl:h1 value="${instance.name}"/>
                <g:set var="parents" value="${instance.listParents()}"/>
                <g:each var="p" in="${parents}">
                    <h2><g:link action="show" id="${p.uid}">${p.name}</g:link></h2>
                </g:each>
                <cl:valueOrOtherwise value="${instance.acronym}"><span
                        class="acronym"><g:message code="public.show.header.acronym"/>: ${fieldValue(bean: instance, field: "acronym")}</span></cl:valueOrOtherwise>
                <g:if test="${instance.guid?.startsWith('urn:lsid:')}">
                    <span class="lsid"><a href="#lsidText" id="lsid" class="local"
                                          title="Life Science Identifier (pop-up)"><g:message code="public.lsid" /></a></span>

                    <div style="display:none; text-align: left;">
                        <div id="lsidText" style="text-align: left;">
                            <b><a class="external_icon" href="https://wayback.archive.org/web/20100515104710/http://lsids.sourceforge.net:80/"
                                  target="_blank"><g:message code="public.lsidtext.link" />:</a></b>
                            <p><cl:guid target="_blank" guid='${fieldValue(bean: instance, field: "guid")}'/></p>
                            <p><g:message code="public.lsidtext.des" />.</p>
                        </div>
                    </div>
                </g:if>

                <g:if test="${instance.pubDescription}">
                    <h2><g:message code="public.des" /></h2>
                    <cl:formattedText>${fieldValue(bean: instance, field: "pubDescription")}</cl:formattedText>
                    <cl:formattedText>${fieldValue(bean: instance, field: "techDescription")}</cl:formattedText>
                </g:if>
                <g:if test="${instance.focus}">
                    <h2><g:message code="public.si.content.label02" /></h2>
                    <cl:formattedText>${fieldValue(bean: instance, field: "focus")}</cl:formattedText>
                </g:if>
                <h2><g:message code="public.si.content.label03" /></h2>
                <ol>
                    <g:each var="c" in="${instance.listCollections().sort { it.name }}">
                        <li><g:link controller="public" action="show"
                                    id="${c.uid}">${c?.name}</g:link> ${c?.makeAbstract(400)}</li>
                    </g:each>
                </ol>

                <div id='usage-stats'>
                    <h2><g:message code="public.usagestats.label" /></h2>

                    <div id='usage'>
                        <p><g:message code="public.usage.des" />...</p>
                    </div>
                </div>

                <h2><g:message code="public.si.content.label04" /></h2>

                <div>
                    <p style="padding-bottom:8px;"><span id="numBiocacheRecords"><g:message code="public.numbrs.des01" /></span> <g:message code="public.numbrs.des02" />.</p>
                    <p><cl:recordsLink entity="${instance}"><g:message code="public.numbrs.link" /> ${instance.name}.</cl:recordsLink></p>
                </div>

                <div id="recordsBreakdown" class="section vertical-charts">
                    <div id="charts"></div>
                </div>

                <cl:lastUpdated date="${instance.lastUpdated}"/>

            </div><!--close section-->
            <section class="col-md-4">

                <g:if test="${fieldValue(bean: instance, field: 'logoRef') && fieldValue(bean: instance, field: 'logoRef.file')}">
                    <section class="public-metadata">
                    <img class="institutionImage"
                         src='${resource(absolute: "true", dir: "data/institution/", file: fieldValue(bean: instance, field: 'logoRef.file'))}'/>
                    </section>
                </g:if>

                <g:if test="${fieldValue(bean: instance, field: 'imageRef') && fieldValue(bean: instance, field: 'imageRef.file')}">
                    <section class="public-metadata">
                        <img alt="${fieldValue(bean: instance, field: "imageRef.file")}"
                             src="${resource(absolute: "true", dir: "data/institution/", file: instance.imageRef.file)}"/>
                        <cl:formattedText
                                pClass="caption">${fieldValue(bean: instance, field: "imageRef.caption")}</cl:formattedText>
                        <cl:valueOrOtherwise value="${instance.imageRef?.attribution}"><p
                                class="caption">${fieldValue(bean: instance, field: "imageRef.attribution")}</p></cl:valueOrOtherwise>
                        <cl:valueOrOtherwise value="${instance.imageRef?.copyright}"><p
                                class="caption">${fieldValue(bean: instance, field: "imageRef.copyright")}</p></cl:valueOrOtherwise>
                    </section>
                </g:if>

                <div id="dataAccessWrapper" style="display:none;">
                    <g:render template="dataAccess" model="[instance:instance]"/>
                </div>

                <section class="public-metadata">
                    <h4><g:message code="public.location" /></h4>
                    <g:if test="${instance.address != null && !instance.address.isEmpty()}">
                        <p>
                            <cl:valueOrOtherwise
                                    value="${instance.address?.street}">${instance.address?.street}<br/></cl:valueOrOtherwise>
                            <cl:valueOrOtherwise
                                    value="${instance.address?.city}">${instance.address?.city}<br/></cl:valueOrOtherwise>
                            <cl:valueOrOtherwise
                                    value="${instance.address?.state}">${instance.address?.state}</cl:valueOrOtherwise>
                            <cl:valueOrOtherwise
                                    value="${instance.address?.postcode}">${instance.address?.postcode}<br/></cl:valueOrOtherwise>
                            <cl:valueOrOtherwise
                                    value="${instance.address?.country}">${instance.address?.country}<br/></cl:valueOrOtherwise>
                        </p>
                    </g:if>
                    <g:if test="${instance.email}"><cl:emailLink>${fieldValue(bean: instance, field: "email")}</cl:emailLink><br/></g:if>
                    <cl:ifNotBlank value='${fieldValue(bean: instance, field: "phone")}'/>
                </section>

            <!-- contacts -->
                <g:render template="contacts" bean="${instance.getPublicContactsPrimaryFirst()}"/>

            <!-- web site -->
                <g:if test="${instance.websiteUrl}">
                    <section class="public-metadata">
                        <h4><g:message code="public.website" /></h4>

                        <div class="webSite">
                            <a class='external' target="_blank"
                               href="${instance.websiteUrl}"><g:message code="public.si.website.link01" /> <cl:institutionType
                                    inst="${instance}"/><g:message code="public.si.website.link02" /></a>
                        </div>
                    </section>
                </g:if>

            <!-- network membership -->
                <g:if test="${instance.networkMembership}">
                    <section class="public-metadata">
                        <h4><g:message code="public.network.membership.label" /></h4>
                        <g:if test="${instance.isMemberOf('CHAEC')}">
                            <p><g:message code="public.network.membership.des01" /></p>
                            <img src="${resource(absolute: "true", dir: "data/network/", file: "chaec-logo.png")}"/>
                        </g:if>
                        <g:if test="${instance.isMemberOf('CHAH')}">
                            <p><g:message code="public.network.membership.des02" /></p>
                            <a target="_blank" href="http://www.chah.gov.au"><img style="padding-left:25px;"
                                                                                  src="${resource(absolute: "true", dir: "data/network/", file: "CHAH_logo_col_70px_white.gif")}"/>
                            </a>
                        </g:if>
                        <g:if test="${instance.isMemberOf('CHAFC')}">
                            <p><g:message code="public.network.membership.des03" /></p>
                            <img src="${resource(absolute: "true", dir: "data/network/", file: "CHAFC_sm.jpg")}"/>
                        </g:if>
                        <g:if test="${instance.isMemberOf('CHACM')}">
                            <p><g:message code="public.network.membership.des04" /></p>
                            <img src="${resource(absolute: "true", dir: "data/network/", file: "chacm.png")}"/>
                        </g:if>
                    </div>
                </g:if>

            <!-- external identifiers -->
                <g:render template="externalIdentifiers" model="[instance:instance]"/>

    </div>
        </div><!--close content-->
</div>
<g:render template="charts" model="[facet:'institution_uid', instance: instance]" />
</body>
</html>
