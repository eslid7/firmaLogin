<cfcomponent displayname="CFServer" output="false" 
	hint="Componente y WebService de: 1) Verificacion en CF de Firma de Mensajes y Documentos PDF/XML, 2) Firma en CF con Certificado .P12">

	<cfset LvarSystem 			= CreateObject("java","java.lang.System")>
	<cfset LvarJava8Path		= LvarSystem.getProperty("FirmaDigital.jre8_home",	"*")>
	<cfset LvarHost				= LvarSystem.getProperty("FirmaDigital.host", 		"localhost")>
	<cfset LvarPuerto			= LvarSystem.getProperty("FirmaDigital.puerto", 	"9000")>
	<cfset LvarHilos			= LvarSystem.getProperty("FirmaDigital.hilos",  	"5")>
	<cfset LvarP12_Path			= LvarSystem.getProperty("FirmaDigital.P12_Path",  	"C:/FirmaDigitalServer/FirmaDigitalServer.p12")>
	<cfset LvarP12_PWD			= LvarSystem.getProperty("FirmaDigital.P12_PWD",  	"2629")>

	<!-------------------------------------
		Metodos para WebServices y publicos
	--------------------------------------->

	<!---
		verifyXML Verifica la Firma Digital de un Documento XML en formato String
	--->
	<cffunction name="verifyXML" access="remote" output="no" returnType="string">
		<cfargument name="XML"	type="string">

		<cfreturn verifyXML_struct(Arguments.XML).texto>
	</cffunction>

	<!---
		verifyPDF Verifica la Firma Digital de un Documento PDF en formato Base64
	--->
	<cffunction name="verifyPDF" access="remote" output="no" returnType="string">
		<cfargument name="PDF"	type="binary">

		<cfreturn verifyPDF_struct(Arguments.PDF).texto>
	</cffunction>

	<!---
		signP12_XML Firma Digital con Certificado .p12 de un Mensaje XML en formato String
	--->
	<cffunction name="signP12_XML" access="remote" output="no" returnType="string">
		<cfargument name="XML"		type="string">

		<cfreturn signP12_XML2(Arguments.XML)>
	</cffunction>

	<!---
		signP12_PDF Firma Digital con Certificado .p12 de un Mensaje PDF
	--->
	<cffunction name="signP12_PDF" access="remote" output="no" returnType="binary">
		<cfargument name="PDF"		type="binary">
		
		<cfreturn signP12_PDF2(Arguments.PDF)>
	</cffunction>
	<!-------------------
		Metodos publicos
	--------------------->

	<!---
		verifyFILE Verifica la Firma Digital de un Documento guardado en el Servidor
	--->
	<cffunction name="verifyFILE" access="public" output="no" returnType="string">
		<cfargument name="file"	type="string">

		<cfreturn verifyFILE_struct(Arguments.file).texto>
	</cffunction>

	<!---
		verifyXML_struct, verifyPDF_struct, verifyFILE_struct: en lugar de texto devuelve la estructura
	--->
	<cffunction name="verifyXML_struct" access="public" output="no" returnType="struct">
		<cfargument name="XML"				type="string">
		<cfargument name="withUsucodigos"	type="boolean" default="no">

		<cfset var LvarData = binaryEncode(Arguments.XML.getBytes("UTF-8"),"base64")>
		<cfreturn fnSend_FirmaDigitalServer("XML", LvarData, Arguments.withUsucodigos)>
	</cffunction>

	<cffunction name="verifyPDF_struct" access="public" output="no" returnType="struct">
		<cfargument name="PDF"	type="binary">
		<cfargument name="withUsucodigos"	type="boolean" default="no">

		<cfset var LvarData = binaryEncode(Arguments.PDF,"base64")>
		<cfreturn fnSend_FirmaDigitalServer("PDF", LvarData, Arguments.withUsucodigos)>
	</cffunction>

	<cffunction name="verifyFILE_struct" access="public" output="no" returnType="struct">
		<cfargument name="file"	type="string">
		<cfargument name="withUsucodigos"	type="boolean" default="no">

		<cfreturn fnSend_FirmaDigitalServer("FILE", Arguments.file, Arguments.withUsucodigos)>
	</cffunction>

	<!---
		signP12_XML2 Firma Digital con Certificado .p12 de un Mensaje XML en formato String (indicando P12_Path y P12_PWD)
	--->
	<cffunction name="signP12_XML2" access="public" output="no" returnType="string">
		<cfargument name="XML"		type="string">
		<cfargument name="P12_Path"	type="string" default="#LvarP12_Path#">
		<cfargument name="P12_PWD"	type="string" default="#LvarP12_PWD#">

		<!--- Data = XML_ZIP_Base64 + chr(31) + Path_Base64 + chr(31) + PWD_Base64 --->
		<cfset var LvarData = 
						createObject("component","home.public.FirmaDigital.Componentes.crypto").ZIP_compressTXT(Arguments.XML) & chr(31) & 
						binaryEncode(Arguments.P12_Path.getBytes("UTF-8"),"base64") & chr(31) & 
						binaryEncode(Arguments.P12_PWD.getBytes("UTF-8"),"base64")
		>
		
		<cfset LvarData = fnSend_FirmaDigitalServer("P12_XML", LvarData, false)>
		<cfif LvarData.Resultado NEQ "OK">
			<cfthrow message="#LvarData.Resultado#">
		</cfif>
		
		<cfreturn createObject("component","home.public.FirmaDigital.Componentes.crypto").ZIP_decompressToTXT(LvarData.XML)>
	</cffunction>

	<!---
		signP12_PDF2 Firma Digital con Certificado .p12 de un Mensaje PDF (indicando P12_Path y P12_PWD)
	--->
	<cffunction name="signP12_PDF2" access="public" output="no" returnType="binary">
		<cfargument name="PDF"		type="binary">
		<cfargument name="P12_Path"	type="string" default="#LvarP12_Path#">
		<cfargument name="P12_PWD"	type="string" default="#LvarP12_PWD#">

		<!--- Data = PDF_ZIP_Base64 + chr(31) + Path_Base64 + chr(31) + PWD_Base64 --->
		<cfset var LvarData = 
						createObject("component","home.public.FirmaDigital.Componentes.crypto").ZIP_compressBIN(Arguments.PDF) & chr(31) & 
						binaryEncode(Arguments.P12_Path.getBytes("UTF-8"),"base64") & chr(31) & 
						binaryEncode(Arguments.P12_PWD.getBytes("UTF-8"),"base64")
		>
		
		<cfset LvarData = fnSend_FirmaDigitalServer("P12_PDF", LvarData, false)>
		<cfif LvarData.Resultado NEQ "OK">
			<cfthrow message="#LvarData.Resultado#">
		</cfif>
		
		<cfreturn createObject("component","home.public.FirmaDigital.Componentes.crypto").ZIP_decompressToBIN(LvarData.PDF)>
	</cffunction>

	<!---
		signP12_FILE Firma Digital con Certificado .p12 de un Documento XML/PDF guardado en el Servidor
	--->
	<cffunction name="signP12_FILE" access="public" output="no" returnType="any">
		<cfargument name="file"		type="string">

		<cfreturn signP12_FILE2(Arguments.file)>
	</cffunction>

	<!---
		signP12_FILE2 Firma Digital con Certificado .p12 de un Documento XML/PDF guardado en el Servidor  (indicando P12_Path y P12_PWD)
	--->
	<cffunction name="signP12_FILE2" access="public" output="no" returnType="any">
		<cfargument name="file"		type="string">
		<cfargument name="P12_Path"	type="string" default="#LvarP12_Path#">
		<cfargument name="P12_PWD"	type="string" default="#LvarP12_PWD#">

		<!--- Data = FILE_Base64 + chr(31) + Path_Base64 + chr(31) + PWD_Base64 --->
		<cfset var LvarData = 
						binaryEncode(Arguments.file.getBytes("UTF-8"),"base64") & chr(31) & 
						binaryEncode(Arguments.P12_Path.getBytes("UTF-8"),"base64") & chr(31) & 
						binaryEncode(Arguments.P12_PWD.getBytes("UTF-8"),"base64")
		>
		<cfset LvarData = fnSend_FirmaDigitalServer("P12_FILE", LvarData, false)>
		<cfif LvarData.Resultado NEQ "OK">
			<cfthrow message="#LvarData.Resultado#">
		<cfelseif isdefined("LvarData.XML")>
			<cfreturn createObject("component","home.public.FirmaDigital.Componentes.crypto").ZIP_decompressToTXT(LvarData.XML)>
		<cfelse>
			<cfreturn createObject("component","home.public.FirmaDigital.Componentes.crypto").ZIP_decompressToBIN(LvarData.PDF)>
		</cfif>
	</cffunction>

	<!---
		ping Verifica el CFServer.java está activo
	--->
	<cffunction name="ping" access="public" output="no" returnType="string">
		<cfargument name="file"	type="string">

		<cfreturn fnSend_FirmaDigitalServer("ping", "", false)>
	</cffunction>

	<!-------------------
		Metodos privados
	--------------------->

	<cfscript>
		private any function fnSend_FirmaDigitalServer(required string op, required string data, required boolean withUsucodigos ) 
		{
			var result = "";
			var socket = createObject("java", "java.net.Socket");
			var outputStream = "";
			var inputStream = "";
			var output = "";
			var input = "";
			var inputStreamReader = "";

			if (op EQ "init")
				op = "ping";
			else
				sbCFServerInit();
			
			try {
				socket.init(LvarHost, LvarPuerto);
			} catch(java.net.ConnectException error) {
				throw (message="#error.Message#: Could not connected to LvarHost #LvarHost# on LvarPuerto #LvarPuerto#");
			}

			if ( socket.isConnected() ) {
				outputStream = socket.getOutputStream();
				output = createObject("java", "java.io.PrintWriter").init(outputStream );
				inputStream = socket.getInputStream();
				inputStreamReader = createObject("java", "java.io.InputStreamReader").init(inputStream);
				input = createObject("java", "java.io.BufferedReader").init(inputStreamReader);
				output.println(arguments.op);
				output.println(arguments.data);
				output.println();
				output.flush();
				LvarResultado = "";
				while(true)
				{
					LvarResult = input.readLine();
					if (NOT isdefined("LvarResult"))
						break;
					if (Len(LvarResultado) GT 0)
						LvarResultado &= chr(13) & chr(10);
					LvarResultado &= LvarResult;
				}
				socket.close();
			} else {
				throw (message="Not connected to LvarHost #LvarHost# via LvarPuerto #LvarPuerto#");
			}
			
			if (LvarResultado NEQ "OK")
				try {
					LvarResultado = deserializeJson(LvarResultado);
					if (withUsucodigos)
						LvarResultado = fnGetUsucodigos(LvarResultado);
				} catch(any e) {
					LvarResultado = {texto : LvarResultado};
				}

			return LvarResultado;
		}

		private any function sbCFServerInit() 
		{
			try {
				LvarResultado = fnSend_FirmaDigitalServer("init","",false);
			} catch(any e) {
				LvarResultado = e.message;
			}

			if (trim(LvarResultado) NEQ "OK")
				sbCFServerStart();
		}

		private void function sbCFServerStart() 
		{
			LvarSep	= LvarSystem.getProperty("file.separator");

			LvarVer	= LvarSystem.getProperty("java.version");
			LvarVer	= listToArray(LvarVer,".");
			if ("#LvarVer[1]#.#LvarVer[2]#" GTE 1.8 AND LvarJava8Path EQ "*")
			{
				LvarJava8Path	= LvarSystem.getProperty("java.home");
				LvarJavaPath	= LvarJava8Path & LvarSep & "bin" & LvarSep & "java";
			}
			else
			{
				if (LvarJava8Path EQ "*")
					throw (message="ERROR: No se ha definido el System.property 'FirmaDigital.jre8_home'");
				if (NOT DirectoryExists(LvarJava8Path))
					throw (message="ERROR: System.property 'FirmaDigital.jre8_home' = '#LvarJava8Path#', pero no existe directorio '#LvarJava8Path & LvarSep & "bin"#'");
				LvarJavaPath	= LvarJava8Path & LvarSep & "bin" & LvarSep & "java";
			}
			
			LvarClassPath	= expandPath("/home/public/FirmaDigital/plugin/lib/FirmaDigitalServer.jar");

			LvarArgs = "-cp #LvarClassPath# -Xms256m -Xmx1024m com.soin.firmaDigital.CFServer SRV #LvarPuerto# #LvarHilos#";
			LvarCmd = LvarJavaPath & " " & LvarArgs;
			sbStartServer(LvarJavaPath, LvarArgs);
			//LvarProc = CreateObject("java","java.lang.Runtime").getRuntime().exec(LvarCmd);
		}
	</cfscript>
	
	<cffunction name="fnGetUsucodigos" output="yes" returnType="void" access="private">
		<cfargument name="Res">
			
		<cfloop index="i" from="1" to="#arrayLen(Arguments.Res.Firmas)#">
			<cfset LvarFirma = Arguments.Res.Firmas[i]>
			<cfset LvarRes = createobject("component","sign").sbGetUsucodigos(LvarFirma.SubjectSN)>
			<cfset LvarFirma.Usucodigos = LvarRes.Usucodigo>
			<cfset LvarFirma.Usulogins = LvarRes.Usulogin>
			<cfset LvarFirma.Usutipo = LvarRes.Tipo>
		</cfloop>
		<cfreturn Arguments.Res>
	</cffunction>
		
	<cffunction name="sbStartServer" output="yes" returnType="void" access="private">
		<cfargument name="cmd">
		<cfargument name="args">
		
		<cfset var LvarResultado = "">
		<cfexecute name="#LvarJavaPath#" 
					arguments="#LvarArgs#" 
					outputFile="#LvarClassPath#.txt" 
					errorvariable="LvarError" 
					timeout="0"
		>
		<cfparam name="LvarError" default="">
		<cfif LvarError EQ "">
			<cfthread action="sleep" duration="2000" />
			<cffile action="read" file="#LvarClassPath#.txt" variable="LvarResultado">
			<cfset LvarError = "#LvarResultado#">
		</cfif>
		<cfif NOT (left(LvarError,2) EQ "OK" and len(LvarError) LTE 4)>
			<cfoutput>
				===============================================================<br>
				Starting FirmaDigital.CFServer...<br>
				Cmd=<font face="Monospace">#LvarCmd#</font><br>
				<font color="##FF0000">Error=<strong>#replace(LvarError,chr(10),"<br>#chr(10)#","ALL")#</strong></font><br>
				===============================================================<br>
				<br>
			</cfoutput>
			<cfabort>
		<cfelseif left(LvarError,2) EQ "OK">
			<cffile action="write" file="#LvarClassPath#.txt" output="Starting FirmaDigital.CFServer..." addnewline="true">
			<cffile action="append" file="#LvarClassPath#.txt" output="#datetimeFormat(now(),"YYYY-mm-dd HH:nn:ss")#" addnewline="true">
			<cffile action="append" file="#LvarClassPath#.txt" output="OK" addnewline="true">
		</cfif>
		<cfreturn>
	</cffunction>
</cfcomponent>
