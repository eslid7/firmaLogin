<!--- 
	Control de GoBack:
		Dentro de un iframe funciona solo en Firefox, y se puede preguntar si no viene de GoBack:
			if (document.formRL.RELOAD.value == "1")
		En Chrome se vuelve a ejecutar el pintado de coldfusion por lo que no se puede preguntar si viene o no de GoBack (nunca viene),
			pero da error porque no existe el token
 --->
<cfset createObject("component","login").pintaControlBack()>

<cftry>
	<cfparam name="url.e" default="">

	<cfset LvarCertData = createObject("component","login").getLoginData(form.token, url.e)>

	<cfif LvarCertData.forLogon>
		<cfset LvarResultado = createObject("component","login").fnAspLogin(form.token, LvarCertData, url.e)>
		<cfif LvarResultado EQ "AUTOREGISTRO">
			<cfif url.a EQ "*">
				<cfset LvarLogin_FDauto = "#cgi.CONTEXT_PATH#/home/public/FirmaDigital/plugin/autoregistro/login_FDauto.cfm">
			<cfelse>
				<cfset LvarLogin_FDauto = createObject("java","java.lang.String").init(BinaryDecode(url.a,"HEX"))>
			</cfif>
			<script>
				// Redirigir a pantalla de autoregistro de FirmaDigital
				if (document.formRL.RELOAD.value == "1")
					window.top.location.href = <cfoutput>"#LvarLogin_FDauto#?e=#url.e#&token=#form.token#&UID=#LvarCertData.UID#"</cfoutput>;
			</script>
			<cfabort />
		<cfelseif LvarResultado NEQ "OK">
			<cfthrow message="#LvarResultado#">
		</cfif>
		<script>
			if (parent.sbPostFirmaDigital)
			{
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
				parent.sbPostFirmaDigital(<cfoutput>"#JSStringFormat(LvarUID)#","#JSStringFormat(LvarNOMBRE)#","#JSStringFormat(LvarAPELLIDOS)#"</cfoutput>);
			}
			else
			{
				// Aqui redirigir a inicio del sistema:  /home/menu/index.cfm
				if (document.formRL.RELOAD.value == "1")
					window.top.location.href = <cfoutput>"#cgi.CONTEXT_PATH#/"</cfoutput>;
			}
		</script>
		<cfabort>
	<cfelse>
		<cfset session._FD_Autenticacion_ = LvarCertData>
		<cfset session._FD_Autenticacion_.PWD = "****">
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
		<script>
			parent.sbPostFirmaDigital(<cfoutput>"#JSStringFormat(LvarUID)#","#JSStringFormat(LvarNOMBRE)#","#JSStringFormat(LvarAPELLIDOS)#"</cfoutput>);
		</script>
	</cfif>
<cfcatch type="any">
	<script>
		// Aqui iniciar proceso de Autenticacion
		<cfif not isdefined("LvarCertData.forLogon")>
			<!--- 
				Control de GoBack:
					En Chrome se vuelve a ejecutar el pintado de coldfusion por lo que no se puede preguntar si viene o no de GoBack (siempre es la primera vez)
			 --->			
			//alert("ERROR en proceso de Autenticación:\n\t\t" + <cfoutput>"#JSStringFormat(cfcatch.message & ' ' & cfcatch.detail)#"</cfoutput>)
			window.top.location.reload();
		<cfelse>
			if (confirm("ERROR en proceso de Autenticación:\n        " + <cfoutput>"#JSStringFormat(cfcatch.message & ' ' & cfcatch.detail)#"</cfoutput> + "\n\n¿Desea reintentar la Autenticación?"))
			{
				<cfif LvarCertData.forLogon>
					<cfoutput>
					location.href = "login.cfm?tkn=#url.tkn#&a=#url.a#&e=#url.e#";
					</cfoutput>
				<cfelse>
					location.href = "login.cfm";
				</cfif>
			}
		</cfif>
	</script>
</cfcatch>
</cftry>
