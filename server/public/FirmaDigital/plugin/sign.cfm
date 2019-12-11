<!---
	Pantalla de sign (2 niveles: se genera el XML y token temporal al primer nivel y se crea el token en el segundo nivel):
	1. Conecte el dispositivo de lectura de SmartCards en un USB
	2. Coloque la firma digital en el dispositivo
	3. Acepte el Download del Archivo 'FirmaDigital.jnlp' (debe ejecutarse con Java Web Start)
	4. Ejecute el jnlp si no arrancó automáticamente (double-click en 'FirmaDigital.jnlp')
	5. Digite el PIN de la firma digital 
	   (PRECAUCION:  Después de 3 intentos fallidos la FirmaDigital se bloquea)
--->
<cfif isdefined("form.token")>
	<cfparam name="url.TKNTMP" default="#form.token#">
<cfelse>
	<cfparam name="url.TKNTMP">
</cfif>

<!--- Control de GoBack --->
<cfset createObject("component","login").pintaControlBack()>

<!--- Pantalla a Nivel 1 --->
<cfif url.TKNTMP EQ "0">
	<cfset createObject("component","home.public.FirmaDigital.plugin.sign").pintaIframe1(url.args)>
	<cfabort>
</cfif>

<!--- Pantalla a Nivel 2 --->
<!--- LlaveDeAutenticacion LlaveDeFirma ---->

<cfif not isdefined("Application._FirmaDigital_.tokens.TK" & url.TKNTMP & ".MSGDATA")>
	<script>
		parent.parent.sbInvocarFirmaDigital();
	</script>
	<cfabort>
</cfif>

<cfset LvarToken = createObject("component","sign").createToken(url.TKNTMP)>
<cfif NOT (isdefined("Server.ClusterCfg") and Server.ClusterCfg.isCluster)>
	<cftry>
		<cfwebsocket name="LvarWebSocket" onOpen="openHandler" onMessage="msgHandler" subscribeTo="wsChannelFD.WSC_#LvarToken#" /> 
	<cfcatch type="any"></cfcatch></cftry>
</cfif>

<script> 
	function getToken()
	{
		return "<cfoutput>#LvarToken#</cfoutput>";
	}
</script> 
<script type="text/javascript">
	var GvarDebug	= true;
	
	<!---
		La comunicación original es por WebSocket.  El status del JavaWebStart se envía al javascript por WebSocket
			JWS ==(WebService sendData)==> Server ==(Canal WebSocket)==> JS
		Si después de un segundo no se ha establecido la comunicación por WebSocket, se establece comunicación ajax por WebService
		y el JavaScript pregunta cada segundo el Status del WebJavaStart por medio del WebService getStatus()
			JWS ==(WebService sendData)==> Server | Cada segundo: JS ==(WebService getStatus)==> Server
	--->
	var GvarWS		= 0;	// 0=Inicio, 1=WebSocket (OUT/IN), 3=Ajax WebService (OUT/ getStatus "IN")
	window.setTimeout("sbVerifyWebSocket();",1000);
	function msgHandler(pMsg)
	{ 
		if (GvarWS == 2)			// Si se inició la comunicación Ajax por WebService ya no hay nada que hacer
			return;
			
		if (GvarDebug && document.getElementById("divDebug"))
		{
			var LvarDivDebug = document.getElementById("divDebug");
			var message = ColdFusion.JSON.encode(pMsg); 
			LvarDivDebug.innerHTML += message + "<br>" + "<br>"; 
		}

		var LvarOK	= false;
		var LvarMSG	= "";
		var LvarTIP	= "";
		// Obtiene el tipo
		if ((pMsg.reqType && pMsg.reqType == "subscribeTo") || (pMsg.type && pMsg.type == "subscribe"))
		{
			LvarTIP = "subscribe";
		}
		else if (pMsg.data && pMsg.data.TYPE)
		{
			LvarTIP = pMsg.data.TYPE;
		}
		else if (pMsg.reqType && pMsg.reqType == "invoke")
		{
			LvarTIP = pMsg.reqType;
		}

		// Obtiene el status
		if (pMsg.data && pMsg.data.STATUS)
		{
			LvarMSG		= pMsg.data.STATUS;
			LvarOK		= (LvarMSG == "OK");
		}
		else if (pMsg.msg)
		{
			LvarMSG		= pMsg.msg;
			LvarOK		= (LvarMSG == "ok");
		}
		else
		{
			LvarOK		= false;
			LvarMSG		= ColdFusion.JSON.encode(pMsg);
		}
	
		// Procesa los eventos
		if (LvarTIP == "subscribe")
		{
			if (GvarWS == 2)
				return;
				
			// Resultado de Subscribe
			setStatus("Suscripción al WebSocket Channel: " + LvarMSG);
			if (LvarOK)
			{
				GvarWS = 1;
				LvarWebSocket.invoke("sign", "initTokenJS", ["<cfoutput>#LvarToken#</cfoutput>",0]);
			}
			else
				return;		// Si hay error en la suscripción se inicia comunicación Ajax por WebService
		}
		else if (LvarTIP == "initTokenJS")
		{
			// Resultado de invoke initTokenJS
			setStatus ("Inicialización de token por WebSocket: " + LvarMSG);
			if (!LvarOK)
				sbError(LvarMSG);
		}
		else if (LvarTIP == "initTokenJWS")
		{
			// Enviado por JWS: initTokenJWS
			setStatus ("Inicialización de Java Web Start: " + LvarMSG);
			if (!LvarOK)
				sbError(LvarMSG);
		}
		else if (LvarTIP == 'sendPort' || LvarTIP == 'sendData' || LvarTIP == 'sendError')
		{
			sbSendPortDataError(LvarTIP, LvarOK, LvarMSG);
		}

		// Resultado de otros invokes cuya respuesta sea: return {type="nombre", status="OK o Error"}
		else if (pMsg.reqType && pMsg.reqType == "invoke" && pMsg.data && pMsg.data.TYPE && pMsg.data.STATUS)
		{
			setStatus ("Invocación a " + pMsg.data.TYPE + ": " + pMsg.data.STATUS);
			if (!LvarOK)
				sbError(LvarMSG);
		}
	} 

	function openHandler()
	{ 
		setStatus("Conectado al WebSocket: ok");
	} 

	var GvarSameLine = false;
	function setStatus(pMsg, pSameLine)
	{ 

		if (GvarDebug)
		{
			if (!pSameLine && GvarSameLine)
				document.getElementById("divStatus").innerHTML += "<br>" + "<br>";
			GvarSameLine = pSameLine;
			if (pSameLine)
				document.getElementById("divStatus").innerHTML += pMsg;
			else
				document.getElementById("divStatus").innerHTML += pMsg + "<br>" + "<br>";
		}
		else
			document.getElementById("divStatus").innerHTML = pMsg;
	} 		

	function sbVerifyWebSocket()
	{ 
		if (GvarWS == 1)		// Si ya se suscribió no hay nada que hacer
			return;

		GvarWS = 2;				// Si no se suscrito despues de un segundo, entonces la comunicación es ajax por WebService
			
		var LvarAjax = new XMLHttpRequest();
		LvarAjax.open("GET", "sign.cfc?Method=initTokenJS&Token=<cfoutput>#LvarToken#</cfoutput>&getStatus=1", true);
		LvarAjax.onreadystatechange = sbVerifyWebSocket_Response;
		LvarAjax.send();
	}
	
	function sbVerifyWebSocket_Response()
	{
		if (this.readyState != 4)
			return;

		LvarResponse = this.responseText.split(",");
		LvarTIP = LvarResponse[0];
		LvarMSG = LvarResponse[1];
		LvarOK	= (LvarMSG == "OK");

		setStatus ("Inicialización de Token por WebService: " + LvarMSG);
		if (LvarOK)
		{
			window.setTimeout("getStatus(true);",1000);
		}
		else
			sbError(LvarMSG);
	}
	
	function getStatus(pIni)
	{
		var LvarMSG = "";
		var LvarAjax = new XMLHttpRequest();

		if (pIni)
			setStatus ("Inicialización de getStatus() por WebService: OK");

		LvarAjax.open("GET", "sign.cfc?Method=getStatus&Token=<cfoutput>#LvarToken#</cfoutput>&ts=" + Math.random(), false);
		LvarAjax.onreadystatechange = getStatus_Response;
		LvarAjax.send();
	}
	
	function getStatus_Response()
	{
		if (this.readyState != 4)
			return;

		LvarResponse = this.responseText.split(",");
		
		LvarTIP = LvarResponse[0];
		LvarMSG = LvarResponse[1];
		LvarOK	= (LvarMSG == "OK");

		if (LvarTIP == "initTokenJWS")
		{
			// Enviado por JWS: initTokenJWS
			setStatus ("Inicialización de Java Web Start: " + LvarMSG);
			if (LvarOK)
				window.setTimeout("getStatus();",1000);
			else
				sbError(LvarMSG);
		}
		else if (LvarTIP == 'sendPort' || LvarTIP == 'sendData' || LvarTIP == 'sendError')
		{
			sbSendPortDataError(LvarTIP, LvarOK, LvarMSG);
		}

		else if (LvarTIP == "getStatus" && ! LvarOK)
		{
			// Enviado por JWS: sendError
			setStatus ("Error enviado desde getStatus: " + LvarMSG);
			sbError(LvarMSG);
		}
		else if (LvarOK)
		{
			setStatus ("*", true);
			window.setTimeout("getStatus();",1000);
		}
		else 
			setStatus (LvarResponse);
	}
	
	function sbSendPortDataError(LvarTIP, LvarOK, LvarMSG)
	{
		if (LvarTIP == "sendPort")
		{
			// Enviado por FirmaDigitalInit (javaWebStart): sendPort
			LvarOK = LvarMSG.substring(0,3) == "OK:";
			LvarPort = LvarMSG.substring(3);

			if (!LvarOK)
			{
				sbError(LvarMSG);
			}
			else
			{
				setStatus ("Puerto del Servidor Local: " + LvarPort);
				localStorage.setItem("FirmaDigitalServer.Port", LvarPort+"");
				<cfif isdefined("url.tkn")>
				document.form1.action = "<cfoutput>sign.cfm?tkn=#url.tkn#&e=#url.e#&a=#url.a#&r=1</cfoutput>";
				<cfelse>
				document.form1.action = "sign.cfm?r=1";
				</cfif>
				document.form1.submit();
			}
		}
		else if (LvarTIP == "sendData")
		{
			// Enviado por FirmaDigitalInit (javaWebStart) o FirmaDigitalServer (java): sendData
			setStatus ("Firma de Mensaje: " + LvarMSG);
			if (!LvarOK)
			{
				sbError(LvarMSG);
			}
			else
			{
				sbSubmit();
			}
		}
		else if (LvarTIP == "sendError")
		{
			// Enviado por FirmaDigitalInit (javaWebStart) o FirmaDigitalServer (java): sendError
			setStatus ("Error enviado desde Java: " + LvarMSG);
			sbError(LvarMSG);
		}
	}

	function sbSubmit()
	{
		// Aqui enviar a proceso de procesar XML firmado
		try {
			LvarWebSocket.unsubscribe("wsChannelFD.WSC_<cfoutput>#LvarToken#</cfoutput>");
		} catch (e) {}
		try {
			LvarWebSocket.closeConnection();
		} catch (e) {}
		document.form1.action = "sign_ok.cfm";
		document.form1.submit();
	}

	function sbError(pMsg)
	{
		// Se desconecta del WebSocket
		try {
			LvarWebSocket.unsubscribe("wsChannelFD.WSC_<cfoutput>#LvarToken#</cfoutput>");
		} catch (e) {}
		try {
			LvarWebSocket.closeConnection();
		} catch (e) {}

		// Aqui volver a pantalla de sign
		if (confirm("Proceso de firma XML con $error:\n        " + pMsg + "\n\n¿Desea reintentar la Firma del Mensaje?"))
		{
			document.form1.action = "sign.cfm";
			document.form1.submit();
		} else {
			window.parent.parent.sbPostFirmaDigital('','',pMsg);
		}
		return;
	}
</script> 

<form name="form1" method="post">
	<strong>Status del proceso Sign:</strong>

	<input type="hidden" name="TOKEN"		value="<cfoutput>#LvarToken#</cfoutput>">
	<input type="hidden" name="RELOAD"	value="0">
	<div id="divStatus"  style="font: 10px arial, sans-serif">
		Iniciando...<br><br>
	</div>

	<BR><BR>
	
	<strong>Debug del proceso:</strong>
	<div id="divDebug"	 style="font: 10px arial, sans-serif"> 
	</div>
	<cfparam name="url.r" default="0">
	<iframe style="display:none;" src="sign_jnlp.cfm?TKN1=<cfoutput>#LvarToken#&r=#url.r#</cfoutput>"></iframe>
</form>



