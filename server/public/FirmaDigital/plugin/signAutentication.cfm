<!---
	Pantalla de login (1 nivel: se crea el token directamente):
	1. Conecte el dispositivo de lectura de SmartCards en un USB
	2. Coloque la firma digital en el dispositivo
	3. Acepte el Download del Archivo 'FirmaDigital.jnlp' (debe ejecutarse con Java Web Start)
	4. Ejecute el jnlp si no arrancó automáticamente (double-click en 'FirmaDigital.jnlp')
	5. Digite el PIN de la firma digital
		(PRECAUCION:  Después de 3 intentos fallidos la FirmaDigital se bloquea)
--->

<!--- LlaveDeAutenticacion LlaveDeFirma ---->
<cfset LvarToken = createObject("component","login").createToken("LlaveDeAutenticacion", isdefined("URL.tkn"))>

<cfif NOT (isdefined("Server.ClusterCfg") and Server.ClusterCfg.isCluster)>
	<cftry>
		<cfwebsocket name="LvarWebSocket" onOpen="openHandler" onMessage="msgHandler" subscribeTo="wsChannelFD.WSC_#LvarToken#" />
	<cfcatch type="any"></cfcatch></cftry>
</cfif>

<script type="text/javascript">
	var GvarDebug = true;
	<!---
	La comunicación original es por WebSocket.  El status del JavaWebStart se envía al javascript por WebSocket
	JWS ==(WebService sendData)==> Server ==(Canal WebSocket)==> JS
	Si después de un segundo no se ha establecido la comunicación por WebSocket, se establece comunicación ajax por WebService y el JavaScript pregunta cada segundo el Status del WebJavaStart por medio del WebService getStatus()
		JWS ==(WebService sendData)==> Server | Cada segundo: JS ==(WebService getStatus)==> Server
	--->
	var GvarWS = 0;	<!--- 0=Inicio, 1=WebSocket (OUT/IN), 2=Ajax WebService (OUT/ getStatus "IN") --->
	window.setTimeout("sbVerifyWebSocket();", 1000);

	function msgHandler(pMsg) {
		if (GvarWS == 2) { <!--- Si se inició la comunicación Ajax por WebService ya no hay nada que hacer --->
			return;
		}
		if (GvarDebug && document.getElementById("divDebug")) {
			var LvarDivDebug = document.getElementById("divDebug");
			var message = ColdFusion.JSON.encode(pMsg);
			LvarDivDebug.innerHTML += message + "<br>" + "<br>";
		}
		var LvarOK = false;
		var LvarMSG	= "";
		var LvarTIP	= "";
		<!--- Obtiene el tipo --->
		if ((pMsg.reqType && pMsg.reqType == "subscribeTo") || (pMsg.type && pMsg.type == "subscribe")) {
			LvarTIP = "subscribe";
		} else if (pMsg.data && pMsg.data.TYPE) {
			LvarTIP = pMsg.data.TYPE;
		} else if (pMsg.reqType && pMsg.reqType == "invoke") {
			LvarTIP = pMsg.reqType;
		}
		<!--- Obtiene el status --->
		if (pMsg.data && pMsg.data.STATUS) {
			LvarMSG = pMsg.data.STATUS;
			LvarOK = (LvarMSG == "OK");
		} else if (pMsg.msg) {
			LvarMSG = pMsg.msg;
			LvarOK = (LvarMSG == "ok");
		} else {
			LvarOK = false;
			LvarMSG = ColdFusion.JSON.encode(pMsg);
		}
		<!--- Procesa los eventos --->
		if (LvarTIP == "subscribe") {
			if (GvarWS == 2) {
				return;
			}
			<!--- Resultado de Subscribe --->
			setStatus("Suscripción al WebSocket Channel: " + LvarMSG);
			if (LvarOK) {
				GvarWS = 1;
				LvarWebSocket.invoke("login", "initTokenJS", ["<cfoutput>#LvarToken#</cfoutput>",0]);
			} else {
				return; <!--- Si hay error en la suscripción se inicia comunicación Ajax por WebService --->
			}
		} else if (LvarTIP == "initTokenJS") {
			<!--- Resultado de invoke initTokenJS --->
			setStatus ("Inicialización de token por WebSocket: " + LvarMSG);
			if (!LvarOK) {
				sbError(LvarMSG);
			}
		} else if (LvarTIP == "initTokenJWS") {
			<!--- Enviado por JWS: initTokenJWS --->
			setStatus ("Inicialización de Java Web Start: " + LvarMSG);
			if (!LvarOK) {
				sbError(LvarMSG);
			}
		} else if (LvarTIP == 'sendPort' || LvarTIP == 'sendData' || LvarTIP == 'sendError') {
			sbSendPortDataError(LvarTIP, LvarOK, LvarMSG);
		} else if (pMsg.reqType && pMsg.reqType == "invoke" && pMsg.data && pMsg.data.TYPE && pMsg.data.STATUS) {
			<!--- Resultado de otros invokes cuya respuesta sea: return {type="nombre", status="OK o Error"} --->
			setStatus ("Invocación a " + pMsg.data.TYPE + ": " + pMsg.data.STATUS);
			if (!LvarOK) {
				sbError(LvarMSG);
			}
		}
	}

	function openHandler() {
		setStatus("Conectado al WebSocket: ok");
	}

	var GvarSameLine = false;
	function setStatus(pMsg, pSameLine) {
		if (GvarDebug) {
			if (!pSameLine && GvarSameLine) {
				document.getElementById("divStatus").innerHTML += "<br>" + "<br>";
			}
			GvarSameLine = pSameLine;
			if (pSameLine) {
				document.getElementById("divStatus").innerHTML += pMsg;
			} else {
				document.getElementById("divStatus").innerHTML += pMsg + "<br>" + "<br>";
			}
		} else {
			document.getElementById("divStatus").innerHTML = pMsg;
		}
	}

	function sbVerifyWebSocket() {
		if (GvarWS == 1) { <!--- Si ya se suscribió no hay nada que hacer --->
			return;
		}
		GvarWS = 2; <!--- Si no se suscrito despues de un segundo, entonces la comunicación es ajax por WebService --->

		var LvarAjax = new XMLHttpRequest();
		LvarAjax.open("GET", "login.cfc?Method=initTokenJS&Token=<cfoutput>#LvarToken#</cfoutput>&getStatus=1", true);
		LvarAjax.onreadystatechange = sbVerifyWebSocket_Response;
		LvarAjax.send();
	}

	function sbVerifyWebSocket_Response() {
		if (this.readyState != 4) {
			return;
		}

		LvarResponse = this.responseText.split(",");
		LvarTIP = LvarResponse[0];
		LvarMSG = LvarResponse[1];
		LvarOK	= (LvarMSG == "OK");

		setStatus ("Inicialización de Token por WebService: " + LvarMSG);
		if (LvarOK)	{
			window.setTimeout("getStatus(true);",1000);
		} else {
			sbError(LvarMSG);
		}
	}

	function getStatus(pIni) {
		var LvarMSG = "";
		var LvarAjax = new XMLHttpRequest();

		if (pIni) {
			setStatus ("Inicialización de getStatus() por WebService: OK");
		}

		LvarAjax.open("GET", "login.cfc?Method=getStatus&Token=<cfoutput>#LvarToken#</cfoutput>&ts=" + Math.random(), true);
		LvarAjax.onreadystatechange = getStatus_Response;
		LvarAjax.send();
	}

	function getStatus_Response() {
		if (this.readyState != 4) {
			return;
		}

		LvarResponse = this.responseText.split(",");
		LvarTIP = LvarResponse[0];
		LvarMSG = LvarResponse[1];
		LvarOK	= (LvarMSG == "OK");

		if (LvarTIP == "initTokenJWS") {
			<!--- Enviado por JWS: initTokenJWS --->
			setStatus ("Inicialización de Java Web Start: " + LvarMSG);
			if (LvarOK) {
				window.setTimeout("getStatus();",1000);
			} else {
				sbError(LvarMSG);
			}
		} else if (LvarTIP == 'sendPort' || LvarTIP == 'sendData' || LvarTIP == 'sendError') {
			sbSendPortDataError(LvarTIP, LvarOK, LvarMSG);
		} else if (LvarTIP == "getStatus" && ! LvarOK) {
			<!--- Enviado por getStatus: sendError --->
			setStatus ("Error enviado desde getStatus: " + LvarMSG);
			sbError(LvarMSG);
		} else if (LvarOK) {
			setStatus ("*", true);
			window.setTimeout("getStatus();",1000);
		} else {
			setStatus (LvarResponse);
		}
	}

	function sbSendPortDataError(LvarTIP, LvarOK, LvarMSG) {
		if (LvarTIP == "sendPort") {
			<!--- Enviado por FirmaDigitalInit.InitServer: sendPort --->
			LvarOK = LvarMSG.substring(0,3) == "OK:";
			LvarPort = LvarMSG.substring(3);

			if (!LvarOK) {
				sbError(LvarMSG);
			} else {
				setStatus ("Puerto del Servidor Local: " + LvarPort);
				localStorage.setItem("FirmaDigitalServer.Port", LvarPort+"");
				<cfif isdefined("URL.tkn")>
					document.form1.action = "<cfoutput>signAutentication.cfm?tkn=#URL.tkn#&a=*&e=RX&fn=#URL.FN#&errorFn=#URL.errorFn#&r=1</cfoutput>";
				<cfelse>
					document.form1.action = "signAutentication.cfm?r=1";
				</cfif>
				document.form1.submit();
			}
			return true;
		} else if (LvarTIP == "sendData") {
			<!--- Enviado por JWS: sendData --->
			setStatus ("Autenticación: " + LvarMSG);
			if (!LvarOK) {
				sbError(LvarMSG);
			} else {
				sbSubmit();
			}
			return true;
		} else if (LvarTIP == "sendError") {
			<!--- Enviado por JWS: sendError --->
			setStatus ("Error enviado desde Java: " + LvarMSG);
			sbError(LvarMSG);
			return true;
		}
		return false;
	}

	function sbSubmit() {
		<!--- Aqui enviar a proceso de autenticación y autorización de Applicacion WEB --->
		try {
			LvarWebSocket.unsubscribe("wsChannelFD.WSC_<cfoutput>#LvarToken#</cfoutput>");
		} catch (e) {}
		try {
			LvarWebSocket.closeConnection();
		} catch (e) {}
		parentWindow = window.parent;
		parentWindow.signOnePerTurn = true;
		var fn = parentWindow["<cfoutput>#URL.FN#</cfoutput>"];
		if (typeof fn === "function") {
			fn(<cfoutput>#LvarToken#</cfoutput>);
		}
	}

	function sbError(pMsg) {
		<!--- Se desconecta del WebSocket --->
		try {
			LvarWebSocket.unsubscribe("wsChannelFD.WSC_<cfoutput>#LvarToken#</cfoutput>");
		} catch (e) {}
		try {
			LvarWebSocket.closeConnection();
		} catch (e) {}
		parentWindow = window.parent;
		parentWindow.signOnePerTurn = true;
		var fn = parentWindow["<cfoutput>#URL.errorFn#</cfoutput>"];
		if (typeof fn === "function") {
			fn();
		}
		if (typeof parentWindow.PNotify === "function") {
			$ = parentWindow.$;
			(new parentWindow.PNotify({
				type: 'error',
				title: 'Proceso de Autenticación con error',
				text: pMsg,
				icon: '',
				hide: false,
				confirm: {
					confirm: true,
					buttons: [ { text: "Aceptar" }, null ]
				},
				buttons: {
					closer: false,
					sticker: false
				},
				history: {
					history: false
				},
				addclass: 'stack-modal',
				stack: {'dir1': 'down', 'dir2': 'right', 'modal': true}
			})).get().on('pnotify.confirm', function() {
				$(".ui-pnotify-modal-overlay").remove();
			});
			$('.ui-pnotify').css({top: ($(parentWindow).height() / 2) - ($('.ui-pnotify').height() / 2) });
		} else {
			alert("Proceso de Autenticación con error:\n\n" + pMsg);
		}
		return;
	}
</script>

<form name="form1" method="post">
	<strong>Status del proceso Login:</strong>
	<input type="hidden" name="TOKEN" value="<cfoutput>#LvarToken#</cfoutput>">
	<div id="divStatus" style="font: 10px arial, sans-serif">
		Iniciando...
		<br><br>
	</div>
	<br><br>
	<strong>Debug del proceso:</strong>
	<div id="divDebug" style="font: 10px arial, sans-serif"></div>
	<cfparam name="URL.r" default="0">
	<iframe style="display:none;" src="login_jnlp.cfm?TKN1=<cfoutput>#LvarToken#&r=#URL.r#</cfoutput>"></iframe>
</form>