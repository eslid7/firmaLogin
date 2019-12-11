<!--- 
	El FirmaDigital.jnlp se genera 2 veces:
		1. En un iframe de sign.cfm, para realizar el download del jnlp (se indica enviando parámetro TKN1=<token>)
		2. Por el javaws, durante la ejecución del jnlp, porque existe un href para que vuelve a bajar el jnlp y no de errores de seguridad (se indica enviando parámetro TKN2=<token> y TKN3=<tkn3>)
--->

<cfset LvarCodebase = createObject("component","home.public.FirmaDigital.plugin.cluster").getJNLP_Codebase()>

<cfsavecontent variable="LvarJNLP"
><?xml version="1.0" encoding="UTF-8" standalone="no"?>
<jnlp	codebase="<cfoutput>#LvarCodebase#</cfoutput>"
		href="prueba_FDjnlp.cfm" 
		spec="1.0+">
	<information>
		<title>Firma de Mensaje XML por FirmaDigital</title>
		<vendor>SOIN Soluciones Integrales S. A.</vendor>
		<homepage href="http://www.soin.co.cr"/>
		<description>Prueba para configuración de bajada y ejecución automática de archivos .FDjnlp</description>
		<description kind="short">FirmaDigitalTest</description>
	</information>
	<update check="always"/>
	<security>
		<all-permissions/>
	</security>
	<resources>
		<java version="1.8+" initial-heap-size="128m" max-heap-size="1024m"/>
		<jar href="lib/FirmaDigitalSignInit.jar" main="true"/>
	</resources>
	<application-desc main-class="com.soin.firmaDigital.test">
	</application-desc>
</jnlp>
</cfsavecontent>

<cfheader name="Expires" value="0">
<cfheader name="Pragma" value="no-cache">
<cfheader name="Content-Disposition" value="attachment; filename=prueba.FDjnlp">
<cfcontent type="application/x-java-jnlp-file" variable="#LvarJNLP.getBytes("UTF-8")#">
