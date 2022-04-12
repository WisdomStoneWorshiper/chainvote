let app = require("../../index")
let Account = require("../../Helper functions/mongoose/accModel")
let eosDriver = require("../../Helper functions/eosDriver")
let {addVoterPlaceholder} = require("../../Helper functions/eosPlaceholder")
let getRandomString = require("../../Helper functions/randomStringGeneration")

let chai = require("chai")
let chaiHttp = require('chai-http')
const { assert } = require("chai")
let should = chai.should()

require('dotenv').config()

chai.use(chaiHttp)

describe("Full testing", function (){

    const accountName = getRandomString(7);
    const keyConf = getRandomString(5);
    const fixedName = getRandomString(12);
    let keypair = {};

    const DAY_OFFSET = new Date(1000 * 3600 * 24);
    let currentDate = new Date();
    let startTime = new Date( currentDate.getTime() + DAY_OFFSET.getTime());
    let endTime = new Date( currentDate.getTime() + 2 * DAY_OFFSET.getTime());

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
    
    // describe('/registration', function () {
    
    //     beforeEach( async function  () {
    //         let temp = new Account({
    //             itsc: accountName,
    //             key : keyConf,
    //             accountName : accountName,
    //             created : false
    //         });
    //         return temp.save()
    //     })

    //     it("Should register properly", (done) => {

    //         chai.request(app)
    //         .post("/registration")
    //         .send({
    //             itsc : accountName
    //         })
    //         .end((err, res) => {
    //             res.should.have.status(200);
    //             res.body.should.have.property("error").eql(false);
    //             done();
    //         })
    //     })

    //     it("Should reject registration", (done) => {

    //         chai.request(app)
    //         .post("/registration")
    //         .send({
    //             itsc : getRandomString(7)
    //         })
    //         .end((err, res) => {
    //             res.should.have.status(500);
    //             res.body.should.have.property("error").eql(true);
    //             res.body.should.have.property("message").eql("Invalid itsc")
    //             done();
    //         })
    //     })

    //     afterEach(function () {
    //         return Account.deleteOne({itsc : accountName, accountName : accountName});
    //     })
    // })

    // describe("/account/create", function () {

    //     beforeEach(async function() {
    //         let temp = new Account({
    //             itsc: accountName,
    //             key : keyConf,
    //             accountName : accountName,
    //             created : false
    //         });
    //         await temp.save();

    //     })



    //     it("should reject due to invalid itsc", (done) => {
    //         chai.request(app)
    //         .post("/account/create")
    //         .send({
    //             itsc : getRandomString(7),
    //             key : keyConf,
    //             accname: fixedName,
    //             pkey : keypair.public
    //         })
    //         .end((err, res) => {
    //             res.should.have.status(500);
    //             res.body.should.have.property("error").eql(true);
    //             res.body.should.have.property("message").eql("Invalid itsc");
    //             done()
    //         })
    //     })
        
    //     it("should reject due to invalid key", (done) => {
    //         chai.request(app)
    //         .post("/account/create")
    //         .send({
    //             itsc : accountName,
    //             key : getRandomString(5),
    //             accname: fixedName,
    //             pkey : keypair.public
    //         })
    //         .end((err, res) => {
    //             res.should.have.status(500);
    //             res.body.should.have.property("error").eql(true);
    //             res.body.should.have.property("message").eql("Invalid confirmation key");
    //             done()
    //         })
    //     })

    //     it("should reject due to invalid accname (extra char)", (done) => { //bad acc name
    //         chai.request(app)
    //         .post("/account/create")
    //         .send({
    //             itsc : accountName,
    //             key : keyConf,
    //             accname: (fixedName + "a"),
    //             // pkey : keypair.public
    //         })
    //         .end((err, res) => {
    //             res.should.have.status(500);
    //             res.body.should.have.property("error").eql(true);
    //             res.body.should.have.property("message").eql("Invalid account name");
    //             done()
    //         })
    //     })

    //     it("should reject due to invalid accname (invalid initial char)", (done) => { //bad acc name
    //         chai.request(app)
    //         .post("/account/create")
    //         .send({
    //             itsc : accountName,
    //             key : keyConf,
    //             accname: "." + getRandomString(11),
    //             // pkey : keypair.public
    //         })
    //         .end((err, res) => {
    //             res.should.have.status(500);
    //             res.body.should.have.property("error").eql(true);
    //             res.body.should.have.property("message").eql("Invalid account name");
    //             done()
    //         })
    //     })

    //     // it("should reject due to invalid pkey", (done) => {
    //     //     chai.request(app)
    //     //     .post("/account/create")
    //     //     .send({
    //     //         itsc : accountName,
    //     //         key : keyConf,
    //     //         accname: fixedName,
    //     //         pkey : "Gibberish"
    //     //     })
    //     //     .end((err, res) => {
    //     //         res.should.have.status(500);
    //     //         res.body.should.have.property("error").eql(true);
    //     //         res.body.should.have.property("message").eql("Name should be less than 13 characters, or less than 14 if last character is between 1-5 or a-j, and only contain the following symbols .12345abcdefghijklmnopqrstuvwxyz");
    //     //         done()
    //     //     })
    //     // })

    //     // it("should create account", (done) => {
    //     //     chai.request(app)
    //     //     .post("/account/create")
    //     //     .send({
    //     //         itsc : process.env.REAL_NAME,
    //     //         key : process.env.CONF_KEY,
    //     //         accname: fixedName,
    //     //         // pkey : keypair.public
    //     //     })
    //     //     .end((err, res) => {
    //     //         res.should.have.status(200);
    //     //         res.body.should.have.property("error").eql(false);
    //     //         done()
    //     //     })
    //     // })

    //     // it("should reject due to account has been created before", async () => {
    //     //     await chai.request(app)
    //     //     .post("/account/create")
    //     //     .send({
    //     //         itsc : process.env.REAL_NAME,
    //     //         key : process.env.CONF_KEY,
    //     //         accname: fixedName,
    //     //         // pkey : keypair.public
    //     //     })
    //     //     .then(res => {
    //     //         return chai.request(app)
    //     //         .post("/account/create")
    //     //         .send({
    //     //             itsc : process.env.REAL_NAME,
    //     //             key : process.env.CONF_KEY,
    //     //             accname: fixedName,
    //     //             // pkey : keypair.public
    //     //         })
    //     //         .then((res) => {
    //     //             res.should.have.status(500);
    //     //             res.body.should.have.property("error").eql(true);
    //     //             res.body.should.have.property("message").eql("Account has already been created");
    //     //         })
    //     //     })
    //     // })

    //     afterEach(function () {
    //         return Account.deleteMany({itsc : accountName});
    //     })

    // })

    // describe("/account/confirm", function(){
    //     beforeEach( async function() {
    //         let temp = new Account({
    //             itsc: accountName,
    //             key : keyConf,
    //             accountName : accountName,
    //             created : false
    //         });
    //         await temp.save();
    //     })

    //     it("should fail link via itsc", (done) => {
    //         chai.request(app)
    //         .post("/account/confirm")
    //         .send({
    //             itsc : getRandomString(7),
    //             key : keyConf,
    //             accname: fixedName,
    //         })
    //         .end((err,res) => {
    //             res.should.have.status(500);
    //             res.body.should.have.property("error").eql(true);
    //             res.body.should.have.property("message").eql("Invalid itsc");
    //             done()
    //         })
    //     });

    //     it("should fail link via key", (done) => {
    //         chai.request(app)
    //         .post("/account/confirm")
    //         .send({
    //             itsc : accountName,
    //             key : getRandomString(5),
    //             accname: fixedName,
    //             // pkey : keypair.public
    //         })
    //         .end((err,res) => {
    //             res.should.have.status(500);
    //             res.body.should.have.property("error").eql(true);
    //             res.body.should.have.property("message").eql("Invalid confirmation key");
    //             done()
    //         })
    //     });
    //     it("should reject due to invalid accname (extra char)", (done) => { //bad acc name
    //         chai.request(app)
    //         .post("/account/confirm")
    //         .send({
    //             itsc : accountName,
    //             key : keyConf,
    //             accname: (fixedName + "a"),
    //             // pkey : keypair.public
    //         })
    //         .end((err, res) => {
    //             res.should.have.status(500);
    //             res.body.should.have.property("error").eql(true);
    //             res.body.should.have.property("message").eql("Invalid account name");
    //             done()
    //         })
    //     })

    //     it("should reject due to invalid accname (invalid initial char)", (done) => { //bad acc name
    //         chai.request(app)
    //         .post("/account/confirm")
    //         .send({
    //             itsc : accountName,
    //             key : keyConf,
    //             accname: "." + getRandomString(11),
    //         })
    //         .end((err, res) => {
    //             res.should.have.status(500);
    //             res.body.should.have.property("error").eql(true);
    //             res.body.should.have.property("message").eql("Invalid account name");
    //             done()
    //         })
    //     })

    //     // it("link successfully", (done) => {
    //     //     chai.request(app)
    //     //     .post("/account/confirm")
    //     //     .send({
    //     //         itsc : process.env.REAL_NAME,
    //     //         key : process.env.CONF_KEY,
    //     //         accname: fixedName,
    //     //         // pkey : keypair.public
    //     //     })
    //     //     .end((err,res) => {
    //     //         res.should.have.status(200);
    //     //         res.body.should.have.property("error").eql(false);
    //     //         res.body.should.not.have.property("message");
    //     //         done()
    //     //     })
    //     // });

    //     // it("should fail link via public", async () => {
    //     //     await chai.request(app)
    //     //     .post("/account/confirm")
    //     //     .send({
    //     //         itsc : process.env.REAL_NAME,
    //     //         key : process.env.CONF_KEY,
    //     //         accname: fixedName,
    //     //         // pkey : keypair.public
    //     //     })
    //     //     .then(res => {
    //     //         return chai.request(app)
    //     //         .post("/account/confirm")
    //     //         .send({
    //     //             itsc : process.env.REAL_NAME,
    //     //             key : process.env.CONF_KEY,
    //     //             accname: fixedName,
    //     //             // pkey : keypair.public
    //     //         })
    //     //         .then(res => {
    //     //             res.should.have.status(500);
    //     //             res.body.should.have.property("error").eql(true);
    //     //             res.body.should.have.property("message").eql("Account has been linked");
    //     //         })
    //     //     })
    //     // });

    //     afterEach(function () {
    //         return Account.deleteOne({itsc : accountName});
    //     })
    // });

    // describe("/contract/login", function(){
    //     beforeEach( async function() {
    //         let temp = new Account({
    //             itsc: accountName,
    //             key : keyConf,
    //             accountName : accountName,
    //             created : false
    //         });
    //         return temp.save();
    //     })

    //     it("Should provide login", async function (){
    //         await Account.updateOne({itsc : accountName}, {accountName: "Correct"});

    //         let res = await chai.request(app)
    //         .post("/contract/login")
    //         .send({
    //             itsc : accountName,
    //         })

    //         res.should.have.status(200);
    //         res.body.should.have.property("error").eql(false);
    //         res.body.should.have.property("accountName").eql("Correct");
            
    //     });

    //     it("Should not provide login", async function (){
    //         let res = await chai.request(app)
    //         .post("/contract/login")
    //         .send({
    //             itsc : accountName,
    //         })

    //         res.should.have.status(200);
    //         res.body.should.have.property("error").eql(false);
    //         res.body.should.have.property("accountName").eql(null);
    //     });

    //     this.afterEach( async function () {
    //         await Account.deleteOne({itsc : accountName});
    //     })
    // })

    // describe("/contract/getITSC", function(){
        
    //     beforeEach( async function() {
    //         let temp = new Account({
    //             itsc: accountName,
    //             key : keyConf,
    //             accountName : accountName,
    //             created : false
    //         });
    //         return temp.save();
    //     })

    //     it("should provide ITSC", async function () {
    //         await Account.updateOne({itsc : accountName}, {accountName: "Correct"});

    //         let res = await chai.request(app)
    //         .post("/contract/getITSC")
    //         .send({
    //             accountName : "Correct",
    //         })

    //         res.should.have.status(200);
    //         res.body.should.have.property("error").eql(false);
    //         res.body.should.have.property("itsc").eql(accountName);
    //     })

    //     it("should not provide ITSC", async function () {

    //         let res = await chai.request(app)
    //         .post("/contract/getITSC")
    //         .send({
    //             accountName : accountName,
    //         })

    //         res.should.have.status(500);
    //         res.body.should.have.property("error").eql(true);
    //         res.body.should.have.property("message").eql("Account has not been created! (ITSC = AccountName)");
    //     })

    //     this.afterEach( async function () {
    //         await Account.deleteOne({itsc : accountName});
    //     })

    // })

    describe("/contract/addvoter", function() {
        let campaignId = -1;
        const campaignName = getRandomString(8);
        this.timeout(1000000);
        before(async function () {
            console.log(accountName.toLowerCase())
            await eosDriver.transact({
                actions : [
                    {
                        account: process.env.ACC_NAME,
                        name: 'createcamp',
                        authorization: [{
                          actor: process.env.ACC_NAME,
                          permission: 'active',
                        }],
                        data: {
                            owner : process.env.ACC_NAME,
                            campaign_name : campaignName,
                            start_time_string : startTime.toISOString(),
                            end_time_string : endTime.toISOString()
                        },
                      },
                      {
                        account: process.env.ACC_NAME,
                        name: 'createvoter',
                        authorization: [{
                          actor: process.env.ACC_NAME,
                          permission: 'active',
                        }],
                        data: {
                           new_voter : accountName.toLowerCase()
                        },
                      }
                ]
                },
                {
                    blocksBehind: 3,
                    expireSeconds: 30,
                }
            )
            .catch(err => { assert.fail(err)})
            
            let currentBound = "";
            do {
                const table = await eosDriver.rpc.get_table_rows({
                    json: true,               // Get the response as json
                    code: `${process.env.ACC_NAME}`,      // Contract that we target
                    scope: `${process.env.ACC_NAME}`,         // Account that owns the data
                    table: 'campaign',        // Table name,
                    lower_bound : currentBound,
                    reverse: false,           // Optional: Get reversed data
                    show_payer: false          // Optional: Show ram payer
                });
        
                for (let i = 0; i < table["rows"].length; i++) {
                    if (table["rows"][i]["campaign_name"] == campaignName) {
                        console.log(`Found campaign id at ${table["rows"][i]["id"]}`)
                        campaignId = table["rows"][i]["id"]
                    }
                }
        
                if(table["more"]){
                    currentBound = table["next_key"]
                }
                else break;
        
            } while(campaignId == -1)
        
            if(campaignId == -1) {assert.fail("Cannot Find Campaign")}


            //ITSC Setup
            let temp = new Account({
                itsc: accountName,
                key : keyConf,
                accountName : accountName.toLowerCase(),
                created : false
            });
            return temp.save()
        });

        it("Should reject invalid campaignId", (done) => {

            chai.request(app)
            .post("/contract/addvoter")
            .send({
                itsc : [accountName],
                campaignId : 12345,
                owner : process.env.ACC_NAME
            })
            .end((err, res) => {
                console.log(res.body);
                res.should.have.status(400);
                res.body.should.have.property("error").eql(true);
                done();
            })
        })

        it("Should reject invalid itsc", (done) => {
            let temp = getRandomString(8);

            chai.request(app)
            .post("/contract/addvoter")
            .send({
                itsc : [temp],
                campaignId : campaignId,
                owner : process.env.ACC_NAME
            })
            .end((err, res) => {
                console.log(res.body)
                res.should.have.status(400);
                res.body.should.have.property("failed").eql([temp]);
                done();
            })
        })

        it("Should reject invalid owner account", (done) => {

            chai.request(app)
            .post("/contract/addvoter")
            .send({
                itsc : [accountName],
                campaignId : campaignId,
                owner : "__"
            })
            .end((err, res) => {
                console.log(res.body);
                res.should.have.status(400);
                res.body.should.have.property("error").eql(true);
                res.body.should.have.property("message").eql("Cannot find specified campaignId");
                done();
            })
        })

        it("Should insert account", (done) => {

            chai.request(app)
            .post("/contract/addvoter")
            .send({
                itsc : [accountName],
                campaignId : campaignId,
                owner : process.env.ACC_NAME
            })
            .end((err, res) => {
                console.log(res.body);
                res.should.have.status(200);
                res.body.should.have.property("error").eql(false);
                done();
            })
        })

        after(async function(){
            await Account.deleteOne({itsc : accountName});
            await eosDriver.transact({
                actions : [
                      {
                        account: process.env.ACC_NAME,
                        name: 'deletevoter',
                        authorization: [{
                          actor: process.env.ACC_NAME,
                          permission: 'active',
                        }],
                        data: {
                           voter : accountName.toLowerCase()
                        },
                      }
                ]
                },
                {
                    blocksBehind: 3,
                    expireSeconds: 30,
                }
            )
            .catch(err => { assert.fail(err)})
        })

    })

    describe("/contract/delvoter", function() {
        let campaignId = -1;
        const campaignName = getRandomString(8);
        this.timeout(1000000);

        before(async function () {
            console.log(accountName.toLowerCase())
            await eosDriver.transact({
                actions : [
                    {
                        account: process.env.ACC_NAME,
                        name: 'createcamp',
                        authorization: [{
                          actor: process.env.ACC_NAME,
                          permission: 'active',
                        }],
                        data: {
                            owner : process.env.ACC_NAME,
                            campaign_name : campaignName,
                            start_time_string : startTime.toISOString(),
                            end_time_string : endTime.toISOString()
                        },
                      },
                      {
                        account: process.env.ACC_NAME,
                        name: 'createvoter',
                        authorization: [{
                          actor: process.env.ACC_NAME,
                          permission: 'active',
                        }],
                        data: {
                           new_voter : accountName.toLowerCase()
                        },
                      }
                ]
                },
                {
                    blocksBehind: 3,
                    expireSeconds: 30,
                }
            )
            .catch(err => { assert.fail(err)})
            
            let currentBound = "";
            do {
                const table = await eosDriver.rpc.get_table_rows({
                    json: true,               // Get the response as json
                    code: `${process.env.ACC_NAME}`,      // Contract that we target
                    scope: `${process.env.ACC_NAME}`,         // Account that owns the data
                    table: 'campaign',        // Table name,
                    lower_bound : currentBound,
                    reverse: false,           // Optional: Get reversed data
                    show_payer: false          // Optional: Show ram payer
                });
        
                for (let i = 0; i < table["rows"].length; i++) {
                    if (table["rows"][i]["campaign_name"] == campaignName) {
                        console.log(`Found campaign id at ${table["rows"][i]["id"]}`)
                        campaignId = table["rows"][i]["id"]
                    }
                }
        
                if(table["more"]){
                    currentBound = table["next_key"]
                }
                else break;
        
            } while(campaignId == -1)
        
            if(campaignId == -1) {assert.fail("Cannot Find Campaign")}

            //Add user to the campaign

            eosDriver.transact({
                actions : [ 
                    addVoterPlaceholder(accountName.toLowerCase(), campaignId)
                ]
                },
                {
                    blocksBehind: 3,
                    expireSeconds: 30,
                }
            )

            //ITSC Setup
            let temp = new Account({
                itsc: accountName,
                key : keyConf,
                accountName : accountName.toLowerCase(),
                created : false
            });
            return temp.save()
        });

        it("Should reject invalid campaignId", (done) => {

            chai.request(app)
            .post("/contract/delvoter")
            .send({
                itsc : [accountName],
                campaignId : 12345,
                owner : process.env.ACC_NAME
            })
            .end((err, res) => {
                // console.log(res.body);
                res.should.have.status(400);
                res.body.should.have.property("error").eql(true);
                res.body.should.have.property("message").eql("Cannot find specified campaignId/ ITSC");
                done();
            })
        })

        it("Should reject invalid itsc", (done) => {
            let temp = getRandomString(8);

            chai.request(app)
            .post("/contract/delvoter")
            .send({
                itsc : [temp],
                campaignId : campaignId,
                owner : process.env.ACC_NAME
            })
            .end((err, res) => {
                // console.log(res.body)
                res.should.have.status(400);
                res.body.should.have.property("error").eql(true);
                res.body.should.have.property("message").eql("Cannot find specified campaignId/ ITSC");
                done();
            })
        })

        it("Should reject invalid owner account", (done) => {

            chai.request(app)
            .post("/contract/delvoter")
            .send({
                itsc : [accountName],
                campaignId : campaignId,
                owner : "__"
            })
            .end((err, res) => {
                // console.log(res.body);
                res.should.have.status(400);
                res.body.should.have.property("error").eql(true);
                res.body.should.have.property("message").eql("Cannot find specified campaignId/ ITSC");
                done();
            })
        })

        it("Should delete account", (done) => {

            chai.request(app)
            .post("/contract/delvoter")
            .send({
                itsc : [accountName],
                campaignId : campaignId,
                owner : process.env.ACC_NAME
            })
            .end((err, res) => {
                // console.log(res.body);
                res.should.have.status(200);
                res.body.should.have.property("error").eql(false);
                done();
            })
        })

        after(async function(){
            await Account.deleteOne({itsc : accountName});
        })

    })

});







