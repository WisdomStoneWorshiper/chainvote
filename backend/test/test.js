let app = require("../index")
let Account = require("../Helper functions/mongoose/accModel")
let eosDriver = require("../Helper functions/eosDriver")
let {accountPlaceholder} = require("../Helper functions/eosPlaceholder")
let axios = require("axios")

let chai = require("chai")
let chaiHttp = require('chai-http')
let should = chai.should()

require('dotenv').config()

chai.use(chaiHttp)

function getRandomString(length) {
    var randomChars = 'abcdefghijklmnopqrstuvwxyz';
    var result = '';
    for ( var i = 0; i < length; i++ ) {
        result += randomChars.charAt(Math.floor(Math.random() * randomChars.length));
    }
    return result;
}

describe("Full testing", function (){

    before(function(done){
        this.timeout(10000);
        app.on("serverStart", () => {
            done();
        })
    });
    
    describe('/registration', function () {
    
        beforeEach( async function  () {
            this.timeout(2000);
            await Account.deleteOne({itsc : process.env.REAL_NAME});
            let temp = new Account({
                itsc: process.env.REAL_NAME,
                key : process.env.CONF_KEY,
                accountName : null,
                // publicKey : null,
                created : false
            });
            return temp.save()
        })

        it("Should register properly", (done) => {
            let itsc = {itsc : process.env.REAL_NAME};

            chai.request(app)
            .post("/registration")
            .send(itsc)
            .end((err, res) => {
                res.should.have.status(200);
                res.body.should.have.property("error").eql(false);
                done();
            })
        })

        it("Should reject registration", (done) => {
            let itsc = {itsc: process.env.FAKE_NAME};

            chai.request(app)
            .post("/registration")
            .send(itsc)
            .end((err, res) => {
                res.should.have.status(500);
                res.body.should.have.property("error").eql(true);
                res.body.should.have.property("message").eql("Invalid itsc")
                done();
            })
        })

        afterEach(function () {
            return Account.deleteOne({itsc : process.env.REAL_NAME});
        })
    })

    describe("/account/create", function () {

        let keypair = null;

        let fixedName = null;

        beforeEach(async function() {
            this.timeout(3000); //account generation
            let temp = new Account({
                itsc: process.env.REAL_NAME,
                key : process.env.CONF_KEY,
                accountName : null,
                // publicKey : null,
                created : false
            });
            await temp.save();

            fixedName = getRandomString(12);

            let result = await chai.request(app)
            .get("/account/pair")
            keypair = result.body;
        })

        this.timeout(100000)


        it("should reject due to invalid itsc", (done) => {
            chai.request(app)
            .post("/account/create")
            .send({
                itsc : process.env.FAKE_NAME,
                key : process.env.CONF_KEY,
                accname: fixedName,
                // pkey : keypair.public
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
                itsc : process.env.REAL_NAME,
                key : process.env.FAKE_KEY,
                accname: fixedName,
                // pkey : keypair.public
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
                itsc : process.env.REAL_NAME,
                key : process.env.CONF_KEY,
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
                itsc : process.env.REAL_NAME,
                key : process.env.CONF_KEY,
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

        it("should reject due to invalid pkey", (done) => {
            chai.request(app)
            .post("/account/create")
            .send({
                itsc : process.env.REAL_NAME,
                key : process.env.CONF_KEY,
                accname: fixedName,
                pkey : "Gibberish"
            })
            .end((err, res) => {
                res.should.have.status(500);
                res.body.should.have.property("error").eql(true);
                res.body.should.have.property("message").eql("unrecognized public key format");
                done()
            })
        })

        it("should create account", (done) => {
            chai.request(app)
            .post("/account/create")
            .send({
                itsc : process.env.REAL_NAME,
                key : process.env.CONF_KEY,
                accname: fixedName,
                // pkey : keypair.public
            })
            .end((err, res) => {
                res.should.have.status(200);
                res.body.should.have.property("error").eql(false);
                done()
            })
        })

        it("should reject due to account has been created before", async () => {
            await chai.request(app)
            .post("/account/create")
            .send({
                itsc : process.env.REAL_NAME,
                key : process.env.CONF_KEY,
                accname: fixedName,
                // pkey : keypair.public
            })
            .then(res => {
                return chai.request(app)
                .post("/account/create")
                .send({
                    itsc : process.env.REAL_NAME,
                    key : process.env.CONF_KEY,
                    accname: fixedName,
                    // pkey : keypair.public
                })
                .then((res) => {
                    res.should.have.status(500);
                    res.body.should.have.property("error").eql(true);
                    res.body.should.have.property("message").eql("Account has already been created");
                })
            })
        })

        afterEach(function () {
            return Account.deleteMany({itsc : process.env.REAL_NAME});
        })

    })

    describe("/account/confirm", function(){
        let keypair, fixedName;

        console.log(fixedName)
        beforeEach( async function() {
            this.timeout(3000); //account generation
            let temp = new Account({
                itsc: process.env.REAL_NAME,
                key : process.env.CONF_KEY,
                accountName : null,
                // publicKey : null,
                created : true
            });
            await temp.save();

            let result = await chai.request(app)
            .get("/account/pair")
            
            keypair = result.body;
            fixedName = getRandomString(12);

            await eosDriver.transact({
                actions: [
                    accountPlaceholder(fixedName, keypair.public)
                ]
               }, {
                blocksBehind: 3,
                expireSeconds: 30,
               }) //to save the account

        })

        it("should fail link via itsc", (done) => {
            chai.request(app)
            .post("/account/confirm")
            .send({
                itsc : process.env.FAKE_NAME,
                key : process.env.CONF_KEY,
                accname: fixedName,
                // pkey : keypair.public
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
                itsc : process.env.REAL_NAME,
                key : process.env.FAKE_KEY,
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
                itsc : process.env.REAL_NAME,
                key : process.env.CONF_KEY,
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
                itsc : process.env.REAL_NAME,
                key : process.env.CONF_KEY,
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
        //     .post("/account/confirm")
        //     .send({
        //         itsc : process.env.REAL_NAME,
        //         key : process.env.CONF_KEY,
        //         accname: fixedName,
        //         pkey : "Gibberish"
        //     })
        //     .end((err, res) => {
        //         res.should.have.status(500);
        //         res.body.should.have.property("error").eql(true);
        //         res.body.should.have.property("message").eql("unrecognized public key format");
        //         done()
        //     })
        // })


        it("link successfully", (done) => {
            chai.request(app)
            .post("/account/confirm")
            .send({
                itsc : process.env.REAL_NAME,
                key : process.env.CONF_KEY,
                accname: fixedName,
                // pkey : keypair.public
            })
            .end((err,res) => {
                res.should.have.status(200);
                res.body.should.have.property("error").eql(false);
                res.body.should.not.have.property("message");
                done()
            })
        });

        it("should fail link via public", async () => {
            await chai.request(app)
            .post("/account/confirm")
            .send({
                itsc : process.env.REAL_NAME,
                key : process.env.CONF_KEY,
                accname: fixedName,
                // pkey : keypair.public
            })
            .then(res => {
                return chai.request(app)
                .post("/account/confirm")
                .send({
                    itsc : process.env.REAL_NAME,
                    key : process.env.CONF_KEY,
                    accname: fixedName,
                    // pkey : keypair.public
                })
                .then(res => {
                    res.should.have.status(500);
                    res.body.should.have.property("error").eql(true);
                    res.body.should.have.property("message").eql("Account has been linked");
                })
            })
        });

        afterEach(function () {
            return Account.deleteOne({itsc : process.env.REAL_NAME});
        })
    });

});







