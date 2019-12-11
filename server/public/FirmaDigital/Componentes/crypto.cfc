<cfcomponent>
	<!--- Rutinas de criptografía asimétrica RSA, de llave privada y llave pública --->
	<cfset GvarPrivateKey =
			"0E4F2549DCCEE9C00ED6C72ADF4DD5ACA97FD518D497DEB7C6DD2BAE86D95AD0D6A316C2CBDFC2F823ABFF45DDAD210DEB0ED117C809072DEF1EF85B16FF0CCE5FFDFFCBD7DA43AFC96F2FABA60921558D2CA5D1D9E1296A4B2AEADED9DA0FF7FBFE098AD49FEF285EA2A824502ED4E75AA9B9B8C4DB99AAF8CFD4FAB47FCED6B9A6DCE1EF3B0DB8A651B5F9C1B6B90E4B564FF88F3DF3DF7D03AECDF6C8CB64597608D4CC0AC8E99AC7D74CABD2D84BFBCC6D94A2FBBD5936CBC20FD0B9EA2266C7CC57CC754B98BB333CB6D6DCE8CE42E3C012BD9AD7DC7C8EC7AF2A0D84B588CFD3FA4FF8CDBF93CAC4C5FDFC74B8C680A38AA7CCD20E8BD5A7C8C6B8E47021050AA06CA4C4984110CAD7E388CD7BA5EB73D4C9598E89AE5EB6E5B783C8DFDCDC0DC4A9C2AE590C5BA1DDA6C5D7D451F9BB7AF6C1FED7E96EB41B300BD56DCC08CBE79A7EB6C8662ECCFDFFD9D746070F1AC7C3C0A6D4AEC9CCB03FC7C707F8A20A1A0EEE0FD77BFBF9C1C9D12CAF57F61B680DCACB5AC9DBCE4B64EDC9949AF8DE0EEBC70CBCEC2006A2BE16760C44B88ACA7BF4E754BB0E8DD5A05D8AC8B61792D0BF72A4A12E3C3D5DB8C80CBEB8B6DDCD8CF3FED121BAF05DC9F6E5F88C7FDD2A89F5A5C6CB95C4CBEFC02409B606D02D3F37306804E2059E0320532EF8D900E8D62BC5819A5BFE8C70701567AF4A23C0C9CF5CCBFC7D5ECFBB26EE1DDBCF70BEB25AD1BB9B9907CE110301B56A50F8CACCE502E8A132CA0CFE8CB0BC2950CADDC8DAA9DDBDBFAABA9B23AEB5B91E09C7DDB310BE0D5C527ECBCA76F9FA47DA8BEBD39FDFD1A7665CC99150A8A7C0406E84D9898D9BE3AEEDEDEFDF578AC681BBC6046C0C7DE624D49CD0B14D0780DABEF88CEA0F1FD2C42346E6AE75C692C87BA9CE99A7B553CE2C5FA5E053A4DBA60DA02DCACFEBCA9E2606CEC6EFA3C9BDFADEFB639EDAD384DF8E2B02BAD953BEA8EA6FC90FC7D99FA5C704C1AC8DC6792B09DFC6E217A455CD0FCE57B557FC74F9579EE8E1BAAAB8F80BF9DBFBFAC1EAFDE4A774CCB78B6DA676BBC9BA39D5CF65AAAFB6A7968FD94D0738A3AB576E9CA2C7D7EAA27ABF2FEB1B02D889D0FF6DC7B81CED7EECC198E549FFC9D503DD33E2C9D7CEEA8DE7D3CAE37763DC6BFAB0DC9BCCDD5BAABDD6E6B136885FC4C5CA7D2E9F88CAFD878FE5DFC611BB78DF9EDCBDD8AC07F20BF9559C5F813DFD4DA3B8CE8BFF0D4B8CEEA77CC2FCB0BDEED6C07BE79ABB86CF4CD0F1B8ACE69A70167CBD38FFC90EA6ABCF785C6DB998FCA28B5BF7A1CD7794CA00260A2449CA7C03B2FF7D5A1ED8FD7DAC57AC29ABCEB5CD8D6AA2BFDE892FE8CC108D5BD40AE71FCECBBEB88B7ECECA4C640A8912C9E84AD02B74FBC1D5FBC1722F2FEB8B17E6F1759AB0C9AF1C0FAFC508D4DCEF0EE8CFDA20F58CBEDAD699780BA90AF5D4ED7FBA09C2BE889CE9C78D8AB7BC89AFFE58C02BDE30E91DFBCCAA2D5C8D0BABB9C3DA80CC54ABBCFCC2A607C463067C89DA14DB4ACB01EB65C3EDE2D5D0ABE2ED6893FB8C77ADDFEAEA5DDE3FBC24F718C49DFE040B0CF9A0D8AA80DD1B74D84BDF0869BE05CE02AC6FB1CCDACE17C3CEC2CDCECD9201BA9E7FFA1F76BD789910B10EB2ECAEFFCA908AE50E4CD96E4EB9CCC72BFAE9B14F0DCBDE0C4828FEE9BDD1D70FC6E3247BCBED94F2FAC6B9B25064C607BB5CBD71C4C1554BF8BC4AC4B386C422CA70F9F8ABD8AEFCAC05AB51D5028EA8DBB08A99CBBC7E00EFAE78CD029DE9FAF86BDA27AD6F2F0DCAF205CFCC85C9F8B7">
	<cfset GvarPublicKey =
			"30819F300D06092A864886F70D010101050003818D0030818902818100949083B3B608652449751921062B437D3AE7205DFF72F07007C699FA284F2D95C57AF90E54BBE6F0C2914CDE713E15C082D43025FFE4FBE8914E19B31A7B0AFDBE0F416594DC3EB940163F4155324A78760CBC36EDC159E3A30ACCF6595B2A86189B4FB2F32EBEC2E2E57B0517F1CB5E33A301B7DA82702EA0E9233458C0D7A50203010001">

	<cffunction name="RSA_generateKeyPair" access="remote" returntype="any" output="false">
		<!--- Get the Bouncy Castle Asymmetric Key Generator --->
		<cfset createObject('java', 'java.security.Security')
					.addProvider(createObject('java', 'org.bouncycastle.jce.provider.BouncyCastleProvider').init()) />
		<!--- Get an instance of the provider for the RSA algorithm. --->
        <cfset kpg = createObject('java', 'java.security.KeyPairGenerator').getInstance("RSA", "BC")>
		<!--- Initialize the generator by passing in the size of key we want, and a strong pseudo-random number generator (PRNG) --->
        <cfset kpg.initialize(1024)>
		<!--- This will create two keys, one public, and one private --->
        <cfset kp = kpg.generateKeyPair()>

		<!--- Get the two keys. --->
		<cfset LvarKeys = structNew()>
		<cfset LvarKeys.privateKey	= binaryEncode(kp.getPrivate().getEncoded(),"hex") />
		<cfset LvarKeys.publicKey	= binaryEncode(kp.getPublic().getEncoded() ,"hex") />
		<cfreturn LvarKeys>
	</cffunction>

	<cffunction name="RSA_Encrypt" hint="encrypts a text-string with RSA to a HEX encoded string" access="public" returntype="string" output="false">
		<cfargument name="text" type="string" required="true" hint="plain input text-string" />
		<cfreturn RSA_Encrypt_key (text,RSA_GetPrivateKey()) />
	</cffunction>

	<cffunction name="RSA_Encrypt_key" hint="encrypts a text-string with RSA to a HEX encoded string" access="public" returntype="string" output="false">
		<cfargument name="text" type="string" required="true" hint="plain input text-string" />
		<cfargument name="key" type="any" required="true"  hint="publicKey or privateKey (not in HEX)" />
		<cfscript>
			var local = structNew();
			local.text = Arguments.text;
			// Get the Bouncy Castle Asymmetric Key Generator
			createObject('java', 'java.security.Security')
					.addProvider(createObject('java', 'org.bouncycastle.jce.provider.BouncyCastleProvider').init());

                local.e = createObject('java', 'org.bouncycastle.crypto.engines.RSAEngine').init();
                local.e = createObject('java', 'org.bouncycastle.crypto.encodings.PKCS1Encoding').init(local.e);
                local.e.init(true, key);

                local.messageBytes = local.text.getBytes();
                local.encrypted = local.e.processBlock(local.messageBytes, 0, arrayLen(local.messageBytes));

			/* Convert binary to HEX encoded string */
            return binaryEncode(local.encrypted,"hex");
		</cfscript>
	</cffunction>

	<cffunction name="RSA_Decrypt" hint="decrypts a HEX encoded string with RSA to its value" access="public" returntype="string" output="false">
		<cfargument name="textHex" type="string" required="true" hint="the encrypted value as HEX encoded string" />
		<cfreturn RSA_Decrypt_key (textHex, RSA_GetPrivateKey()) />
	</cffunction>

	<cffunction name="RSA_Decrypt_key" hint="decrypts a HEX encoded string with RSA to its value" access="public" returntype="string" output="false">
		<cfargument name="textHex" type="string" required="true" hint="the encrypted value as HEX encoded string" />
		<cfargument name="key" type="any" required="true"  hint="publicKey or privateKey (not in HEX)" />
		<cfscript>
			var local = structNew();
			// Get the Bouncy Castle Asymmetric Key Generator
			createObject('java', 'java.security.Security')
					.addProvider(createObject('java', 'org.bouncycastle.jce.provider.BouncyCastleProvider').init());

                local.e = createObject('java', 'org.bouncycastle.crypto.engines.RSAEngine').init();
                local.e = createObject('java', 'org.bouncycastle.crypto.encodings.PKCS1Encoding').init(local.e);
                local.e.init(false, key);

                local.messageBytes = binaryDecode(arguments.textHex,"hex");
                local.decrypted = local.e.processBlock(local.messageBytes, 0, arrayLen(local.messageBytes));

			/* Convert binary to HEX encoded string */
			return toString(local.decrypted,"UTF-8");
		</cfscript>
	</cffunction>

	<cffunction name="RSA_GetPublicKey" access="public" returntype="any" output="false">
		<cfargument name="keyHex" type="string" default="#GvarPublicKey#" />

		<cfreturn createObject('java', 'org.bouncycastle.crypto.util.PublicKeyFactory').createKey(binaryDecode(arguments.keyHex,"hex")) />
	</cffunction>

	<cffunction name="RSA_GetPrivateKey" access="public" returntype="any" output="false">
		<cfargument name="keyHex" type="string" default="#GvarPrivateKey#" />

		<cfif arguments.keyHex EQ GvarPrivateKey>
			<cfset arguments.keyHex = decrypt(arguments.keyHex,"asp" & "3.14159265359","CFMX_COMPAT","Hex")>
		</cfif>

		<cfreturn createObject('java', 'org.bouncycastle.crypto.util.PrivateKeyFactory').createKey(binaryDecode(arguments.keyHex,"hex")) />
	</cffunction>

	<!--- Rutinas de criptografía simétrica AES, de llave secreta --->
	<cffunction name="AES_EncryptToHex" hint="encrypts a text-string with RSA to a HEX encoded string" access="public" returntype="string" output="false">
		<cfargument name="text" type="string" required="true" hint="plain input text-string" />
		<cfargument name="keyHex" 	type="string" required="true" hint="secretKey in HEX" />

		<cfreturn binaryEncode(AES_EncryptToBin(text,keyHex),"hex")>
	</cffunction>

	<cffunction name="AES_EncryptToBase64" hint="encrypts a text-string with RSA to a HEX encoded string" access="public" returntype="string" output="false">
		<cfargument name="text" type="string" required="true" hint="plain input text-string" />
		<cfargument name="keyHex" 	type="string" required="true" hint="secretKey in HEX" />

		<cfreturn binaryEncode(AES_EncryptToBin(text,keyHex),"base64")>
	</cffunction>

	<cffunction name="AES_EncryptToBin" hint="encrypts a text-string with RSA to a HEX encoded string" access="public" returntype="any" output="false">
		<cfargument name="text" type="string" required="true" hint="plain input text-string" />
		<cfargument name="keyHex" 	type="string" required="true" hint="secretKey in HEX" />
		<cfscript>
			var local = structNew();
				/* Create a Java Cipher object and get a mode */
				local.cipher = createObject('java', 'javax.crypto.Cipher').getInstance("AES");

				/* Get the SecretKey from HEX */
				local.bs = binaryDecode(arguments.keyHex,"hex");
				local.sk = createObject('java', 'javax.crypto.spec.SecretKeySpec').init(local.bs, 0, arrayLen(local.bs), "AES");

				/* Initialize the Cipher with the mode and the key */
				local.cipher.init(cipher.ENCRYPT_MODE, local.sk);

				/* Perform encryption of bytes, returns binary */
				local.encrypted = cipher.doFinal(arguments.text.getBytes("UTF-8"));

			/* Convert binary to HEX encoded string */
	  		return local.encrypted;
		</cfscript>
	</cffunction>

	<cffunction name="AES_DecryptFromHex" hint="decrypts a HEX encoded string with RSA to its value" access="public" returntype="string" output="false">
		<cfargument name="textHex" 	type="string" required="true" hint="the encrypted value as HEX encoded string" />
		<cfargument name="keyHex" 	type="string" required="true" hint="secretKey in HEX" />

		<cfreturn AES_DecryptFromBin(binaryDecode(arguments.textHex,"hex"), keyHex)>
	</cffunction>

	<cffunction name="AES_DecryptFromBase64" hint="decrypts a HEX encoded string with RSA to its value" access="public" returntype="string" output="false">
		<cfargument name="text64" 	type="string" required="true" hint="the encrypted value as Base64 encoded string" />
		<cfargument name="keyHex" 	type="string" required="true" hint="secretKey in HEX" />

		<cfreturn AES_DecryptFromBin(binaryDecode(arguments.text64,"base64"), keyHex)>
	</cffunction>

	<cffunction name="AES_DecryptFromBin" hint="decrypts a HEX encoded string with RSA to its value" access="public" returntype="string" output="false">
		<cfargument name="encrypted"	type="any" required="true" hint="the encrypted value as byte[]" />
		<cfargument name="keyHex"		type="string" required="true" hint="secretKey in HEX" />
		<cfscript>
			var local = structNew();
				/* Create a Java Cipher object and get a mode */
				local.cipher = createObject('java', 'javax.crypto.Cipher').getInstance("AES");

				/* Get the SecretKey from HEX */
				local.bs = binaryDecode(arguments.keyHex,"hex");
				local.sk = createObject('java', 'javax.crypto.spec.SecretKeySpec').init(local.bs, 0, arrayLen(local.bs), "AES");

				/* Initialize the cipher with the mode and the key */
				local.cipher.init(cipher.DECRYPT_MODE, local.sk);

				/* Perofrm the decryption */
				local.decrypted = local.cipher.doFinal(encrypted);

			/* Convert the bytes back to a string and return it */
			return toString(local.decrypted,"UTF-8");
		</cfscript>
	</cffunction>

	<cffunction name="AES_generateSecretKey" hint="decrypts a HEX encoded string with RSA to its value" access="public" returntype="string" output="false">
        <cfset keyGen = createObject('java', 'javax.crypto.KeyGenerator').getInstance("AES")>
        <cfset keyGen.init(128)>
        <cfreturn binaryEncode(keyGen.generateKey().getEncoded(),"hex")>
	</cffunction>

	<cffunction name="DES_EncryptWithPassword" hint="encrypts a text-string with DES and password to a HEX encoded string" access="public" returntype="any" output="false">
		<cfargument name="text" 		type="string" required="true" hint="plain input text-string" />
		<cfargument name="password" type="string" required="true" hint="secretKey in HEX" />
		<cfscript>
			var local = structNew();
			/* Create a Java Cipher object and get a mode */
			local.cipher = createObject('java', 'javax.crypto.Cipher').getInstance("PBEWithMD5AndDES");

			/* Genera el salt */
			local.s = right("12345678" & arguments.password, 8).getBytes("UTF-8");
			/* Get the SecretKey from String Password */
			local.ps = createObject('java', 'javax.crypto.spec.PBEParameterSpec').init(local.s, local.s[7]);
			local.ks = createObject('java', 'javax.crypto.spec.PBEKeySpec').init(password.toCharArray());
			local.kf = createObject('java', 'javax.crypto.SecretKeyFactory').getInstance("PBEWithMD5AndDES");
			local.sk = local.kf.generateSecret(local.ks);

			/* Initialize the Cipher with the mode and the key */
			local.cipher.init(local.cipher.ENCRYPT_MODE, local.sk, local.ps);

			/* Perform encryption of bytes, returns binary */
			local.encrypted = cipher.doFinal(arguments.text.getBytes("UTF-8"));

			/* Convert binary to HEX encoded string */
			return binaryEncode(local.encrypted,"hex");
		</cfscript>
	</cffunction>

	<cffunction name="AES_DecryptWithPassword" hint="decrypts a HEX encoded string with DES and password to its value" access="public" returntype="string" output="false">
		<cfargument name="textHex"		type="string" required="true" hint="the encrypted value as HEX encoded string" />
		<cfargument name="password"		type="string" required="true" hint="secretKey in HEX" />
		<cfscript>
			var local = structNew();
			/* Create a Java Cipher object and get a mode */
			local.cipher = createObject('java', 'javax.crypto.Cipher').getInstance("PBEWithMD5AndDES");

			/* Genera el salt */
			local.s = right("12345678" & arguments.password, 8).getBytes("UTF-8");
			/* Get the SecretKey from String Password */
			local.ps = createObject('java', 'javax.crypto.spec.PBEParameterSpec').init(local.s, local.s[7]);
			local.ks = createObject('java', 'javax.crypto.spec.PBEKeySpec').init(password.toCharArray());
			local.kf = createObject('java', 'javax.crypto.SecretKeyFactory').getInstance("PBEWithMD5AndDES");
			local.sk = local.kf.generateSecret(local.ks);

			/* Initialize the cipher with the mode and the key */
			local.cipher.init(local.cipher.DECRYPT_MODE, local.sk, local.ps);

			/* Perofrm the decryption */
			local.decrypted = local.cipher.doFinal(binaryDecode(arguments.textHex,"hex"));

			/* Convert the bytes back to a string and return it */
			return toString(local.decrypted,"UTF-8");
		</cfscript>
	</cffunction>

	<!--- Rutinas de compresión y descompresión de datos --->
	<cffunction name="ZIP_compressTXT" hint="compress a byte[] to base64" access="public" returntype="string" output="false">
		<cfargument name="text" type="string" required="true" hint="plain input text-string" />

		<cfreturn ZIP_compressBIN(text.getBytes("UTF-8"))>
	</cffunction>

	<cffunction name="ZIP_compressBIN" hint="compress a byte[] to base64" access="public" returntype="string" output="false">
		<cfargument name="bin" type="any" required="true" hint="byte[] input" />

        <cftry>
			<cfset LvarBIS = createObject("java","java.io.ByteArrayInputStream").init(Arguments.bin)>
			<cfset LvarBOS = createObject("java","java.io.ByteArrayOutputStream").init()>
			<cfset LvarGOS = createObject("java","java.util.zip.GZIPOutputStream").init(LvarBOS)>

			<!---
			<cfset LvarGOS.write(Arguments.bin)>
			--->

			<cfset LvarBuffer = RepeatString(" ", 8192).getBytes()>
			<cfset LvarBytesN = LvarBIS.read(LvarBuffer,0,8192)>
			<cfloop condition="LvarBytesN GTE 0">
				<cfset LvarGOS.write(LvarBuffer, 0, LvarBytesN)>
				<cfset LvarBytesN = LvarBIS.read(LvarBuffer,0,8192)>
			</cfloop>

			<cfset LvarGOS.flush()>
			<cfset LvarGOS.close()>
			<cfset LvarGOS = javacast("null",0)>

			<cfset LvarCompressed = LvarBOS.toByteArray()>

			<cfset LvarBOS.close()>
			<cfset LvarBOS = javacast("null",0)>

			<cfreturn BinaryEncode(LvarCompressed,"base64")>
		<cfcatch type="any">
			<cfif isdefined("LvarGOS")>
				<cfset LvarGOS.close()>
			</cfif>
			<cfif isdefined("LvarBOS")>
				<cfset LvarBOS.close()>
			</cfif>
			<cfrethrow>
		</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="ZIP_decompressToTXT" hint="compress a byte[] to base64" access="public" returntype="string" output="false">
		<cfargument name="base64" type="string" required="true" hint="base64 input text-string" />

        <cfset LvarDecompressed = ZIP_decompressToBIN(base64)>
		<cfreturn createObject("java","java.lang.String").init(LvarDecompressed, "UTF-8")>
	</cffunction>

	<cffunction name="ZIP_decompressToBIN" hint="decompress a base64 to byte[]" access="public" returntype="any" output="false">
		<cfargument name="base64" type="string" required="true" hint="base64 input text-string" />

        <cftry>
			<cfset LvarCompressed = BinaryDecode(base64,"base64")>

			<cfset LvarBIS = createObject("java","java.io.ByteArrayInputStream").init(LvarCompressed)>
			<cfset LvarGIS = createObject("java","java.util.zip.GZIPInputStream").init(LvarBIS)>
			<cfset LvarBOS = createObject("java","java.io.ByteArrayOutputStream").init()>

			<cfset LvarBuffer = RepeatString(" ", 4096).getBytes()>
			<cfset LvarBytesN = LvarGIS.read(LvarBuffer,0,4096)>
			<cfloop condition="LvarBytesN NEQ -1">
				<cfset LvarBOS.write(LvarBuffer, 0, LvarBytesN)>
				<cfset LvarBytesN = LvarGIS.read(LvarBuffer,0,4096)>
			</cfloop>

			<cfset LvarGIS.close()>
			<cfset LvarGIS = javacast("null",0)>

			<cfset LvarDecompressed = LvarBOS.toByteArray()>

			<cfset LvarBOS.close()>
			<cfset LvarBOS = javacast("null",0)>
			<cfset LvarBIS.close()>
			<cfset LvarBIS = javacast("null",0)>

			<cfreturn LvarDecompressed>
		<cfcatch type="any">
			<cfif isdefined("LvarBOS")>
				<cfset LvarBOS.close()>
			</cfif>
			<cfif isdefined("LvarGIS")>
				<cfset LvarGIS.close()>
			</cfif>
			<cfif isdefined("LvarBIS")>
				<cfset LvarBIS.close()>
			</cfif>
			<cfrethrow>
		</cfcatch>
		</cftry>
	</cffunction>

	<!--- Rutinas de Verificación de Certificados X509 --->

	<!---
		validaCert:
			Valida Certificado del CA Emisor:
				El CA Emisor debe ser de SINPE
				El archivo CRT del Certificado del CA Emisor debe estar almacenado manualmente en el repositorio local de certificados de confianza
			Valida Certificado del Usuario:
				Valida la vigencia del certificado
				Valida la validez del certificad (que la firma del certificado pertenezca al emisor)
				Valida la revocación del certificado por OCSP, y si no por CRL local
	--->
	<cffunction name="validaCert" returnType="struct">
    	<cfargument name="CertUsr_X509" type="string">

		<cftry>
			<cfset Paso = "Cargando Biblioteca Java para manejo de certificados" >
			<cfset JvarCert = createObject('java', 'ocspvalidador.Certificate')>
			<cfset Paso = "Obteniendo URLs del Certificado" >
			<!--- Obtiene el URLs: OCSP, CRT, CRL --->
			<cfset LvarUrls	= JvarCert.getUrls(CertUsr_X509)>
			<cfset LvarOCSP	= LvarUrls[1]>
			<cfset LvarCRT	= LvarUrls[2]>
			<cfset LvarCRLs	= LvarUrls[3]>

			<cfset Paso = "Verificación del Certificado del CA Emisor">
			<!--- Verifica y obtiene el Certificado del CA Emisor del Repositorio local de Certificados --->
			<cfset LvarCertEmsr_X509 = getCertEmsr_X509(LvarCRT)>

			<cfset Paso = "Verificando Certificado del Usuario con Certificado del CA Emisor">
			<!--- Verificar el Certificado del Usuario, con el Certificado del Emisor --->
			<cfset JvarCert.validate (arguments.CertUsr_X509, LvarCertEmsr_X509)>

			<cfset Paso = "">

			<!--- Verifica el url del OCSP (Solo se permite de SINPE) --->
			<cfif NOT JvarCert.isUrlFromSINPE(LvarOCSP)>
				<cfthrow message="Servidor OCSP no pertenece a SINPE: #LvarOCSP#">
			</cfif>

			<cfset Paso = "OCSP">
			<!--- Verfica la Revocacion por medio de OCSP --->
			<cfset LvarRespuesta = validaOCSP(arguments.CertUsr_X509, LvarCertEmsr_X509, LvarOCSP)>
			<cfif LvarRespuesta.num EQ 1>
				<cfset LvarRespuesta.msg = "ERROR OCSP: El certificado se encuentra revocado">
			</cfif>
		<cfcatch type="any">
			<cfset LvarRespuesta = structNew()>
			<cfset LvarRespuesta.num = -1>
			<cfset LvarRespuesta.msg = "ERROR #Paso#: #cfcatch.message#">
			<cfif Paso EQ "OCSP">
				<cfset Paso = "CRL">
				<cftry>
					<cfset LvarErroresFile = expandPath("/home/public/FirmaDigital/crls/erroresOCSP.txt")>
					<cfif fileExists(LvarErroresFile) AND GetFileInfo(LvarErroresFile).size GT 102400>
						<cffile action="write"
							file="#LvarErroresFile#"
							output="Reinicio #now()#"
							addNewLine = "yes"
						>
					</cfif>
					<cffile action="append"
						file="#LvarErroresFile#"
						output="OCSP #LvarOCSP#,#dateFormat(now(),"YYYY-MM-DD")# #timeFormat(now(),"HH:MM:SS")#,#cfcatch.message#"
						addNewLine = "yes"
					>
				<cfcatch type="any">
				</cfcatch>
				</cftry>
				<!--- Verfica la Revocacion por medio de CRL: Lista de archivos separados por comma de CRL --->
				<cfset LvarRespuesta = validaCRLs(arguments.CertUsr_X509, LvarCRLs)>
			</cfif>
		</cfcatch>
		</cftry>
		<cfreturn LvarRespuesta>
	</cffunction>

	<!---
		getCertEmsr_X509:
			Obtiene el certificado X509 de la Autoridad CA emisor del Certificado
				Verifica que el url pertenezca al SINPE
				Verifica que el Certificado esté almacenado en el repositorio local de Certificados
				Convierte el archivo CA crt en un certificado X509
	--->
	<cffunction name="getCertEmsr_X509" returnType="any" access="public">
    	<cfargument name="urlCRT"	type="string">
    	<cfargument name="tipo"		type="string" default="X509">

		<cfparam name="JvarCert" default="#createObject('java', 'ocspvalidador.Certificate')#">

		<!--- Verifica el url del Certificado del CA Emisor (Solo se permite de SINPE) --->
		<cfif NOT JvarCert.isUrlFromSINPE(arguments.urlCRT)>
			<cfthrow message="Certificado del CA Emisor no pertenece a SINPE: #arguments.urlCRT#">
		</cfif>

		<!--- Verifica que el Certificado del CA Emisor esté almacenado localmente ---->
		<cfset LvarCertEmsr_filename = getFileFromUrl("/home/public/FirmaDigital/crts/", arguments.urlCRT)>
		<cfif NOT fileExists(LvarCertEmsr_filename)>
			<cfthrow message="Certificado del CA Emisor de SINPE no se encuentra en repositorio local de Certificados de Autoridades Certificadoras: #arguments.urlCRT#">
		</cfif>

		<cfset Paso = "Leyendo Certificado del CA Emisor local">
		<!--- Obtiene el X509Certificate del Certificado del CA Emisor --->
		<cfset JvarCACert = JvarCert.getCertificateFromFile(LvarCertEmsr_filename)>

		<cfif arguments.tipo EQ "HEX">
			<cfreturn binaryEncode(JvarCACert.getEncoded(),"hex")>
		<cfelse>
			<cfreturn JvarCACert>
		</cfif>
	</cffunction>

	<!---
		validaOCSP:
			Valida la Revocación del Certificado en linea por OCPS
	--->
	<cffunction name="validaOCSP" access="public" returntype="any">
    	<cfargument name="CertUsr_X509"		type="any" >
        <cfargument name="CertEmsr_X509"	type="any" >
        <cfargument name="urlOCSP"			type="string" >

		<cfset JvarValidator = createObject('java', 'ocspvalidador.ValidationOCSP').init(urlOCSP)>
		<cfset JvarRespuesta = JvarValidator.validateCert(arguments.CertUsr_X509, arguments.CertEmsr_X509)>

		<cfset LvarRespuesta.num = JvarRespuesta.getNroRespuesta()>
		<cfif LvarRespuesta.num EQ 0>
			<cfset LvarRespuesta.msg = "OK">
		<cfelse>
			<cfset LvarRespuesta.msg = JvarRespuesta.getMensajeRespuesta()>
			<cflog file="crypto" text="validaOCSP: Error al validar el certificado #LvarRespuesta.msg#">	
		</cfif>

		<cfreturn LvarRespuesta>
	</cffunction>

    <cffunction name="validaCRLs" access="public" returntype="struct">
    	<cfargument name="CertUsr_X509"	type="any" >
      <cfargument name="CRLs"			type="string" >

		<cfset var LvarRespuesta = structNew()>

		<cfloop list="#Arguments.CRLs#" index="LvarCRL">
			<!--- Verifica el url del CRL (Solo se permite de SINPE) --->
			<cfif NOT JvarCert.isUrlFromSINPE(LvarCRL)>
				<cfset LvarRespuesta.num = -2>
				<cfset LvarRespuesta.msg = "Archivo CRL no pertenece a SINPE: #LvarCRL#">
			<cfelse>
				<!--- Verifica existencia y actualizacion del archivo y el contenido del archivo CRL (Lista de Certificados Revocados) ---->
				<cfset LvarCRL_filename = getFileFromUrl("/home/public/FirmaDigital/crls/", LvarCRL)>
				<cflock name="CRL" timeout="10">
					<cfif NOT fileExists(LvarCRL_filename)>
						<cftry>
							<cffile action="readbinary"	file="#LvarCRL#"			variable="LvarBIN">
							<cffile action="write"		file="#LvarCRL_filename#"	output ="#LvarBIN#">
							<cffile action="append"		file="#expandPath("/home/public/FirmaDigital/crls/lista.txt")#"	output="#LvarCRL#" addNewLine = "yes">
						<cfcatch type="any">
							<cfset LvarRespuesta.num = -2>
							<cfset LvarRespuesta.msg = "ERROR: Archivo CRL de SINPE no se pudo bajar al repositorio local de Certificados de Autoridades Autorizadoras: #cfcatch.message#, #LvarCRL#">
						</cfcatch>
						</cftry>
					</cfif>

					<cfif NOT fileExists(LvarCRL_filename)>
						<cfbreak>
						<cfset LvarRespuesta.num = -2>
						<cfset LvarRespuesta.msg = "ERROR: Archivo CRL de SINPE no se encuentra en repositorio local de Certificados de Autoridades Autorizadoras: #LvarCRL#">
					<cfelseif abs(DateDiff("n",GetFileInfo(LvarCRL_filename).Lastmodified,now())) GT 20>
						<cfset LvarRespuesta.num = -2>
						<cfset LvarRespuesta.msg = "ERROR: Archivo CRL de SINPE no se ha actualizado en repositorio local de Certificados de Autoridades Autorizadoras: #LvarCRL#">
					<cfelseif createObject('java', 'CRLValidador.RevokedCRL').RevokedByCert(arguments.CertUsr_X509, LvarCRL_filename)>
						<cfset LvarRespuesta.num = 1>
						<cfset LvarRespuesta.msg = "ERROR CRL: El certificado se encuentra revocado">
					<cfelse>
						<cfset LvarRespuesta.num = 0>
						<cfset LvarRespuesta.msg = "OK">
					</cfif>
				</cflock>
			</cfif>

			<cfif LvarRespuesta.num NEQ 0>
				<cfbreak>
			</cfif>
		</cfloop>

        <cfreturn LvarRespuesta>
	</cffunction>

	<!---
		actualizaCRLs:
			Se trae la lista de archivos CRLs cada 10 minutos
	--->
	<cffunction name="actualizaCRLs" access="public" returntype="void">
		<cfset BR = "<br>#chr(13)##chr(10)#">
		<cfoutput>Inicio actualizaCRLs: #now()##BR#</cfoutput>

		<!--- Verifica si hay que crear la tarea Automática 'FirmaDigital CRL download' unicamente la primera vez que inicia la aplicación --->
		<cfset LvarCrear = false>
		<cfif NOT isdefined("server.FirmaDigital_CRL")>
			<cfschedule
				action		= "list"
				result		= "rsSCHDL"
			>
			<cfquery dbtype="query" name="rsSCHDL">
				select count(1) as cantidad from rsSCHDL where Task = 'FirmaDigital CRL download'
			</cfquery>
			<cfset LvarCrear = (rsSCHDL.cantidad EQ 0 OR rsSCHDL.cantidad EQ "")>
		</cfif>

		<cfif LvarCrear>
			<cfset LvarSRV = "localhost:#GetPageContext().GetRequest().GetLocalPort()##getContextRoot()#">

			<cfschedule
				action		= "update"
				task			= "FirmaDigital CRL download"
				interval	= "600"
				startDate	= "#Now()#"
				startTime	= "00:00"
				endTime		= "23:59"
				operation	= "HTTPRequest"
				repeat		= "-1"
				url				=
				"http://#LvarSRV#/home/public/FirmaDigital/plugin/login.cfc?METHOD=actualizaCRLs"
			>
			<cfset server.FirmaDigital_CRL = 0>
		</cfif>

		<cfparam name="server.FirmaDigital_CRL" default="0">
		<cfset LvarTiempo = getTickcount() - server.FirmaDigital_CRL>

		<cfif LvarTiempo GT 0 AND LvarTiempo LT 540000>		<!--- 9 minutos --->
			<cfoutput>No se ejecuta desde hace: #getTickcount() - server.FirmaDigital_CRL# milisegundos#BR#</cfoutput>
			<cfif LvarTiempo GTE 3600000>
				<cfset LvarTiempo = int(LvarTiempo / 3600000) & " horas">
			<cfelseif LvarTiempo GTE 60000>
				<cfset LvarTiempo = int(LvarTiempo / 60000) & " minutos">
			<cfelseif LvarTiempo GTE 1000>
				<cfset LvarTiempo = int(LvarTiempo / 1000) & " segundos">
			<cfelse>
				<cfset LvarTiempo = LvarTiempo & " milisegundos">
			</cfif>
			<cffile action="append"
				file="#expandPath("/home/public/FirmaDigital/crls/run.txt")#"
				output="#dateFormat(now(),"YYYY-MM-DD")# #timeFormat(now(),"HH:MM:SS")#, No se actualizaron los CRLs, última actualización hace #LvarTiempo#"
				addNewLine = "yes"
			>
			<cfreturn>
		</cfif>

		<cfloop file="#expandPath("/home/public/FirmaDigital/crls/lista.txt")#" index="LvarCRL">
			<cfset LvarCRL_filename = getFileFromUrl("/home/public/FirmaDigital/crls/", LvarCRL)>
			<cflock name="CRL" timeout="10">
				<cftry>
					<!--- Dependiendo de la version de coldfusion:
									1) Requiere que el nombre del archivo haya convertido los caracteres especiales: hay que enviar 'CA%20SINPE...'
									2) Convierte los caracteres especiales, si se envía %20 lo convierte a %2520: hay que enviar 'CA SINPE...'
					--->
					<cftry>
						<cffile action="readbinary"	file="#LvarCRL#"											variable="LvarBIN">
					<cfcatch type="any">
						<cffile action="readbinary"	file="#DecodeFromURL(LvarCRL)#"				variable="LvarBIN">
					</cfcatch>
					</cftry>
					<cffile 	action="write"			file="#LvarCRL_filename#"								output ="#LvarBIN#">
				<cfcatch type="any">
					<cfset LvarErroresFile = expandPath("/home/public/FirmaDigital/crls/erroresCRL.txt")>
					<cfif fileExists(LvarErroresFile) AND GetFileInfo(LvarErroresFile).size GT 102400>
						<cffile action="write"
							file="#LvarErroresFile#"
							output="Reinicio #now()#"
							addNewLine = "yes"
						>
					</cfif>
					<cffile action="append"
						file="#LvarErroresFile#"
						output="#LvarCRL#, #dateFormat(now(),"YYYY-MM-DD")# #timeFormat(now(),"HH:MM:SS")#, #cfcatch.message#"
						addNewLine = "yes"
					>
					<cfoutput>Error actualizaCRLs: #cfcatch.message##BR##BR#</cfoutput>
					<cfset slackObject = createObject("component","rx.res.SlackService").init()>
					<cfset slackObject.callRestApi("Error al actualizaCRLs,  revisar; #cfcatch.message#")>
					<cfreturn>
				</cfcatch>
				</cftry>
			</cflock>
		</cfloop>
		<cfset server.FirmaDigital_CRL = getTickcount()>
		<cffile action="write"
			file="#expandPath("/home/public/FirmaDigital/crls/run.txt")#"
			output="#dateFormat(now(),"YYYY-MM-DD")# #timeFormat(now(),"HH:MM:SS")#, Archivos CRLs actualizados"
			addNewLine = "yes"
		>
		<cfoutput>Final actualizaCRLs: #now()##BR##BR#</cfoutput>
	</cffunction>

	<cffunction name="getFileFromUrl" returntype="string">
		<cfargument name="path"	type="string">
		<cfargument name="url"	type="string">

		<cfset LvarPto = 0>
		<cfset LvarFilename =  getFileFromPath(arguments.url)>
		<cfloop list="##/;?" index="LvarChr">
			<cfset LvarPto1 = find(LvarChr,LvarFilename)>
			<cfif LvarPto1 GT 0 and (LvarPto EQ 0 OR LvarPto1 LT LvarPto)>
				<cfset LvarPto = LvarPto1>
			</cfif>
		</cfloop>
		<cfif LvarPto GT 0>
			<cfset LvarFilename =  left(LvarFilename,LvarPto-1)>
		</cfif>

		<cfreturn expandPath(Arguments.path) & DecodeFromURL(LvarFilename)>
	</cffunction>

	<cffunction name="getCertificateFromBase64" access="public" returnType="any">
    	<cfargument name="cert_base64" type="string" >
		<cfreturn createObject('java', 'ocspvalidador.Certificate').getCertificateFromBase64(Arguments.cert_base64)>
	</cffunction>
	<cffunction name="getCertificateFromHexString" access="public" returnType="any">
    	<cfargument name="cert_Hex" type="string" >
		<cfreturn createObject('java', 'ocspvalidador.Certificate').getCertificateFromHexString(Arguments.cert_Hex)>
	</cffunction>
	<cffunction name="getCertificateFromByteArray" access="public" returnType="any">
    	<cfargument name="cert_bytes" type="any" >
		<cfreturn createObject('java', 'ocspvalidador.Certificate').getCertificateFromByteArray(Arguments.cert_bytes)>
	</cffunction>
	<cffunction name="getCertificateFromFile" access="public" returnType="any">
    	<cfargument name="cert_FileName" type="string" >
		<cfreturn createObject('java', 'ocspvalidador.Certificate').getCertificateFromFile(Arguments.cert_FileName)>
	</cffunction>
	<cffunction name="getUrlsFromCertificate" access="public" returnType="array">
    	<cfargument name="cert_X509" type="any" >
		<cfreturn createObject('java', 'ocspvalidador.Certificate').getUrls(Arguments.cert_X509)>
	</cffunction>
</cfcomponent>

