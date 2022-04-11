let app = require("../../index")
let Account = require("../../Helper functions/mongoose/accModel")
let eosDriver = require("../../Helper functions/eosDriver")
let {accountPlaceholder} = require("../../Helper functions/eosPlaceholder")
let getRandomString = require("../../Helper functions/randomStringGeneration")

let chai = require("chai")
let chaiHttp = require('chai-http')
let should = chai.should()

require('dotenv').config()

chai.use(chaiHttp)

describe("Full testing", function (){

    const accountName = getRandomString(7);
    const keyConf = getRandomString(5);
    const fixedName = getRandomString(12);
    let keypair = {};

    before(function(done){
        this.timeout(10000);
        app.on("serverStart", () => {
            done();
        })

        chai.request(app)
        .post("/test/pair")
        .then( result => {
            keypair = result.body
        })
    }); 
    
    describe('/registration', function () {
    
        beforeEach( async function  () {
            let temp = new Account({
                itsc: accountName,
                key : keyConf,
                accountName : accountName,
                created : false
            });
            return temp.save()
        })

        it("Should register properly", (done) => {

            chai.request(app)
            .post("/registration")
            .send({
                itsc : accountName
            })
            .end((err, res) => {
                res.should.have.status(200);
                res.body.should.have.property("error").eql(false);
                done();
            })
        })

        it("Should reject registration", (done) => {

            chai.request(app)
            .post("/registration")
            .send({
                itsc : getRandomString(7)
            })
            .end((err, res) => {
                res.should.have.status(500);
                res.body.should.have.property("error").eql(true);
                res.body.should.have.property("message").eql("Invalid itsc")
                done();
            })
        })

        afterEach(function () {
            return Account.deleteOne({itsc : accountName, accountName : accountName});
        })
    })

    describe("/account/create", function () {

        beforeEach(async function() {
            let temp = new Account({
                itsc: accountName,
                key : keyConf,
                accountName : accountName,
                created : false
            });
            await temp.save();

        })



        it("should reject due to invalid itsc", (done) => {
            chai.request(app)
            .post("/account/create")
            .send({
                itsc : getRandomString(7),
                key : keyConf,
                accname: fixedName,
                pkey : keypair.public
            })
            .end((err, res) => {
                res.should.have.status(500);
                res.body.should.have.property("error").eql(true);
                res.body.should.have.property("message").eql("Invalid itsc");
                done()
            })
        })
        
        it("should reject due to invalid key", (done) => {
            chai.request(app)
            .post("/account/create")
            .send({
                itsc : accountName,
                key : getRandomString(5),
                accname: fixedName,
                pkey : keypair.public
            })
            .end((err, res) => {
                res.should.have.status(500);
                res.body.should.have.property("error").eql(true);
                res.body.should.have.property("message").eql("Invalid confirmation key");
                done()
            })
        })

        it("should reject due to invalid accname (extra char)", (done) => { //bad acc name
            chai.request(app)
            .post("/account/create")
            .send({
                itsc : accountName,
                key : keyConf,
                accname: (fixedName + "a"),
                // pkey : keypair.public
            })
            .end((err, res) => {
                res.should.have.status(500);
                res.body.should.have.property("error").eql(true);
                res.body.should.have.property("message").eql("Invalid account name");
                done()
            })
        })

        it("should reject due to invalid accname (invalid initial char)", (done) => { //bad acc name
            chai.request(app)
            .post("/account/create")
            .send({
                itsc : accountName,
                key : keyConf,
                accname: "." + getRandomString(11),
                // pkey : keypair.public
            })
            .end((err, res) => {
                res.should.have.status(500);
                res.body.should.have.property("error").eql(true);
                res.body.should.have.property("message").eql("Invalid account name");
                done()
            })
        })

        // it("should reject due to invalid pkey", (done) => {
        //     chai.request(app)
        //     .post("/account/create")
        //     .send({
        //         itsc : accountName,
        //         key : keyConf,
        //         accname: fixedName,
        //         pkey : "Gibberish"
        //     })
        //     .end((err, res) => {
        //         res.should.have.status(500);
        //         res.body.should.have.property("error").eql(true);
        //         res.body.should.have.property("message").eql("Name should be less than 13 characters, or less than 14 if last character is between 1-5 or a-j, and only contain the following symbols .12345abcdefghijklmnopqrstuvwxyz");
        //         done()
        //     })
        // })

        // it("should create account", (done) => {
        //     chai.request(app)
        //     .post("/account/create")
        //     .send({
        //         itsc : process.env.REAL_NAME,
        //         key : process.env.CONF_KEY,
        //         accname: fixedName,
        //         // pkey : keypair.public
        //     })
        //     .end((err, res) => {
        //         res.should.have.status(200);
        //         res.body.should.have.property("error").eql(false);
        //         done()
        //     })
        // })

        // it("should reject due to account has been created before", async () => {
        //     await chai.request(app)
        //     .post("/account/create")
        //     .send({
        //         itsc : process.env.REAL_NAME,
        //         key : process.env.CONF_KEY,
        //         accname: fixedName,
        //         // pkey : keypair.public
        //     })
        //     .then(res => {
        //         return chai.request(app)
        //         .post("/account/create")
        //         .send({
        //             itsc : process.env.REAL_NAME,
        //             key : process.env.CONF_KEY,
        //             accname: fixedName,
        //             // pkey : keypair.public
        //         })
        //         .then((res) => {
        //             res.should.have.status(500);
        //             res.body.should.have.property("error").eql(true);
        //             res.body.should.have.property("message").eql("Account has already been created");
        //         })
        //     })
        // })

        afterEach(function () {
            return Account.deleteMany({itsc : accountName});
        })

    })

    describe("/account/confirm", function(){
        beforeEach( async function() {
            let temp = new Account({
                itsc: accountName,
                key : keyConf,
                accountName : accountName,
                created : false
            });
            await temp.save();
        })

        it("should fail link via itsc", (done) => {
            chai.request(app)
            .post("/account/confirm")
            .send({
                itsc : getRandomString(7),
                key : keyConf,
                accname: fixedName,
            })
            .end((err,res) => {
                res.should.have.status(500);
                res.body.should.have.property("error").eql(true);
                res.body.should.have.property("message").eql("Invalid itsc");
                done()
            })
        });

        it("should fail link via key", (done) => {
            chai.request(app)
            .post("/account/confirm")
            .send({
                itsc : accountName,
                key : getRandomString(5),
                accname: fixedName,
                // pkey : keypair.public
            })
            .end((err,res) => {
                res.should.have.status(500);
                res.body.should.have.property("error").eql(true);
                res.body.should.have.property("message").eql("Invalid confirmation key");
                done()
            })
        });
        it("should reject due to invalid accname (extra char)", (done) => { //bad acc name
            chai.request(app)
            .post("/account/confirm")
            .send({
                itsc : accountName,
                key : keyConf,
                accname: (fixedName + "a"),
                // pkey : keypair.public
            })
            .end((err, res) => {
                res.should.have.status(500);
                res.body.should.have.property("error").eql(true);
                res.body.should.have.property("message").eql("Invalid account name");
                done()
            })
        })

        it("should reject due to invalid accname (invalid initial char)", (done) => { //bad acc name
            chai.request(app)
            .post("/account/confirm")
            .send({
                itsc : accountName,
                key : keyConf,
                accname: "." + getRandomString(11),
            })
            .end((err, res) => {
                res.should.have.status(500);
                res.body.should.have.property("error").eql(true);
                res.body.should.have.property("message").eql("Invalid account name");
                done()
            })
        })

        // it("link successfully", (done) => {
        //     chai.request(app)
        //     .post("/account/confirm")
        //     .send({
        //         itsc : process.env.REAL_NAME,
        //         key : process.env.CONF_KEY,
        //         accname: fixedName,
        //         // pkey : keypair.public
        //     })
        //     .end((err,res) => {
        //         res.should.have.status(200);
        //         res.body.should.have.property("error").eql(false);
        //         res.body.should.not.have.property("message");
        //         done()
        //     })
        // });

        // it("should fail link via public", async () => {
        //     await chai.request(app)
        //     .post("/account/confirm")
        //     .send({
        //         itsc : process.env.REAL_NAME,
        //         key : process.env.CONF_KEY,
        //         accname: fixedName,
        //         // pkey : keypair.public
        //     })
        //     .then(res => {
        //         return chai.request(app)
        //         .post("/account/confirm")
        //         .send({
        //             itsc : process.env.REAL_NAME,
        //             key : process.env.CONF_KEY,
        //             accname: fixedName,
        //             // pkey : keypair.public
        //         })
        //         .then(res => {
        //             res.should.have.status(500);
        //             res.body.should.have.property("error").eql(true);
        //             res.body.should.have.property("message").eql("Account has been linked");
        //         })
        //     })
        // });

        afterEach(function () {
            return Account.deleteOne({itsc : accountName});
        })
    });

    describe("/contract/login", function(){
        beforeEach( async function() {
            let temp = new Account({
                itsc: accountName,
                key : keyConf,
                accountName : accountName,
                created : false
            });
            return temp.save();
        })

        it("Should provide login", async function (){
            await Account.updateOne({itsc : accountName}, {accountName: "Correct"});

            let res = await chai.request(app)
            .post("/contract/login")
            .send({
                itsc : accountName,
            })

            res.should.have.status(200);
            res.body.should.have.property("error").eql(false);
            res.body.should.have.property("accountName").eql("Correct");
            
        });

        it("Should not provide login", async function (){
            let res = await chai.request(app)
            .post("/contract/login")
            .send({
                itsc : accountName,
            })

            res.should.have.status(200);
            res.body.should.have.property("error").eql(false);
            res.body.should.have.property("accountName").eql(null);
        });

        this.afterEach( async function () {
            await Account.deleteOne({itsc : accountName});
        })
    })

});







