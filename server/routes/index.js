////routes

'use strict'

const express = require('express')
const dataController = require('../controllers/dataController')
const signController = require('../controllers/signController')
const xadesController = require('../controllers/xadesController')
const signLotePDFController = require('../controllers/signLotePDFController')

const router = express.Router()
router.route('/login').get(dataController.login);
router.route('/singPDF').get(dataController.singPDF);

router.route('/PDFarray').get(dataController.PDFarray);
router.route('/PDFarrayRESPONSE').post(dataController.PDFarrayRESPONSE);
router.route('/PDFarrayRESPONSE').get(dataController.PDFarrayRESPONSE);



router.route('/login.cfc').get(dataController.loginComponente);
router.route('/login.cfc').post(dataController.loginComponente);

//repuestas para el logueo
router.route('/loginResponse').post(dataController.loginResponse);
router.route('/loginResponse').get(dataController.loginResponse);

//verificacion de un PDF
router.route('/verifyPDF').get(dataController.verifyPDF);


router.route('/fileInstaller').get(dataController.fileInstaller);

router.route('/home/public/FirmaDigital/plugin/sign.cfc').get(dataController.port);

router.route('/home/public/FirmaDigital/plugin/lib/FirmaDigitalServer.lib').get(dataController.getFirmaDigitalServerlib);

router.route('/home/public/FirmaDigital/plugin/lib/FirmaDigitalServer.jar').get(dataController.getFirmaDigitalServerJAR);

router.route('/home/public/FirmaDigital/plugin/lib/libASEP11.dylib').get(dataController.getlibASEP11dylib);

router.route('/fileInstallerReal').get(dataController.fileInstallerReal);

router.route('/seeeCard').get(dataController.seeeCard);

router.route('/loginWhitSign/:id').get(signController.loginWhitSign);

router.route('/tryXades/:id').get(xadesController.tryXades);


router.route('/singPDFLote').get(signLotePDFController.singPDFLote);

router.route('/PDFResponse').get(signLotePDFController.PDFResponse);
router.route('/PDFResponse').post(signLotePDFController.PDFResponse);

module.exports = router