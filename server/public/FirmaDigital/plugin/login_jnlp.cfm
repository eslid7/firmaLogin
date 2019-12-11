<!--- 
	Originalmente se bajaba el Firmador por JNLP:
		El FirmaDigital.jnlp se genera 2 veces:
			1. En un iframe de login.cfm, para realizar el download del jnlp (se indica enviando parámetro TKN1=<token>)
			2. Por el javaws, durante la ejecución del jnlp, porque existe un href para que vuelve a bajar el jnlp y no de errores de seguridad (se indica enviando parámetro TKN2=<token> y TKN3=<tkn3>)
	Posteriormente se bajaba el Instalador por JNLP:
		Se genera el ajax 
		Fuerza la logica del punto 2
	Actualmente se baja el Instalador como .jar
--->

<cfif NOT isdefined("url.TKN1")>
	<cfthrow message="ERROR: El token es inválido">
</cfif>
<cfset LvarTOKEN=url.TKN1>
<cfset StructDelete(url,"TKN1")>
<cfif NOT isdefined("Application._FirmaDigital_.tokens.TK#LvarToken#.MSG")>
	<cfthrow message="ERROR: El token es inválido">
</cfif>
<cfset url.TKN2 = LvarTOKEN>
<cfset url.TKN3	= getTickcount()>
<cfset Application._FirmaDigital_.tokens["TK#LvarToken#"].TKN3 = url.TKN3>
<cfset Application._FirmaDigital_.tokens["TK#LvarToken#"].TKN_CNT = 1>

<cfset LvarMSG	= "A1A2A3">

<cfif isdefined("url.TKN2") and isdefined("url.TKN3")>
	<!--- Si el token es remoto ejecuta el download desde el otro servidor y termina --->
	<cfset createObject("component","home.public.FirmaDigital.plugin.cluster").download_JNLP(url.TKN2)>

	<cfset LvarTOKEN= url.TKN2>
	<cfset LvarTKN3	= url.TKN3>

	<cfif isdefined("Application._FirmaDigital_.tokens.TK#LvarToken#.TKN3")
		AND Application._FirmaDigital_.tokens["TK#LvarToken#"].TKN3 EQ LvarTKN3
		AND isdefined("Application._FirmaDigital_.tokens.TK#LvarToken#.MSG")
	>
		<cfset LvarMSG	= Application._FirmaDigital_.tokens["TK#LvarToken#"].MSG>
		<cfset Application._FirmaDigital_.tokens["TK#LvarToken#"].TKN_CNT++>
		<cfif NOT (isdefined("Server.ClusterCfg") and Server.ClusterCfg.isCluster) OR Application._FirmaDigital_.tokens["TK#LvarToken#"].TKN_CNT GT 2>
			<cfset StructDelete(Application._FirmaDigital_.tokens["TK#LvarToken#"], "MSG", false)>
			<cfset StructDelete(Application._FirmaDigital_.tokens["TK#LvarToken#"], "TKN3", false)>
		</cfif>
	<cfelse>
		<cfset StructDelete(Application._FirmaDigital_.tokens, "TK#LvarToken#", false)>
	</cfif>
<cfelse>
	<cfset StructDelete(Application._FirmaDigital_.tokens, "TK#LvarToken#", false)>
	<cfthrow message="ERROR: El token es inválido">
</cfif>

<cfset LvarCodebase = createObject("component","home.public.FirmaDigital.plugin.cluster").getJNLP_Codebase()>

<cfset LvarWS 	= LvarCodebase & "login.cfc">
<cfset LvarData = "#LvarToken#%1F#LvarMSG#%1F#BinaryEncode(LvarWS.getBytes(),"HEX")#">
<script>
	window.setTimeout("sbCheck();",1001);
	var GvarPort = null;
	
	function sbCheck()
	{
		GvarPort	= localStorage.getItem("FirmaDigitalServer.Port");
		if (GvarPort == null)
		{
			sbFirmaDigitalInit();
			return;
		}
		<cfset LvarChecksum = hash(fileReadBinary( expandPath( "lib/FirmaDigitalServer.jar" ) ), "MD5")>
		<cfset LvarChecksumDES = createObject("component","home.public.FirmaDigital.Componentes.crypto").DES_EncryptWithPassword(LvarChecksum, "FD" & LvarTOKEN)>
			
		var LvarAjax 	= new XMLHttpRequest();
		
		try
		{
		<cfoutput>
			LvarAjax.open("GET", "https://firmadigitallocal.com:"+GvarPort+"/FirmaDigitalServer?OP=check&data=#LvarToken#%1F#LvarChecksum#%1F1", true);
			</cfoutput>
			LvarAjax.onreadystatechange = sbCheck_Response;
			LvarAjax.send();
		}
		catch (e)
		{
			sbFirmaDigitalInit();
		}
	
	}
	
	function sbCheck_Response()
	{
		if (this.readyState != 4)
			return;

		if (this.status == 202)
		{
			if (this.responseText.substring(0,2) == "OK")
			{
				if (this.responseText.substring(3).split(/\s+/)[0] ==	 "<cfoutput>#LvarChecksumDES#</cfoutput>")
				{
					sbLogin();
					return;
				}
			}
		}
		sbFirmaDigitalInit();
	}
	
	function sbLogin()
	{
		var LvarAjax 	= new XMLHttpRequest();
		
		<cfoutput>
		LvarAjax.open("GET", "https://firmadigitallocal.com:"+GvarPort+"/FirmaDigitalServer?OP=login&data=#LvarData#", true);
		</cfoutput>
		LvarAjax.send();
	}

<cfif isdefined("url.R") and url.R EQ 1>
	function sbFirmaDigitalInit()
	{
		//parent.sbError("No se pudo instalar correctamente el FirmaDigitalServer");
		alert("El Servicio Local de FirmaDigital ya está instalado. Sin embargo no se ha concedido el permiso para poderse comunicar con el mismo:\n\n"
				 +"Se va a abrir una nueva ventana accediendo al https://firmadigitallocal.com:"+GvarPort+" (confirme que no se haya bloqueado una ventana emergente)\n\n"
				 +"Favor conceda acceso al Servicio Local de FirmaDigital\n\n"
				 +"Cierre la ventana de confirmación"
				 )
		<cfoutput>
		window.open("https://firmadigitallocal.com:"+GvarPort+"/FirmaDigitalServer?OP=check&data=#LvarToken#%1F#LvarChecksum#%1F0","_blank");
		</cfoutput>
	}
<cfelse>
	function sbFirmaDigitalInit()
	{
		var LvarAjax = new XMLHttpRequest();
		LvarAjax.open("GET", "login.cfc?Method=initServer&Token=<cfoutput>#LvarToken#</cfoutput>", true);
		LvarAjax.onreadystatechange = sbFirmaDigitalInit_Response;
		LvarAjax.send();
	}
	
	GvarInitErr = false;
	function sbFirmaDigitalInit_Response()
	{
		if (this.readyState != 4)
			return;

		LvarResponse = this.responseText.split(",");
		LvarTIP = LvarResponse[0];
		LvarMSG = LvarResponse[1];
		LvarOK	= (LvarMSG == "OK");

		parent.setStatus ("FirmaDigitalInit: " + LvarMSG);
		if (LvarOK)
		{
			location.href = "init_installer.cfm?tkn1=<cfoutput>#LvarToken#</cfoutput>&proceso=login";
		}
		else if( typeof LvarMSG === 'undefined' || LvarMSG === null )
debugger;
		else
			parent.sbError(LvarMSG);
	}
</cfif>
</script>
