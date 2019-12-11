// ServicesEmailTemplate
const config = require('../env')
console.log(config.route)
const serviceEmailTemplateLocation = `${config.route}`
const serviceEmailTemplateAppName = 'ContabPlus'
const serviceEmailTemplateFont = 'Helvetica Neue'

module.exports = {
  headMail() {
    return ''
  },
  footerMail() {
    return ''
  },
  accountConfirmation(param) {
    let templateEmail = this.headMail()
    templateEmail += `
			<table width="100%" cellspacing="0" cellpadding="0" border="0" valign="top">
				<tbody>
					<tr>
						<td valign="top" align="left" style="word-break:normal;border-collapse:collapse;font-family:proxima_nova,${serviceEmailTemplateFont},Helvetica,Arial,sans-serif;font-size:25px;line-height:30px;color:#555555;font-weight:100;letter-spacing:0.02em;padding:0px 20px 0px 20px">
							Hola ${param.name} ${param.lastName}
						</td>
					</tr>
				</tbody>
			</table>
			<br>
			<table width="100%" cellspacing="0" cellpadding="0" border="0" valign="top">
				<tbody>
					<tr>
						<td valign="top" align="left" style="word-break:normal;border-collapse:collapse;font-family:proxima_nova, ${serviceEmailTemplateFont},Helvetica,Arial,sans-serif;font-size:15px;line-height:20px;color:#555555;font-weight:300;letter-spacing:0.02em;padding:0px 20px 0px 20px">
							Para activar su cuenta en ${serviceEmailTemplateAppName}, necesita dar click a este link:
						</td>
					</tr>
					<tr>
						<td valign="top" align="left" style="word-break:normal;border-collapse:collapse;font-family:proxima_nova, ${serviceEmailTemplateFont},Helvetica,Arial,sans-serif;font-size:15px;line-height:20px;color:#555555;font-weight:300;letter-spacing:0.02em;padding:0px 20px 0px 20px">
							<a target="_blank" style="color:#EB8723;text-decoration:none" border="0" href="${serviceEmailTemplateLocation}/auth/accountConfirmation/${encodeURIComponent(
      param.encryptData
    )}">Da click aquí</a>
						</td>
					</tr>
					<tr>
						<td valign="top" align="left" style="word-break:normal;border-collapse:collapse;font-family:proxima_nova, ${serviceEmailTemplateFont},Helvetica,Arial,sans-serif;font-size:15px;line-height:20px;color:#555555;font-weight:300;letter-spacing:0.02em;padding:0px 20px 0px 20px">
							Nuestros mejores deseos, equipo de ${serviceEmailTemplateAppName}
						</td>
					</tr>
				</tbody>
			</table>
		`
    templateEmail += this.footerMail()
    return templateEmail
  },
}
