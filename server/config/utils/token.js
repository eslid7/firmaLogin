const bearer = require('token-extractor');
const jwt = require('jsonwebtoken')

module.exports.extractToken = function extractToken(req) {
	return new Promise((resolve, reject) => {
		bearer(req, (err, token)=>{
			if(err) return reject(err)

			return resolve(token)
		})

	})
}


module.exports.verify = function verify(token, options) {
	return new Promise((resolve, reject) => {
		jwt.verify(token, 'b33dd00', (err, decoded) => {
			if (err) return reject(err)

			return resolve(decoded)
		})
	})
}