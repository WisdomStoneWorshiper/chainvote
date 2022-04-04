const sgMail = require('@sendgrid/mail')
require('dotenv').config()
sgMail.setApiKey("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")

const msgTemplate = (email, subject, content) => {
    return {
        to: `${email}`, // Change to your recipient
        from: 'fyp.chainvote@gmail.com', // Change to your verified sender
        subject: `${subject}`,
        // text: `${content}`,
        html: `<p>${content}</p>`,
      }
}

const sendEmail = (email, subject = "", content = "") => {
    return sgMail.send(msgTemplate(email, subject, content));
}

module.exports = sendEmail;