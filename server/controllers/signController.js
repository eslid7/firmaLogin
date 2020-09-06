const fs = require('fs');
const path = require('path'); 
const pkcs11js = require("pkcs11js");
 
var pkcs11 = new pkcs11js.PKCS11();
///  pkcs11.load("/usr/local/lib/libASEP11.dylib");
// pkcs11.load("/usr/local/lib/softhsm/libsofthsm2.so");

 

function loginWhitSign(req, res){
     console.log('Iniciando proceso');
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
             throw 'La firma no esta conectada';
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
        // session.find({ class: pkcs11js.CKC_X_509 }).length
        console.log('session', session.toString())


        ////////////////////////////////////////////////////////////////////////////////////////////////
        console.log('pkcs11js.CKA_SUBJECT', pkcs11js.CKA_SUBJECT);
        console.log('pkcs11js.CKA_VALUE', pkcs11js.CKA_VALUE);
        console.log('pkcs11js.CKA_CLASS', pkcs11js.CKA_CLASS);
        console.log('pkcs11js.CKO_DATA', pkcs11js.CKO_DATA);
        console.log('pkcs11js.CKO_CERTIFICATE', pkcs11js.CKO_CERTIFICATE);
        console.log('pkcs11js.CKC_X_509', pkcs11js.CKC_X_509);
        console.log('pkcs11js.CKC_X_509_ATTR_CERT', pkcs11js.CKC_X_509_ATTR_CERT);
        console.log('pkcs11js.CKA_CERTIFICATE_TYPE', pkcs11js.CKA_CERTIFICATE_TYPE);
        console.log('pkcs11js.CKA_TOKEN', pkcs11js.CKA_TOKEN);


        // BUSCAR TODOS LOS CERTIFICADOS
        var data =  pkcs11.C_FindObjectsInit(session, [{ type: pkcs11js.CKA_CLASS, value: pkcs11js.CKO_CERTIFICATE }]);
        var hObject = pkcs11.C_FindObjects(session);
        console.log('pkcs11js.hObject', hObject);
        while (hObject) {
            var attrs = pkcs11.C_GetAttributeValue(session, hObject, [
                { type: pkcs11js.CKA_CLASS },
                { type: pkcs11js.CKA_TOKEN },
                { type: pkcs11js.CKA_LABEL },
                { type: pkcs11js.CKA_VALUE },
                { type: pkcs11js.CKA_SUBJECT },
                { type: pkcs11js.CKA_ISSUER },
                { type: pkcs11js.CKA_SERIAL_NUMBER }
                // { type: pkcs11js.CKA_END_DATE }
            ]);
              // console.log(`Object #${hObject}: ${attrs[2].value.toString()}`);
            if (attrs[1].value[0]){
                console.log(`Object #${hObject}: ${attrs[2].value.toString()}`);
                if(attrs[2].value.toString()=='LlaveDeAutenticacion'){
                    var DatosFirma = attrs[4].value.toString('ascii');
                    const [,id,lastName,name,,type] =DatosFirma.replace(/[^a-zA-Z0-9-áéíóúÁÉÍÓÚñÑ ]/g, "").split('10U')
                    const [last1, last2] = lastName.split(' ')

                    dataSign = `Bienvenido Nombre: ${name} Apellidos: ${last1} ${last2} id: ${id} tipo: ${type}`;
                }           
            }
            hObject = pkcs11.C_FindObjects(session);
        }
        pkcs11.C_FindObjectsFinal(session);

        /////////////////////////////////////////////////////////////////////////////////////////////////
        // fecha de vencimiento.

        // var data =  pkcs11.C_FindObjectsInit(session, [{ 
        //     type: pkcs11js.CKA_CLASS, value: pkcs11js.CKO_CERTIFICATE 
        // ,   type: pkcs11js.CKA_CERTIFICATE_TYPE , value: pkcs11js.CKC_X_509 
        // ,   type: pkcs11js.CKA_TOKEN, value : true
        // // ,   type: pkcs11js.CKA_PRIVATE, value : false
        // }]);
        // console.log("CKA_END_DATE " ,pkcs11js.CKA_END_DATE)
        // var hObject = pkcs11.C_FindObjects(session);
        // console.log('pkcs11js.hObject', hObject);
        // while (hObject) {
        //     var attrs = pkcs11.C_GetAttributeValue(session, hObject, [
        //         // { type: pkcs11js.CKA_CLASS },
        //         // { type: pkcs11js.CKA_LABEL },
        //         // { type: pkcs11js.CKA_VALUE },
        //         // { type: pkcs11js.CKA_CHECK_VALUE },
        //         { type: pkcs11js.CKA_CERTIFICATE_TYPE },
        //         { type: pkcs11js.CKA_TRUSTED },
        //         { type: pkcs11js.CKA_START_DATE }, 
        //         { type: pkcs11js.CKA_END_DATE }
        //         //esta no sirven  CKO_PUBLIC_KEY, CKO_PRIVATE_KEY and CKO_SECRET_KEY
               
        //         //
        //         // { type: pkcs11js.CKA_START_DATE }, 
        //         // { type: pkcs11js.CKA_END_DATE }               
        //     ]);

        //        console.log(attrs);
        //        console.log(attrs[1].value.toString())
        //        console.log("0  ", attrs[0].value.toString())
        //        console.log("1 ", attrs[1].value.toString())
        //        // console.log(pkcs11js.CKA_START_DATE)
        //        // console.log("FECHA INIT ", attrs[3].value.toString())
        //        // console.log("FECHA FIN ",attrs[4].value.toString())
        //         dataSign = "Bienvenido  Nombre "
        //     hObject = pkcs11.C_FindObjects(session);
        // }
        // pkcs11.C_FindObjectsFinal(session);
        ////////////////////////////////////////////////////////////////////////////////////////////////

        // FIRMAR DOCUMENTOS
            //INTENTO 111111
            //estructurar las llaves
            // const publicKeyTemplate = [
            //   { type: pkcs11js.CKA_CLASS, value: pkcs11js.CKO_PUBLIC_KEY },
            //   { type: pkcs11js.CKA_TOKEN, value: true },
            //   { type: pkcs11js.CKA_LABEL, value: "30819F300D06092A864886F70D010101050003818D0030818902818100949083B3B608652449751921062B437D3AE7205DFF72F07007C699FA284F2D95C57AF90E54BBE6F0C2914CDE713E15C082D43025FFE4FBE8914E19B31A7B0AFDBE0F416594DC3EB940163F4155324A78760CBC36EDC159E3A30ACCF6595B2A86189B4FB2F32EBEC2E2E57B0517F1CB5E33A301B7DA82702EA0E9233458C0D7A50203010001" },
            //   { type: pkcs11js.CKA_PUBLIC_EXPONENT, value: Buffer.from([1, 0, 1]) },
            //   { type: pkcs11js.CKA_MODULUS_BITS, value: 2048 },
            //   { type: pkcs11js.CKA_VERIFY, value: true }
            // ];

            // const privateKeyTemplate = [
            //   { type: pkcs11js.CKA_CLASS, value: pkcs11js.CKO_PRIVATE_KEY },
            //   { type: pkcs11js.CKA_TOKEN, value: true },
            //   { type: pkcs11js.CKA_LABEL, value: "0E4F2549DCCEE9C00ED6C72ADF4DD5ACA97FD518D497DEB7C6DD2BAE86D95AD0D6A316C2CBDFC2F823ABFF45DDAD210DEB0ED117C809072DEF1EF85B16FF0CCE5FFDFFCBD7DA43AFC96F2FABA60921558D2CA5D1D9E1296A4B2AEADED9DA0FF7FBFE098AD49FEF285EA2A824502ED4E75AA9B9B8C4DB99AAF8CFD4FAB47FCED6B9A6DCE1EF3B0DB8A651B5F9C1B6B90E4B564FF88F3DF3DF7D03AECDF6C8CB64597608D4CC" },
            //   { type: pkcs11js.CKA_SIGN, value: true },
            // ];
            // //generar las llaves
            // const keys = pkcs11.C_GenerateKeyPair(session, { mechanism: pkcs11js.CKM_RSA_PKCS_KEY_PAIR_GEN }, publicKeyTemplate, privateKeyTemplate);
            
            // pkcs11.C_SignInit(session, { mechanism: pkcs11js.CKM_SHA256_RSA_PKCS }, keys.privateKey);
            // // let fileDataBinary = fs.readFileSync(path.resolve(__dirname,'../public/receta.xml'));

            // pkcs11.C_SignUpdate(session, new Buffer("Incomming message 1"));
            
            // //firmar
            // var signature = pkcs11.C_SignFinal(session, Buffer(256));
            // console.log("Sign file")
            // console.log(signature)
            // console.log(signature.toString('base64'))
            // console.log(signature.toString('hex'))
            // console.log(signature.toString('ascii'))
            

            
            // dataSign = `Archivo firmado `;
            //INTENTO 222222222222
            // var data =  pkcs11.C_FindObjectsInit(session, [{ 
            //     type: pkcs11js.CKA_CLASS, value: pkcs11js.CKO_CERTIFICATE 
            // ,   type: pkcs11js.CKA_CERTIFICATE_TYPE , value: pkcs11js.CKC_X_509 
            // ,   type: pkcs11js.CKA_TOKEN, value : true
            // }]);
            // var hObject = pkcs11.C_FindObjects(session);
            // var  keys = { privateKey :null};
            // console.log('pkcs11js.hObject', hObject);
            // while (hObject) {
            //     var attrs = pkcs11.C_GetAttributeValue(session, hObject, [
            //         { type: pkcs11js.CKA_CLASS },
            //         { type: pkcs11js.CKA_TOKEN },
            //         { type: pkcs11js.CKA_LABEL },
            //         // { type: pkcs11js.CKA_END_DATE }
            //     ]);
            //       // console.log(`Object #${hObject}: ${attrs[2].value.toString()}`);
            //     if (attrs[1].value[0]){
            //         console.log(`Object #${hObject}: ${attrs[2].value.toString()}`);
            //         if(attrs[2].value.toString()=='LlaveDeFirma'){
            //             keys.privateKey = hObject;
            //         }
            //         else{
            //             keys.publicKey = hObject;
            //         }           
            //     }
            //     hObject = pkcs11.C_FindObjects(session);
            // }
            // pkcs11.C_FindObjectsFinal(session);
            // // console.log(keys.privateKey)
            // pkcs11.C_SignInit(session, { mechanism: pkcs11js.CKM_SHA256_RSA_PKCS }, keys.privateKey);
            // // let fileDataBinary = fs.readFileSync(path.resolve(__dirname,'../public/receta.xml'));

            // pkcs11.C_SignUpdate(session, new Buffer("Incomming message 1"));
            
            // //firmar
            // var signature = pkcs11.C_SignFinal(session, Buffer(256));
            // console.log("Sign file")
            // console.log(signature)
            // console.log(signature.toString('base64'))
            // console.log(signature.toString('hex'))
            // dataSign = `Sign file ${signature.toString('base64')}`;
            //Vérification
                // pkcs11.C_VerifyInit(session, { mechanism: pkcs11js.CKM_SHA256_RSA_PKCS }, keys.publicKey);

                // pkcs11.C_VerifyUpdate(session, Buffer.from("Incomming message 1"));

                // var verify = pkcs11.C_VerifyFinal(session, signature);
                // console.log("Vérification");
                // console.log(verify);
        //////////////////////////////////////////////// ////////////////////////////////////////////////

            //ultima opcion digest
            // pkcs11.C_DigestInit(session, { mechanism: pkcs11js.CKM_SHA256 });
 
            // pkcs11.C_DigestUpdate(session, new Buffer("Incomming message 1"));
             
            // var digest = pkcs11.C_DigestFinal(session, Buffer(256 / 8));
            // console.log(digest); 
            // console.log(digest.toString("base64"));
            // dataSign = `Sign file ${digest.toString('base64')}`;
        //////////////////////////////////////////////// ////////////////////////////////////////////////

        pkcs11.C_Logout(session);
        pkcs11.C_CloseSession(session);
        res.send(200, dataSign);
    }
    catch(e){
        console.error(e);
        res.send(200, e);
        //CKR_PIN_INCORRECT
    }
    finally {
        pkcs11.C_Finalize();
    }
}

module.exports = {
    loginWhitSign
}