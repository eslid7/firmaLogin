var pkcs11js = require("pkcs11js");
 
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
            // var publicKeyTemplate = [
            //     { type: pkcs11js.CKA_CLASS, value: pkcs11js.CKO_PUBLIC_KEY },
            //     { type: pkcs11js.CKA_TOKEN, value: false },
            //     { type: pkcs11js.CKA_LABEL, value: "30819F300D06092A864886F70D010101050003818D0030818902818100949083B3B608652449751921062B437D3AE7205DFF72F07007C699FA284F2D95C57AF90E54BBE6F0C2914CDE713E15C082D43025FFE4FBE8914E19B31A7B0AFDBE0F416594DC3EB940163F4155324A78760CBC36EDC159E3A30ACCF6595B2A86189B4FB2F32EBEC2E2E57B0517F1CB5E33A301B7DA82702EA0E9233458C0D7A50203010001" },
            //     { type: pkcs11js.CKA_EC_PARAMS, value: new Buffer("06082A8648CE3D030107", "hex") }, // secp256r1
            // ];
            // var privateKeyTemplate = [
            //     { type: pkcs11js.CKA_CLASS, value: pkcs11js.CKO_PRIVATE_KEY },
            //     { type: pkcs11js.CKA_TOKEN, value: false },
            //     { type: pkcs11js.CKA_LABEL, value: "0E4F2549DCCEE9C00ED6C72ADF4DD5ACA97FD518D497DEB7C6DD2BAE86D95AD0D6A316C2CBDFC2F823ABFF45DDAD210DEB0ED117C809072DEF1EF85B16FF0CCE5FFDFFCBD7DA43AFC96F2FABA60921558D2CA5D1D9E1296A4B2AEADED9DA0FF7FBFE098AD49FEF285EA2A824502ED4E75AA9B9B8C4DB99AAF8CFD4FAB47FCED6B9A6DCE1EF3B0DB8A651B5F9C1B6B90E4B564FF88F3DF3DF7D03AECDF6C8CB64597608D4CC0AC8E99AC7D74CABD2D84BFBCC6D94A2FBBD5936CBC20FD0B9EA2266C7CC57CC754B98BB333CB6D6DCE8CE42E3C012BD9AD7DC7C8EC7AF2A0D84B588CFD3FA4FF8CDBF93CAC4C5FDFC74B8C680A38AA7CCD20E8BD5A7C8C6B8E47021050AA06CA4C4984110CAD7E388CD7BA5EB73D4C9598E89AE5EB6E5B783C8DFDCDC0DC4A9C2AE590C5BA1DDA6C5D7D451F9BB7AF6C1FED7E96EB41B300BD56DCC08CBE79A7EB6C8662ECCFDFFD9D746070F1AC7C3C0A6D4AEC9CCB03FC7C707F8A20A1A0EEE0FD77BFBF9C1C9D12CAF57F61B680DCACB5AC9DBCE4B64EDC9949AF8DE0EEBC70CBCEC2006A2BE16760C44B88ACA7BF4E754BB0E8DD5A05D8AC8B61792D0BF72A4A12E3C3D5DB8C80CBEB8B6DDCD8CF3FED121BAF05DC9F6E5F88C7FDD2A89F5A5C6CB95C4CBEFC02409B606D02D3F37306804E2059E0320532EF8D900E8D62BC5819A5BFE8C70701567AF4A23C0C9CF5CCBFC7D5ECFBB26EE1DDBCF70BEB25AD1BB9B9907CE110301B56A50F8CACCE502E8A132CA0CFE8CB0BC2950CADDC8DAA9DDBDBFAABA9B23AEB5B91E09C7DDB310BE0D5C527ECBCA76F9FA47DA8BEBD39FDFD1A7665CC99150A8A7C0406E84D9898D9BE3AEEDEDEFDF578AC681BBC6046C0C7DE624D49CD0B14D0780DABEF88CEA0F1FD2C42346E6AE75C692C87BA9CE99A7B553CE2C5FA5E053A4DBA60DA02DCACFEBCA9E2606CEC6EFA3C9BDFADEFB639EDAD384DF8E2B02BAD953BEA8EA6FC90FC7D99FA5C704C1AC8DC6792B09DFC6E217A455CD0FCE57B557FC74F9579EE8E1BAAAB8F80BF9DBFBFAC1EAFDE4A774CCB78B6DA676BBC9BA39D5CF65AAAFB6A7968FD94D0738A3AB576E9CA2C7D7EAA27ABF2FEB1B02D889D0FF6DC7B81CED7EECC198E549FFC9D503DD33E2C9D7CEEA8DE7D3CAE37763DC6BFAB0DC9BCCDD5BAABDD6E6B136885FC4C5CA7D2E9F88CAFD878FE5DFC611BB78DF9EDCBDD8AC07F20BF9559C5F813DFD4DA3B8CE8BFF0D4B8CEEA77CC2FCB0BDEED6C07BE79ABB86CF4CD0F1B8ACE69A70167CBD38FFC90EA6ABCF785C6DB998FCA28B5BF7A1CD7794CA00260A2449CA7C03B2FF7D5A1ED8FD7DAC57AC29ABCEB5CD8D6AA2BFDE892FE8CC108D5BD40AE71FCECBBEB88B7ECECA4C640A8912C9E84AD02B74FBC1D5FBC1722F2FEB8B17E6F1759AB0C9AF1C0FAFC508D4DCEF0EE8CFDA20F58CBEDAD699780BA90AF5D4ED7FBA09C2BE889CE9C78D8AB7BC89AFFE58C02BDE30E91DFBCCAA2D5C8D0BABB9C3DA80CC54ABBCFCC2A607C463067C89DA14DB4ACB01EB65C3EDE2D5D0ABE2ED6893FB8C77ADDFEAEA5DDE3FBC24F718C49DFE040B0CF9A0D8AA80DD1B74D84BDF0869BE05CE02AC6FB1CCDACE17C3CEC2CDCECD9201BA9E7FFA1F76BD789910B10EB2ECAEFFCA908AE50E4CD96E4EB9CCC72BFAE9B14F0DCBDE0C4828FEE9BDD1D70FC6E3247BCBED94F2FAC6B9B25064C607BB5CBD71C4C1554BF8BC4AC4B386C422CA70F9F8ABD8AEFCAC05AB51D5028EA8DBB08A99CBBC7E00EFAE78CD029DE9FAF86BDA27AD6F2F0DCAF205CFCC85C9F8B7" },
            //     { type: pkcs11js.CKA_DERIVE, value: true },
            // ];
            // var keys = pkcs11.C_GenerateKeyPair(session, { mechanism: pkcs11js.CKM_EC_KEY_PAIR_GEN }, publicKeyTemplate, privateKeyTemplate);

            // pkcs11.C_SignInit(session, { mechanism: pkcs11js.CKM_SHA256_RSA_PKCS }, keys.privateKey);
     
            // pkcs11.C_SignUpdate(session, new Buffer("Incomming message 1"));
             
            // var signature = pkcs11.C_SignFinal(session, Buffer(256));


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

                    ///// intento 2
                    // console.log("CKA_SUBJECT", attrs[4].value.toString('ascii'))
                    // console.log("CKA_SUBJECT", attrs[4])
                    // var arrayDatosFirma = attrs[4].value.toString().split('\u001e');
                    var DatosFirma = attrs[4].value.toString('ascii');


                    // console.log("DatosFirma",DatosFirma)
                    var arrayDatosFirma = DatosFirma.split('U');
                    console.log("arrayDatosFirma",arrayDatosFirma)
                   // console.log("arrayDatosFirma[0] ", arrayDatosFirma[0])
                    cedula = arrayDatosFirma[1].replace('1\u001b0\u0019\u0006','')
                    apellidos = arrayDatosFirma[2].replace("1\u00130\u0011\u0006",'')
                    name = arrayDatosFirma[3].replace("\n",'','ALL').replace("*",'','ALL').replace("1\u000b0\t\u0006","")
                    typeId = arrayDatosFirma[5].replace("\n",'','ALL').replace("1\u00120\u0010\u0006","")
                   console.log("arrayDatosFirma[1] ", arrayDatosFirma[1].replace('1\u001b0\u0019\u0006',''))
                   console.log("arrayDatosFirma[2] ", arrayDatosFirma[2].replace("1\u00130\u0011\u0006",''))
                   console.log("arrayDatosFirma[3] ", arrayDatosFirma[3].replace("\n",'','ALL').replace("*",'','ALL').replace("1\u000b0\t\u0006",""))
                   // console.log("arrayDatosFirma[4] ", arrayDatosFirma[4])
                   console.log("arrayDatosFirma[5] ", arrayDatosFirma[5].replace("\n",'','ALL').replace("1\u00120\u0010\u0006",""))
                    // dataSign = arrayDatosFirma[3].toString('utf-8');
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