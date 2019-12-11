<cfif isdefined("form.Download")>
	<iframe src="test.cfm?download1" style="display:none;">
	</iframe>
	<cfset LvarFile = GetTempFile(GetTempDirectory(), "test")>
	<cffile action="write" output="#form.java#" file="#LvarFile#">
	<cffile action="APPEND" output="pause" file="#LvarFile#" addnewline="yes">
	<iframe src="test.cfm?download2=<cfoutput>#BinaryEncode(LvarFile.getBytes(),"hex")#</cfoutput>" style="display:none;">
	</iframe>
	<script>
		window.setTimeout("location.href='test.cfm';",500);
	</script>
<cfelseif isdefined("url.Download1")>
	<cfheader name="Content-Disposition" value="attachment; filename=FirmaDigitalTest.jar">
	<cfcontent type="application/java-archive" file="#expandPath('lib/FirmaDigitalTest.jar')#" deletefile="no" reset="yes">
<cfelseif isdefined("url.Download2")>
	<cfset LvarFile = BinaryDecode(url.Download2,"hex")>
	<cfset LvarFile = createObject("java", "java.lang.String").init(LvarFile)>
	<cfheader name="Content-Disposition" value="attachment; filename=FirmaDigitalTest.bat">
	<cfcontent type="application/x-batscript" file="#LvarFile#" deletefile="yes" reset="yes">
<cfelse>
	<form name="frmJava" method="post" action="test.cfm">
		<strong>Verifica la instalación y comunicación del Servicio de Firma Digital</strong><br>
		(Servidor Local, Servidor Remoto y Servidor SINPE)<br><br>
		1. Baje el programa de pruebas con el botón "Download"<br>
		2. Asegúrese de salvar (Save/Keep) los 2 archivos (FirmaDigitalTest.jar y FirmaDigitalTest.bat) y que ya hayan sido bajados<br>
		3. Ejecute el FirmaDigitalTest.bat (doble click sobre su nombre)<br>
		<input type="text" 	 name="java"		id="java" style="display:none;" onfocus="this.select();" readOnly><br><br>
		<input type="submit" name="Download"	value="Download">
	</form>
	<br>
	<script>
		LvarPort	= localStorage.getItem("FirmaDigitalServer.Port");
		if (LvarPort == null)
		{
		  LvarPort = "0";
		}

		LvarChecksum = "<cfoutput>#hash(fileReadBinary( expandPath( 'lib/FirmaDigitalServer.jar' ) ), 'MD5')#</cfoutput>";
		LvarWS = location.href.substr(0,location.href.indexOf("/home/public/FirmaDigital")) + "/home/public/FirmaDigital/plugin/login.cfc?METHOD=initTokenJWS&token=0";
		document.getElementById("java").value = "java -cp FirmaDigitalTest.jar -Djava.net.useSystemProxies=true com.soin.firmaDigital.Test " + LvarPort + " " + LvarChecksum + " \"" + LvarWS  + "\"";
	</script>
</cfif>
