'use strict'

const bodyParser = require('body-parser')
const express = require('express')
const session = require('express-session')
const routes = require('../routes')


module.exports.initRoutes = function initRoutes(app) {
  app.use('/', routes)
}

module.exports.initViewsEngine = function initViewsEngine(app) {
  app.set('view engine', 'ejs')
  app.set('views', './server/views')
  app.use('/static',express.static('./server/public'))
}

module.exports.init = () => {

  const app = express()
  app.use(bodyParser.json({ limit: '50mb', extended: true }))
  app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }))  
  // this.initDB(app)
  this.initRoutes(app)
  this.initViewsEngine(app)
  app
    .listen(3000, () => {
      console.log(
        'App listening on port %s, in environment %s!',
       3000
      )
      console.log('**********************')
      console.log('contab-server online')
      console.log('**********************')
    })
    .on('error', err => {
      console.error(err)
    })
  return app
}
