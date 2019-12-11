<!--- 
	Originalmente se bajaba el Firmador por JNLP:
		El FirmaDigital.jnlp se genera 2 veces:
			1. En un iframe de login.cfm, para realizar el download del jnlp (se indica enviando parámetro TKN1=<token>)
			2. Por el javaws, durante la ejecución del jnlp, porque existe un href para que vuelve a bajar el jnlp y no de errores de seguridad (se indica enviando parámetro TKN2=<token> y TKN3=<tkn3>)
	Posteriormente se bajaba el Instalador por JNLP:
		Se genera el ajax 
		Fuerza la logica del punto 2
	Actualmente se baja el Instalador como .jar
--->

<cfif IsDefined("url.TKN1")>
	<cfset LvarTOKEN=url.TKN1>
	<cfset LvarChecksum = "010203">
<cfelse>
	<cfset LvarTOKEN=url.TKN2>
	<cfset LvarChecksum = hash(fileReadBinary( expandPath( "lib/FirmaDigitalServer.jar" ) ), "MD5")>
</cfif>
<cfset LvarCodebase = createObject("component","home.public.FirmaDigital.plugin.cluster").getJNLP_Codebase()>

<cfsavecontent variable="LvarJNLP"
><?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- <cfoutput>#hash(fileReadBinary( expandPath( "lib/FirmaDigitalServer.jar" ) ), "MD5")#</cfoutput> -->
<jnlp	codebase="<cfoutput>#LvarCodebase#</cfoutput>"
		href="init_installer.cfm?TKN2=<cfoutput>#LvarToken#</cfoutput>&proceso=<cfoutput>#url.proceso#</cfoutput>";
		spec="1.0+">
	<information>
		<title>Inicializa FirmaDigital</title>
		<vendor>SOIN Soluciones Integrales S. A.</vendor>
		<homepage href="http://www.soin.co.cr"/>
		<description>Busca, Ejecuta o Instala el Servidor Local de FirmaDigital</description>
		<description kind="short">FirmaDigitalInit</description>
	</information>
	<update check="always"/>
	<security>
		<all-permissions/>
	</security>
	<resources>
		<java version="1.8+" initial-heap-size="128m" max-heap-size="1024m"/>
		<jar href="lib/FirmaDigitalSignInit.jar" main="true"/>
	</resources>
	<application-desc main-class="com.soin.firmaDigital.InitServer">
		<argument><cfoutput>#LvarToken#</cfoutput></argument>
		<argument><cfoutput>#LvarChecksum#</cfoutput></argument>
		<argument><cfoutput>#url.proceso#</cfoutput></argument>
	</application-desc>
</jnlp>
</cfsavecontent>

<cfheader name="Expires" value="0">
<cfheader name="Pragma" value="no-cache">
<cfheader name="Content-Disposition" value="attachment; filename=FirmaDigital.jnlp">
<cfcontent type="application/x-java-jnlp-file" variable="#LvarJNLP.getBytes("UTF-8")#">
