const express = require("express");
const router = express.Router();
const sgMail = require('../../Helper functions/emailDriver')

const Account = require("../../Helper functions/mongoose/accModel")

//waypoints to add
/*
    1. Check if the registration name is created
    2. Register the name and create a randomized code key
*/

// router.get("/check/:userId", async (req, res) => {
//     //Insert username checking function
//     //Return the result if it is valid
//     console.log(`Current ID check ${req.params.userId}`)
//     res.send("check userID route")
// });

function getRandomString(length) {
    var randomChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    var result = '';
    for ( var i = 0; i < length; i++ ) {
        result += randomChars.charAt(Math.floor(Math.random() * randomChars.length));
    }
    return result;
}

router.get('/test', async (req, res) => {
    const test = await sgMail(`irug.com@gmail.com`, "Email confirmation", "testkey").then(result => console.log(result))
    res.send("test done?")
})

router.post("/", async (req, res) => {
    const {name} = req.body;
    const result = await Account.find({name : name})
    .catch(err => {

    })
    if(result.length  <= 0){ //no acc found
        const saveAcc = new Account({name : name, key : getRandomString(5)})
        saveAcc.save()
        .then( result => {
            sgMail(`${name}@connect.ust.hk`, "Email confirmation", `Your confirmation key is ${saveAcc.key}`)//TODO handle mail limit?
            res.send(result)
        })
        .catch(err => {
            console.log(err)
            res.send("Unexpected Error")
        })
    }
    else{
        res.send("Account has been created!")
    }

});

module.exports = router;