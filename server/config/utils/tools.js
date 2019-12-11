// útiles
const crypto = require('crypto')

module.exports = {
  encryptData(dataToEncrypt, algorithm, key, errorMsn) {
    let output = ''
    try {
      const keyHash = crypto
        .createHash('sha256')
        .update(key)
        .digest('base64')
      const keyBuf = Buffer.from(Array(32))

      keyBuf.write(keyHash, 'base64')

      const ivBuf = Buffer.from(Array(16))
      const cipher = crypto.createCipheriv(algorithm, keyBuf, ivBuf)

      output =
        cipher.update(dataToEncrypt, 'utf-8', 'base64') + cipher.final('base64')
    } catch (err) {
      console.log(`Error al encriptar ${errorMsn}. ${err}`)
    }
    return output
  },
  decryptData(dataToDencrypt, algorithm, key, errorMsn) {
    let decrypted = ''
    try {
      const keyHash = crypto
        .createHash('sha256')
        .update(key)
        .digest('base64')
      const keyBuf = Buffer.from(Array(32))

      keyBuf.write(keyHash, 'base64')

      const ivBuf = Buffer.from(Array(16))
      const deCipher = crypto.createDecipheriv(algorithm, keyBuf, ivBuf)
      decrypted =
        deCipher.update(dataToDencrypt, 'base64', 'utf-8') +
        deCipher.final('utf-8')
    } catch (err) {
      console.log(`Error al Desencriptar ${errorMsn}. ${err}`)
    }
    return decrypted
  },
}
