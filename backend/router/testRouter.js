const express = require('express');
const eosDriver = require('../../Helper functions/eosDriver')
const {ecc} = require("eosjs/dist/eosjs-ecc-migration")
const Account = require("../Helper functions/mongoose/accModel")

const router = express.Router();

function getRandomString(length) {
    var randomChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    var result = '';
    for ( var i = 0; i < length; i++ ) {
        result += randomChars.charAt(Math.floor(Math.random() * randomChars.length));
    }
    return result;
}


router.get('/testAccount', async (req, res) => {
    // const {name} = req.body;
    // const tempKeypair = await generateKeyPair();
    // const accAction = accountPlaceholder(name, tempKeypair.public)

    // console.log(accAction);
    // const transaction = await eosDriver.transact({
    //     actions: [accAction]
    //    }, {
    //     blocksBehind: 3,
    //     expireSeconds: 30,
    //    });

    // console.log(transaction);
    // res.json(transaction);

    const temp = new Account({itsc : req.body.itsc, key : getRandomString(5), accountName: null, publicKey : null});
    temp.save().then(result => {
        res.json(result);
    })
    .catch(err => {
        res.json({
            error : true,
            message : "Cannot create test account"
        });
    })
})