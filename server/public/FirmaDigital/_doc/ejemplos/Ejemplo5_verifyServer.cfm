Pantalla de prueba para Verificación de Documentos firmados, por el Servidor
<br><br>
<cfsetting requesttimeout="300000">
<!---
	La verificación de documentos firmados permite:
		Reutilización en el Servidor del jar de Verificación de documentos firmados 
		Verificar en el Servidor documentos firmados con un componente coldfusion
		Verificar remotamente documentos firmados con un WebService

	Servidor de Verificación:
		El jar de Verificación choca con los jar de Coldfusion, por tanto, se implementó un Servidor independiente de Sockets Multihilos que interactua con coldfusion:
		Configuración:
			En el Administrador de coldfusion se puede configurar 4 parámetros, que si no se configuran utiliza los defaults:
			Administrador de coldfusion --> Java and JVM --> JVM Arguments:
				-DFirmaDigital.jre8_home=<path al jre_home de java 8 o superior>	--> default=jre de coldfusion, configurar cuando coldfusion usa java 7 (coldfusion 10)
				-DFirmaDigital.host=<dirección del servidor>						--> default=localhost, si se cambia no se podría iniciar automáticamente
				-DFirmaDigital.puerto=<puerto del servidor>							--> default=9000, se debe cambiar sólo si el puerto 9000 ya está ocupado
				-DFirmaDigital.hilos=<cantidad de hilos para verificación>			--> default=5, para efectos de tunning
		Coldfusion lo inicia automáticamente (unicamente si #HOST#=localhost)
			#JRE8_HOME#\bin\java 
				 -cp #CF_HOME#\home\public/FirmaDigital\plugin\lib\FirmaDigitalServer.jar 
				 -Xms256m -Xmx1024m com.soin.firmaDigital.VerifyServer SRV #PUERTO# #HILOS#
		Coldfusion se comunica transparentemente con el Servidor de Verificación:
			s = java.net.Socket(#HOST#, #PUERTO#)
			s.println(operador)			--> ping, XML, PDF
			s.println(data)				--> "",   documento a verificar en base64
			r=s.read()					--> JSON con el resultado de la verificacion
			s.close()
			return deserializeJson(r)	--> return struct de coldfusion con el resultado de la verificacion

	Verificacion en el servidor:
		Componente:		home.public.FirmaDigital.plugin.verify
			Metodos para Verficar que el Servidor de Verificación está en línea
					ping()			
			Metodos para Verficar documentos PDF o XML y devuelve el resultado en estructura
				r=verifyFILE_struct("path de archivo")		--> Verifica Archivos PDF o XML guardados en el servidor
				r=verifyXML_struct(XML en texto)			--> Verifica documento XML enviado en texto
				r=verifyPDF_struct(PDF en binario)			--> Verifica documento PDF enviado en binario
				
				donde r es la siguiente estructura:
					Texto					--> Resultado en formato texto
												"Firmado por: OSCAR ENRIQUE BONILLA CALDERON (FIRMA), 2016-09-21 11:20:00 
													 Formato:   XAdES_BASELINE_LTA 
													 Resultado: TOTAL_FAILED
													 ERRORES:
														Error1
														Error2"
					Firmas[]				--> Array de struct de cada firma encontrada con el siguiente formato
						Fecha 				2016-09-21 11:20:00
						FirmadoPor 			OSCAR ENRIQUE BONILLA CALDERON (FIRMA)
						Formato 			XAdES_BASELINE_LTA
						Resultado 			TOTAL_FAILED
						ERRORES[]			--> Array con la lista de errores encontrados
											"error1"
											"error2"
						
			Metodos para Verficar documentos PDF o XML y devuelve el resultado únicamente en formato texto:
				r=verifyFILE("path de archivo")			--> Verifica Archivos PDF o XML guardados en el servidor
				r=verifyXML(XML en texto)				--> Verifica documento XML enviado en texto
				r=verifyPDF(PDF en binario)				--> Verifica documento PDF enviado en binario
		
				donde r es el Resultado en formato texto
						"Firmado por: OSCAR ENRIQUE BONILLA CALDERON (FIRMA), 2016-09-21 11:20:00 
							 Formato:   XAdES_BASELINE_LTA 
							 Resultado: TOTAL_PASSED"
						
	Verificacion remota por WebService
		WebService:		http://<ServidorCF>:<puerto>/<root>/home/public/FirmaDigital/plugin/verify.cfc?WSDL
			Metodos para Verficar documentos PDF o XML y devuelve el resultado únicamente en formato texto:
				r=WS.verifyXML(XML en texto)				--> Verifica documento XML enviado en texto
				r=WS.verifyPDF(PDF en binario)				--> Verifica documento PDF enviado en binario
		
				donde r es el Resultado en formato texto
						"Firmado por: OSCAR ENRIQUE BONILLA CALDERON (FIRMA), 2016-09-21 11:20:00 
							 Formato:   XAdES_BASELINE_LTA 
							 Resultado: TOTAL_PASSED"
--->

<cfset LvarOBJ = CreateObject("component","home.public.FirmaDigital.plugin.verify")>

<cfoutput>
=======================================================================<BR>
VERIFICACION EN EL SERVIDOR<BR>
=======================================================================<BR>
Metodos para Verficar que el Servidor de Verificación está en línea<BR>
Metodo ping()<BR>
#LvarOBJ.ping()#<BR>
<BR>
=======================================================================<BR>
Metodos para Verficar documentos PDF o XML y devuelve el resultado en estructura<BR>
Metodo verifyFILE_struct:<BR>
<cfdump var="#LvarOBJ.verifyFILE_struct("#expandPath("test_xml2_Signed.xml")#")#"><BR>
<cfdump var="#LvarOBJ.verifyFILE_struct("#expandPath("test_pdf1_Signed.pdf")#")#"><BR>
<BR>
Metodo verifyXML_struct:<BR>
<cffile action="read" file="#expandPath("test_xml1_Signed.xml")#" charset="utf-8" variable="LvarData1">
<cfdump var="#LvarOBJ.verifyXML_struct(LvarData1)#"><BR>
<BR>
Metodo verifyPDF_struct:<BR>
<cffile action="readBinary" file="#expandPath("test_pdf1_Signed.pdf")#" charset="utf-8" variable="LvarData2">
<cfdump var="#LvarOBJ.verifyPDF_struct(LvarData2)#"><BR>
<BR>
=======================================================================<BR>
Metodos para Verficar documentos PDF o XML y devuelve el resultado en TEXTO<BR>
Metodo verifyFILE:<BR>
<cfdump var="#LvarOBJ.verifyFILE("#expandPath("test_xml1_Signed.xml")#")#"><BR>
<cfdump var="#LvarOBJ.verifyFILE("#expandPath("test_pdf1_Signed.pdf")#")#"><BR>
<BR>
Metodo verifyXML:<BR>
<cffile action="read" file="#expandPath("test_xml1_Signed.xml")#" charset="utf-8" variable="LvarData1">
<cfdump var="#LvarOBJ.verifyXML(LvarData1)#"><BR>
<BR>
Metodo verifyPDF:<BR>
<cffile action="readBinary" file="#expandPath("test_pdf1_Signed.pdf")#" charset="utf-8" variable="LvarData2">
<cfdump var="#LvarOBJ.verifyPDF(LvarData2)#"><BR>
<BR>
=======================================================================<BR>
VERIFICACION REMOTA CON WebService<BR>
=======================================================================<BR>
WebService "http://localhost:8500/home/public/FirmaDigital/plugin/verify.cfc?WSDL":<BR>
Metodo verifyXML:<BR>
<cffile action="read" file="#expandPath("test_xml1_Signed.xml")#" charset="utf-8" variable="LvarData1">
<cfinvoke 	webservice=			"http://localhost:8500/home/public/FirmaDigital/plugin/verify.cfc?WSDL"
			method=				"verifyXML"
			XML=				"#LvarData1#"
			returnVariable = 	"LvarRES"
>
<cfdump var="#LvarRES#"><BR>
<BR>
<BR>
Metodo verifyPDF:<BR>
<cffile action="readBinary" file="#expandPath("test_pdf1_Signed.pdf")#" charset="utf-8" variable="LvarData2">
<cfinvoke 	webservice=			"http://localhost:8500/home/public/FirmaDigital/plugin/verify.cfc?WSDL"
			method=				"verifyPDF"
			PDF=				"#LvarData2#"
			returnVariable = 	"LvarRES"
>
<cfdump var="#LvarRES#"><BR>
<BR>
=======================================================================<BR>
FINAL<BR>
=======================================================================<BR>
</cfoutput>