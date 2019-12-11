<!--- 
	El FirmaDigital.jnlp se genera sin ningun tipo de seguridad
--->

<cfset LvarTOKEN=getTickcount()>
<cfset StructDelete(url,"TKN1")>
<cfset url.TKN2 = LvarTOKEN>

<cfset LvarChecksum = "000000">
<cfif isdefined("url.TKN2")>
	<cfset LvarChecksum = hash(fileReadBinary( expandPath( "lib/FirmaDigitalServer.jar" ) ), "MD5")>
</cfif>

<cfset LvarCodebase = createObject("component","home.public.FirmaDigital.plugin.cluster").getJNLP_Codebase()>

<cfset LvarWS 	= LvarCodebase & "sign.cfc">
<cfset LvarData = "#LvarToken#%1FA1A2A3%1F000000%1F0%1F#LvarChecksum#%1FDocSign%1F#URLEncodedFormat("Firma y Verficacion de Archivos")#%1F#BinaryEncode(LvarWS.getBytes(),"HEX")#">
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
					sbDocSign();
					return;
				}
			}
		}
		sbFirmaDigitalInit();
	}
	
	function sbDocSign()
	{
		var LvarAjax 	= new XMLHttpRequest();
		
		<cfoutput>
		LvarAjax.open("GET", "https://firmadigitallocal.com:"+GvarPort+"/FirmaDigitalServer?OP=DocSign&data=#LvarData#", true);
		</cfoutput>
		LvarAjax.send();
	}

<cfif isdefined("url.R") and url.R EQ 1>
	function sbFirmaDigitalInit()
	{
		alert("No se pudo instalar correctamente el FirmaDigitalServer");
	}
<cfelse>
	function sbFirmaDigitalInit()
	{
		var LvarAjax = new XMLHttpRequest();
		location.href = "init_installer.cfm?tkn1=<cfoutput>#LvarToken#</cfoutput>&proceso=DocSign";
	}
</cfif>
</script>

