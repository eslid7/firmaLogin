<!--- 
	Originalmente se bajaba el Firmador por JNLP:
		El FirmaDigital.jnlp se genera 2 veces:
			1. En un iframe de login.cfm, para realizar el download del jnlp (se indica enviando parámetro TKN1=<token>)
			2. Por el javaws, durante la ejecución del jnlp, porque existe un href para que vuelve a bajar el jnlp y no de errores de seguridad (se indica enviando parámetro TKN2=<token> y TKN3=<tkn3>)
	Posteriormente se bajaba el Instalador por JNLP:
		Se genera el ajax 
		Fuerza la logica del punto 2
	Actualmente se baja el Instalador como .jar
--->

<cfif IsDefined("url.TKN1")>
	<cfset LvarTOKEN=url.TKN1>
</cfif>
<cfset LvarChecksum = hash(fileReadBinary( expandPath( "lib/FirmaDigitalServer.jar" ) ), "MD5")>
<cfset LvarCodebase = createObject("component","home.public.FirmaDigital.plugin.cluster").getJNLP_Codebase()>

<cfset LvarInstallerTXT = expandPath("./lib/TMP_#getTickcount()#.txt")>
<cfset LvarInstallerZIP = expandPath("./lib/TMP_#getTickcount()#.zip")>
<cffile action="write"	file="#LvarInstallerTXT#" output="url=#LvarCodebase#"		addnewline="true">
<cffile action="append" file="#LvarInstallerTXT#" output="token=#LvarToken#"		addnewline="true">
<cffile action="append" file="#LvarInstallerTXT#" output="proceso=#url.proceso#" 	addnewline="true">
<cffile action="append" file="#LvarInstallerTXT#" output="checksum=#LvarChecksum#"	addnewline="true">

<cffile action="copy" source="#expandPath("./lib/FirmaDigitalInstaller.jar")#" destination="#LvarInstallerZIP#">
<cfzip
    action="delete"
    file="#LvarInstallerZIP#"
	entrypath="parametros.txt"
/>

<cfzip
    action="zip"
    file="#LvarInstallerZIP#"
>
    <cfzipparam
		source="#LvarInstallerTXT#"
		entrypath="parametros.txt"
        />
</cfzip>
<cffile action="delete" file="#LvarInstallerTXT#">

<cfheader name="Expires" value="0">
<cfheader name="Pragma" value="no-cache">
<cfheader name="Content-Disposition" value="attachment; filename=FirmaDigitalInstaller.jar">
<cfcontent type="application/java-archive" file="#LvarInstallerZIP#" deleteFile="yes">
