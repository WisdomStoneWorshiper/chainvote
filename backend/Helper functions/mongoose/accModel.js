const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const regisSchema = new Schema({
    itsc : {
        type: String,
        required: true,
        unique: true,
        index: true
    },
    key : {
        type: String,
        required: true
    },
    accountName: {
        type: String,
        unique: true
    },
    // publicKey : {
    //     type: String,
    //     unique: true
    // },
    created : {
        type : Boolean,
        required: true
    }
}, {timestamps : true});

const Account = mongoose.model('Account', regisSchema);

module.exports = Account;