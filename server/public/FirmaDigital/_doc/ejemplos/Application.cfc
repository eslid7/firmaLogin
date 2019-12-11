<cfcomponent displayname="Application" output="true" hint="Handle the application.">
	<cfset THIS.Name				= "SIF_ASP" />
	<cfset THIS.SessionManagement	= true />
	<cfset THIS.ClientManagement	= False/>
	<cfset THIS.ApplicationTimeout	= CreateTimeSpan( 0, 10, 0, 0 ) />
	<cfset THIS.SetClientCookies	= True />

	<cfsetting requesttimeout="20" showdebugoutput="false" enablecfoutputonly="false"/>

	<!--- **************************************************************************** --->
	<!--- Firma digital: estas 2 instrucciones se requieren para activar Firma Digital --->
	<!--- **************************************************************************** --->
		
	<cftry>
		<!--- Inicializa Canal WebSocket seguro --->
		<cfset THIS.wsChannels			= [{name="wsChannelFD", cfcListener="home.public.FirmaDigital.plugin.Application_wsChannelFD"}] />
		<cfcatch type="any"></cfcatch>
	</cftry>
	<cfif NOT isdefined("server.FirmaDigital_CRL")>
		<!--- Inicializa Tarea programada de Actualización de Archivos CRLs cada 10 minutos --->
		<cfset createObject("component","home.public.FirmaDigital.Componentes.crypto").actualizaCRLs()>
	</cfif>
</cfcomponent>
