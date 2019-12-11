Pantalla de prueba para download de la aplicación de<br>
Firma de Documentos PDFs y XMLs y<BR>
Verificación de Documentos firmados, por el Usuario
<br><br>

<!---
	En la pantalla de descarga de la aplicacion de Firma de Documentos PDF y XML y de Verificacioón de Documentos firmados:
		Pintar el IFrame con el componente “sign” para descargar el jnlp (JWS)
			Componente:		public.home.FirmaDigital.plugin.sign
			Método:			pintaIframeSignDoc
			Parámetros
				automatico	type="boolean" 		true	= inicia la descarga automáticamente
												false	= se debe invocar javascript:sbInvocarFirmaDigital()
				pruebas		type="boolean"		true	= IFrame visible para debug
												false	= IFrame invisible para produccion
		Incluir un botón o imagen para descargar la Firma Digital de Documentos (no incluir en automatico):
			Al presionar este botón se debe ejecutar el javascript:sbInvocarFirmaDigital()
--->

<!--- Pinta 1 IFrame para download del jnlp (no hay interaccion con el java web start) --->
<cfset 	createObject("component","home.public.FirmaDigital.plugin.sign").pintaIframeSignDoc(
			false,			<!--- true=inicia automáticamente, false=requiere ejecutar función javascript:sbInvocarFirmaDigital() --->
			true			<!--- true=Visualiza el iframe para efectos de debug, false=iframe invisible para efectos de produccion --->
		)
>
<!--- Pinta boton para iniciar manualmente el download de la aplicación --->
<input type="button" value="Bajar" onclick="javascript:sbInvocarFirmaDigital()">
