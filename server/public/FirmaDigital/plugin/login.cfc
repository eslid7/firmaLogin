<cfcomponent displayname="Autenticacion" output="true" hint="Autenticacion a Sistemas WEB"
             extends="home.public.FirmaDigital.Componentes.FirmaDigital"
>
	<!---
		pintaIframe:
			pinta el IFrame que sustituye al lightBox anterior, para iniciar el componente de FirmaDigital para autenticacion

			GUI de Autenticacion:	<iframe> + js:sbInvocarFirmaDigital()
				login.cfm:  				monitoreo al JavaWebStart
				login_ok.cfm				Se autentica, asigna usuario, verifica permisos y cflocation al index del sistema
	--->
	<cffunction name="pintaIframe" access="public" output="yes" returnType="void">
		<cfargument name="automatico"		type="boolean" default="false">
		<cfargument name="pruebas"			type="boolean" default="false">
		<cfargument name="idOpenFD"			type="string"  default="loginFD"> 

		<cfset pintaIframe_(Arguments.automatico, false, Arguments.pruebas)>
		<cfoutput>
			<cf_confirm index="1" importLibs="false" width="30" ShowButtons="true" BlockModal="true">
	          <div class="firma_digitalLogueo"> 
	            <div class="bs-example">
	              <div class="list-group">
	                <a class="list-group-item active"><center><h4>Autenticación con Firma Digital</h4></center></a>
	                <a class="list-group-item"><i class="fa fa-arrow-down"></i> 1. Conecte el lector de Firma Digital</a>
	                <a class="list-group-item"><i class="fa fa-arrow-down"></i> 2. Coloque la Tarjeta de Firma Digital en el lector</a>
	                <a class="list-group-item"><i class="fa fa-arrow-down"></i> 3. Se descargar&aacute; el archivo: <i id="descargarFirmaDigital">FirmaDigital.jnlp</i></a>
	                <a class="list-group-item"><i class="fa fa-arrow-down"></i> 4. Ejecute el archivo descargado (double-clic en 'FirmaDigital.jnlp')</a>
	                <a class="list-group-item"><i class="fa fa-arrow-down"></i> 5. Digite el PIN de la Firma Digital (<l><b style='color:red'>PRECAUCION:</b>  Después de 3 intentos fallidos la FirmaDigital se bloquea</l>)</a>
	                <span class="list-group-item">
	                  <div class="btn-group-vertical" style="display:block">
	                    <span class="btn btn-default" id="showStepsFD"><i class="fa fa-question-circle"></i>  Mostrar informaci&oacute;n para la autenticaci&oacute;n</span>
	                    <span class="btn btn-primary" id="closeStepsFD">Confirmar y no volver a mostrar información</span>
	                  </div>
	                </span>
	              </div>
	            </div>
	          </div>
	       </cf_confirm>
	       <script type="text/javascript">
	       		OpenFirma=function(){
		        	GvarJEmpresa = document.getElementById("j_empresa").value;
		        	if (GvarJEmpresa == "")
		        	{
		        	  alert ("Seleccione primero una Empresa");
		        	  return false;
		        	}
			        var Mostrar = getCookie('CFSHOWFDSTEPS');
			        if( Mostrar=='' || Mostrar=='0' ){
			          PopUpAbrir1(); 
			        }
			        else{
			           sbInvocarFirmaDigital();
			        }
			      }

		      $(function(){
		        $("##myModal1").on("hidden.bs.modal", function () {
		            sbInvocarFirmaDigital();
		        });
		        $("##myModal1 a.list-group-item:not(:first-child)").hide();
		        $("##showStepsFD").click(function(){ $("##myModal1 a.list-group-item").show(500); });
		        $("##closeStepsFD").click(function() {$('##myModal1').modal('hide'); document.cookie = "CFSHOWFDSTEPS=1;";})
		        $("###arguments.idOpenFD#").click(OpenFirma);
		      });

		      $("##chkNoMostrarMas").click(
                function(){  
                  if(this.checked){
                     document.cookie = "CFSHOWFDSTEPS=1;"; 
                   }else{
                     document.cookie = "CFSHOWFDSTEPS=0;"; 
                   }
                }
          		);
      
 
      		function getCookie(cname) { var name = cname + "="; var ca = document.cookie.split(';');
      		for(var i = 0; i < ca.length; i++) 
      		{ var c = ca[i]; while (c.charAt(0) == ' ') { c = c.substring(1); } 
      		if (c.indexOf(name) == 0) { return c.substring(name.length, c.length); } } return ""; }	
	       </script>

		</cfoutput>
	</cffunction>

	
	<!---
		pintaIframe:
			pinta el IFrame para iniciar el componente de FirmaDigital para autenticacion

			GUI de Autenticacion:	<iframe> + js:sbInvocarFirmaDigital()
				login.cfm:  				monitoreo al JavaWebStart
				login_ok.cfm				Se autentica e invoca el js:sbPostFirmaDigital()
	--->
	<cffunction name="pintaIframeSoloAutenticacion" access="public" output="yes" returnType="void">
		<cfargument name="automatico"		type="boolean" default="false">
		<cfargument name="pruebas"			type="boolean" default="false">

		<cfset pintaIframe_(Arguments.automatico, true, Arguments.pruebas)>
	</cffunction>

	<cffunction name="pintaIframe_" access="private" output="yes" returnType="void">
		<cfargument name="automatico"			type="boolean" default="false">
		<cfargument name="soloAutenticacion"	type="boolean" default="false">
		<cfargument name="pruebas"				type="boolean" default="false">

		<cfset var LvarPath	 = "#cgi.CONTEXT_PATH#/home/public/FirmaDigital/plugin">

		<cfset session._FD_conFirma_ = false>
		<cfset session._FD_Autenticacion_ = structNew()>

		<cfquery name="rsCEalias" datasource="asp">
			select CEaliaslogin
			  from CuentaEmpresarial
		</cfquery>

		<cfoutput>
			<cfif Arguments.pruebas>
			<iframe name="ifrLogin" id="ifrLogin" style="display:inline" width="450" height="350"></iframe>
		  <cfelse>
			<iframe name="ifrLogin" id="ifrLogin" style="display:none"></iframe>
		  </cfif>
			<script type="text/javascript" language="javascript">
				var Gvar1vez = true;
			  <cfif Arguments.soloAutenticacion>
				function exists_PostFirmaDigital()
				{
					if (window.sbPostFirmaDigital)
						return true;
					alert("ERROR en AUTENTICACION con FirmaDigital:\nNo se encontró la función javascript sbPostFirmaDigital(), coloquela antes de la invocación a pintaIframeSoloAutenticacion().\nNo se puede continuar con el proceso");
					return false;
				}

				exists_PostFirmaDigital();
			  <cfelse>
				var GvarJEmpresa;
				var GvarJEmpresas = [#QuotedValueList(rsCEalias.CEaliaslogin)#];
				function exists_j_empresa(t)
				{
					if (
							parent.document.getElementById("j_empresa")
						)
					{
						GvarJEmpresa = parent.document.getElementById("j_empresa").value;
						if (t == 2 && GvarJEmpresa == "")
						{
							alert ("Seleccione primero una Empresa");
							return false;
						}
						if (t == 2 && GvarJEmpresas.indexOf(GvarJEmpresa) == -1)
						{
							alert ("No existe Empresa seleccionada");
							return false;
						}
					}
					else
					{
						alert ("ERROR en pantalla de Login, se requiere definir el campo j_empresa (con id y name)");
						return false;
					}
					return true;
				}
				
				exists_j_empresa(1);
			  </cfif>
				function sbInvocarFirmaDigital() 
				{
					var LvarIFrame = document.getElementById("ifrLogin"); 
				  <cfif Arguments.soloAutenticacion>
					if (!exists_PostFirmaDigital())
						return;
				  <cfelse>
					if (!exists_j_empresa(2))
						return;
				  </cfif>
					if (Gvar1vez)
					{
						Gvar1vez = false;
						<!---alert(
							"AUTENTICACION con FirmaDigital:\n"+
							"1. Conecte el Dispositivo de lectura de SmartCards en un USB\n"+
							"2. Coloque la Tarjeta de Firma Digital en el Dispositivo\n"+
							"3. Digite el PIN de la firma digital\n"+
							"    (PRECAUCION:  Después de 3 intentos fallidos la FirmaDigital se bloquea)"
							<!---
							"3. Acepte el Download del Archivo 'FirmaDigital.jnlp'\n"+
							"    (se debe ejecutar con Java WebStart o Java IcedTea)\n"+
							"4. Ejecute el jnlp (double-click en 'FirmaDigital.jnlp')\n"+
							"5. Digite el PIN de la firma digital\n"+
							"    (PRECAUCION:  Después de 3 intentos fallidos la FirmaDigital se bloquea)"
							--->
						);--->
					}
					<cfif NOT Arguments.soloAutenticacion>
						<cfset LvarLogin_FDauto = "*">
						<cfif isdefined("session.sitio.login") and find(".cfm", session.sitio.login)>
							<cfset LvarLogin = session.sitio.login>
							<cfset LvarLogin = left(LvarLogin, find(".cfm", LvarLogin)-1) & "_FDauto.cfm">
							<cfif fileExists(expandPath(LvarLogin))>
								<cfset LvarLogin = GetContextRoot() & LvarLogin>
								<cfset LvarLogin_FDauto = BinaryEncode(LvarLogin.getBytes(),"HEX")>
							</cfif>
							// #LvarLogin#
						</cfif>
						LvarIFrame.src = "#LvarPath#/login.cfm?tkn=<cfoutput>#GetTickCount()#</cfoutput>&a=#LvarLogin_FDauto#&e="+GvarJEmpresa;
					<cfelse>
						LvarIFrame.src = "#LvarPath#/login.cfm";
					</cfif>
					return;
				}
				<cfif Arguments.automatico>
					sbInvocarFirmaDigital();
				</cfif>
			</script>
		</cfoutput>
		<cfreturn>
	</cffunction>

	<!---
		pintaControlBack:
			Refresca la pantalla cuando viene de goBack
	--->
	<cffunction name="pintaControlBack" access="public" output="yes" returnType="void">
		<cfoutput>
			<form name="formRL" method="post">
				<input type="hidden" name="RELOAD"	value="0">
			</form>
			<script type="text/javascript">
				if (document.formRL.RELOAD.value == "1")
				{
					document.formRL.RELOAD.value = "2";
					window.top.location.reload();
				}
				document.formRL.RELOAD.value = "1";
			</script>
		</cfoutput>
	</cffunction>

	<!---
		pintaEliminaBack:
			Elimina la funcionalidad del boton Back
	--->
	<cffunction name="pintaEliminaBack" access="public" output="yes" returnType="void">
		<cfoutput>
			<script type="text/javascript">
				// Elimina el Back Button
				(function (global) { if(typeof (global) === "undefined") {throw new Error("window is undefined");} var _hash = "!"; var noBackPlease = function () {global.location.href += "##"; global.setTimeout(function () {global.location.href += "!";}, 50);};global.onhashchange = function () {if (global.location.hash !== _hash) {global.location.hash = _hash;}};global.onload = function () {noBackPlease(); document.body.onkeydown = function (e) {var elm = e.target.nodeName.toLowerCase();if (e.which === 8 && (elm !== 'input' && elm  !== 'textarea')) {e.preventDefault();} e.stopPropagation();};}})(window);
			</script>
		</cfoutput>
	</cffunction>
	
	<!---
		initTokenJS:
			Inicializa el token desde la aplicación Java Web Start de login
	--->
	<cffunction name="initTokenJS" access="remote" output="no" returnType="any" returnFormat="plain">
		<cfargument name="token"			type="string">
		<cfargument name="getStatus"	type="numeric">

		<cfset LvarClusterResponse = createObject("component","home.public.FirmaDigital.plugin.cluster").exeToken(Arguments.Token)>
		<cfif LvarClusterResponse NEQ "*LOCAL*">
			<cfreturn LvarClusterResponse>
		</cfif>

		<cfreturn super.initTokenJS(argumentcollection=Arguments)>
	</cffunction>

	<!---
		initServer:
			Inicializa el proceso de Instalacion o Ejecucion o Busqueda del FirmaDigitalServer
	--->
	<cffunction name="initServer" access="remote" output="no" returnType="any" returnFormat="plain">
		<cfargument name="token"			type="string">
		<cfargument name="getStatus"	type="numeric">

		<cfset LvarClusterResponse = createObject("component","home.public.FirmaDigital.plugin.cluster").exeToken(Arguments.Token)>
		<cfif LvarClusterResponse NEQ "*LOCAL*">
			<cfreturn LvarClusterResponse>
		</cfif>

		<cfreturn super.initServer(argumentcollection=Arguments)>
	</cffunction>

	<!---
		initTokenJWS:
			Inicializa el token desde la aplicación Java Web Start de login
	--->
	<cffunction name="initTokenJWS" access="remote" output="no" returnType="string" returnFormat="plain">
		<cfargument name="token" type="string">		
		<cfargument name="data"	 type="string">		

		<cfset LvarClusterResponse = createObject("component","home.public.FirmaDigital.plugin.cluster").exeToken(Arguments.Token)>
		<cfif LvarClusterResponse NEQ "*LOCAL*">
			<cfreturn LvarClusterResponse>
		</cfif>

		<cfreturn super.initTokenJWS(argumentcollection=Arguments)>
	</cffunction>

	<!---
		sendPort:
			Recibe el puerto donde se instaló el Servidor Local de FirmaDigital y lo envía al javascript 
	--->
	<cffunction name="sendPort" access="remote" output="no" returnType="string" returnFormat="plain">
		<cfargument name="token" type="string">		
		<cfargument name="port" type="string">		

		<cfset LvarClusterResponse = createObject("component","home.public.FirmaDigital.plugin.cluster").exeToken(Arguments.Token)>
		<cflog file="loginFirma" text="sendPort #LvarClusterResponse#">
		<cfif LvarClusterResponse NEQ "*LOCAL*">
			<cfreturn LvarClusterResponse>
		</cfif>

		<cfreturn super.sendPort(argumentcollection=Arguments)>
	</cffunction>

	<!---
		sendData:
			Recibe y almacena "los datos de la firma digital" enviados por la aplicación Java Web Start de login
			Ejecuta el proceso de Autenticacion de SOIN
			Envía la señal de submit al javascript de la pantalla de login
	--->
	<cffunction name="sendData" access="remote" output="no" returnType="string" returnFormat="plain">
		<cfargument name="token" type="string">		
		<cfargument name="data" type="string">		

		<cfset LvarClusterResponse = createObject("component","home.public.FirmaDigital.plugin.cluster").exeToken(Arguments.Token)>
		<cfif LvarClusterResponse NEQ "*LOCAL*">
			<cfreturn LvarClusterResponse>
		</cfif>

		<cftry>
			<cfif not isdefined("Application._FirmaDigital_.tokens.TK" & Arguments.token)>
				<cfreturn "El tiempo para ejecutar la aplicación ha expirado">
			</cfif> 
		
			<cfset validaCert(argumentcollection=Arguments)>
			<cfset LvarMSG = super.sendData(argumentcollection=Arguments)>
			<cflog file="loginFirma" text="sendData #LvarMSG#">
		<cfcatch type="any">
			<cfset LvarMSG = cfcatch.message & " " & cfcatch.detail>
		</cfcatch>
		</cftry>

		<cfreturn LvarMSG>
	</cffunction>

	<!---
		validaCert:
			Valida Vigencia, Certificación y Revocación del Certificado que se envía encriptado en data
	--->
	<cffunction name="validaCert" access="private" output="no" returnType="void">
		<cfargument name="token" type="string">		
		<cfargument name="data" type="string">		

		<!--- Valida Vigencia, Certificación y Revocación del Certificado de Login --->
		<cfset LvarAppTokenTK 	= Application._FirmaDigital_.tokens["TK" & Arguments.token]>
		<cfset LvarData 		= getDecryptData(Arguments.token, Arguments.data, LvarAppTokenTK.skey)>
		<cfset LvarCertHex		= listGetAt(LvarData,2)>
		<cfset LvarCrypt		= createObject("component","home.public.FirmaDigital.Componentes.crypto")>
		<cfset LvarCert509		= LvarCrypt.getCertificateFromHexString(LvarCertHex)>
		<cfset LvarCertResp		= LvarCrypt.validaCert(LvarCert509)>

		<cfif LvarCertResp.num NEQ 0>
			<cfthrow message= "#LvarCertResp.msg# (#LvarCertResp.num#)">
		</cfif>
	</cffunction>

	<!---
		sendError:
			Recibe un mensaje de error enviado por la aplicación Java Web Start de login 
			y envía la señal de error al javascript de la pantalla de login 
	--->
	<cffunction name="sendError" access="remote" output="no" returnType="string" returnFormat="plain">
		<cfargument name="token" type="string">		
		<cfargument name="MSG" type="string">		

		<cfset LvarClusterResponse = createObject("component","home.public.FirmaDigital.plugin.cluster").exeToken(Arguments.Token)>
		<cfif LvarClusterResponse NEQ "*LOCAL*">
			<cfreturn LvarClusterResponse>
		</cfif>
		<cflog file="loginFirma" text="sendError #LvarClusterResponse#">
		<cfreturn super.sendError(argumentcollection=Arguments)>
	</cffunction>

	<!---
		getStatus:
			Metodo alternativo cuando el publish/suscribe de WebSocket falla.  Devuelve el Status del JavaWebSocket 
	--->
	<cffunction name="getStatus" access="remote" output="no" returnType="string" returnFormat="plain">
		<cfargument name="token" type="string">		

		<cfset LvarClusterResponse = createObject("component","home.public.FirmaDigital.plugin.cluster").exeToken(Arguments.Token)>
		<cfif LvarClusterResponse NEQ "*LOCAL*">
			<cfreturn LvarClusterResponse>
		</cfif>
		<cflog file="loginFirma" text="getStatus #LvarClusterResponse#">
		<cfreturn super.getStatus(argumentcollection=Arguments)>
	</cffunction>

	<!---
		getLoginData:
			Desencripta la información de la firma digital enviada por la aplicación Java Web Start de login
	--->
	<cffunction name="getLoginData" access="public" output="no" returnType="struct">
		<cfargument name="token"   type="string">		
		<cfargument name="CEalias" type="string" default="">
		
		<cfset var LvarMSG = validateToken(Arguments.token, 3)>

		<cfif LvarMSG NEQ "OK">
			<cfthrow message="#LvarMSG#">
		</cfif>

		<cfset LvarAppTokenTK 	= Application._FirmaDigital_.tokens["TK" & Arguments.token]>
		<cfset LvarData 		= getDecryptData(Arguments.token, LvarAppTokenTK.data, LvarAppTokenTK.skey)>

		<cfset destroyToken(Arguments.token)>

		<cfset LvarCert509	= validaLoginData (Arguments.token, LvarData)>
		
		<cfset LvarResultado = addListToStruct(structNew(), LvarCert509.getSubjectX500Principal().toString())>
		<!--- <cfset LvarResultado.X509	= BinaryEncode(LvarCert509.getEncoded(),"base64")> --->
		<cfset LvarResultado.X509SUBJECT= LvarCert509.getSubjectX500Principal().toString()>
		<cfset LvarResultado.X509ISSUER	= LvarCert509.getIssuerX500Principal().toString()>
		<cfset LvarResultado.X509SERIAL	= LvarCert509.getSerialNumber().toString()>
		<cfset LvarResultado.TKN		= Arguments.token>
		<cfset LvarResultado.forLogon	= LvarAppTokenTK.forLogon>
		<cfset LvarResultado.NAME		= LvarResultado.GIVENNAME & " " & LvarResultado.SURNAME>
		<cfset LvarResultado.SubjectSN	= LvarResultado.SERIALNUMBER>
		<cfset LvarResultado.UID		= mid(LvarResultado.SubjectSN,5,12)>
		<cfset LvarResultado.PWD		= mid(LvarResultado.SubjectSN,5,12) & LvarResultado.GIVENNAME>

		<cftry>
			<cfset LvarRes = sbGetUsucodigo(LvarResultado, Arguments.CEalias)>
			<cfset LvarResultado.Usucodigo = LvarRes.Usucodigo>
			<cfset LvarResultado.Usulogin = LvarRes.Usulogin>
			<cfset LvarResultado.Usutipo = LvarRes.Tipo>
		<cfcatch type="any">
			<cfset LvarResultado.Usucodigo = -1>
			<cfset LvarResultado.UsuError = cfcatch.message>
		</cfcatch>
		</cftry>
		<cfreturn LvarResultado>
	</cffunction>

	<!---
		validaLoginData:
			Asegura que el Certificado esté firmado (Firma Digital Simple) por la llave privada de la FirmaDigital
			data = token, CertHex, FirmaDigital(token,CertHex)
	--->
	<cffunction name="validaLoginData" access="public" output="no" returnType="any" returnFormat="plain">
		<cfargument name="token" type="string">		
		<cfargument name="data"	type="string">
		
		<cfset LvarToken	= listGetAt(arguments.data,1)>
		<cfset LvarCertHex	= listGetAt(arguments.data,2)>
		<cfset LvarFirmaHex	= listGetAt(arguments.data,3)>
		<cfset LvarData		= LvarToken & "," & LvarCertHex>
		
		<cfif Arguments.token NEQ LvarToken>
			<cfthrow message="ERROR: Token encriptado inválido: #Arguments.token# NEQ #LvarToken#">
		</cfif>

		<!--- Valida Firma Digital Simple de la información recibida --->
		<cfset LvarCrypt	= createObject("component","home.public.FirmaDigital.Componentes.crypto")>
		<cfset LvarCert509	= LvarCrypt.getCertificateFromHexString(LvarCertHex)>

        <cfset LvarDigitalSignatureAlgorithm = LvarCert509.getSigAlgName()>
        <cfset LvarDSA		= createObject("java","java.security.Signature").getInstance(LvarDigitalSignatureAlgorithm)>
		<cfset LvarKey		= LvarCert509.getPublicKey()>
        <cfset LvarDSA.initVerify(LvarKey)>
        <cfset LvarDSA.update(LvarData.getBytes())>
		
        <cfif NOT LvarDSA.verify(binaryDecode(LvarFirmaHex,"hex"))>
			<cfthrow message="ERROR: La Firma del Certificado encriptado es inválida">
		</cfif>
		
		<!--- Valida Vigencia, Certificación y Revocación del Certificado de Login --->
		<cfset LvarCertResp		= LvarCrypt.validaCert(LvarCert509)>

		<cfif LvarCertResp.num EQ 0>
			<cfreturn LvarCert509>
		<cfelse>
			<cfthrow message="#LvarCertResp.msg# (#LvarCertResp.num#)">
		</cfif>
	</cffunction>

	<!---
		sbGetUsucodigo:
			Obtiene el Usucodigo asociado a la FirmaDigital
	--->
	<cffunction name="sbGetUsucodigo" access="public" output="no" returnType="struct">
		<cfargument name="X509"		type="struct">
		<cfargument name="CEalias" 	type="string" default="">	

		<cfset var LvarResult = structNew()>
		<cfset LvarResult.Usucodigo = "0">
		<cfset LvarResult.Usulogin = "">

		<cfif Arguments.CEalias EQ "">
			<cfif not isdefined("session.CEcodigo") or session.CEcodigo EQ ""  or session.CEcodigo EQ "0">
				<cfset LvarResult.CEcodigo = 0>
			<cfelse>
				<cfset LvarResult.CEcodigo = session.CEcodigo>
			</cfif>
		<cfelse>
			<cfquery name="rsCE" datasource="asp" >
				select CEcodigo
				  from CuentaEmpresarial
				 where CEaliaslogin=<cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.CEalias#">
			</cfquery>
			<cfset LvarResult.CEcodigo = rsCE.CEcodigo>
		</cfif>

		<cftry>
			<!---
				CREATE TABLE UsuarioFirmaDigital
				( 
					FDid		varchar(40),
					FDidControl	varchar(40),
					SubjectSN   varchar(40),
					CEcodigo	numeric(18),
					Usucodigo	numeric(18),
					
					CONSTRAINT UsuarioFirmaDigital_PK PRIMARY KEY (FDid)
				)
			--->
			<cfquery name="rsFD" datasource="asp" >
				select Usucodigo, FDidControl, SubjectSN
				  from UsuarioFirmaDigital
				 where FDid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#fnUsuarioFirmaDigital_FDid(Arguments.X509.X509SERIAL, LvarResult.CEcodigo)#">
			</cfquery> 

			<cfset LvarResult.Tipo = "UsuarioFirmaDigital">

			<cfif LvarResult.CEcodigo EQ 0>
				<cfset LvarResult.Usucodigo = "-1">
				<cfreturn LvarResult>
			<cfelseif rsFD.Usucodigo EQ "">
				<cfreturn LvarResult>
			</cfif>

			<cfif fnUsuarioFirmaDigital_FDid(Arguments.X509.X509SERIAL, LvarResult.CEcodigo, rsFD.SubjectSN, rsFD.Usucodigo) NEQ rsFD.FDidControl>
				<cfthrow message="El Registro de la FirmaDigital ha sido modificada.  Se cambio el SubjectSN o Usuario.  Comuniquese con el Administrador del Sistema">
			</cfif>
			
			<cfquery name="rsFD" datasource="asp" >
				select u.Usucodigo, u.Usulogin
				  from Usuario u
				 where u.Usucodigo=<cfqueryparam cfsqltype="cf_sql_numeric" value="#rsFD.Usucodigo#">
			</cfquery> 

			<cfset LvarResult.Usucodigo = rsFD.Usucodigo>
			<cfset LvarResult.Usulogin = rsFD.Usulogin>
		<cfcatch type="database">
			<cfset LvarResult.Tipo = "DatosPersonales">
			<cfquery name="rsCed" datasource="asp" >
				select u.Usucodigo, u.Usulogin
				  from DatosPersonales d
					inner join Usuario u on u.datos_personales = d.datos_personales
				 where d.Pid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.X509.UID#">
			</cfquery> 
			<cfif rsCed.Usucodigo EQ "">
				<cfreturn LvarResult>
			</cfif>
			<cfset LvarResult.Usucodigo = rsCed.Usucodigo>
			<cfset LvarResult.Usulogin = rsCed.Usulogin>
		</cfcatch>
		</cftry>
		<cfreturn LvarResult>
	</cffunction>
			
	<!---
		Este fuente realiza la funcion del antiguo signerLogueoSql
		a. Registra al usuario la primera vez, pero no tiene permiso de ingresar a la plataforma 
		b. Verifica con los datos obtenidos de la firma si el usuario ya se encuentra registrado en la plataforma 
	--->
	<cffunction name="fnAspLogin" access="public" output="no" returnType="string">
		<cfargument name="token" 	type="string"	required="true">
		<cfargument name="certData" type="struct"	required="true">
		<cfargument name="CEalias" type="string"	required="true">

		<cftry>
			<cfset LvarCertData = Arguments.certData>

			<cfif isdefined("LvarCertData.UsuError")>
				<cfreturn LvarCertData.UsuError>
			</cfif>

			<cfif LvarCertData.UsuTipo EQ "UsuarioFirmaDigital">
				<!--- FirmaDigital no registrada, lo envía a pantalla de autoregistro: le pide usuario y password --->
				<cfif LvarCertData.Usucodigo EQ "0">
					<cfset session._FD_Autenticacion_ = LvarCertData>
					<cfset session._FD_Autenticacion_.PWD = "****">
					<cfreturn "AUTOREGISTRO">
				</cfif>
				
				<!---Asignacion datos de ingreso a la plataforma--->
				<cfset session.autoafiliado=LvarCertData.Usucodigo>
				<cfset session.login_no_interactivo = true>
			<cfelse>
				<!---Usuario no registrado, se crea un usuario y asignan datos de ingreso al Sistema--->
				<cfif LvarCertData.Usucodigo eq 0>
					<cftransaction>
						<cfquery name="insDatos" datasource="asp">
							insert into DatosPersonales(Pid,Pnombre,Papellido1,BMfechamod,BMUsucodigo)
							values(
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#LvarCertData.UID#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#LvarCertData.GIVENNAME#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#LvarCertData.SURNAME#">,
								<cfqueryparam cfsqltype="cf_sql_date" value="#LSDateFormat(now(),'DD/MM/YYYY')#">,
								777
							)
							<cf_dbidentity1 datasource="asp" name="insDatos">
						</cfquery>
						<cf_dbidentity2 datasource="asp" name="insDatos" returnvariable="LvarDP">	
						
						<!--- Creacion del Usuario: Inserta el usuario, le asocia la direccion y los datos personales --->
						<cfinvoke component="home.Componentes.Seguridad" method="init" returnvariable="sec">
						<cfset usuario = sec.crearUsuario(21, 31, LvarDP, 'es_CR',ParseDateTime('01/01/6100','dd/mm/yyyy'), #LvarCertData.UID#, false)>
						<cfset sec.renombrarUsuario(usuario, #LvarCertData.UID#, #LvarCertData.PWD#)>
					</cftransaction>
				</cfif>

				<!---Asignacion datos de ingreso a la plataforma--->
				<cfset form.j_empresa  = Arguments.CEalias>
				<cfset form.j_username = LvarCertData.UID>
				<cfset form.j_password = LvarCertData.PWD>
			</cfif>

			<!--- se indica a la seguridad que se esta ingresando por firma digital --->
			<cfset request._LOGIN_POR_FIRMA_DIGITAL = true >

			<!---Validaciones de ingreso a la plataforma--->
			<cfinclude template="/home/check/aspmonitor.cfm">
			<cfinclude template="/home/check/dominio.cfm">
			<cfinclude template="/home/check/autentica.cfm">
			<cfinclude template="/home/check/acceso.cfm">
			<cfinclude template="/home/check/bienvenido.cfm">

			<cfset session._FD_conFirma_ = true>

			<cfset structdelete(session, "autoafiliado", false)>
			<cfset structdelete(session, "login_no_interactivo", false)>

			<cfreturn "OK">
		<cfcatch type="any">
			<cfset structdelete(session, "autoafiliado", false)>
			<cfset structdelete(session, "login_no_interactivo", false)>
			<cfreturn "ERROR: #cfcatch.message# #cfcatch.detail#">
		</cfcatch>
		</cftry>
	</cffunction>
	
	<!---
		fnAddAspLogin
			Realiza el Autoregistro de FirmaDigital conociendo el usuario y password
	--->
	<cffunction name="fnAddAspLogin" access="public" output="yes" returnType="any">
		<cfargument name="CEalias" type="string">	
		<cfargument name="UID" type="string">	
		<cfargument name="PWD" type="string">	

		<cftry>
			<cfinvoke component="home.Componentes.Seguridad" method="init" returnvariable="sec">
			<cfset LvarUsucodigo = sec.buscarUsuarioGlobal(arguments.CEalias, arguments.UID)>
			<cfset LvarAutenticado = sec.autenticarUsucodigo(LvarUsucodigo, arguments.PWD)>
			<cfif Len(LvarAutenticado) EQ 0>
				<cflogout>
				<cfthrow message="Usuario/Password no han sido encontrados en nuestras cuentas">
			</cfif>

			<cfset session._FD_Autenticacion_.fnAddAspUsucodigo = true>
			<cfreturn fnAddAspUsucodigo(LvarUsucodigo)>
		<cfcatch type="any">
			<cfreturn "ERROR: #cfcatch.message# #cfcatch.detail#">
		</cfcatch>
		</cftry>
	</cffunction>

	<!---
		fnAddAspUsucodigo
			Realiza el Autoregistro de FirmaDigital desde la pantalla de Autoregistro de usuario
	--->
	<cffunction name="fnAddAspUsucodigo" access="public" output="yes" returnType="string">
		<cfargument name="Usucodigo" type="numeric">	

		<cfparam name="session._FD_Autenticacion_.fnAddAspUsucodigo" default="false">
		<cfif NOT session._FD_Autenticacion_.fnAddAspUsucodigo>
			<cfset session._FD_Autenticacion_ = structNew()>
			<cfreturn "OK">
		</cfif>

		<cftry>
			<cfset LvarUsucodigo = Arguments.Usucodigo>

			<cfquery name="rsUsu" datasource="asp" >
				select Pid, CEcodigo
				  from Usuario u
					inner join DatosPersonales dp on dp.datos_personales = u.datos_personales
				 where u.Usucodigo=<cfqueryparam cfsqltype="cf_sql_numeric" value="#LvarUsucodigo#">
			</cfquery>
			
			<cfif replace(rsUsu.Pid,"-","","ALL") NEQ replace(session._FD_Autenticacion_.UID,"-","","ALL")>
				<cfthrow message="La Cédula en la FirmaDigital no corresponde a la registrada en el Sistema para Usuario '#rsUsu.Pid#=#session._FD_Autenticacion_.UID#'. Comuníquese con el Administrador del Sistema">
			</cfif>
			
			<cfquery name="rsFD" datasource="asp" >
				insert into UsuarioFirmaDigital (FDid, FDidControl, SubjectSN, CEcodigo, Usucodigo, FDalta) 
				values (
					 <cfqueryparam cfsqltype="cf_sql_varchar" value="#fnUsuarioFirmaDigital_FDid(session._FD_Autenticacion_.X509SERIAL, rsUsu.CEcodigo)#">,
					 <cfqueryparam cfsqltype="cf_sql_varchar" value="#fnUsuarioFirmaDigital_FDid(session._FD_Autenticacion_.X509SERIAL, rsUsu.CEcodigo, session._FD_Autenticacion_.SubjectSN, LvarUsucodigo)#">,
					 <cfqueryparam cfsqltype="cf_sql_varchar" value="#session._FD_Autenticacion_.SubjectSN#">,
					 <cfqueryparam cfsqltype="cf_sql_numeric" value="#rsUsu.CEcodigo#">,
					 <cfqueryparam cfsqltype="cf_sql_numeric" value="#LvarUsucodigo#">,
					 <cfqueryparam cfsqltype="cf_sql_date"	  value="#now()#">
				)
			</cfquery> 
			<cfset session._FD_Autenticacion_ = structNew()>
			<cfreturn "OK">
		<cfcatch type="any">
			<cfreturn "ERROR: #cfcatch.message# #cfcatch.detail#">
		</cfcatch>
		</cftry>
	</cffunction>

	<!---
		fnUsuarioFirmaDigital_FDid:
			Genera el UsuarioFirmaDigital.FDid y UsuarioFirmaDigital.FDidControl
	--->
	<cffunction name="fnUsuarioFirmaDigital_FDid" returnType="string" access="private">
		<cfargument name="X509SERIAL"	required="true">
		<cfargument name="CEcodigo"		required="true">
		<cfargument name="SubjectSN"	default="*">
		<cfargument name="Usucodigo"	default="*">
		
		<cfset var LvarX509SERIAL = "X509SERIAL=#Arguments.X509SERIAL#,CEcodigo=#Arguments.CEcodigo#,SubjectSN=#Arguments.SubjectSN#,Usucodigo=#Arguments.Usucodigo#">
		<cfset LvarX509SERIAL = Encrypt(LvarX509SERIAL, "CE_#Arguments.CEcodigo#", "CFMX_COMPAT", "HEX")>
		<cfset LvarX509SERIAL = hash(LvarX509SERIAL, "SHA", "UTF-8")>

		<cfreturn LvarX509SERIAL>
	</cffunction>

	<!---
		getCAcert:
			Envia el Certificado del Emisor
	--->
	<cffunction name="getCAcert" access="remote" output="no" returnType="string" returnFormat="plain">
		<cfargument name="urlCrt" type="string">		

		<cfreturn "OK=" & createObject("component","home.public.FirmaDigital.Componentes.crypto").getCertEmsr_X509 (arguments.urlCrt, "HEX")>
	</cffunction>

	<!---
		actualizaCRLs:
			Tarea Automatica que trae la lista de archivos CRLs cada 10 minutos
	--->
    <cffunction name="actualizaCRLs" access="remote" returntype="void">
		<cfset createObject("component","home.public.FirmaDigital.Componentes.crypto").actualizaCRLs()>
	</cffunction>
</cfcomponent>

