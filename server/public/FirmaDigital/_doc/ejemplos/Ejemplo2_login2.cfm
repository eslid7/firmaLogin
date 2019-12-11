Pantalla de prueba de sólo Autenticacion (Comprobación de la presencia del Usuario)
<br><br>

<!---
	En la pantalla de Comprobacion de identidad del usuario
		Pintar el IFrame con el componente “login” para descargar el jnlp (JWS) y ejecutar el javascript  (JS)
			Componente:		public.home.FirmaDigital.plugin.login
			Método:			pintaIframeSoloAutenticacion	
			Parámetros
				automatico	type="boolean" 		true	= inicia la descarga automáticamente
												false	= se debe invocar javascript:sbInvocarFirmaDigital()
				pruebas		type="boolean"		true	= IFrame visible para debug
												false	= IFrame invisible para produccion
		Incluir un botón o imagen para invocar el proceso de autenticación por Firma Digital (no incluir en automatico):
			Al presionar este botón se debe ejecutar el javascript:sbInvocarFirmaDigital()
		Incluir una función javascript sbPostFirmaDigital(ced,nom,apellidos) que se ejecuta despues del método de procesarXML:
			La ced y nom no son seguros pero sirven para adelantar mensajes
				(a modo de ejemplo se colocó:	alert(c+","+n);)
			Informacion segura se encuentra en la variable "session._FD_AUTENTICACION_"
				(
					a modo de ejemplo se colocó:	location.href="/prueba/login2.cfm?VER";
					para desplegar el contenido de "session._FD_AUTENTICACION_":
						<cfif isdefined("url.VER")>
							<cfdump var="#session._FD_Autenticacion_#" label="session._FD_Autenticacion_">
						</cfif>
				)
			OJO: Se debe colocar antes de invocar el pintarIframeSoloAutenticacion()
		
		session._FD_AUTENTICACION_
			Contiene la información del certificado de la FirmaDigital enviado por el java web start:
				Informacion del X509:
					X509SERIAL		446014913972730977375308133900745280571049862
					X509SUBJECT		CN=OSCAR ENRIQUE BONILLA CALDERON (AUTENTICACION), OU=CIUDADANO, O=PERSONA FISICA, C=CR, GIVENNAME=OSCAR ENRIQUE, SURNAME=BONILLA CALDERON, SERIALNUMBER=CPF-01-0688-0721
					X509ISSUER		CN=CA SINPE - PERSONA FISICA v2, OU=DIVISION SISTEMAS DE PAGO, O=BANCO CENTRAL DE COSTA RICA, C=CR, SERIALNUMBER=CPJ-4-000-004017 
				Informacion del Subject:
					SERIALNUMBER 	CPF-01-0688-0721
					CN 				OSCAR ENRIQUE BONILLA CALDERON (AUTENTICACION)
					GIVENNAME 		OSCAR ENRIQUE
					SURNAME 		BONILLA CALDERON
					O 				PERSONA FISICA
					OU 				CIUDADANO
					C 				CR

				Informacion Adicional:
					TKN 			1475265960020
					UID 			01-0688-0721 						(OJO: Esta es la Cédula de Persona Física con guiones)	
					NAME 			OSCAR ENRIQUE BONILLA CALDERON
					FORLOGON 		NO
--->

<!--- A modo de ejemplo al terminar el proceso se visualiza la información segura del certificado --->
<cfif isdefined("url.VER")>
	<cfdump var="#session._FD_Autenticacion_#" label="session._FD_Autenticacion_"><br>
</cfif>

<script>
	<!--- 
		Funcion javascript:sbPostFirmaDigital que se ejecuta automáticamente al finalizar el proceso de Autenticación
		para continuar con la siguiente pantalla a voluntad del programador (no ejecuta el proceso de Autorización ni Ingreso al Sistema)
		(debe ir antes del login.pintaIframeSoloAutenticacion)
	--->
	function sbPostFirmaDigital(ced,nom,apellidos)
	{
		alert(ced+","+nom+","+apellidos);
		<cfoutput>
		location.href="#getContextRoot()#/home/public/FirmaDigital/_doc/ejemplos/Ejemplo2_login2.cfm?VER";
		</cfoutput>
	}
</script>

<!--- Pinta 2 IFrames necesarios para download del jnlp del java web start, y para ejecutar javascript de monitoreo del java web start --->
<cfset createObject("component","home.public.FirmaDigital.plugin.login").pintaIframeSoloAutenticacion(
			false,			<!--- true=inicia automáticamente, false=requiere ejecutar función javascript:sbInvocarFirmaDigital() --->
			true			<!--- true=Visualiza el iframe para efectos de debug, false=iframe invisible para efectos de produccion --->
		)
>

<!--- Pinta boton para iniciar manualmente el proceso de autenticacion --->
<input type="button" value="Comprobar" onclick="javascript:sbInvocarFirmaDigital()">
