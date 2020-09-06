const fs = require('fs');
const path = require('path'); 
const pkcs11js = require("pkcs11js");
 
var pkcs11 = new pkcs11js.PKCS11();
var xadesjs = require("xadesjs");
var { Crypto } = require("@peculiar/webcrypto");
// const { Crypto } = require("node-webcrypto-p11");

// const XmlDSigJs = require("xmldsigjs");
// var SignedXml = require('xml-crypto').SignedXml	  

// const webcryptoLiner = require("./webcrypto-liner.min.js");
// const asmcrypto = require("./asmcrypto.js");
// const elliptic = require("./elliptic.js");
// const xadesjs = require("./xades.min.js");
// const xadesjs = require("./xades.min.js");

async function  tryXades(req, res){


		 try {

		 	        // Getting info about PKCS11 Module
        pkcs11.load("/usr/local/lib/libASEP11.dylib");
        // pkcs11.load("/usr/local/lib/softhsm/libsofthsm2.so");

        pkcs11.C_Initialize();

        var module_info = pkcs11.C_GetInfo();
        console.log('linea 14 ')
        // Getting list of slots
        var slots = pkcs11.C_GetSlotList(true);
        console.log('slots ', slots)
        var slot = slots[0];
        console.log('slot ', slot)
        if(slot== undefined){
             throw {'message' : ' La firma no esta conectada'};
        }
        // Getting info about slot
        var slot_info = pkcs11.C_GetSlotInfo(slot);
        console.log('slot_info ', slot_info)
        // Getting info about token
        var token_info = pkcs11.C_GetTokenInfo(slot);
        console.log('token_info ', token_info)
        // Getting info about Mechanism
        var mechs = pkcs11.C_GetMechanismList(slot);
        var mech_info = pkcs11.C_GetMechanismInfo(slot, mechs[0]);
         console.log('mech_info ',mech_info)

        var session = pkcs11.C_OpenSession(slot, pkcs11js.CKF_RW_SESSION | pkcs11js.CKF_SERIAL_SESSION);
       
        // Getting info about Session
        var info = pkcs11.C_GetSessionInfo(session);
        console.log(req.params.id)
        pkcs11.C_Login(session, 1, req.params.id);


        console.log('session', session.toString())


			var data =  pkcs11.C_FindObjectsInit(session, [{ 
                type: pkcs11js.CKA_CLASS, value: pkcs11js.CKO_CERTIFICATE 
            }]);
            var hObject = pkcs11.C_FindObjects(session);

            let certificate = "";

            while (hObject) {
                var attrs = pkcs11.C_GetAttributeValue(session, hObject, [
                    { type: pkcs11js.CKA_CLASS },
                    { type: pkcs11js.CKA_TOKEN },
                    { type: pkcs11js.CKA_LABEL },
                    { type: pkcs11js.CKA_VALUE },
                    // { type: pkcs11js.CKA_END_DATE }
                ]);
                if (attrs[1].value[0]){
                    if(attrs[2].value.toString()=='LlaveDeFirma'){
                        // keys.privateKey = hObject;
                        console.log('certificate3 ', attrs[3].value.toString('base64'));
                        certificate = attrs[3].value.toString('base64');
                    }
                    else{
                        // keys.publicKey = hObject;
                    }           
                }
                hObject = pkcs11.C_FindObjects(session);
            }
            pkcs11.C_FindObjectsFinal(session);
            xadesjs.Application.setEngine("NodeJS", new Crypto());

        	const keys = await xadesjs.Application.crypto.subtle.generateKey({
			        name: "RSASSA-PKCS1-v1_5",
			        modulusLength: 1024, //can be 1024, 2048, or 4096,
			        publicExponent: new Uint8Array([1, 0, 1]),
			        hash: { name: "SHA-256" }, //can be "SHA-1", "SHA-256", "SHA-384", or "SHA-512"
			    },
			    false, //whether the key is extractable (i.e. can be used in exportKey)
			    ["sign", "verify"] //can be any combination of "sign" and "verify"
			);

            console.log('keys.privateKey' , keys.privateKey);

			var xmlString = '<player bats="left" id="10012" throws="right">\n\t<!-- Here\'s a comment -->\n\t<name>Alfonso Soriano</name>\n\t<position>2B</position>\n\t<team>New York Yankees</team>\n</player>';
		    const signfile = await SignXml(xmlString, keys, { name: "RSASSA-PKCS1-v1_5", hash: { name: "SHA-256" } }, certificate);
			console.log(signfile.toString('base64'));
			console.log(signfile.toString('base64'));    

		pkcs11.C_Logout(session);
        pkcs11.C_CloseSession(session);
        res.send(200, { "signfile" : signfile.toString('base64')});
    }
    catch(e){
        console.log(e.message);
        if(e.message.includes("La firma no esta conectada")){
        	res.send(400, { error: "La firma no esta conectada"});
        }
        else if(e.message.includes("CKR_PIN_INCORRECT")){
        	res.send(400, { error: "El pin no es correcto."});
        }
        else if(e.message.includes("CKR_PIN_LOCKED")){
        	res.send(400, { error: "La firma esta bloqueada. Por intentos excedidos."});
        }
        else{
        	res.send(400, {e:e.message});
        }
    }
    finally {
        pkcs11.C_Finalize();
    }
} 




 
function SignXml(xmlString, keys, algorithm, certificate) {
	 console.log('testing  ' )
    return Promise.resolve()
	    .then(() => {
	        var xmlDoc = xadesjs.Parse(xmlString);
	        var signedXml = new xadesjs.SignedXml();

	        return signedXml.Sign(               // Signing document
	            algorithm,                              // algorithm
	            keys.privateKey,                        // key
	            xmlDoc,                                 // document
	            {                                       // options
	                keyValue: keys.publicKey,
	                references: [
	                    { hash: "SHA-256", transforms: ["enveloped"] }
	                ],
	                signingCertificate: certificate
	            })
	        }).then(signature => signature.toString());
}


module.exports = {
    tryXades
}