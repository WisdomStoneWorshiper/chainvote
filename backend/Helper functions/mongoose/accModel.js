const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const regisSchema = new Schema({
    name : {
        type: String,
        required: true,
        unique: true,
        index: true
    },
    key : {
        type: String,
        required: true
    }
}, {timestamps : true});

const Account = mongoose.model('Account', regisSchema);

module.exports = Account;