'use strict'

const express = require('express')
const dataController = require('../controllers/dataController')

const router = express.Router()
router.route('/login').get(dataController.login);
router.route('/singPDF').get(dataController.singPDF);



router.route('/login.cfc').get(dataController.loginComponente);
router.route('/login.cfc').post(dataController.loginComponente);

//repuestas para el logueo
router.route('/loginResponse').post(dataController.loginResponse);
router.route('/loginResponse').get(dataController.loginResponse);



router.route('/fileInstaller').get(dataController.fileInstaller);

router.route('/home/public/FirmaDigital/plugin/sign.cfc').get(dataController.port);

router.route('/home/public/FirmaDigital/plugin/lib/FirmaDigitalServer.lib').get(dataController.getFirmaDigitalServerlib);

router.route('/home/public/FirmaDigital/plugin/lib/FirmaDigitalServer.jar').get(dataController.getFirmaDigitalServerJAR);

router.route('/home/public/FirmaDigital/plugin/lib/getlibASEP11.dylib').get(dataController.getlibASEP11dylib);

module.exports = router