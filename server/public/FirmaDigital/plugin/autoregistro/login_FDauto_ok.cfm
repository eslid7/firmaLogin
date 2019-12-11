<cfif isdefined("form.OK")>
	<cfoutput>#form.auto_UID#</cfoutput>
	<cfset LvarMSG = createObject("component","/home/public/FirmaDigital/plugin/login").fnAddAspLogin(form.auto_CEalias, form.auto_UID, form.auto_PWD)>
	<script>
		// Despliege resultado del AutoRegistro
		<cfif LvarMSG EQ "OK">
			<cfoutput>
			alert("La FirmaDigital ha sido asociada exitosamente al Usuario '#form.auto_UID#' en '#form.auto_CEalias#'.  Ya puede ser utilizada");
			</cfoutput>
			// Redirigir a pantalla de inicio
			location.href = <cfoutput>"#cgi.CONTEXT_PATH#/"</cfoutput>;
		<cfelse>
			alert("<cfoutput>#LvarMSG#</cfoutput>");
			location.href = <cfoutput>"login_FDauto.cfm?e=#form.auto_CEalias#"</cfoutput>;
		</cfif>
	</script>
<cfelse>
	<script>
		location.href = <cfoutput>"login_FDauto.cfm?e=#form.auto_CEalias#"</cfoutput>;
	</script>
</cfif>