<cfcomponent output="true">
	<!--- Application name, should be unique --->
	<cfset this.name = "RX_DIGITAL">
	<!--- How long application vars persist --->
	<cfset this.applicationTimeout = createTimeSpan(0,2,0,0)>
	<!--- Should client vars be enabled? --->
	<cfset this.clientManagement = false>
	<!--- Should we even use sessions? --->
	<cfset this.sessionManagement = true>
	<!--- How long do session vars persist? --->
	<!--- Should we set cookies on the browser? --->
	<cfset this.setClientCookies = true>
	<!--- Ruta de los jars que se usan en el app --->
	<cfset jarLocation = ExpandPath('/commons/JAR/')>
	<!--- Ruta de los jars de la firma --->
	<cfset jarLocationSignature = ExpandPath('/home/public/FirmaDigital/plugin/lib')>
	<!--- Settings para leer los jar sin tener que reiniciar el server --->
	<cfset this.javaSettings = {LoadPaths = ["#jarLocation#","#jarLocationSignature#"], loadColdFusionClassPath = true, reloadOnChange = true, watchInterval = 10 }>
	<!--- Define the page request properties. --->
	<cfsetting requesttimeout="60" showdebugoutput="false" enablecfoutputonly="false"/>

	<!--- Esto es para el manejo de webSockets de coldfusion para lo de firma, para que no use ajax, en caso de no servir igual usaría Ajax --->
	<cftry>
		<cfset this.wsChannels = [{name="wsChannelFD", cfcListener="home.public.FirmaDigital.plugin.Application_wsChannelFD"}] />
		<cfcatch type="any"></cfcatch>
	</cftry>

	<!--- Run when application starts up --->
	<cffunction name="onApplicationStart" returnType="boolean" output="false">

		<cfreturn true>
	</cffunction>

	<cffunction name="onRequest" returnType="void" output="true">
		<cfargument name="targetPage" type="String" required="true"/>

		<cfinclude template="#Arguments.targetPage#">
	</cffunction>

	<cffunction name="OnSessionStart" access="public" returntype="boolean" output="false"  hint="Fires when the user's session begins.">
		<!--- Store the date created. --->
		<cfset SESSION.DateCreated = Now() />
		<cfset this.sessionTimeout = createTimeSpan(0, 0,0,GetPageContext().getRequest().getSession().getMaxInactiveInterval())>

		<!--- Return out. --->
		<cfreturn true />
	</cffunction>

	<cffunction name="OnSessionEnd" access="public" returntype="void" output="false" hint="Fires when the session is terminated.">
		<!--- Define arguments. --->
		<cfargument name="Session" type="struct" required="true" hint="The expired session scope." />

		<!--- Return out. --->
		<cfreturn />
	</cffunction>

	<!--- Los componentes se deben llamar dentro del onRequestStart porque Application no existe en el cuerpo de Application.cfc --->
	<cffunction name="onRequestStart" returnType="void" output="yes">
		<cfargument name="targetPage" type="String" required="true"/>

		<!--- Tarea programada que se encarga de actualiza la lista de las firmas revocadas --->
		<cfif NOT isdefined("server.FirmaDigital_CRL")>
			<cfset createObject("component","home.public.FirmaDigital.Componentes.crypto").actualizaCRLs()>
		</cfif>

		<!--- Configuración para Cluster y HTTPS --->
		<cfif NOT isdefined('session.app.clusterIps') OR NOT isdefined('session.app.useHttpsCluster')>
			<cfquery name="rsParameters" datasource="rxhub">
				SELECT
					MAIP_CODE, MAIP_VALUE
				FROM MAINTENANCE_PARAMETERS
				WHERE
					MAIP_CODE = <cfqueryparam cfsqltype="cf_sql_numeric" value="86">
					OR MAIP_CODE = <cfqueryparam cfsqltype="cf_sql_numeric" value="87">
			</cfquery>

			<cfloop query="rsParameters">
				<cfswitch expression="#rsParameters.MAIP_CODE#">
					<cfcase value="86">
						<cfset session.app.clusterIps = rsParameters.MAIP_VALUE >
					</cfcase>
					<cfcase value="87">
						<cfset session.app.useHttpsCluster = rsParameters.MAIP_VALUE >
					</cfcase>
				</cfswitch>
			</cfloop>
		</cfif>
		<cfset createObject("component","home.public.FirmaDigital.plugin.cluster").config(session.app.clusterIps, false)>
		<cfset Application._FirmaDigital_.jnlpHTTPS = false>
		<cfif session.app.useHttpsCluster EQ "1">
			<cfset Application._FirmaDigital_.jnlpHTTPS = true>
		</cfif>
	</cffunction>

	<!--- Runs at end of request --->
	<cffunction name="onRequestEnd" returnType="void" output="false">
		<cfargument name="thePage" type="string" required="true">

	</cffunction>

</cfcomponent>