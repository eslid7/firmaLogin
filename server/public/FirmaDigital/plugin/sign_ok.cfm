<h1>Proceso de Firma de Mensajes XML por Firma Digital en el Servidor</h1>
<!--- Control de GoBack --->
<cfset createObject("component","login").pintaControlBack()>

<script> 
	function getToken()
	{
		return "*";
	}
</script> 
<cftry>
	<cfset LvarMSGData = createObject("component","sign").getMSGData(form.token)>
	<!--- 
		LvarMSGData.SignedXML
		LvarMSGData.Componente
		LvarMSGData.procesaMSG
		LvarMSGData.Parametros
		LvarMSGData.Parametros.Cert509.TKN
		LvarMSGData.Parametros.Cert509.UID
	--->

	<cfinvoke 
			component						= "#LvarMSGData.Componente#"
			method							= "#LvarMSGData.procesaMSG#"
			argumentcollection	= "#LvarMSGData.Parametros#"
			returnvariable			= "LvarMSG"
	>
	<cfparam name="LvarMSG" default="ERROR: component='#LvarMSGData.Componente#' method='#LvarMSGData.procesaMSG#' no devolvió ningún valor">

	<cfset LvarCertData = LvarMSGData.Parametros.Cert509>
	<cfif isdefined("LvarCertData.UID")>
		<cfset LvarUID = LvarCertData.UID>
	<cfelse>
		<cfset LvarUID = "">
	</cfif>
	<cfif isdefined("LvarCertData.GIVENNAME")>
		<cfset LvarNOMBRE = LvarCertData.GIVENNAME>
	<cfelse>
		<cfset LvarNOMBRE = "">
	</cfif>
	<cfif isdefined("LvarCertData.SURNAME")>
		<cfset LvarAPELLIDOS = LvarCertData.SURNAME>
	<cfelse>
		<cfset LvarAPELLIDOS = "">
	</cfif>
<cfcatch type="any">
	<cfset LvarMSG = cfcatch.message>
	<cfif cfcatch.detail NEQ "">
		<cfset LvarMSG = LvarMSG & ", " & cfcatch.detail>
	</cfif>
</cfcatch>
</cftry>

<script>
	<cfif not isdefined("LvarMSGData")>
		//alert("ERROR en proceso de Firma de Mensaje:\n\t\t" + <cfoutput>"#JSStringFormat(LvarMSG)#"</cfoutput>)
		window.top.location.reload();
	<cfelse>
		<cfoutput>
		<cfparam name="LvarUID" default="">
		<cfparam name="LvarNOMBRE" default="">
		<cfparam name="LvarAPELLIDOS" default="">
		<!---parent.parent.sbPostFirmaDigital("#JSStringFormat(LvarUID)#","#JSStringFormat(LvarNOMBRE)#","#JSStringFormat(LvarAPELLIDOS)#","#JSStringFormat(LvarMSG)#"); --->
		parent.parent.sbPostFirmaDigital("#JSStringFormat(LvarUID)#","#JSStringFormat(LvarNOMBRE)# #JSStringFormat(LvarAPELLIDOS)#","#JSStringFormat(LvarMSG)#");
		</cfoutput>
	</cfif>
</script>
