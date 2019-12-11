Pantalla de prueba de Autenticacion e Ingreso al Sistema (Pantalla de Login)
<br><br>

<!---
	En la pantalla de Login
		Pueden o no existir los campos j_username y j_password y el boton de login para realizar el proceso tradicional de login
		El campo j_empresa es obligatorio (alias del CEcodigo o Cliente Empresarial)
		Pintar el IFrame con el componente “login” para descargar el jnlp (JWS) y ejecutar el javascript  (JS)
			Componente:		public.home.FirmaDigital.plugin.login
			Método:			pintaIframe	
			Parámetros
				automatico	type="boolean" 		true	= inicia la descarga automáticamente
												false	= se debe invocar javascript:sbInvocarFirmaDigital()
				pruebas		type="boolean"		true	= IFrame visible para debug
												false	= IFrame invisible para produccion
		Incluir un botón o imagen para invocar el proceso de autenticación por Firma Digital (no incluir en automatico):
			Al presionar este botón se debe ejecutar el javascript:sbInvocarFirmaDigital()
--->

<form>
Empresa:	<input name="j_empresa" 	id="j_empresa" value="soin"><br>
Usuario:	<input name="j_username"	id="j_username"><br>
Password:	<input name="j_password" 	id="j_password"><br>
</form>

<!--- Pinta 2 IFrames necesarios para download del jnlp del java web start, y para ejecutar javascript de monitoreo del java web start --->
<cfset createObject("component","home.public.FirmaDigital.plugin.login").pintaIframe(
			false,			<!--- true=inicia automáticamente, false=requiere ejecutar función javascript:sbInvocarFirmaDigital() --->
			true			<!--- true=Visualiza el iframe para efectos de debug, false=iframe invisible para efectos de produccion --->
		)
>
<!--- Pinta boton para iniciar manualmente el proceso de autenticacion --->
<input type="button" value="Login" onclick="javascript:sbInvocarFirmaDigital()">
<!--- Al finalizar el proceso automaticamente se redirije al root del sistema --->

<script>
	<!--- 
		Funcion javascript:sbPostFirmaDigital que se ejecuta automáticamente al finalizar el proceso de Autenticación
		para continuar con la siguiente pantalla a voluntad del programador (no ejecuta el proceso de Autorización ni Ingreso al Sistema)
		(debe ir antes del login.pintaIframeSoloAutenticacion)
	--->
	function sbPostFirmaDigital1(ced,nom,apellidos)
	{
		alert(ced+","+nom+","+apellidos);
		<cfoutput>
		location.href="#getContextRoot()#/home/public/FirmaDigital/_doc/ejemplos/Ejemplo2_login2.cfm?VER";
		</cfoutput>
	}
</script>
