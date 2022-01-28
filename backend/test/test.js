let app = require("../index")
let Account = require("../Helper functions/mongoose/accModel")

let chai = require("chai")
let chaiHttp = require('chai-http')
let should = chai.should()

chai.use(chaiHttp)

describe("Registration testing", function (){

    this.timeout(100000)
    
    describe('/registration', () => {

        before(function(done){
            app.on("serverStart", () => {
                done();
            })
        });
    
        beforeEach( async function  () {
            await Account.deleteOne({itsc : "username1"});
            let temp = new Account({
                itsc: "username1",
                key : "12345",
                accountName : null,
                publicKey : null,
                created : false
            });
            return temp.save()
        })

        it("Should register properly", (done) => {
            let itsc = {itsc : "username1"};

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
            let itsc = {itsc: "username2"};

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
            return Account.deleteOne({itsc : "username1"});
        })
    })

});




