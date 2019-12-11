<!---
	Componente libre Coldfusion para generar el PDF a firmar y procesar el PDF firmado:
		Método para generarPDF (nombre del método libre): 
			Parametros: 
				todos los necesarios para generar el PDF a firmar y procesar el PDF firmado
			Retornar el PDF a firmar en formato binario (binary o byte[] en java)
		Método para procesarPDF (nombre del método libre):
			Parámetros
				los mismos parámetros definidos para el método generarPDF más 2 adicionales:
					PDF: 		PDF firmado en formato texto (string)
					Cert509: 	información del certificado de la FirmaDigital enviado por el java web start:
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
			Retornar String con mensaje de exito o error (a discreción del programador). Este msg se enviara automaticamente al javascript:sbPostFirmaDigital()
				Exito: “OK”		
				Error: “cualquier otro texto”
--->
<cfcomponent>
	<cffunction name="genera" returntype="binary">
		<cfargument name="in">
		<cfargument name="out">
		
		<cffile action="readbinary" file="#Arguments.in#" variable="LvarPDF">
		<cfreturn LvarPDF>
	</cffunction>

	<cffunction name="procesa" returntype="string">
		<cfargument name="in">
		<cfargument name="out">

		<cfargument name="pdf">
		<cfargument name="Cert509">
		
		<cffile action="write" file="#Arguments.out#" output="#Arguments.PDF#" charset="utf-8">

		<cfreturn "OK">
	</cffunction>
</cfcomponent>