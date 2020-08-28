var pkcs11js = require("pkcs11js");
 
var pkcs11 = new pkcs11js.PKCS11();
///  pkcs11.load("/usr/local/lib/libASEP11.dylib");
// pkcs11.load("/usr/local/lib/softhsm/libsofthsm2.so");

 

function loginWhitSign(req, res){
     console.log('Iniciando proceso')
     res.send(200, "Pin incorrecto");
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
        // Getting info about slot
        var slot_info = pkcs11.C_GetSlotInfo(slot);
        console.log('slot_info ', slot_info)
        // Getting info about token
        var token_info = pkcs11.C_GetTokenInfo(slot);
        console.log('token_info ', token_info)
        // Getting info about Mechanism
        var mechs = pkcs11.C_GetMechanismList(slot);
        var mech_info = pkcs11.C_GetMechanismInfo(slot, mechs[0]);
         console.log('pkcs11js.CKF_RW_SESSION ', pkcs11js.CKF_RW_SESSION)

        var session = pkcs11.C_OpenSession(slot, pkcs11js.CKF_RW_SESSION | pkcs11js.CKF_SERIAL_SESSION);
       
        // Getting info about Session
        var info = pkcs11.C_GetSessionInfo(session);
        console.log(req.params.id)
        pkcs11.C_Login(session, 1, req.params.id);
        // session.find({ class: pkcs11js.CKC_X_509 }).length
        console.log('session', session)
        ////////////////////////////////////////////////////////////////////////////////////////////////

        // FIRMAR DOCUMENTOS



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
                { type: pkcs11js.CKA_VALUE }
            ]);
            // Output info for objects from token only
            // console.log(attrs[3]);
            

            if (attrs[1].value[0]){
                console.log(`Object #${hObject}: ${attrs[2].value.toString()}`);
                if(attrs[2].value.toString()=='LlaveDeAutenticacion'){
                    data2 = attrs[3].value.toString('ascii');

                    var array = data2.split("\u001e")

                    console.log(array)
                    var dataNew = array[1].replace("\n",'','ALL')
                    var array2 = dataNew.split("\u0013")
                    console.log(array2)
                    var idLength = array2[1].length - 2;
                     console.log(array2[1].length)
                    console.log(idLength)
                    console.log(`||${array2[1].replace("1\u001b0\u0019\u0006\u0003U\u0004\u0004",'')}||`)
                    console.log(`||${array2[2].replace("1",'')}||`)
                    console.log(`||${array2[4].replace("1\u000b0\t\u0006\u0003U\u0004\u0006",'')}||`)
                    console.log(`||${array2[6].replace("1\u00120\u0010\u0006\u0003U\u0004\u000b",'')}||`)
                    let cedula = array2[1].replace("1\u001b0\u0019\u0006\u0003U\u0004\u0004",'')
                    let apellidos = array2[2].replace("1",'')
                    let name = array2[4].replace("1\u000b0\t\u0006\u0003U\u0004\u0006",'');
                    let typeId = array2[6].replace("1\u00120\u0010\u0006\u0003U\u0004\u000b",'')
                    // dataSign = data2;
                    dataSign = "Bienvenido  Nombre "+name+" Apellidos "+apellidos+" id "+cedula+" tipo "+typeId;
                }             
            }
            hObject = pkcs11.C_FindObjects(session);
        }
        pkcs11.C_FindObjectsFinal(session);

        //////////////////////////////////////////////// ////////////////////////////////////////////////
        pkcs11.C_Logout(session);
        pkcs11.C_CloseSession(session);
        res.send(200, dataSign);
    }
    catch(e){
        console.error(e);
        res.send(200, "Pin incorrecto");
        //CKR_PIN_INCORRECT
    }
    finally {
        pkcs11.C_Finalize();
    }
}

module.exports = {
    loginWhitSign
}