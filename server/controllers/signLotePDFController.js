'use strict'
var jwt = require('jwt-simple');
const crypto = require('crypto');
const request = require('request');
const zlib = require('zlib');
const {gzip, ungzip} = require('node-gzip');
const fs = require('fs');


function singPDFLote(req, res){
	/////// PDF 6 minutos para firmar
	let datetime = new Date().getTime();
	let datetimeEXP =datetime  + 60000;

	let secretInterno = 'AjfM0QA2hKYAXQ@rx_506_soin@hA4KsN0P2OA7uwHsih' ; //secreto interno para el access token
	let theKey	='52583034507233354336363032303132'; //llave para encrytar el acces token
	let theKey2 = 'UlgwNFByMzVDNjYwMjAxMg==';

	//preparar el token
	let tokenData = {
				"jti":"token", 
				"iat": datetime.toString().substring(0,10), 
				"iss":"firmDigital",
				"exp": datetimeEXP.toString().substring(0,10)
			};

	let accessTokenJWT =  jwt.encode(tokenData,secretInterno,'HS512')

	//procedemos a encryptar el token
	let key = new Buffer(theKey)
	console.log(key.toString('hex'));
	var cc = crypto.createCipher('aes-128-ecb', key);
	var encrypted = Buffer.concat([cc.update(accessTokenJWT, 'utf8'), cc.final()]).toString('hex');

	 // let arrayUrls = [
		// 		{
		// 			"id": 452,
		// 			"link": "http://recetadigital.soin.net/cfmx/home/public/terminos_condiciones.pdf",
		// 			"type": "PDF"
		// 		},
		// 		{
		// 			"id": 452,
		// 			"link": "http://recetadigital.soin.net/cfmx/home/public/terminos_condiciones.pdf",
		// 			"type": "PDF"
		// 		},
		// 		{
		// 			"id": 452,
		// 			"link": "http://recetadigital.soin.net/cfmx/home/public/terminos_condiciones.pdf",
		// 			"type": "PDF"
		// 		}
		// 	];

	// let arrayUrls =[ "452", "http://recetadigital.soin.net/cfmx/home/public/terminos_condiciones.pdf"];

	let arrayUrls = [ "452", "http://recetadigital.soin.net/cfmx/home/public/terminos_condiciones.pdf", "453","http://recetadigital.soin.net/cfmx/home/public/terminos_condiciones.pdf"]
	console.log(arrayUrls)
    let secret ="0kQZrhqOMP7Xjtmi@rx_506_soin@8qDN4pebwmXFcMAZ";
		
	let tokenDataFinal = {
		"jti":"token", 
		"iss":"rxFirmaInterno",
		"token": datetime,
		"exp": datetime.toString().substring(0,10),
		"tipo": "PvarARRUrls",
		"titulo":"Firmado de Receta",
		"url":"http://localhost:3000/login.cfc",
		"urlUploadPDF":"http://localhost:3000/PDFResponse",
		// "pdf": compressed.toString('base64'), 
		"arrayLote": arrayUrls,	
		"sub" : arrayUrls,		
		"accessToken" : encrypted.toUpperCase()
	}

	var token =  jwt.encode(tokenDataFinal,secret,'HS512')

	//console.log(token);
	request.get('https://firmadigitallocal.com:61983/FirmaDigitalServer?OP=DocsSign&data='+token, {}, (error, res2, body) => {
	  if (error) {
	    console.error(error)
	    return
	  }
	  console.log(`statusCode: ${res2.statusCode}`)
	  res.send(200, "OK");	
	})
}

async function PDFResponse(req, res){
	let SECRET ="0kQZrhqOMP7Xjtmi@rx_506_soin@8qDN4pebwmXFcMAZ";
	const { signedMSG, token: timestamp } = req.body
	if(req.query.METHOD!= undefined){

		console.log('METHOD '+req.query.METHOD);
		console.log('token '+req.query.token);
		console.log('port '+req.query.port)

		if(req.query.METHOD=='sendError'){
			console.log('mensaje '+req.query.MSG)
		}
		console.log('responiendo OKK ')
		res.send(200,"OK");		
	}
	else if (signedMSG !== undefined) {
	    const token = jwt.decode(signedMSG, SECRET, 'HS512')
	    console.log('METHOD '+req.query.METHOD);
			const buffer = Buffer.from(token.sub, 'base64');
			zlib.unzip(buffer, (err, buffer) => {
			  if (!err) {

					fs.writeFile('recetafirmadaArrayPDF.pdf', buffer, (err) => {
					  if (err) throw err;

					  console.log('It\'s saved!');
					  // res.send(200, "OK");	
					});			    
			  } else {
			   // res.send(200, "OK");	
			  }
			});

      	res.send(200,"OK");	
    } else{
		console.log('req ', req)
		console.log('responiendo OK ')
		res.send(200,"OK");		
	}
}

module.exports = {
	singPDFLote,
	PDFResponse
}