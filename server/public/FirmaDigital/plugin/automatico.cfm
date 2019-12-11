<cfparam name="cookie.FDjnlp" default="false">
<cfif isdefined("url.FDjnlp")>
	<cfcookie name="FDjnlp" value = "#url.FDjnlp#" expires="never">
	<cfabort>
</cfif>

<h1>Ejecución Automática de la FirmaDigital en Google Chrome</h1>
Los navegadores de internet tomaron la decisión de eliminar ciertas funcionalidades "peligrosas" de su browser, como son, flash, ActiveX y <strong>applets de Java</strong>.<br><br>
Como alternativa para los <strong>applets de Java</strong>, Oracle recomienda utilizar una tecnología llamada Java Web Start, que consiste en bajar un archivo con extensión .jnlp, que se ejecuta con un programa llamado Java Web Start (javaws), y toda la magia empieza a suceder.  Cabe mencionar que esta magia sucede en forma segura, puesto que el programa Java debe tener un certificado digital que comprueba la autenticidad de su autor y que el programa no ha sido cambiado por un tercero.<br><br>
Sin embargo, Google y otros fabricantes decide que los archivos .jnlp son peligrosos en su navegadores (Chrome, Firefox, Explorer), y obliga al usuario a confirmar que se baje este tipo de archivo y a eliminar la opción de ejecutar automáticamente el javaws para  estos archivos, de modo que cada vez que se baja un .jnlp, el usuario tiene que confirmar que sí lo desea bajar e indicarle manualmente que se abra el archivo.<br><br>
Hemos diseñado un procedimiento manual para ahorrarse estos dos pasos. Si usted está de acuerdo en ahorarse estos 2 pasos adicionales y engorrosos a la hora de utilizar su firma digital, nosotros le ayudamos a configurar su browser para su satisfacción.<br><br>
Si le da seguir le explicaremos el procedimiento para ahorrarse estos 2 pasos.<br><br>
Si le da cancelar seguirá confirmando el baje del archivo .jnlp y tendrá que seguir abriendolo en forma manual<br><br>

<input type="button" value="Continuar" onclick="document.getElementById('instrucciones').style.display = '';"> 
<input type="button" value="Regresar" onclick="window.history.back();">
<div id="instrucciones" style="display:none;";>
<br>
<h2>Configuración para bajar archivos con extensión .FDjnlp y se ejecute automáticamente con Java Web Star (javaws):</h2>
1. Baje el Archivo de pruebas.FDjnlp, presionando el siguiente botón: 
<input type="button" value="Download pruebas.FDjnlp" onclick="document.getElementById('FDjnlp').src = 'prueba_FDjnlp.cfm';">
<br>
2. Abrir siempre archivos de este tipo: en la parte inferior izquierda de Chrome aparece el archivo bajado (prueba.FDjnlp o prueba(xx).FDjnlp), presione el botón a la derecha del nombre para que aparezca un menú.  Ahí se escoge y se deja marcado "Abrir siempre archivos de este tipo"
<br>
3. Asociar extensiones .FDjnlp con Java Web Star (javaws): en el mismo menú a la derecha del nombre del archivo bajado:<br>
   a) si no se ha asociado antes, se puede escoger la opción "Abrir"<br>
	 b) si no se ha asociado antes, también puede escoger "Mostrar en carpeta" y en la carpeta escoger el archivo y con click derecho escoger "Abrir con..."<br>
	 c) si ya ha sido asociado, se debe escoger la opción "Mostrar en carpeta" y en la carpeta escoger el archivo y con click derecho escoger "Abrir con..." y "Seleccionar otra Aplicación"<br>
	 <li>Debe marcar la opción "Abrir siempre con esta aplicación"</li>
	 <li>Se debe escoger la aplicación "Java (TM) Web Star Launcher". Si no está escoja "Más Aplicaciones"</li>
	 <li>Se debe escoger la aplicación "Java (TM) Web Star Launcher". Si no está escoja "Buscar Más Aplicaciones en esta computadora"</li>
	 <li>Se debe buscar el programa: c:\Programs File\Java\jdk1.8...\bin\javaws.exe o c:\Programs File\Java\jre1.8...\bin\javaws.exe</li>
4. Prueba final, presionando el siguiente botón: 
<input type="button" value="Download pruebas.FDjnlp" onclick="document.getElementById('FDjnlp').src = 'prueba_FDjnlp.cfm';document.getElementById('resultado').style.display = '';">
<br>
<table id="resultado" style="display:none;">
<tr><td> </td><td>Resultado:</td><td> </td></tr>
<tr><td> </td><td> </td><td>Si se inició automáticamente el programa, presione:</td><td><input type="button" value="OK: seguir utilizando .FDjnlp" onclick="document.getElementById('FDjnlp').src = 'automatico.cfm?FDjnlp=1';"></td></tr>
<tr><td> </td><td> </td><td>Si el programa no comenzó como se esperaba, presione: </td><td><input type="button" value="Mantener .jnlp normal" onclick="document.getElementById('FDjnlp').src = 'automatico.cfm?FDjnlp=0';"></td></tr>
</div>
<iframe style="display:none;" id="FDjnlp" src=""></iframe>
