<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Registro Firma Digital</title>
<link rel="stylesheet" type="text/css" href="css/style.css">
</head>

<body>
<div class="contenedor">
  <h1>Autoregistro de FirmaDigital</h1>
  <h2>Asocia una nueva FirmaDigital a un Usuario ya existente en el Sistema</h2>
  <hr/>
  <cfoutput>
	<cf_dbfunction name="op_concat" returnVariable="_CON_">
  <cfquery name="rsCEalias" datasource="asp">
	select CEaliaslogin #_CON_# ' - ' #_CON_# CEnombre as alias
	  from CuentaEmpresarial
	 where CEaliaslogin = '#url.e#'
  </cfquery>
  <form method="post" action="login_FDauto_ok.cfm">
	  <table class="datosBD">
		<tbody>
		  <tr>
			<td><p><strong>C&eacute;dula:</strong></p></td>
			<td><p>#session._FD_Autenticacion_.UID#</p></td>
		  </tr>
		  <tr>
			<td><p><strong>Nombre:</strong></p></td>
			<td><p>#session._FD_Autenticacion_.NAME#</p></td>
		  </tr>
		  <tr>
			<td><p><strong>Empresa:</strong></p></td>
			<td nowrap><p>#rsCEalias.alias#</p></td>
			<input type="hidden" name="auto_CEalias" value="#url.e#">
		  </tr>
		</tbody>
	  </table>
	  <input type="text"		name="auto_UID" id="auto_UID" value="" autocomplete="off" placeholder="Usuario"/>
	  <input type="password" 	name="auto_PWD" id="auto_PWD" value="" autocomplete="off" placeholder="Contrase&ntilde;a"/>

	  <div class="botones">
		  <input type="submit" class="btnPrimario" 		value="REGISTRAR"	name="OK"		onclick="javascript:return sbRegistrar();"/>
		  <input type="button" class="btnSecundario" 	value="CANCELAR"	name="CANCELAR"	onclick="javascript:return sbCancelar();"/>
	  </div>
	  <div class="powerbySoin"></div>    
	</form>
	<script>
		window.setTimeout("sbLimpiar();",200);
		function sbLimpiar()
		{
			document.getElementById("auto_UID").value = "";
			document.getElementById("auto_PWD").value = "";
		}
		
		function sbRegistrar()
		{
			if (document.getElementById("auto_UID").value=="" || document.getElementById("auto_PWD").value=="")
			{
				alert ("Favor digitar Usuario y Contraseña");
				return false;
			}
			return true;
		}

		function sbCancelar()
		{
			location.href = "#cgi.CONTEXT_PATH#/";
			return true;
		}
	</script>
	</cfoutput>
</div>
</body>
</html>