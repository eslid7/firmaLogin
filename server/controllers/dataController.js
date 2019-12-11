'use strict'
const fs = require('fs');
const path = require('path');    
const crypto = require('crypto');

const Struct = require('struct');
const NodeRSA = require('node-rsa');
const keygen = require("keygenerator");
const sha1 = require('sha1');
const request = require('request');
const zlib = require('zlib');
const {gzip, ungzip} = require('node-gzip');
var jwt = require('jwt-simple');
var aesjs = require('aes-js');

const decompress = require('decompress');

function singPDF(req, res){
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

	//// no pude hacer el ecrypt como java y coldfusion lo hacen
	 // iv = crypto.randomBytes(16);
	//  accessTokenJWT = new	Buffer(accessTokenJWT);
	//  iv = theKey.substring(0,16)
	// console.log(iv);
	// var cipher = crypto.createCipheriv('aes-256-cbc', new Buffer(theKey), theKey.substring(0,16));
	// var encrypted = cipher.update(accessTokenJWT);

	// encrypted = Buffer.concat([encrypted, cipher.final()]);
	// console.log(iv.toString('hex').toUpperCase())
	// console.log(encrypted.toString('hex').toUpperCase());

	//inicia proceso de lectura del PDF y transformacion
	let fileDataBinary = fs.readFileSync(path.resolve(__dirname,'../public/receta.pdf'));
		
	gzip(fileDataBinary, 'Buffer')
	  .then((compressed) => {
	   	
	    console.log(compressed.toString('base64'))
	  
	    //secreto compartido
	    let secret ="0kQZrhqOMP7Xjtmi@rx_506_soin@8qDN4pebwmXFcMAZ";
  
  
		let tokenData = {
			"jti":"token", 
			"iss":"rxFirmaInterno",
			"token": datetime,
			"exp": datetime.toString().substring(0,10),
			"tipo":"PDF",
			"titulo":"Firmado de Receta",
			"url":"http://localhost:3000/login.cfc",
			"pdf": compressed.toString('base64'), 			
			"accessToken" : encrypted.toUpperCase()
		}

		var token =  jwt.encode(tokenData,secret,'HS512')

		console.log(token);
		request.get('https://firmadigitallocal.com:52900/FirmaDigitalServer?OP=DocsSign&data='+token, {}, (error, res2, body) => {
		  if (error) {
		    console.error(error)
		    return
		  }
		  console.log(`statusCode: ${res2.statusCode}`)
		  res.send(200, "OK");	
		})

	}) 
}



/// este man recibe las respuesta que envia la firma
async function loginComponente(req, res){
	
	if(req.query.METHOD!= undefined){
		console.log('METHOD '+req.query.METHOD);
		console.log('token '+req.query.token);
		console.log('data '+req.query.data)

		if(req.query.METHOD=='sendError'){
			console.log('mensaje '+req.query.MSG)
		}
		
		res.send(200,"OK");		
	}
	else{
		console.log('token '+req.body.token);
		let secret ="0kQZrhqOMP7Xjtmi@rx_506_soin@8qDN4pebwmXFcMAZ"
		
		let data =req.body;
		if(data.signedMSG!= undefined){
			//validar si esta definido data.signedMSG
			var token =  jwt.decode(data.signedMSG, secret, 'HS512')

			//ver cuando es un pdf hay que hacer algo para crear el archivo
			const buffer = Buffer.from(token.sub, 'base64');
			zlib.unzip(buffer, (err, buffer) => {
			  if (!err) {

					fs.writeFile('recetafirmada.pdf', buffer, (err) => {
					  if (err) throw err;

					  console.log('It\'s saved!');
					  res.send(200, "OK");	
					});			    
			  } else {
			   res.send(200, "OK");	
			  }
			});
		}
		
	}
}

//autentica
function login(req, res){
	/////// PDF 6 minutos para firmar
	let datetime = new Date().getTime();
	let datetimeEXP =datetime  + 60000;

	let secretInterno = 'AjfM0QA2hKYAXQ@rx_506_soin@hA4KsN0P2OA7uwHsih' ; //secreto interno para el access token
	let theKey	='52583034507233354336363032303132'; //llave para encrytar el acces token

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

	tokenData = {
		"jti":"token", 
		"iss":"rxFirmaInterno",
		"token": datetime,
		"exp": datetime.toString().substring(0,10),
		"url":"http://localhost:3000/loginResponse",		
		"accessToken" : encrypted.toUpperCase()
	}
	//secreto compartido
	let secret ="0kQZrhqOMP7Xjtmi@rx_506_soin@8qDN4pebwmXFcMAZ";
	var token =  jwt.encode(tokenData,secret,'HS512')

	console.log(token);

	request.get('https://firmadigitallocal.com:52900/FirmaDigitalServer?OP=autentica&data='+token, {}, (error, res2, body) => {
	  if (error) {
	    console.error(error)
	    return
	  }
	  console.log(`statusCode: ${res2.statusCode}`)
	  res.send(200, "OK");	
	})
}

//respuesta para el logueo
function loginResponse(req, res){
	
	if(req.query.METHOD!= undefined){
		console.log('METHOD '+req.query.METHOD);
		console.log('token '+req.query.token);
		console.log('data '+req.query.data)

		if(req.query.METHOD=='sendError'){
			console.log('mensaje '+req.query.MSG)
		}
		
		res.send(200,"OK");		
	}
	else{
		console.log('token '+req.body.token);
		let secret ="0kQZrhqOMP7Xjtmi@rx_506_soin@8qDN4pebwmXFcMAZ"
		
		let data =req.body;

		// console.log(data)
		//validar si esta definido data.signedMSG
		var token =  jwt.decode(data.data, secret, 'HS512')
		console.log(token.sub);

		var array = token.sub.split(",")
		console.log("primer array");
		// console.log(array[0]);
		console.log(array[1]);

		//saber si es fisica o juridica
		console.log(array[2]);

		//saber nombre
		console.log(array[4]);

		//saber apellido
		console.log(array[5]);

		//saber identificacion 
		console.log(array[6]);
		console.log(array[6].substring(18,array[6].length));
		res.send(200,"OK");		

	}
}

// responde el installer
async function fileInstaller(req, res){
	let fileDataBinary = fs.readFileSync(path.resolve(__dirname,'../public/TMP_file.zip'));

	let filePath =  path.resolve(__dirname,'../public/TMP_file.zip') // or any file format

	  // Check if file specified by the filePath exists 
	  fs.exists(filePath, function(exists){
	      if (exists) {     
	        // Content-type is very interesting part that guarantee that
	        // Web browser will handle response in an appropriate manner.
	        res.writeHead(200, {
	          "Content-Type": "application/octet-stream",
	          "Content-Disposition": "attachment; filename=FirmaDigitalInstaller.jar" 
	        });
	        fs.createReadStream(filePath).pipe(res);
	      } else {
	        res.writeHead(400, {"Content-Type": "text/plain"});
	        res.end("ERROR File does not exist");
	      }
	    });


	// let texto ="url=http://localhost:3000/login.cfc";
	// token +="token="+ new Date().getTime();
	// token +="proceso=Login";
	// //token +="checksum=";// tengo que analizar que hacer con este

	// // se crea el txt que debo agregar al jar
	// fs.writeFile('parametros.txt', texto, (err) => {
	//   if (err) throw err;

	//   	//descomprimo el jar 
	//   	const buffer = Buffer.from(fileDataBinary, 'base64');
	// 	zlib.unzip(buffer, (err, buffer) => {
	// 	  if (!err) {
	// 	  	gzip(fileDataBinary, 'Buffer')
	// 		  .then((compressed) => {
			  	
	// 		})
							    
	// 	  } else {
	// 	   res.send(200, "OK");	
	// 	  }
	// 	});


	// });	
}


// el puerto solo responde a una ruta en concreta
function port(req, res){
	if(req.query.METHOD!= undefined){
		console.log('METHOD '+req.query.METHOD);
		console.log('token '+req.query.token);
		console.log('port '+req.query.port)

		if(req.query.METHOD=='sendError'){
			console.log('mensaje '+req.query.MSG)
		}
		
		res.send(200,"OK");		
	}
}

//retornar el lib
function getFirmaDigitalServerlib(req, res){
	console.log('getFirmaDigitalServerlib');
	let filePath =  path.resolve(__dirname,'../public/FirmaDigital/plugin/lib/FirmaDigitalServer.lib');

	// Check if file specified by the filePath exists 
  	fs.exists(filePath, function(exists){
      if (exists) {     
        // Content-type is very interesting part that guarantee that
        // Web browser will handle response in an appropriate manner.
        res.writeHead(200, {
          "Content-Type": "application/octet-stream",
          "Content-Disposition": "attachment; filename=FirmaDigitalServer.lib"
        });
        fs.createReadStream(filePath).pipe(res);
      } else {
        response.writeHead(400, {"Content-Type": "text/plain"});
        response.end("ERROR File does not exist");
      }
    });
}

//retornar el getFirmaDigitalServerJAR
function getFirmaDigitalServerJAR(req, res){
	console.log('getFirmaDigitalServerJAR');
	let filePath =  path.resolve(__dirname,'../public/FirmaDigital/plugin/lib/FirmaDigitalServer.jar');

	// Check if file specified by the filePath exists 
  	fs.exists(filePath, function(exists){
      if (exists) {     
        // Content-type is very interesting part that guarantee that
        // Web browser will handle response in an appropriate manner.
        res.writeHead(200, {
          "Content-Type": "application/octet-stream",
          "Content-Disposition": "attachment; filename=FirmaDigitalServer.jar"
        });
        fs.createReadStream(filePath).pipe(res);
      } else {
        response.writeHead(400, {"Content-Type": "text/plain"});
        response.end("ERROR File does not exist");
      }
    });
}

//retornar el getFirmaDigitalServerJAR
function getlibASEP11dylib(req, res){
	console.log('libASEP11');
	let filePath =  path.resolve(__dirname,'../public/FirmaDigital/plugin/lib/libASEP11.dylib');

	// Check if file specified by the filePath exists 
  	fs.exists(filePath, function(exists){
      if (exists) {     
        // Content-type is very interesting part that guarantee that
        // Web browser will handle response in an appropriate manner.
        res.writeHead(200, {
          "Content-Type": "application/octet-stream",
          "Content-Disposition": "attachment; filename=libASEP11.dylib"
        });
        fs.createReadStream(filePath).pipe(res);
      } else {
        response.writeHead(400, {"Content-Type": "text/plain"});
        response.end("ERROR File does not exist");
      }
    });
}



module.exports = {
	singPDF,
    login,
    loginComponente,    
    port,   
    loginResponse,
    fileInstaller,
    getFirmaDigitalServerlib,
    getFirmaDigitalServerJAR,
    getlibASEP11dylib
}