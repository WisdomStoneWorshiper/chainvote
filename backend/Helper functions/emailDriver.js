const sgMail = require('@sendgrid/mail')
require('dotenv').config()
sgMail.setApiKey(process.env.SG_API)

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
