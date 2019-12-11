<cfcomponent displayname="FirmaDigital" output="no" hint="Procesos de Autenticacion y Firma de mensajes XML">
	<!---
		createToken:
			Inicio del proceso de login por firma digital en Coldfusion
			Se crea una estructura en Application._FirmaDigital_.tokens[] con un tiempo de vida de 61 segundos
			Todo el proceso debe terminar en menos de 60 segundos
	--->
	<cfset GvarTimeout_LoginDL 	= 60000> 	<!--- Timeout del proceso de Login, y de bajar el jnlp en el proceso de Sign --->
	<cfset GvarTimeout_Sign 		= 300000> <!--- Timeout del proceso completo de Sign --->
	<cfset GvarTimeout_Expire 	= 60000> 	<!--- Timeout para borrar definitivamente el token despues de que expiró.  El mensaje cambia de "Token expirado" a "Token no exite" --->
	
	<cfset GvarThreadLife		 	= 600000> <!--- Tiempo de vida del Thread para Destruir Tokens. Se va a ejecutar un ciclo de GvarThreadLife/GvarThreadWait veces --->
	<cfset GvarThreadWait		 	= 20000> 	<!--- Cada cuanto se verifican los Tokens a Destruir --->
	<cfset GvarLocalPort			= GetPageContext().GetRequest().GetLocalPort()>
	
	<cffunction name="createToken" access="public" output="no" returnType="string">
		<cfargument name="tipoLlave" 	type="string">
		<cfargument name="forLogon"		type="boolean" default="false">
		
		<cfif NOT listFind("LlaveDeAutenticacion,LlaveDeFirma,Temporal", Arguments.tipoLlave)>
			<cfthrow message="Tipos de Token: LlaveDeAutenticacion,LlaveDeFirma">
		</cfif>
		
		<cflock name="_FirmaDigital_" type = "exclusive" timeout="100">
			<cfset init_FirmaDigital_()>
			<cfset LvarTS = getTickcount()>
			<cfif LvarTS EQ Application._FirmaDigital_.ts>
				<cfset Application._FirmaDigital_.count++>
				<cfset LvarToken = LvarTS & "_" & Application._FirmaDigital_.count>
			<cfelse>
				<cfset Application._FirmaDigital_.count = 0>
				<cfset LvarToken = LvarTS>
			</cfif>
			<cfset Application._FirmaDigital_.ts = LvarTS>
			<cfset Application._FirmaDigital_.tokens["TK" & LvarToken] = structNew()>
			<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].ts_sts				= 0>
			<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].ts_Timeout		= 0>
			<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].ts						= 0>
		</cflock>

		<!--- Define el Timeout del Token: 1 min autenticacion, 5 min firma msg --->
		<cfif Arguments.tipoLlave EQ "LlaveDeAutenticacion">
			<cfset LvarTimeout = GvarTimeout_LoginDL + 1000>
		<cfelse>
			<cfset LvarTimeout = GvarTimeout_Sign + 1000>
		</cfif>
		<cfset destroyTokensThread()>

		<!--- Se crea el cluster en el Servidor local y se informa a los Servidores remotos --->
		<cfset createObject("component","home.public.FirmaDigital.plugin.cluster").newToken(LvarToken, LvarTimeout)>

		<cfif Arguments.tipoLlave EQ "Temporal">
			<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].ts_sts				= 2>
			<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].ts						= LvarTS>
			<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].ts_Timeout		= LvarTimeout>
			<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].getStatus		= "Temporal">
			<cfreturn LvarToken>
		</cfif>

		<cfset LvarCryp = createObject("component","home.public.FirmaDigital.Componentes.crypto")>
		<cfset LvarSKey = LvarCryp.AES_generateSecretKey()>
		<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].ts_sts				= 1>
		<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].ts						= LvarTS>
		<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].ts_Timeout		= LvarTimeout>

		<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].tipo					= Arguments.tipoLlave>
		<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].forLogon			= Arguments.forLogon>
		<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].sessionId		= encrypt(session.sessionId,"asp128" & LvarToken)>
		<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].skey					= encrypt(LvarSKey,"asp128" & LvarToken)>
		<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].data					= "">
		<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].getStatus		= "*">
		<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].subscribed		= false>
		<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].initiatedJS	= false>
		<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].initiatedJWS	= false>
		<cfif Arguments.tipoLlave EQ "LlaveDeAutenticacion">
			<!--- 
				Información de seguridad a verificar en JavaWebStart: 
					. Se encripta con la llave privada del Servidor: Token,Tkn2,Tipo 	(asegura que el Servidor sea el verdadero - Autenticidad del Servidor)
			--->
			<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].MSG		= LvarCryp.RSA_Encrypt(LvarToken & "," & LvarSKey & "," & Arguments.tipoLlave)>
		</cfif>

		<cfreturn LvarToken>
	</cffunction>

	<!---
		init_FirmaDigital_:
			Objetivo: Crear la estructura Application._FirmaDigital_ antes de incluirle los tokens
	--->
	<cffunction name="init_FirmaDigital_" access="public" output="no" returnType="string">
		<cfif not isdefined("Application._FirmaDigital_.ts")>
			<cfset Application._FirmaDigital_ = structNew()>
			<cfset Application._FirmaDigital_.tokens = structNew()>
			<cfset Application._FirmaDigital_.count = 0>
			<cfset Application._FirmaDigital_.ts = 0>
			<cfset Application._FirmaDigital_.destroy_ts = 0>
			<cfset Application._FirmaDigital_.jnlpHTTPS = false>
		</cfif>
	</cffunction>

	<!---
		destroyTokens:
			Objetivo: Exiprar tokens vencidos o destruir tokens con un minuto posterior a su timeout
				Esto se ejecuta en un thread que dura GvarThreadLife milisegundos (10 minutos por defualt)
				Unicamente un thread se ejecuta a la vez (cada intento de por ejecutar el thread si se acaba de ejecutar no lo inicia)
				El thread es un ciclo de n veces (GvarThreadLife/GvarThreadWait): destruye los tokens y se espera GvarThreadWait para el proximo ciclo (cada 20 segundos por default)
				- Los Tokens cuya vida haya pasado su timeout, se expiran: Daría error de "Token expirado (DL/TM)":
						Si es sign y no bajó a tiempo el programa: 	"Token expirado (DL)"  por timeout de Download
						Si es sign y bajó a tiempo el programa: 		"Token expirado (TM)"  por timeout de vida del token
						Si es login: 																"Token expirado (TM)"  por timeout de vida del token
				- Los Tokens de sign cuya vida haya pasado su timeout de download, se expiran: Daría error de "Token expirado (DL)":
				- Los Tokens cuya vida haya pasado su timeout + un minuto se borran definitivamente:  Daria error de "Token no existe"
				
				Si al final de los 10 minutos del thread todavía hay tokens sin destruir, se vuelve a esperar 20 segundos, para darle oportunidad a otro thread que empiece.
				Si no empieza ningun nuevo thread, lanza un WebService a si mismo para destruir los tokens faltantes.
	--->
	<cffunction name="destroyTokensThread" access="public" output="no" returnType="void">

		<cfset var LvarToken = 0>
		<cfset var LvarTK = 0>
		
		<!--- Este control asegura que solo se ejecuta un thread a la vez --->
		<cfif getTickcount() - Application._FirmaDigital_.destroy_ts GT GvarThreadWait + 1000>
			<!--- Si GvarThreadLife es menor a GvarThreadWait se configuro mal y se ponen los valores defautl --->
			<cfif GvarThreadLife LT GvarThreadWait>
				<cfset GvarThreadLife		 	= 600000> <!--- El valor default es 10 minutos:  La vida del thread es de 10 minutos --->
				<cfset GvarThreadWait		 	= 20000> 	<!--- El valor default es 20 segundos: Durante el thread se van ejecutar la destruccion 30 veces cada 20 segundos --->
			</cfif>

			<cfthread action="run" name="_FirmaDigital_detroyToken">
				<cftry>
					<cfset LvarThreadLoop = int(GvarThreadLife / GvarThreadWait)>
					<cfloop index="i" from="1" to="#LvarThreadLoop#">
						<cfset Application._FirmaDigital_.destroy_ts = getTickcount()>
						<cfloop collection="#Application._FirmaDigital_.tokens#" item="LvarTK">
							<cflock name="_FirmaDigital_" type = "exclusive" timeout="100">
								<cfif left(LvarTK,2) NEQ "TK" OR NOT isdefined("Application._FirmaDigital_.tokens.#LvarTK#.ts_sts")>
									<!--- Tokens inválidos por cambio de version: Esto es unicamente la primera vez que se usa esta version --->
									<cfset Application._FirmaDigital_.tokens["#LvarTK#"] = JavaCast("null",0)>
									<cfset StructDelete(Application._FirmaDigital_.tokens, "#LvarTK#", false)>
									<cfcontinue>
								<cfelseif Application._FirmaDigital_.tokens[LvarTK].ts_sts EQ 0>
									<!--- Tokens en creacion --->
									<cfcontinue>
								</cfif>
							</cflock>

							<cfset LvarToken = mid(LvarTK,3,100)>
							<cfif Application._FirmaDigital_.tokens[LvarTK].ts_sts GT 0 and isdefined("Application._FirmaDigital_.tokens.#LvarTK#.tipo") and Application._FirmaDigital_.tokens[LvarTK].tipo EQ "Temporal">
								<cfset LvarTimeout_Expire = 0>
							<cfelse>
								<cfset LvarTimeout_Expire = GvarTimeout_Expire>
							</cfif>
							<cfif (getTickcount() - Application._FirmaDigital_.tokens[LvarTK].ts GT Application._FirmaDigital_.tokens[LvarTK].ts_Timeout + LvarTimeout_Expire)>
								<!--- Si es temporal    y ha pasado el timeout exacto  se borra definitivamente --->
								<!--- Si no es temporal y ha pasado el timeout + Timeout_Expire se borra definitivamente (Timeout_Expire antes habian quedado expirados) --->
								<cfset Application._FirmaDigital_.tokens[LvarTK] = JavaCast("null",0)>
								<cfset StructDelete(Application._FirmaDigital_.tokens, LvarTK, false)>
							<cfelseif Application._FirmaDigital_.tokens[LvarTK].ts_sts GT 0 AND (getTickcount() - Application._FirmaDigital_.tokens[LvarTK].ts GT Application._FirmaDigital_.tokens[LvarTK].ts_Timeout)>
								<!--- Si pasa el timeout, expira --->
								<cfset expireToken(LvarToken)>
								<cfset invokeWSsendError(LvarToken, "El token ha expirado (TM)")>
							<cfelseif Application._FirmaDigital_.tokens[LvarTK].ts_sts EQ 1 AND (getTickcount() - Application._FirmaDigital_.tokens[LvarTK].ts GT GvarTimeout_LoginDL)>
								<!--- Si pasa 60000 (sin bajar el jnlp), expira --->
								<cfset expireToken(LvarToken)>
								<cfset invokeWSsendError(LvarToken, "El token ha expirado (DL)")>
							</cfif>
							<cfset Application._FirmaDigital_.destroy_ts = getTickcount()>
						</cfloop>
						
						<cfthread action="sleep" duration="#GvarThreadWait#" />
					</cfloop>
					
					<!--- Unicamente para destruir los ultimos tokens existentes cuando ya no hay actividad --->
					<cfif structCount(Application._FirmaDigital_.tokens) GT 0>
						<cfthread action="sleep" duration="#GvarThreadWait#" />
						<cfif getTickcount() - Application._FirmaDigital_.destroy_ts GT GvarThreadWait + 1000>
							<cfset invokeWSdestroyTokens()>
						</cfif>
					</cfif>
				<cfcatch type="any">
					<cflog file="destroyThread" text="#cfcatch.message# #cfcatch.detail#">
				</cfcatch>
				</cftry>
			</cfthread>
		</cfif>
	</cffunction>

	<!--- Solo sirve para invocarlo dentro del cfthread --->
			<cffunction name="invokeWSdestroyTokens" access="private" output="no" returnType="void">
				<cfset var LvarSRV = "localhost:#GvarLocalPort##getContextRoot()#">

				<!--- Para poder activar un nuevo cfthread se debe hacer fuera del cfthread, por eso se hace con WebService --->
				<cfif CGI.https EQ "on">
					<cfset LvarWS = "https://#LvarSRV#/home/public/FirmaDigital/plugin/login.cfc">
				<cfelse>
					<cfset LvarWS = "http://#LvarSRV#/home/public/FirmaDigital/plugin/login.cfc">
				</cfif>
				<cfhttp url="#LvarWS#?METHOD=WSdestroyTokens" />
			</cffunction>
			<cffunction name="WSdestroyTokens" access="remote" output="no" returnType="void">
				<cfset destroyTokensThread()>
			</cffunction>

			<cffunction name="invokeWSsendError" access="private" output="no" returnType="void">
				<cfargument name="token" 	type="string">
				<cfargument name="msg" 		type="string">

				<cfset var LvarSRV = "localhost:#GvarLocalPort##getContextRoot()#">

				<cfif isdefined("Application._FirmaDigital_.tokens.#LvarTK#.getStatus") AND Application._FirmaDigital_.tokens["TK" & Arguments.token].getStatus NEQ "*">
					<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token].getStatus = "sendError," & Arguments.MSG>
					<cfreturn>
				</cfif>

				<!--- Unicamente para WebSockets se debe enviar el mensaje fuera del cfthread, por eso se hace con WebService --->
				<cfif CGI.https EQ "on">
					<cfset LvarWS = "https://#LvarSRV#/home/public/FirmaDigital/plugin/login.cfc">
				<cfelse>
					<cfset LvarWS = "http://#LvarSRV#/home/public/FirmaDigital/plugin/login.cfc">
				</cfif>
				<cfhttp url="#LvarWS#?METHOD=WSsendError&token=#Arguments.token#&MSG=#Arguments.msg#" />
			</cffunction>
			<cffunction name="WSsendError" access="remote" output="no" returnType="void">
				<cfargument name="token" 	type="string">
				<cfargument name="msg" 		type="string">

				<cfset sendError(Arguments.token,Arguments.msg)>
			</cffunction>
	<!------>
	

	<!---
		expireToken:
			Expira el token
	--->
	<cffunction name="expireToken" access="public" output="no" returnType="void">
		<cfargument name="token" 	type="string">

		<cfset var LvarTS 			= Application._FirmaDigital_.tokens["TK" & token].ts>
		<cfset var LvarTS_STS 	= Application._FirmaDigital_.tokens["TK" & token].ts_sts>
		<cfset var LvarGetSTS 	= "">

		<cfif isdefined("Application._FirmaDigital_.tokens.TK" & Arguments.token & ".getStatus")>
			<cfset LvarGetSTS 	= Application._FirmaDigital_.tokens["TK" & token].getStatus>
		</cfif>
		
		<cfset Application._FirmaDigital_.tokens["TK" & token].ts_sts 		= -1>
		<cfset Application._FirmaDigital_.tokens["TK" & token] = JavaCast("null",0)>
		<cfset StructDelete(Application._FirmaDigital_.tokens, "TK" & token, false)>
		<cfset Application._FirmaDigital_.tokens["TK" & token] = structNew()>
		<cfset Application._FirmaDigital_.tokens["TK" & token].ts_sts 		= -abs(LvarTS_STS)>
		<cfset Application._FirmaDigital_.tokens["TK" & token].ts 				= LvarTS>
		<cfset Application._FirmaDigital_.tokens["TK" & token].ts_Timeout = getTickcount() - LvarTS>
		<cfset Application._FirmaDigital_.tokens["TK" & token].getStatus	= LvarGetSTS>
	</cffunction>
	
	<!---
		destroyToken:
			Destruye definitivamente el token y todos los tokens asociados por TK_TMP
			Cuando:
				1. Se detecta un error y se envía el mensaje de error al usuario (validateToken)
				2. Termina con éxito el proceso y se obtiene la información de la firma digital (getLoginData o getMSGData)
	--->
	<cffunction name="destroyToken" access="public" output="no" returnType="void">
		<cfargument name="token" 	type="string">

		<cfparam name="Application._FirmaDigital_.tokens.#Arguments.token#.TK_TMP" default="TK#Arguments.token#">
		<cfset LvarTK_TMP = Arguments.token OR Application._FirmaDigital_.tokens[LvarTK].TK_TMP>
		<cfloop collection="#Application._FirmaDigital_.tokens#" item="LvarTK">
			<cfparam name="Application._FirmaDigital_.tokens.#LvarTK#.TK_TMP" default="#LvarTK#">
			<cfif LvarTK EQ Arguments.token OR Application._FirmaDigital_.tokens[LvarTK].TK_TMP EQ LvarTK_TMP>
				<cfset Application._FirmaDigital_.tokens[LvarTK] = JavaCast("null",0)>
				<cfset StructDelete(Application._FirmaDigital_.tokens, LvarTK, false)>
			</cfif>
		</cfloop>
	</cffunction>
	
	<!---
		validateToken:
			Verifica la validez de un token para los diferentes procesos en Coldfusion
				El token debe existir (tener menos de 60 segundos)
				El token debe de inicializarse, pero solo una vez
				El token debe de suscriberse (subcanal WebSocket wsChannelFD.TOKEN), pero solo una vez
				El token debe haberse inicializado y suscrito una sola vez para aceptar los datos
	--->

	<cffunction name="validateToken" access="private" output="no" returnType="string">
		<cfargument name="token" type="string">
		<cfargument name="init" type="numeric">
		<cfargument name="fromJWS" type="boolean" default="false">
		<!---
			Arguments.init:
				0: No se ha suscrito subcanal.	Se usa en evento allowSubscribe de Application_wsChannelFD.cfc (sólo permite subscribir una sola vez)
				1: No se ha incializado JS.		Se usa en initTokenJS  (sólo permite inicializar una sola vez el javascript)
				2: No se ha incializado JWS.	Se usa en initTokenJWS (sólo permite inicializar una sola vez el java web start)
				3: Ya fue incializado.			Se usa en sendData  	(sólo permite enviar datos si ya fue inicializado una sola vez y subscrito una sola vez)
		--->

		<!--- 
					Se cambia el mensaje para informar que el token no ha existido en el ultimo minuto: 
					por seguridad, ejecución de un jnlp viejo, o cluster mal configurado 
		--->
		<cfif not isdefined("Application._FirmaDigital_.tokens.TK" & Arguments.token)>
			<cfreturn "ERROR: El token no existe">
		</cfif> 
		<cfset LvarAppTokenTK = Application._FirmaDigital_.tokens["TK" & Arguments.token]>
		
		<cfset LvarMSG = "OK">
		<cfset LvarVerificarSessionId = NOT (Arguments.fromJWS OR NOT isdefined("session.sessionId"))>

		<cfif LvarVerificarSessionId AND LvarAppTokenTK.sessionId NEQ encrypt(session.sessionId,"asp128" & Arguments.token)>
			<cfset LvarMSG = "ERROR: El token es inválido (SID)">
		<cfelseif LvarAppTokenTK.ts_sts eq -2 OR (getTickcount() - LvarAppTokenTK.ts GT LvarAppTokenTK.ts_Timeout)>
			<cfset LvarAppTokenTK.ts_sts = -2>
			<cfset LvarMSG = "ERROR: El token ha expirado (TM)">
		<cfelseif LvarAppTokenTK.ts_sts eq -1 OR (LvarAppTokenTK.ts_sts EQ 1 AND (getTickcount() - LvarAppTokenTK.ts GT 60000))>
			<cfset LvarAppTokenTK.ts_sts = -1>
			<cfset LvarMSG = "ERROR: El token ha expirado (DL)">
		<cfelseif getTickcount() - LvarAppTokenTK.ts LT 0>
			<cfset LvarMSG = "ERROR: El token es inválido (N)">
		<cfelseif Arguments.init eq 0 
			AND LvarAppTokenTK.subscribed>
			<cfset LvarMSG = "ERROR: El token es inválido (S)">
		<cfelseif Arguments.init eq 1 
			AND LvarAppTokenTK.initiatedJS>
			<cfset LvarMSG = "ERROR: El token es inválido (JS)">
		<cfelseif Arguments.init eq 2 
			AND LvarAppTokenTK.initiatedJWS>
			<cfset LvarMSG = "ERROR: El token es inválido (JWS)">
		<cfelseif Arguments.init eq 2 
			AND NOT LvarAppTokenTK.subscribed>
			<cfset LvarMSG = "ERROR: No hay comunicación Websocket con el Navegador">
		<cfelseif Arguments.init eq 3>
			<cfif NOT LvarAppTokenTK.subscribed>
				<cfset LvarMSG = "ERROR: El token es inválido (NS)">
			<cfelseif NOT LvarAppTokenTK.initiatedJS>
				<cfset LvarMSG = "ERROR: El token es inválido (NJS)">
			<cfelseif NOT LvarAppTokenTK.initiatedJWS>
				<cfset LvarMSG = "ERROR: El token es inválido (NJWS)">
			</cfif>
		</cfif>

		<cfif LvarMSG NEQ "OK">
			<cfset destroyToken(Arguments.token)>
		</cfif>

		<cfreturn LvarMSG>
	</cffunction>

	<!---
		wsSubscribeToken:
			Inicializa la suscripción del token desde el evento allowSubscribe del ChannelListener Application_wsChannelFD.cfc
	--->
	<cffunction name="wsSubscribeToken" access="public" output="no" returnType="boolean">
		<cfargument name="channelName" type="string">		

		<cfif left(Arguments.channelName,16) NEQ "wsChannelFD.WSC_">
			<cfreturn false>
		</cfif>

		<cfset LvarToken = listGetAt(Arguments.channelName,2,"_")>
		<cfset LvarMSG = validateToken(LvarToken, 0)>
		<cfif LvarMSG EQ "OK">
			<cfset Application._FirmaDigital_.tokens["TK" & LvarToken].subscribed = true>
		</cfif>

		<cfreturn (LvarMSG EQ "OK")>
	</cffunction>

	<!---
		initTokenJS:
			Inicializa el token desde la aplicación Javascript de login
	--->
	<cffunction name="initTokenJS" access="public" output="no" returnType="any">
		<cfargument name="token"		type="string">
		<cfargument name="getStatus"	type="numeric">

		<cftry>
			<cfif arguments.getStatus EQ 1>
				<cfset LvarMSG = validateToken(Arguments.token, 0)>
				<cfif LvarMSG NEQ "OK">
					<cfreturn "initTokenJS," & LvarMSG>
				</cfif>

				<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token].subscribed	= true>
				<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token].getStatus	= "getStatus,OK">
			</cfif>
			
			<cfset LvarMSG = validateToken(Arguments.token, 1)>
			<cfif LvarMSG EQ "OK">
				<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token].initiatedJS = true>
			</cfif>
		<cfcatch type="any">
			<cfset LvarMSG = "#cfcatch.message# #cfcatch.detail#">
		</cfcatch>
		</cftry>

		<cfif arguments.getStatus EQ 1>
			<cfreturn "initTokenJS," & LvarMSG>
		<cfelse>
			<cfreturn {type="initTokenJS", status=LvarMSG}>
		</cfif>
	</cffunction>

	<!---
		initServer:
			Inicializa el proceso de Instalacion o Ejecucion o Busqueda del FirmaDigitalServer (Siempre se invoca por Ajax)
	--->
	<cffunction name="initServer" access="public" output="no" returnType="string">
		<cfargument name="token"			type="string">

		<cftry>
			<cfset LvarMSG = validateToken(Arguments.token, -1)>

			<cfif LvarMSG EQ "OK">
				<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token].ts_Timeout	= GvarTimeout_Sign + 1000>
				<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token].ts_sts = 3>
			</cfif>
		<cfcatch type="any">
			<cfset LvarMSG = "#cfcatch.message# #cfcatch.detail#">
		</cfcatch>
		</cftry>

		<cfreturn "initServer," & LvarMSG>
	</cffunction>

	<!---
		initTokenJWS_init:
			El FirmaDigitalSignInit.jar le reporta al servidor que ya se bajó y se ejecutó dentro de los primeros 60 segundos
	--->
	<cffunction name="initTokenJWS_init" access="remote" output="no" returnType="string" returnFormat="plain">
		<cfargument name="token" type="string">	
		
		<cfset var LvarMSG = validateToken(Arguments.token, -1, true)>
		<cfif LvarMSG EQ "OK">
			<!--- Se ejecutó el JWS dentro de los primeros 60 segundos --->
			<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token].ts_sts = 2>
		</cfif>
		<cfreturn LvarMSG>
	</cffunction>
	
	<!---
		initTokenJWS:
			Inicializa el token desde la aplicación Java Web Start de login
	--->
	<cffunction name="initTokenJWS" access="public" output="no" returnType="string">
		<cfargument name="token" type="string">		
		<cfargument name="data"	 type="string">		

		<cfset var LvarMSG = "">
		<cftry>
			<cfset LvarMSG = validateToken(Arguments.token, 2, true)>

			<cfif LvarMSG EQ "OK">
				<cfset LvarAppTokenTK = Application._FirmaDigital_.tokens["TK" & Arguments.token]>
				<cfset LvarAppTokenTK.ts_sts = 2>		<!--- Se ejecutó el JWS dentro de los primeros 60 segundos --->
				<cfset LvarData	= createObject("component","home.public.FirmaDigital.Componentes.crypto").RSA_Decrypt (Arguments.data)>
				<cfset LvarData	= listToArray(LvarData)>
				<cfset LvarSTkn = LvarAppTokenTK.skey>
				<cfset LvarSTkn = decrypt(LvarSTkn,"asp128" & Arguments.token)>
				<cfif Arguments.token NEQ LvarData[1]>
					<cfset LvarMSG = "ERROR: Token encriptado inválido">
				<cfelseif LvarData[2] NEQ LvarSTkn>
					<cfset LvarMSG = "ERROR: Token secreto inválido">
				</cfif>
			</cfif>

			<cfif LvarMSG EQ "OK">
				<cfset LvarSKey = LvarData[3]>
				<cfset LvarAppTokenTK.SKey = encrypt(LvarSKey, "asp128" & Arguments.token)>
				<cfset LvarAppTokenTK.initiatedJWS = true>
			</cfif>

			<cfif isdefined("Application._FirmaDigital_.tokens.TK" & Arguments.token)>
				<cfif LvarAppTokenTK.getStatus EQ "*">
					<cfset wsPublish("wsChannelFD.WSC_#Arguments.token#", {type="initTokenJWS", status=LvarMSG})>
				<cfelse>
					<cfset LvarAppTokenTK.getStatus = "initTokenJWS," & LvarMSG>
				</cfif>
			</cfif>
		<cfcatch type="any">
			<cfset LvarMSG = cfcatch.message & " " & cfcatch.detail>
		</cfcatch>
		</cftry>

		<cfreturn LvarMSG>
	</cffunction>

	<!---
		sendPort:
			Recibe el puerto donde se instaló el Servidor Local de FirmaDigital y lo envía al javascript 
	--->
	<cffunction name="sendPort" access="public" output="no" returnType="string">
		<cfargument name="token" type="string">		
		<cfargument name="port" type="string">		

		<cftry>
			<cfif isdefined("Application._FirmaDigital_.tokens.TK#Arguments.token#.getStatus")>
				<cfif Application._FirmaDigital_.tokens["TK" & Arguments.token].getStatus EQ "*">
					<cfset wsPublish("wsChannelFD.WSC_#Arguments.token#", {type="sendPort", status="OK:" & Arguments.port})>
				<cfelse>
					<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token].getStatus = "sendPort,OK:" & Arguments.port>
				</cfif>
			</cfif>
		<cfcatch type="any">
		</cfcatch>
		</cftry>

		<cfreturn "OK">
	</cffunction>

	<!---
		sendData:
			Recibe y almacena los datos de la firma digital enviados por la aplicación Java Web Start de login 
			y envía la señal de submit al javascript de la pantalla de login 
	--->
	<cffunction name="sendData" access="public" output="no" returnType="string">
		<cfargument name="token" type="string">		
		<cfargument name="data" type="string">		

		<cfset var LvarMSG = "">
		<cftry>
			<cfset LvarMSG = validateToken(Arguments.token, 3, true)>
			<cfif LvarMSG EQ "OK">
				<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token].data = Arguments.data>
				
				<cfif Application._FirmaDigital_.tokens["TK" & Arguments.token].getStatus EQ "*">
					<cfset wsPublish("wsChannelFD.WSC_#Arguments.token#", {type="sendData", status=LvarMSG})>
				<cfelse>
					<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token].getStatus = "sendData," & LvarMSG>
				</cfif>
			</cfif>
		<cfcatch type="any">
			<cfset LvarMSG = cfcatch.message & " " & cfcatch.detail>
		</cfcatch>
		</cftry>
			
		<cfreturn LvarMSG>
	</cffunction>

	<cffunction name="getDecryptData" access="public" output="no" returnType="string">
		<cfargument name="token" 		type="string">
		<cfargument name="encryptData"	type="string">
		<cfargument name="SKey"			type="string">

		<cfset LvarSKey = decrypt(Arguments.SKey,"asp128" & Arguments.token)>
		<cfset LvarData	= createObject("component","home.public.FirmaDigital.Componentes.crypto").AES_DecryptFromHex(Arguments.encryptData, LvarSKey)>

		<cfreturn LvarData>
	</cffunction>
	
	<!---
		sendError:
			Recibe un mensaje de error enviado por la aplicación Java Web Start de login 
			y envía la señal de error al javascript de la pantalla de login 
	--->
	<cffunction name="sendError" access="public" output="no" returnType="string">
		<cfargument name="token" type="string">		
		<cfargument name="MSG" type="string">		

		<cfset var LvarMSG = "">
		<cftry>
			<cfif left(Arguments.MSG,5) NEQ "ERROR">
				<cfset Arguments.MSG = "ERROR:" & Arguments.MSG>
			</cfif>

			<cfif isdefined("Application._FirmaDigital_.tokens.TK#Arguments.token#.getStatus")>
				<cfif Application._FirmaDigital_.tokens["TK" & Arguments.token].getStatus EQ "*">
					<cfset wsPublish("wsChannelFD.WSC_#Arguments.token#", {type="sendError", status=Arguments.MSG})>
				<cfelse>
					<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token].getStatus = "sendError," & Arguments.MSG>
				</cfif>
			</cfif>
		<cfcatch type="any">
		</cfcatch>
		</cftry>

		<cfreturn "OK">
	</cffunction>

	<!---
		getStatus:
			Metodo alternativo cuando el publish/suscribe de WebSocket falla.  Devuelve el Status del JavaWebSocket 
	--->
	<cffunction name="getStatus" access="public" output="no" returnType="string">
		<cfargument name="token" type="string">		

		<cfset var LvarMSG = "">
		<cftry>
			<cfset LvarMSG = validateToken(Arguments.token, -1, true)>
			<cfif LvarMSG EQ "OK">
				<cfset LvarMSG = Application._FirmaDigital_.tokens["TK" & Arguments.token].getStatus>
				<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token].getStatus = "getStatus,OK">
				<cfreturn LvarMSG>
			<cfelse>
				<cfreturn "getStatus," & LvarMSG>
			</cfif>
		<cfcatch type="any">
			<cfreturn "getStatus," & cfcatch.message & " " & cfcatch.detail>
		</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="addListToStruct">
		<cfargument name="struct" type="struct">
		<cfargument name="list">
		<cfargument name="delimiters" default=",">
		
		<cfloop list="#Arguments.list#" index="LvarElem" delimiters="#Arguments.delimiters#">
			<cfset LvarNom	= trim(listGetAt(LvarElem & "=",1,"="))>
			<cfset LvarVal	= trim(listGetAt(LvarElem & "=",2,"="))>
			<cfset Arguments.Struct[trim(LvarNom)] = trim(LvarVal)>
		</cfloop>
		<cfreturn Arguments.Struct>
	</cffunction>
</cfcomponent>

