const express = require('express');
const eosDriver = require('../../Helper functions/eosDriver')
const {ecc} = require("eosjs/dist/eosjs-ecc-migration")

const router = express.Router();

const generateKeyPair = async () => {
    const tempPrivate = await ecc.randomKey(undefined,{secureEnv : true});
    return {
        private : `${tempPrivate}`,
        public : `${ecc.privateToPublic(tempPrivate)}`
    };
}

const accountPlaceholder = (name, publicKey) => {
    return (
        {
            account: 'eosio',
            name: `newaccount`, // new account name
            authorization: [{
              actor: 'main', // which account generates it
              permission: 'active',
            }],
            data: {
              creator: 'main',
              name: `${name}`,
              owner: {
                threshold: 1,
                keys: [{
                  key: `${publicKey}`,
                  weight: 1
                }],
                accounts: [],
                waits: []
              },
              active: {
                threshold: 1,
                keys: [{
                  key: `${publicKey}`,
                  weight: 1
                }],
                accounts: [],
                waits: []
              },
            }
          }
    );
}

router.get('/generate', async (req, res) => {
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

    const temp = await generateKeyPair();
    res.json(temp);
})


module.exports = router

