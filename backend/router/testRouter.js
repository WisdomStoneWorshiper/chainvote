const express = require('express');
const Account = require("../Helper functions/mongoose/accModel")
const generateKeyPair = require("../Helper functions/keyPairGeneration")
const getRandomString = require("../Helper functions/randomStringGeneration")
const router = express.Router();
const check = false;

router.use((req, res, next) => {
    if(req.params.auth != process.env.TEST_AUTH && check){
        res.status(400).json({
            error : true,
            message : "Auth key to access test router is required"
        })
    }
    next();
})


router.post('/', async (req, res) => {
    const temp = new Account({itsc : req.body.itsc, key : getRandomString(5), accountName: req.body.itsc, created : false});
    temp.save().then(result => {
        res.json(result);
    })
    .catch(err => {
	console.log(err);
        res.json({
            error : true,
            message : "Cannot create test account"
        });
    })
})

router.delete('/', async(req, res) => {
    const {itsc} = req.body;
    Account.findOneAndDelete({itsc: itsc}, (err, result) => {
        if(!err){
            res.json({
                error: false
            });
        }
        else{
            res.status(500).json({
                error: true,
                message: "cannot find/ delete"
            })
        }
    })
})

router.post('/pair', async (req, res) => {
    const temp = await generateKeyPair();
    res.json(temp);
})

module.exports = router
