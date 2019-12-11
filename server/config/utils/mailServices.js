const nodemailer = require('nodemailer')

module.exports = {
  sendMail(mailContent, callback) {
    const smtpTransport = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: 'contabplusinfo@gmail.com',
        pass: 'Asp128CF',
      },
    })

    const contentToSend = {
      from: 'contabplusinfo <no-reply@contabplus>',
      to: mailContent.to,
      subject: mailContent.subject
        ? mailContent.subject
        : 'Mensaje de ContabPlus',
    }

    if (mailContent.isText) {
      contentToSend.text = mailContent.msn
    } else {
      contentToSend.html = mailContent.msn
    }

    if (mailContent.attachments) {
      contentToSend.attachments = mailContent.attachments
    }

    smtpTransport.sendMail(contentToSend, (error, info) => {
      let resp
      if (error) {
        console.log(`Error occurred${error}`)
        resp = {
          code: 404,
          message: `${error}`,
        }
      } else {
        console.log('Server responded with "%s"', info.response)
        resp = {
          code: 200,
          message: 'Email Enviado correctamente!',
        }
      }
      if (callback) {
        callback(resp)
      }
    })
  },
}
