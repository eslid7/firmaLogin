Este directorio contiene todos los ejemplos necesarios para utilizar firma digital:

Para Autenticacion y firma de Mensajes XML:
- Application.cfc:				incluye las 2 instrucciones que debe tener el Application para activar firma digital

Para Autenticacion, Autorización e ingreso al Sistema WEB:
- Ejemplo1_login1.cfm			pantalla de login

Para sólo Autenticación (comprobar la presencia del usuario):
- Ejemplo2_login2.cfm			pantalla de comprobacion de usuario

Firma de Mensajes XML:
- Ejemplo3_xml.cfc				componente para generar y para guardar XML
- Ejemplo3_signXML.cfm		pantalla final con datos a generar XML
- Ejemplo3_xml_array.cfc	componente para generar y para guardar array de XMLs
- Ejemplo3_signXMLs.cfm		pantalla final con datos a generar XMLs
- test_xml1.xml						ejemplo de un XML sin firmar
- test_xml1_Signed.xml		ejemplo de un XML generado con firma XAdES-BASELINE-LTA

Firma de Mensajes PDF:
- Ejemplo3_pdf.cfc				componente para generar y para guardar PDF
- Ejemplo3_signPDF.cfm		pantalla final con datos a generar PDF
- Ejemplo3_pdf_array.cfc	componente para generar y para guardar array de PDFs
- Ejemplo3_signPDFs.cfm		pantalla final con datos a generar PDFs
- pdf1.xml								ejemplo de un PDF sin firmar
- pdf1_Signed.xml					ejemplo de un PDF generado con firma PAdES-LTV

Firma de Documentos PDFs y Documentos XML y Verificación por el usuario:
- Ejemplo4_signDOC.cfm		pantalla de download para firma de Documentos y Verificacion de documentos firmados
- test_xml1.xml						ejemplo de un XML sin firmar
- test_xml1_Signed				ejemplo de un XML generado con firma XAdES-BASELINE-LTA
- test_pdf1.pdf						ejemplo de un PDF sin firmar
- test_pdf1_Signed.pdf		ejemplo de un PDF generado con firma PAdES-LTA

- pdf1.xml								ejemplo de un PDF sin firmar
- pdf1_Signed.xml					ejemplo de un PDF generado con firma PAdES-LTV
- xml1.xml								ejemplo de un XML sin firmar
- test_pdf1.pdf						ejemplo de un XML generado con firma XAdES-BASELINE-LTA

Verificación de documentos por el servidor:
- Ejemplo5_verifyServer.cfm	ejemplos del Componente y WebService de Verificacion en el Servidor
