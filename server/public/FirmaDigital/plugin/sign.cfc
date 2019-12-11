<cfcomponent displayname="FirmaMensajesXML" output="true" hint="Firma de Mensajes XML. Sigue la lógica general de Autenticacion"
             extends="home.public.FirmaDigital.plugin.login"
>
	<!---
		pintaIframe en la pantalla de la GUI que ve el Usuario:
			pinta el IFrame que sustituye al lightBox anterior, para iniciar el componente de FirmaDigital
			genera el XML/PDF a firmar y lo guarda en un token temporal
			El proceso de firma debe INICIAR en menos de 120 segundos
			
			GUI de firma:	<iframe> + js:sbInvocarFirmaDigital()
				sign.cfm nivel 1:	<iframe> + js:sbInvocarFirmaDigital()
					sign.cfm nivel 2:  monitoreo al JavaWebStart
					sign_ok.cfm				procesa XML/PDF firmado y ejecuta jsFinal
	--->
	<cffunction name="pintaIframe" access="public" output="yes" returnType="void">
		<cfargument name="automatico"	type="boolean" default="false">
		<cfargument name="componente"	type="string">
		<cfargument name="generaMSG"	type="string">
		<cfargument name="procesaMSG"	type="string">
		<cfargument name="parametros"	type="struct">
		<cfargument name="pruebas"		type="boolean" default="false">
		<cfargument name="btnVer"	type="boolean" default="true">
		<cfargument name="tipoMSG"		type="string"  default="XML">
		<cfargument name="lblTitulo"	type="string"  default="">

		<cfset var LvarPath	 = "#cgi.CONTEXT_PATH#/home/public/FirmaDigital/plugin">
		
		<cfif not fileExists(expandPath("/#replace(Arguments.componente,".","/","ALL")#.cfc"))>
			<cfthrow message="Error: no existe el componente para procesamiento de XML o PDF: #Arguments.componente#">
		</cfif>

		<cfif NOT listFind("XML,PDF",Arguments.tipoMSG)>
			<cfthrow message="Error: Tipo de mensaje a firmar (tipoMSG) solo puede ser XML o PDF: '#Arguments.tipoMSG#'">
		</cfif>

		<cfif Arguments.lblTitulo EQ "">
			<cfset Arguments.lblTitulo = "Firma de Mensaje con FirmaDigital">
		</cfif>

		<cfset LvarCrypt	= createObject("component","home.public.FirmaDigital.Componentes.crypto")>
		<cfset LvarArgs 	= URLEncodedFormat(LvarCrypt.ZIP_compressTXT(SerializeJSON(Arguments)))>

		<cfoutput>
			<cfif Arguments.pruebas>
				<iframe name="ifrSignMSG" id="ifrSignMSG" style="display:inline" width="450" height="350"></iframe>
			<cfelse>
				<iframe name="ifrSignMSG" id="ifrSignMSG" style="display:none"></iframe>
			</cfif>
			<script type="text/javascript" language="javascript">
				function getToken()
				{
					var LvarIFrame = document.getElementById("ifrSignMSG"); 
					if (LvarIFrame.contentWindow.getToken)
						return LvarIFrame.contentWindow.getToken();
					else
						return "*";
				}
				function existPostFirmaDigital()
				{
					if (window.sbPostFirmaDigital)
						return true;
					alert("ERROR en FIRMA DE MENSAJES XML/PDF con FirmaDigital:\nNo se encontró la función javascript sbPostFirmaDigital(), coloquela antes de la invocación a pintaIframe().\nNo se puede continuar con el proceso");
					return false;
				}
			</script> 
			<script type="text/javascript" language="javascript">
				<cfif ISNULL(Application._FirmaDigital_.Tokens) >
				var Gvar1vez = true;
				<cfelse>
				var Gvar1vez = false;
				</cfif>

				existPostFirmaDigital();
				function sbInvocarFirmaDigital() 
				{
					var LvarToken;
					var LvarIFrame = document.getElementById("ifrSignMSG"); 

					if (!existPostFirmaDigital())
						return;
						
					if (Gvar1vez)
					{
						Gvar1vez = false;
						alert(
							"FIRMA DE MENSAJES XML/PDF con FirmaDigital:\n"+
							"1. Conecte el Dispositivo de lectura de SmartCards en un USB\n"+
							"2. Coloque la Tarjeta de Firma Digital en el Dispositivo\n"+
							"3. Digite el PIN de la firma digital\n"+
							"    (PRECAUCION:  Después de 3 intentos fallidos la FirmaDigital se bloquea)"
							<!---
							"3. Acepte el Download del Archivo 'FirmaDigital.jnlp'\n" +
							"    (se debe ejecutar con Java WebStart o Java IcedTea)\n"+
							"4. Ejecute el jnlp (double-click en 'FirmaDigital.jnlp')\n"+
							"5. Digite el PIN de la firma digital\n"+
							"    (PRECAUCION:  Después de 3 intentos fallidos la FirmaDigital se bloquea)"
							--->
						);
						// Llama la pantalla de firma al primer nivel: generacion del XML/PDF y token temporal
						LvarIFrame.src = "#LvarPath#/sign.cfm?TKNTMP=0&args=#LvarArgs#";
					}
					else
					{
						LvarToken = getToken();
						// Si hay un token vivo, invoca sbInvocarFirmaDigital de la pantalla del primer nivel si no empieza de nuevo con la pantalla del primer nivel
						if (LvarToken == '*' || LvarToken == "undefined")
							LvarIFrame.src = "#LvarPath#/sign.cfm?TKNTMP=0&args=#LvarArgs#";
						else
							LvarIFrame.contentWindow.sbInvocarFirmaDigital();
					}
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
		pintaIframe1:
			pinta el IFrame que sustituye al lightBox anterior, para iniciar el componente de FirmaDigital
			genera el XML/PDF a firmar y lo guarda en un token temporal
			El proceso de firma debe INICIAR en menos de 120 segundos
	--->
	<cffunction name="pintaIframe1" access="public" output="yes" returnType="string">
		<cfargument name="args"	type="string">

		<cfset LvarCrypt	= createObject("component","home.public.FirmaDigital.Componentes.crypto")>
		<cfset Arguments = DeserializeJSON(LvarCrypt.ZIP_decompressToTXT(Arguments.args))>

		<cfset var LvarToken = generaMSGdataEnTokenTMP (argumentcollection=Arguments)>
		<cfset var LvarPath	 = "#cgi.CONTEXT_PATH#/home/public/FirmaDigital/plugin">
		
		<cfoutput>
			<iframe name="ifrSignMSG" id="ifrSignMSG" style="display:inline" width="420" height="320"></iframe>
			<script type="text/javascript" language="javascript">
				function getToken()
				{
					var LvarIFrame = document.getElementById("ifrSignMSG"); 
					if (LvarIFrame.contentWindow.getToken)
						return LvarIFrame.contentWindow.getToken();
					else
						return "*";
				}
			</script> 
			<script type="text/javascript" language="javascript">
				var Gvar1vez = true;

				function sbInvocarFirmaDigital() 
				{
					var LvarToken;
					var LvarIFrame = document.getElementById("ifrSignMSG"); 
					if (Gvar1vez)
					{
						Gvar1vez = false;
						LvarToken = "#LvarToken#";
					}
					else
					{
						LvarToken = getToken();

						if (LvarToken == '*')
						{
							alert("El mensaje ya fue firmado");
							return;
						}
					}

					// Llama la pantalla de firma al segundo nivel
					LvarIFrame.src = "#LvarPath#/sign.cfm?TKNTMP=" + LvarToken;
					return;
				}
				sbInvocarFirmaDigital();
			</script>
		</cfoutput>
		<cfreturn LvarToken>
	</cffunction>

	<!---
		pintaIframe:
			pinta el IFrame que sustituye al lightBox anterior, para iniciar el componente de FirmaDigital para autenticacion

			GUI de Autenticacion:	<iframe> + js:sbInvocarFirmaDigital()
				login.cfm:  				monitoreo al JavaWebStart
				login_ok.cfm				Se autentica y cflocation al index del sistema
	--->
	<cffunction name="pintaIframeSignDoc" access="public" output="yes" returnType="void">
		<cfargument name="automatico"	type="boolean" default="false">
		<cfargument name="pruebas"		type="boolean" default="false">

		<cfset var LvarPath	 = "#cgi.CONTEXT_PATH#/home/public/FirmaDigital/plugin">

		<cfoutput>
		  <cfif Arguments.pruebas>
			<iframe name="frmSignDoc" id="frmSignDoc" style="display:inline" width="450" height="350"></iframe>
		  <cfelse>
			<iframe name="frmSignDoc" id="frmSignDoc" style="display:none"></iframe>
		  </cfif>
			<script type="text/javascript" language="javascript">
				var Gvar1vez = true;
				function sbInvocarFirmaDigital() 
				{
					var LvarIFrame = document.getElementById("frmSignDoc"); 
					LvarIFrame.src = "#LvarPath#/signDoc_jnlp.cfm";
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
		generaMSGdataEnTokenTMP:
			invoca el Componente.generaMSG(Parametros) para obtner el XML/PDF y lo amacena en un token temporal
	--->
	<cffunction name="generaMSGdataEnTokenTMP" access="public" output="no" returnType="string">
		<cfargument name="automatico"	type="boolean">
		<cfargument name="componente"	type="string">
		<cfargument name="generaMSG"	type="string">
		<cfargument name="procesaMSG"	type="string">
		<cfargument name="parametros"	type="struct">
		<cfargument name="pruebas"		type="boolean">
		<cfargument name="btnVer"	type="boolean">
		<cfargument name="tipoMSG"		type="string">
		<cfargument name="lblTitulo"	type="string">

		<cfset var LvarToken = "">

		<cfinvoke
				component						= "#Arguments.Componente#"
				method							= "#Arguments.generaMSG#"
				argumentcollection	= "#Arguments.Parametros#"
				returnvariable			= "LvarXML_PDF"
		/>

		<cfif isArray(LvarXML_PDF) AND Arguments.tipoMSG eq "XML">
			<cfset LvarARRAY = "ARRAY:">
			<cfloop index="i" from="1" to="#arrayLen(LvarXML_PDF)#">

				<cfif LvarARRAY NEQ "ARRAY:">
					<cfset LvarARRAY &= chr(30)>
				</cfif>
				<cfif Arguments.tipoMSG eq "XML">
					<cfparam name="LvarXML_PDF[i].XML" type="string">
					<cfset LvarARRAY &= createObject("component","home.public.FirmaDigital.Componentes.crypto").
															ZIP_compressTXT(LvarXML_PDF[i].XML)>
				<cfelseif Arguments.tipoMSG eq "PDF">
					<cfparam name="LvarXML_PDF[i].PDF" type="binary">
					<cf_dump var="aq">
					<cfset LvarARRAY &= createObject("component","home.public.FirmaDigital.Componentes.crypto").
															ZIP_compressBIN(LvarXML_PDF[i].PDF)>
				<cfelse>
					<cfthrow message="Tipo de mensaje a firmar (tipoMSG) solo puede ser XML o PDF">
				</cfif>
			</cfloop>
			<cfset LvarXML_PDF = LvarARRAY>
		<cfelse>
			<cfif Arguments.tipoMSG eq "XML">
				<cfparam name="LvarXML_PDF" type="string">
				<cfset LvarXML_PDF =  createObject("component","home.public.FirmaDigital.Componentes.crypto").
															ZIP_compressTXT(LvarXML_PDF)>
			<cfelseif Arguments.tipoMSG eq "PDF">
				<cfparam name="LvarXML_PDF" type="binary">
				<cfset LvarXML_PDF =  createObject("component","home.public.FirmaDigital.Componentes.crypto").
															ZIP_compressBIN(LvarXML_PDF)>
			<cfelse>
				<cfthrow message="Tipo de mensaje a firmar (tipoMSG) solo puede ser XML o PDF">
			</cfif>
		</cfif>

		<cfset LvarToken = super.createToken("Temporal")>
		<cfset LvarTokenTMP = Application._FirmaDigital_.tokens["TK" & LvarToken]>

		<cfset LvarTokenTMP.tipo				= "Temporal">
		<cfset LvarTokenTMP.MSGData				= Arguments>
		<cfset LvarTokenTMP.MSGData.tipoMSG		= Arguments.tipoMSG>
		<cfset LvarTokenTMP.MSGData.lblTitulo	= Arguments.lblTitulo>
		<cfset LvarTokenTMP.MSGData.XML_PDF		= LvarXML_PDF>

		<cfreturn LvarToken>
	</cffunction>

	
	<!---
		createToken:
			Inicio del proceso de firma de mensaje XML por FirmaDigital en Coldfusion
			Se crea una estructura en Application._FirmaDigital_.tokens[] con un tiempo de vida de 121 segundos
			Pasa la información de creación del XML del token temporal a este token de seguridad
			Todo el proceso debe terminar en menos de 120 segundos
	--->
	<cffunction name="createToken" access="public" output="no" returnType="string">
		<cfargument name="tokenTMP"		type="string">
	
		<cfset LvarAppTokenTK_TMP = Application._FirmaDigital_.tokens["TK" & Arguments.tokenTMP]>

		<cfset LvarTipo  = "LlaveDeFirma">
		<cfset LvarToken = super.createToken(LvarTipo)>
		<cfset LvarAppTokenTK_DST = Application._FirmaDigital_.tokens["TK" & LvarToken]>
		<cfset LvarAppTokenTK_DST.MSGData	= LvarAppTokenTK_TMP.MSGData>
		
		<!--- 
			Información de seguridad a verificar en JavaWebStart: 
				. Genera un digest para el XML: SHA1(token,XML_zip_base64)		(Asegura que el XML sea el verdadero - Integridad del XML)
				. Se encripta con la llave privada del Servidor: Token,Tkn2,Tipo,SHA1(token,XML_zip_base64) (Autenticidad del Servidor) 
		--->
		<cfset LvarData 				= LvarToken & "," & LvarAppTokenTK_DST.MSGData.XML_PDF>
		<cfset LvarSHA1 				= createObject("java", "java.security.MessageDigest").getInstance("SHA1")>
		<cfset LvarSHA1 				= BinaryEncode(LvarSHA1.digest(LvarData.getBytes()),"base64")>
		
		<cfset LvarAppTokenTK_DST.MSG	= createObject("component","home.public.FirmaDigital.Componentes.crypto").
																		RSA_Encrypt(LvarToken & "," & LvarSKey & "," & LvarTipo & "," & LvarSHA1)>

		<cfset LvarAppTokenTK_DST.TK_TMP = "TK" & Arguments.TokenTMP>

		<cfreturn LvarToken>
	</cffunction>

	<!---
		sendData:
			Recibe y almacena "los datos de la firma digital + ZIP_BASE64(XML/PDF firmado)" enviados por la aplicación Java Web Start de sign 
			y envía la señal de submit al javascript de la pantalla de sign 
	--->
	<cffunction name="sendData" access="remote" output="no" returnType="string" returnFormat="plain">
		<cfargument name="token" 			type="string">		
		<cfargument name="data"  			type="string">		
		<cfargument name="signedMSG"  type="string">		

		<cfset LvarClusterResponse = createObject("component","home.public.FirmaDigital.plugin.cluster").exeToken(Arguments.Token)>
		<cfif LvarClusterResponse NEQ "*LOCAL*">
			<cfreturn LvarClusterResponse>
		</cfif>

		<cftry>
			<cfset LvarMSG = super.sendData(Arguments.token, Arguments.data)>
			<cfif LvarMSG EQ "OK">
				<cfset Application._FirmaDigital_.tokens["TK" & Arguments.token].MSGData.signedMSG = Arguments.signedMSG>
			<cfelse>
				<cfset LvarMSG = LvarMSG>
			</cfif>
		<cfcatch type="any">
			<cfset LvarMSG = cfcatch.message & " " & cfcatch.detail>
		</cfcatch>
		</cftry>
		<cfreturn LvarMSG>
	</cffunction>

	<!---
		getMSGData:
			Desencripta la información enviada por el Servidor Local de FirmaDigitalServer.jar
	--->
	<cffunction name="getMSGData" access="public" output="no" returnType="struct">
		<cfargument name="token" type="string">		

		<cfset LvarMSG = validateToken(Arguments.token, 3)>

		<cfif LvarMSG NEQ "OK">
			<cfthrow message="#LvarMSG#">
		</cfif>

		<cfset LvarAppTokenTK 	= Application._FirmaDigital_.tokens["TK" & Arguments.token]>
		<cfset LvarData 				= getDecryptData(Arguments.token, LvarAppTokenTK.data, LvarAppTokenTK.skey)>

		<cfset LvarMSGData	= LvarAppTokenTK.MSGData>

		<cfset destroyToken(Arguments.token)>

		<cfset LvarCert509	= validaMSGData (Arguments.token, LvarData, LvarMSGData.signedMSG)>

		<!--- Incluye en MSGData.parametros los datos del certificado --->
		<cfset LvarMSGData.parametros.Cert509 = structNew()>
		<cfset LvarMSGData.parametros.Cert509 = addListToStruct(LvarMSGData.parametros.Cert509, LvarCert509.getSubjectX500Principal().toString())>
		
		<!--- <cfset LvarMSGData["X509"]	= LvarCert509> --->
		<cfset LvarMSGData.parametros.Cert509.X509SUBJECT	= LvarCert509.getSubjectX500Principal().toString()>
		<cfset LvarMSGData.parametros.Cert509.X509ISSUER	= LvarCert509.getIssuerX500Principal().toString()>
		<cfset LvarMSGData.parametros.Cert509.X509SERIAL	= LvarCert509.getSerialNumber().toString()>
		<cfset LvarMSGData.parametros.Cert509.TKN			= Arguments.token>
		<cfset LvarMSGData.parametros.Cert509.SubjectSN		= LvarMSGData.parametros.Cert509.SERIALNUMBER>
		<cfset LvarMSGData.parametros.Cert509.UID				= mid(LvarMSGData.parametros.Cert509.SubjectSN,5,12)>
		<cfset LvarMSGData.parametros.Cert509.NAME			= LvarMSGData.parametros.Cert509.GIVENNAME & " " & LvarMSGData.parametros.Cert509.SURNAME>
		
		<cftry>
			<cfset LvarRes = sbGetUsucodigos(LvarMSGData.parametros.Cert509.SubjectSN, "")>
			<cfset LvarMSGData.parametros.Cert509.Usucodigos = LvarRes.Usucodigo>
			<cfset LvarMSGData.parametros.Cert509.Usulogins = LvarRes.Usulogin>
			<cfset LvarMSGData.parametros.Cert509.Usutipo = LvarRes.Tipo>
		<cfcatch type="any">
			<cfset LvarMSGData.parametros.Cert509.Usucodigos = -1>
			<cfset LvarMSGData.parametros.Cert509.UsuError = cfcatch.message>
		</cfcatch>
		</cftry>
		
		
		<!--- Descomprime el SignedMSG --->
		<cfif left(LvarMSGData.signedMSG,6) EQ "ARRAY:">
			<cfset LvarSignedMSG = mid(LvarMSGData.signedMSG,7,len(LvarMSGData.signedMSG))>

			<cfif LvarMSGData.tipoMSG EQ "XML">
				<cfset LvarMSGData.parametros.XMLs	= arrayNew(1)>
			<cfelseif LvarMSGData.tipoMSG EQ "PDF">
				<cfset LvarMSGData.parametros.PDFs	= arrayNew(1)>
			</cfif>
			<cfloop index="LvarBase64MSG" list="#LvarSignedMSG#" delimiters="#chr(30)#">
				<cfif LvarMSGData.tipoMSG EQ "XML">
					<!--- Descomprime el XML:  XML_ZIP_Base64 a XML_TXT --->
					<cfset arrayAppend(LvarMSGData.parametros.XMLs, LvarCrypt.ZIP_decompressToTXT(LvarBase64MSG))>
				<cfelseif LvarMSGData.tipoMSG EQ "PDF">
					<!--- Descomprime el XML:  XML_ZIP_Base64 a XML_TXT --->
					<cfset arrayAppend(LvarMSGData.parametros.PDFs, LvarCrypt.ZIP_decompressToBIN(LvarBase64MSG))>
				</cfif>
			</cfloop>
		<cfelse>
			<cfif LvarMSGData.tipoMSG EQ "XML">
				<!--- Descomprime el XML:  XML_ZIP_Base64 a XML_TXT --->
				<cfset LvarMSGData.parametros.XML	= LvarCrypt.ZIP_decompressToTXT(LvarMSGData.signedMSG)>
			<cfelseif LvarMSGData.tipoMSG EQ "PDF">
				<!--- Descomprime el XML:  XML_ZIP_Base64 a XML_TXT --->
				<cfset LvarMSGData.parametros.PDF	= LvarCrypt.ZIP_decompressToBIN(LvarMSGData.signedMSG)>
			</cfif>
		</cfif>
		
		<cfreturn LvarMSGData>
	</cffunction>

	<!---
		validaMSGData:
			Asegura que el Certificado y xml esté firmado (Firma Digital Simple) por la llave privada de la FirmaDigital
			data = token, CertHex, FirmaDigital(token,CertHex,xml_zip_base64)
	--->
	<cffunction name="validaMSGData" access="public" output="no" returnType="any">
		<cfargument name="token" type="string">		
		<cfargument name="data"	type="string">
		<cfargument name="xml"	type="string">
		
		<cfset LvarToken	= listGetAt(arguments.data,1)>
		<cfset LvarCertHex	= listGetAt(arguments.data,2)>
		<cfset LvarFirmaHex	= listGetAt(arguments.data,3)>
		<cfset LvarXML		= Arguments.xml>

		<cfset LvarData		= LvarToken & "," & LvarCertHex & "," & LvarXML>
		
		<cfif Arguments.token NEQ LvarToken>
			<cfthrow message="ERROR: Token encriptado inválido">
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
			<cfthrow message="ERROR: La Firma del XML firmado es inválida">
		</cfif>

		<!--- Valida Vigencia, Certificación y Revocación del Certificado de Sign --->
		<cfset LvarCertResp		= LvarCrypt.validaCert(LvarCert509)>

		<cfif LvarCertResp.num EQ 0>
			<cfreturn LvarCert509>
		<cfelse>
			<cfthrow message="#LvarCertResp.msg# (#LvarCertResp.num#)">
		</cfif>
	</cffunction>

	<!---
		Invalida los metodos propios de login: getLoginData y validaLoginData:
	--->
	<cffunction name="getLoginData" access="public" output="no" returnType="struct">
		<cfargument name="token" type="string">		
		
		<cfthrow message="getLoginData not exit">
	</cffunction>

	<cffunction name="validaLoginData" access="public" output="no" returnType="any" returnFormat="plain">
		<cfargument name="data"	type="string">
		<cfthrow message="validaLoginData not exit">
	</cffunction>

	<!---
		sbGetUsucodigos:
			Obtiene los Usucodigos asociado a la FirmaDigital por SubjectSN
	--->
	<cffunction name="sbGetUsucodigos" access="public" output="no" returnType="struct">
		<cfargument name="SubjectSN"  type="string">
		<cfargument name="CEalias" 		type="string" default="">	

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
			<cfquery name="rsFD" datasource="asp" >
				select distinct u.Usucodigo, u.Usulogin
				  from UsuarioFirmaDigital f
					inner join Usuario u
						on u.Usucodigo = f.Usucodigo
				 where f.SubjectSN=<cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.SubjectSN#">
				<cfif LvarResult.CEcodigo NEQ 0>
					and u.CEcodigo = <cfqueryparam cfsqltype="cf_sql_numeric" value="#LvarResult.CEcodigo#">
				</cfif>
			</cfquery> 

			<cfset LvarResult.Tipo = "UsuarioFirmaDigital">

			<cfif rsFD.Usucodigo EQ "">
				<cfreturn LvarResult>
			</cfif>

			<cfset LvarResult.Usucodigo = valueList(rsFD.Usucodigo)>
			<cfset LvarResult.Usulogin = valueList(rsFD.Usulogin)>
		<cfcatch type="database">
			<cfset LvarResult.Tipo = "DatosPersonales">
			<cfquery name="rsCed" datasource="asp" >
				select distinct u.Usucodigo, u.Usulogin
				  from DatosPersonales d
					inner join Usuario u on u.datos_personales = d.datos_personales
				 where d.Pid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#mid(Arguments.SubjectSN,5,12)#">
			</cfquery> 
			<cfif rsCed.Usucodigo EQ "">
				<cfreturn LvarResult>
			</cfif>
			<cfset LvarResult.Usucodigo = valueList(rsCed.Usucodigo)>
			<cfset LvarResult.Usulogin = valueList(rsCed.Usulogin)>
		</cfcatch>
		</cftry>
		<cfreturn LvarResult>
	</cffunction>
</cfcomponent>
