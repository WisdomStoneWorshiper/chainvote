const express = require('express');
const router = express.Router();
require('dotenv').config();

router.use((req,res,next) => {
    const {authKey} = res.body;
    if(authKey == undefined || authKey != process.env.AUTHKEY){
        res.status(404).json({
            error : true,
            message : "invalid account"
        });
    }
    next();
});

const actionPlaceholder = (action, data) => {
    return         {
        account: 'main',
        name: action, // new account name
        authorization: [{
          actor: 'main', // which account generates it
          permission: 'active',
        }],
        data: data
      }
}

router.post("/edit", async (req, res) => {
//format is name and is_active
    const {name, is_active} = req.body;
    const transaction = await e
})

module.exports = router;
