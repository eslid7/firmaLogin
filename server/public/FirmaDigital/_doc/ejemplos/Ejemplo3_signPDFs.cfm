Pantalla de prueba de firma de mensaje PDF
<br><br>

<!---
	Crear un componente libre Coldfusion para generar el PDF a firmar y procesar el PDF firmado
		Ver pdf.cfc para ejemplo
	En la pantalla donde ya se tiene los datos para generar el PDF (ejemplo, resumen en trámites):
		Pintar el IFrame con el componente “sign” para descargar el jnlp (JWS) y ejecutar el javascript  (JS)
			Componente:		home.public.FirmaDigital.plugin.sign
			Método:			pintaIframe	
			Parámetros
				automatico	type="boolean" 		true	= inicia la descarga automáticamente
												false	= se debe invocar javascript:sbInvocarFirmaDigital()
				componente	type="string"		nombre del componente
				generaMSG	type="string"		nombre del método que genera el PDF a firmar
				procesaMSG	type="string"		nombre del método que procesa el PDF firmado
				parametros	type="struct"		parámetros para las funciones generaMSG y procesaMSG
												{nombre1 = "valor1", nombre2 = "valor2", ...}
				pruebas		type="boolean"		true	= IFrame visible para debug
												false	= IFrame invisible para produccion
		Incluir un botón o imagen para invocar el proceso de Firma Digital (no incluir en automatico):
			Al presionar este botón se debe ejecutar el javascript:sbInvocarFirmaDigital()
		Incluir una función javascript sbPostFirmaDigital(ced,nom,apellidos,msg) que se ejecuta despues del método de procesarPDF:
			La ced y nom no son seguros pero sirven para enviar mensajes.   La información segura ya se procesó con procesaMSG, y si se quiere verificar el resultado, se hace con los parámetros de la función, o bien, prendiendo variables de session.
			Msg es el “mensaje de exito o error” retornado por el método procesarPDF definida en el componente de generación y procesamiento.  
			Msg debe indicar si el proceso fue exitoso, por ejemplo, si viene en “OK” o vacío
				Si msg indica que el proceso fue exitoso, debe programar en javascript la continuación con la siguiente pantalla
				Si msg indica que el proceso no fue exitoso, debe programar el manejo de error
			OJO: Se debe colocar antes de invocar el pintarIframe()
--->

<script>
	<!--- 
		Funcion javascript:sbPostFirmaDigital que se ejecuta automáticamente al finalizar todo el proceso de firma de mensaje PDF 
		(incluso después de ejecutar el metodo de procesarPDF), para continuar con la siguiente pantalla a voluntad del programador
		(debe ir antes del sign.pintaIframe)
	--->
	function sbPostFirmaDigital(ced,nom,apellidos,msg)
	{
		if (msg == "OK")
		{
			document.forms['form1'].action = "Resumen.sql";
			document.forms['form1'].submit();
		}
		else
			alert(ced + "," + nom + "," + apellidos + "," + msg);
	}
</script>
<!--- Pinta 3 IFrames necesarios para download del jnlp del java web start, y para ejecutar javascript de monitoreo del java web start --->
<cfset 	createObject("component","home.public.FirmaDigital.plugin.sign").pintaIframe(
			false,			<!--- true=inicia automáticamente, false=requiere ejecutar función javascript:sbInvocarFirmaDigital() --->

							<!--- nombre del componente específico para generar y procesar PDF --->
			"home.public.FirmaDigital._doc.ejemplos.Ejemplo3_pdf_array",	
			"genera", 		<!--- nombre del metodo en componente anterior para generarPDF --->
			"procesa", 		<!--- nombre del metodo en componente anterior para procesarPDF --->
							<!--- Parametros comunes para los metodos generaMSG y procesaMSG --->
			{in="#expandPath("test_pdf2.pdf")#",out="#expandPath("test_pdf2_Signed.pdf")#"},
			
			true,			<!--- true=Visualiza el iframe para efectos de debug, false=iframe invisible para efectos de produccion --->
			true,			<!--- true=Visualiza el boton <VER PDF> (recomendado), false=boton <VER PDF> invisible --->
			
			'PDF', 'Prueba de Firma de PDFs'
		)
>
<!--- Pinta boton para iniciar manualmente el proceso de firma de mensaje PDF --->
<input type="button" value="Firmar" onclick="javascript:sbInvocarFirmaDigital()">

<form name="form1" action="/">
</form>