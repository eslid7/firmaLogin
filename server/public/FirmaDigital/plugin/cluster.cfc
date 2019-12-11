<cfcomponent displayname="Cluster" output="no" hint="Redirecciona un WebService al Servidor que creo el Token dentro de un Cluster'"
             extends="home.public.FirmaDigital.Componentes.FirmaDigital"
>
	<!--- 
		WebServices utilitarios:
			ping: 									devuelve OK si el servidor pudo ser accesado por el servidor local
			WSinit() o WSinit(ALL): borra la configuración del cluster, para que se vuelva a cargar
			WSsts()  o WSsts(ALL):  consulta la configuración del cluster
	--->

	<!--- Configuracion --->
	<cffunction name="config" access="public" output="no" returnType="void">
		<cfargument name="servers"		type="string" 	default="">
		<cfargument name="new"				type="boolean" 	default="false">

		<cfif Arguments.new>
			<cfset StructDelete(Server, "ClusterCfg", false)>
		</cfif>

		<cfif NOT isdefined("Server.ClusterCfg.isCluster")>
			<!---
				PROBLEMA: no se puede obtener el Local Port:
										no se puede utilizar CGI.HTTP_HOST ni CGI.SERVER_PORT porque da la direccion que se uso en el URL
										que puede ser hasta de otra maquina (parece que es el del cluster o el WebServer o el proxy, no es la direccion local)
									hay que buscar la o las direcciones de la maquina local, y no puede ser localhost o 127.0.0.1
									tampoco se pudo usar getPageContext().getRequest().getLocalAddr() porque repetia una direccion equivocada
			---->
			
			<!--- Obtiene la lista de ips del servidor --->
			<cfset LvarAddresses = "">
			<cfset LvarNIs = CreateObject("java","java.net.NetworkInterface").getNetworkInterfaces()>
			<cfloop condition="#LvarNIs.hasMoreElements()#">
				<cfset LvarNI = LvarNIs.nextElement()>
				<cfif LvarNI.isUp()>
					<cfset LvarIAs = LvarNI.getInetAddresses()>
					<cfloop condition="#LvarIAs.hasMoreElements()#">
						<cfset LvarAddr = LvarIAs.nextElement()>
						<cfset LvarAddress = LvarAddr.getHostAddress()>
						<cfif find(".",LvarAddress) and LvarAddress NEQ "127.0.0.1">
							<cfset LvarAddresses = listAppend(LvarAddresses,LvarAddress)>
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>

			<cfset LvarNET = CreateObject("java", "java.net.InetAddress").getLocalHost()>
			<cfset LvarSRV = CGI.http_host>

			<cfset Server.ClusterCfg = structNew()>
			<cfset Server.ClusterCfg.ERROR 			= "">
			<cfset Server.ClusterCfg.LOCAL_INDX = 0>
			<cfset Server.ClusterCfg.HOST_NAME  = LvarNET.getHostName()>
			<cfset Server.ClusterCfg.LOCAL_PORT = "-1">
			<cfset Server.ClusterCfg.GetLocalPort = "REQ.getServerPort()=#getPageContext().getRequest().getServerPort()#, REQ.getLocalPort()=#getPageContext().getRequest().getLocalPort()#">

			<!--- Incluye en LOCAL_ADDRs el HOST_NAME --->
			<cfset LvarAddresses = ListInsertAt(LvarAddresses,1,Server.ClusterCfg.HOST_NAME)>
			<cfset Server.ClusterCfg.LOCAL_ADDRs 	= "[#LvarAddresses#]">

			<cfif Arguments.Servers EQ "">
				<cfset Server.ClusterCfg.isCluster = false>
				<cfset Server.ClusterCfg.Servers = ArrayNew(1)>
				<cfreturn>
			</cfif>
			
			<cfset Server.ClusterCfg.isCluster 	= true>
			<cfset Server.ClusterCfg.Servers 		= listToArray(Arguments.servers)>

			<!--- Busca la direccion local --->
			<cfset LvarLOCAL_CONT = 0>
			<cfset LvarLOCAL_INDX = 0>
			<cfset LvarLOCAL_SRVS = "">
			<cfset LvarLOCAL_PORT = -1>
			<cfset LvarServers 		= Server.ClusterCfg.Servers>
			<cfset LvarServersStr	= Server.ClusterCfg.Servers.toString()>
			<cfloop index="i" from="1" to="#ArrayLen(LvarServers)#">
				<cfset LvarServers[i] = TRIM(LvarServers[i])>
				<cfif lcase(LvarServers[i]).startsWith("localhost") or LvarServers[i].startsWith("127.0.0.1")>
					<cfset Server.ClusterCfg.ERROR = "Configuracion de FirmaDigital en Cluster: no debe configurar la direccion local 'localhost' o '127.0.0.1'">
					<cfreturn>
				</cfif>
				<cflock name="FD_localport" timeout="5">
					<cfset Server.ClusterCfg.RANDOM = "#int(rand()*1000000000)#">

					<cfif CGI.https EQ "on">
						<cfset LvarWS = "https://#LvarServers[i]##CGI.script_name#?#query_string#">
					<cfelse>
						<cfset LvarWS = "http://#LvarServers[i]##CGI.script_name#?#query_string#">
					</cfif>
					<cfset LvarWS = left(LvarWS, find("?", LvarWS)) & "METHOD=WSlocalport&rndm=#Server.ClusterCfg.RANDOM#">
					<cftry>
						<cfhttp url="#LvarWS#" throwOnError="false" result="LvarResult" timeout="5"/>
						<cfif LvarResult.fileContent EQ "OK">
							<cfset LvarLOCAL_CONT ++>
							<cfset LvarLOCAL_INDX = i>
							<cfset LvarLOCAL_SRVS = listAppend(LvarLOCAL_SRVS,LvarServers[i])>
							<cfset LvarLOCAL_PORT = ListGetAt (LvarServers[i],2,":")>
						</cfif>
					<cfcatch type="any" >
					</cfcatch>
					</cftry>
				</cflock>
			</cfloop>

			<cfif Server.ClusterCfg.ERROR NEQ "">
				<cfset Server.ClusterCfg.isCluster = false>
				<cfset Server.ClusterCfg.Servers = ArrayNew(1)>
				<cfreturn>
			<cfelseif LvarLOCAL_CONT EQ 1>
				<cfset Server.ClusterCfg.LOCAL_INDX = LvarLOCAL_INDX>
				<cfset Server.ClusterCfg.Servers = LvarServers>
			<cfelseif LvarLOCAL_CONT EQ 0>
				<cfset Server.ClusterCfg.isCluster = false>
				<cfset Server.ClusterCfg.Servers = ArrayNew(1)>
				<cfset Server.ClusterCfg.ERROR = "Configuracion de FirmaDigital en Cluster #LvarServersStr#: no se incluyó o no se comunicó con el Servidor Local en la configuracion, uno de '[#LvarAddresses#]' (debe indicar el puerto correcto, se sugiere: getLocalPort()=#getPageContext().getRequest().getLocalPort()#)">
				<cfreturn>
			<cfelseif LvarLOCAL_CONT GT 1>
				<cfset Server.ClusterCfg.isCluster = false>
				<cfset Server.ClusterCfg.Servers = ArrayNew(1)>
				<cfset Server.ClusterCfg.ERROR = "Configuracion de FirmaDigital en Cluster #LvarServersStr#: se incluyó más de una vez al Servidor Local en la configuracion: [#LvarLOCAL_SRVS#]">
				<cfreturn>
			</cfif>

			<cfif LvarLOCAL_PORT EQ "">
				<cfif CGI.https EQ "on">
					<cfset Server.ClusterCfg.LOCAL_PORT = 455>
				<cfelse>
					<cfset Server.ClusterCfg.LOCAL_PORT = 80>
				</cfif>
			<cfelse>
				<cfset Server.ClusterCfg.LOCAL_PORT = LvarLOCAL_PORT>
			</cfif>
		</cfif>
	</cffunction>

	<!--- Verifica que el localport sea el mismo servidor --->
	<cffunction name="WSlocalPort" output="no" access="remote" returnType="string" returnFormat="plain">
		<cfargument name="rndm" default="">
	
		<cfparam name="Server.ClusterCfg.RANDOM" default="-1">
		<cfif Arguments.rndm EQ Server.ClusterCfg.RANDOM>
			<cfreturn "OK">
		<cfelse>
			<cfreturn "#Arguments.rndm# NEQ #Server.ClusterCfg.RANDOM#">
		</cfif>
	</cffunction>
	
	<!--- Token New --->
	<cffunction name="newToken" access="public" output="no" returnType="void">
		<cfargument name="token" 	type="string">
		<cfargument name="time" 	type="string">

		<cfif isdefined("Server.ClusterCfg") and Server.ClusterCfg.isCluster>
			<cfset LvarServers = Server.ClusterCfg.Servers>
			<cfset LvarLocalAddr = LvarServers[Server.ClusterCfg.LOCAL_INDX]>
			<cfloop index="i" from="1" to="#ArrayLen(LvarServers)#">
				<cfif Server.ClusterCfg.LOCAL_INDX EQ i>
					<!--- Local --->
				 	<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token].clusterSrv = "*LOCAL*">
				<cfelse>
					<!--- Remoto --->
					<cfset LvarURL = LvarServers[i] & mid(CGI.script_name,1,find("/plugin/",CGI.script_name)+6) & "/cluster.cfc?METHOD=WSnewToken&token=#Arguments.token#&srv=#LvarLocalAddr#&tm=#Arguments.time#">
					<cftry>
						<cfif CGI.https EQ "on">
							<cfhttp url="https://#LvarURL#" throwOnError="false" timeout="5"/>
						<cfelse>
							<cfhttp url="http://#LvarURL#" throwOnError="false" timeout="5"/>
						</cfif>
					<cfcatch type="any" >
					</cfcatch>
					</cftry>
				</cfif>
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="WSnewToken" access="remote" output="no" returnType="void">
		<cfargument name="token" 	type="string">
		<cfargument name="srv" 		type="string">
		<cfargument name="tm" 		type="string">

		<cfset init_FirmaDigital_()>
		<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token] = structNew()>
	 	<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token].clusterSrv 	= url.srv>
		<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token].ts_sts				= 3>
		<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token].ts_Timeout		= Arguments.tm>
		<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token].ts						= getTickcount()>
		<cfset destroyTokensThread()>
	</cffunction>

	<!--- Ejecución de WebService en Cluster --->
	<cffunction name="exeToken" access="public" output="no" returnType="string">
		<cfargument name="token" 						type="string">
		<cfargument name="forDownload_JNLP"	type="boolean" default="false">

	 	<cfif isdefined("Server.ClusterCfg") and Server.ClusterCfg.isCluster>
		 	<!--- Token pertenece a un Servidor Remoto --->
			<cfif isdefined("Application._FirmaDigital_.tokens.TK#Arguments.token#.clusterSrv") AND Application._FirmaDigital_.tokens["TK" & Arguments.token].clusterSrv NEQ "*LOCAL*">
				<cfset LvarSRV = CGI.http_host>
				<cfif CGI.https EQ "on">
					<cfset LvarWS = "https://#LvarSRV##CGI.script_name#?#query_string#">
				<cfelse>
					<cfset LvarWS = "http://#LvarSRV##CGI.script_name#?#query_string#">
				</cfif>

				<cfset LvarWS = replace(LvarWS,LvarSRV,Application._FirmaDigital_.tokens["TK" & Arguments.token].clusterSrv)>

				<cftry>
					<cfif NOT isdefined("form.method")>
						<cfhttp url="#LvarWS#" method = "GET" throwOnError="true" result="LvarResult" timeout="5"/>
					<cfelse>
						<cfhttp url="#LvarWS#" method = "POST" throwOnError="true" result="LvarResult" timeout="5">
							<cfloop collection="#form#"  item="LvarCampo">
								<cfoutput>
								<cfhttpparam type="formfield" name="#LvarCampo#" value="#form[LvarCampo]#"> 
								</cfoutput>
							</cfloop>
						</cfhttp>
					</cfif>
					
					<cfif Arguments.forDownload_JNLP>
						<cfset LvarCodebase = getJNLP_Codebase()>
						<cfif find("https://", LvarResult.fileContent)>
							<cfset LvarCodebaseRemoto = "https://" & Application._FirmaDigital_.tokens["TK" & Arguments.token].clusterSrv & getDirectoryFromPath(CGI.SCRIPT_NAME)>
						<cfelse>
							<cfset LvarCodebaseRemoto = "http://" & Application._FirmaDigital_.tokens["TK" & Arguments.token].clusterSrv & getDirectoryFromPath(CGI.SCRIPT_NAME)>
						</cfif>

						<cfset LvarContenido = replace (LvarResult.fileContent, LvarCodebaseRemoto, LvarCodebase, "ALL")>
					<cfelse>	
						<cfset LvarContenido = LvarResult.fileContent>
					</cfif>
						
					<cfreturn LvarContenido>
				<cfcatch type="any">
					<cfif find("initTokenJS",LvarWS)>
						<cfreturn "initTokenJS, #cfcatch.message#. WS=#LvarWS#">
					<cfelseif find("getStatus",LvarWS)>
						<cfreturn "getStatus, #cfcatch.message#. WS=#LvarWS#">
					<cfelse>
						<cfreturn "ERROR: #cfcatch.message#. WS=#LvarWS#">
					</cfif>
				</cfcatch>
				</cftry>
			</cfif>
		</cfif>
		<cfreturn "*LOCAL*">
	</cffunction>

	<!--- Generación del jnlp en Cluster --->
	<cffunction name="download_JNLP" output="yes">
		<cfargument name="Token">

		<cfset LvarClusterResponse = exeToken(Arguments.Token, true)>
		<cfif LvarClusterResponse EQ "*LOCAL*">
			<cfreturn>
		</cfif>
		
		<cfheader name="Expires" value="0">
		<cfheader name="Pragma" value="no-cache">
		<cfheader name="Content-Disposition" value="attachment; filename=FirmaDigital.jnlp">
		<cfcontent type="application/x-java-jnlp-file" variable="#LvarClusterResponse.toString().getBytes("UTF-8")#">
		<cfabort>
	</cffunction>

	<!--- Generación del Codebase para jnlp --->
	<cffunction name="getJNLP_Codebase" output="no" returnType="string">
		<cfset var LvarCodebase = "">
		<cfif isdefined("Application._FirmaDigital_.jnlpHTTPS")>
			<cfif Application._FirmaDigital_.jnlpHTTPS>
				<cfset LvarCodebase = "https://" & CGI.HTTP_HOST & getDirectoryFromPath(CGI.SCRIPT_NAME)>
			<cfelse>
				<cfset LvarCodebase = "http://"  & CGI.HTTP_HOST & getDirectoryFromPath(CGI.SCRIPT_NAME)>
			</cfif>
		<cfelse>
			<cfif CGI.HTTPS EQ "on">
				<cfset LvarCodebase = "https://" & CGI.HTTP_HOST & getDirectoryFromPath(CGI.SCRIPT_NAME)>
			<cfelse>
				<cfset LvarCodebase = "http://"  & CGI.HTTP_HOST & getDirectoryFromPath(CGI.SCRIPT_NAME)>
			</cfif>
		</cfif>
		<cfreturn LvarCodebase>
	</cffunction>
	<!---------------------------------------------------------------------------------------------------------------------------------------->
	
	<!--- Ping de prueba de Servidores dentro de la red local del Servidor --->
	<cffunction name="ping" output="no" access="remote" returnType="string" returnFormat="plain">
		<cfargument name="SRV" default="">
	
		<cfif Arguments.SRV EQ "">
			<cfreturn "Servidor Local: OK">
		</cfif>
		
		<cfset LvarSRV = CGI.http_host>
		<cfif CGI.https EQ "on">
			<cfset LvarWS = "https://#LvarSRV##CGI.script_name#?#query_string#">
		<cfelse>
			<cfset LvarWS = "http://#LvarSRV##CGI.script_name#?#query_string#">
		</cfif>
		<cfset LvarWS = left(LvarWS, find("?", LvarWS)) & "METHOD=ping">
		<cfset LvarWS = replace(LvarWS,LvarSRV,Arguments.SRV)>
		
		<cftry>
			<cfhttp url="#LvarWS#" throwOnError="false" result="LvarResult" timeout="5"/>
		<cfcatch type="any" >
			<cfset LvarResult = structNew()>
			<cfset LvarResult.fileContent = "Error: #cfcatch.message# #cfcatch.detail#">
		</cfcatch>
		</cftry>
		<cfreturn replace(LvarResult.fileContent, "Servidor Local: ", "Servidor Remoto [#Arguments.SRV#]: ")>
	</cffunction>

	<!--- Borra la configuración del Cluster --->
	<cffunction name="WSinit" output="no" access="remote" returnType="string" returnFormat="plain">
		<cfargument name="ALL" default="*">

		<cfif Arguments.ALL EQ "*">
			<cfset StructDelete(Server, "ClusterCfg", false)>
			<cfreturn "OK = Configuración del Cluster inicializada">
		<cfelse>
			<cfset LvarIDX_Srv = "">
			<cfif isdefined("Server.ClusterCfg.Servers") and arrayLen(Server.ClusterCfg.Servers) GTE 1>
				<cfset LvarResultado  = "">
				<cfset LvarServers = Server.ClusterCfg.Servers>
				<cfloop index="LvarIDX" from="1" to="#arrayLen(LvarServers)#">
					<cfset LvarIDX_Srv = LvarServers[LvarIDX]>
					<cfset LvarResultado  &= "Configuración remota del Cluster (#LvarIDX_Srv#)<BR>">
					<cfset LvarSRV = CGI.http_host>
					<cfif CGI.https EQ "on">
						<cfset LvarWS = "https://#LvarSRV##CGI.script_name#?#query_string#">
					<cfelse>
						<cfset LvarWS = "http://#LvarSRV##CGI.script_name#?#query_string#">
					</cfif>
					<cfset LvarWS = left(LvarWS, find("?", LvarWS)) & "METHOD=WSinit">
					<cfset LvarWS = replace(LvarWS,LvarSRV,LvarIDX_Srv)>
					
					<cftry>
						<cfhttp url="#LvarWS#" throwOnError="false" result="LvarResult" timeout="5"/>
					<cfcatch type="any" >
						<cfset LvarResult = structNew()>
						<cfset LvarResult.fileContent = "Error: #cfcatch.message# #cfcatch.detail#">
					</cfcatch>
					</cftry>
					<cfset LvarResultado &= "#LvarResult.fileContent#<br><br>">
				</cfloop>
			<cfelse>
				<cfset LvarResultado = "No hay servidores configurados">
			</cfif>
			<cfreturn LvarResultado>
		</cfif>
	</cffunction>

	<!--- Consulta el Status de la configuración de FirmaDigital en Cluster --->
	<cffunction name="WSsts" access="remote" output="no" returnType="string" returnFormat="plain">
		<cfargument name="ALL" default="*">

		<cfset var LvarSRVs = "">
		<cfif Arguments.ALL EQ "*">
			<cfset LvarResultado  = "<STRONG>CONFIGURACION LOCAL DE FIRMA DIGITAL EN CLUSTER</STRONG><BR>">
		<cfelseif Arguments.ALL EQ "**">
			<cfset LvarResultado  = "">
		<cfelse>
			<cfset LvarResultado  = "">
			<cfset LvarIDX_Srv = "">
			<cfif isdefined("Server.ClusterCfg.Servers") and arrayLen(Server.ClusterCfg.Servers) GTE 1>
				<cfset LvarServers = Server.ClusterCfg.Servers>
				<cfloop index="LvarIDX" from="1" to="#arrayLen(LvarServers)#">
					<cfset LvarIDX_Srv = Server.ClusterCfg.Servers[LvarIDX]	>
					<cfset LvarResultado &= "<STRONG>CONFIGURACION REMOTA DE FIRMA DIGITAL EN CLUSTER (#LvarIDX_Srv#)</STRONG><BR>">

					<cfset LvarSRV = CGI.http_host>
					<cfif CGI.https EQ "on">
						<cfset LvarWS = "https://#LvarSRV##CGI.script_name#?#query_string#">
					<cfelse>
						<cfset LvarWS = "http://#LvarSRV##CGI.script_name#?#query_string#">
					</cfif>
					<cfset LvarWS = left(LvarWS, find("?", LvarWS)) & "METHOD=WSsts&ALL=**">
					<cfset LvarWS = replace(LvarWS,LvarSRV,LvarIDX_Srv)>
					
					<cftry>
						<cfhttp url="#LvarWS#" throwOnError="false" result="LvarResult" timeout="5"/>
					<cfcatch type="any" >
						<cfset LvarResult = structNew()>
						<cfset LvarResult.fileContent = "Error: #cfcatch.message# #cfcatch.detail#">
					</cfcatch>
					</cftry>
					<cfset LvarResultado &= "<BR>#LvarResult.fileContent#<BR><BR>">
				</cfloop>
			<cfelse>
				<cfset LvarResultado  = "<STRONG>CONFIGURACION REMOTA DE FIRMA DIGITAL EN CLUSTER</STRONG><BR>">
				<cfset LvarResultado &= "IDX no existe (max=#arrayLen(Server.ClusterCfg.Servers)#)">
			</cfif>
			<cfreturn LvarResultado>
		</cfif>
		
		<!--- Ejecuta la configuracion con los Servers anteriores --->
		<cfif arrayLen(Server.ClusterCfg.Servers) GTE 1>
			<cfset LvarSRVs = arrayToList (Server.ClusterCfg.Servers)>
			<cfset config(LvarSRVs, true)>
		</cfif>
		<cfset LvarResultado &= "HTTP_HOST: #CGI.http_host#, HTTPS for JNLP: #Application._FirmaDigital_.jnlpHTTPS#<BR><BR>">
		<cfif Server.ClusterCfg.LOCAL_PORT eq -1>
			<cfset LvarResultado &= "Servidor Local: Nombre = #Server.ClusterCfg.HOST_NAME#, Posibles direcciones = #Server.ClusterCfg.LOCAL_ADDRs#, #Server.ClusterCfg.getLocalPort#, Puerto = ???<BR>">
			<cfset LvarResultado &= "<font face='monospace' size='2'>">
			<cfset LvarResultado &= "&nbsp;&nbsp;&nbsp;int getServerPort():&nbsp;Returns the port number to which the request was sent. It's the value after ':' in the Host header value, if any, or the server port where the client connection was accepted on.<BR>">
			<cfset LvarResultado &= "&nbsp;&nbsp;&nbsp;int getLocalPort():&nbsp;&nbsp;Returns the Internet Protocol (IP) port number of the interface on which the request was received.<BR>">
			<cfset LvarResultado &= "</font><BR>">
		<cfelse>
			<cfset LvarResultado &= "Servidor Local: Nombre = #Server.ClusterCfg.HOST_NAME#, Posibles direcciones = #Server.ClusterCfg.LOCAL_ADDRs#, #Server.ClusterCfg.getLocalPort#, Puerto = #Server.ClusterCfg.LOCAL_PORT#<BR>">
		</cfif>		
		<cfset LvarResultado &= "Fecha y Hora: #now()#<BR><BR>">

		<cfif isdefined("Server.ClusterCfg") and Server.ClusterCfg.isCluster>
			<cfset LvarResultado &= "Status: CLUSTER CONFIGURADO">
			<cfset LvarResultado &= "<BR>Configuración: [#LvarSRVs#], local idx=#Server.ClusterCfg.LOCAL_INDX#<BR><BR>">
			<cfif Server.ClusterCfg.ERROR NEQ "">
				<cfset LvarResultado &= "<font color='##FF0000'>ERROR: #Server.ClusterCfg.ERROR#</font>">
			<cfelse>
				<cfset LvarResultado &= "Test de Comunicación con los Servidores Remotos:<BR>">
				<cfset LvarSRV = CGI.http_host>
				<cfif CGI.https EQ "on">
					<cfset LvarWS = "https://#LvarSRV##CGI.script_name#?#query_string#">
				<cfelse>
					<cfset LvarWS = "http://#LvarSRV##CGI.script_name#?#query_string#">
				</cfif>
				<cfset LvarWS = replace(LvarWS, "=WSsts","=WSsts2")>
				<cfloop index="i" from="1" to="#ArrayLen(LvarServers)#">
					<cfif Server.ClusterCfg.LOCAL_INDX EQ i>
						<!--- Local --->
						<cfset LvarResultado &= "<BR>" & LvarServers[i] & " (local)">
					<cfelse>
						<!--- Remoto: Si Token pertenece a server remoto: se redirige el WS al Servidor Remoto --->
						<cfset LvarURL="#replace(LvarWS,LvarSRV,LvarServers[i])#&srvs=#ArrayToList(LvarServers)#">
						<cftry>
							<cfhttp url="#LvarURL#" throwOnError="false" result="LvarResult" timeout="5"/>
						<cfcatch type="any" >
							<cfset LvarResult = structNew()>
							<cfset LvarResult.fileContent = "Error: #cfcatch.message# #cfcatch.detail#">
						</cfcatch>
						</cftry>
						<cfset LvarResultado &= "<BR>" & LvarServers[i] & " (remoto=#LvarResult.fileContent#)">
					</cfif>
				</cfloop>
			</cfif>
		<cfelse>
			<cfset LvarResultado &= "Status: EL CLUSTER NO HA SIDO CONFIGURADO, la FirmaDigital no funcionará correctamente en ambiente Cluster o con Load Balance<br>">
			<cfif Server.ClusterCfg.ERROR NEQ "">
				<cfset LvarResultado &= "<font color='##FF0000'>ERROR: #Server.ClusterCfg.ERROR#</font>">
			</cfif>
		</cfif>
		<cfreturn LvarResultado>
	</cffunction>

	<cffunction name="WSsts2" access="remote" output="no" returnType="string" returnFormat="plain">
		<cfargument name="srvs">

	 	<cfif isdefined("Server.ClusterCfg") and Server.ClusterCfg.isCluster>
			<cfset LvarServers = arrayToList (Server.ClusterCfg.Servers)>
			<cfif Server.ClusterCfg.ERROR NEQ "">
				<cfreturn "<font color='##FF0000'>[#LvarServers#] CONFIGURACION CON ERROR: #Server.ClusterCfg.ERROR#</font>">
			<cfelseif LvarServers NEQ Arguments.Srvs>
				<cfreturn "<font color='##FF0000'>CONFIGURACION DIFERENTE: [#LvarServers#]</font>">
			<cfelse>
				<cfreturn "OK">
			</cfif>
		<cfelse>
			<cfreturn "CLUSTER OFF">
		</cfif>
	</cffunction>
</cfcomponent>
