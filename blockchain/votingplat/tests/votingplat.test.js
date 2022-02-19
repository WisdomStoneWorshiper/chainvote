const { loadConfig, Blockchain } = require("@klevoya/hydra");
const { fail } = require("assert");
const assert = require("assert");
const { isTypedArray } = require("util/types");
require("dotenv").config();

const config = loadConfig("hydra.yml");

const DAY_OFFSET = new Date(1000 * 3600 * 24);

let currentDate = new Date();
let startTime = new Date( currentDate.getTime() + DAY_OFFSET.getTime());
let endTime = new Date( currentDate.getTime() + 2 * DAY_OFFSET.getTime());
let prevTime = new Date( currentDate.getTime() - 2 * DAY_OFFSET.getTime());

describe("votingplat", () => {

  let blockchain = new Blockchain(config);
  let contractAcc = blockchain.createAccount(`votingplat`);

  let userAccount1 = blockchain.createAccount("useracc1");
  let userAccount2 = blockchain.createAccount("useracc2");

  beforeAll(async () => {
    contractAcc.setContract(blockchain.contractTemplates[`votingplat`]);
    contractAcc.updateAuth(`active`, `owner`, {
      accounts: [
        {
          permission: {
            actor: contractAcc.accountName,
            permission: `eosio.code`
          },
          weight: 1
        }
      ]
    });
  });

  beforeEach(async () => {
    contractAcc.resetTables();
  });

  describe("createvoter", function(){

    it("Should create new voter", async function(){
      expect.assertions(1);

      await contractAcc.contract.createvoter({
        new_voter : userAccount1.accountName
      })
      .catch(err => console.log(err.message));

      expect(
        contractAcc.getTableRowsScoped("voter")["votingplat"])
      .toEqual(
        [
          {
            voter: 'useracc1',
            owned_campaigns: [],
            votable_campaigns: [],
            is_active : true
          }
        ]
      );
    });

    it('Should not have duplicateed voter', async function(){
      expect.assertions(2);

      await contractAcc.contract.createvoter({
        new_voter : userAccount1.accountName
      })
      
      await contractAcc.contract.createvoter({
        new_voter : userAccount1.accountName
      })
      .catch( err => {
        expect(
          err.message
          .indexOf(
            "assertion failure with message: voter exist"
            ) >= 0
          ).toEqual(true);
        expect(
          contractAcc.getTableRowsScoped("voter")["votingplat"])
        .toEqual(
          [
            {
              voter: 'useracc1',
              owned_campaigns: [],
              votable_campaigns: [],
              is_active : true
            }
          ]
        );
      })
    })

    it('Should not create voter without admin account', async function(){
      expect.assertions(2);
      await contractAcc.contract.createvoter({
        new_voter : userAccount1.accountName
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .catch( err => {
        expect(
          err.message
          .indexOf(
            "missing authority of votingplat"
            ) >= 0
          ).toEqual(true);
        expect(contractAcc.getTableRowsScoped("voter")["votingplat"])
        .toEqual(undefined) //because the table has not been generated
      })
    });
  })

  describe("createcamp", function(){

    beforeEach(async () => {
      await contractAcc.contract.createvoter({
        new_voter : userAccount1.accountName
      })
    })

    it("Should create a campaign", async function(){
      expect.assertions(1);
      await contractAcc.contract.createcamp({
        owner : userAccount1.accountName,
        campaign_name : "testcamp",
        start_time : startTime.toISOString().split(".")[0],
        end_time : endTime.toISOString().split(".")[0]
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .then( res => {
        expect(contractAcc.getTableRowsScoped("campaign")["votingplat"])
        .toEqual([{
          id : "0",
          campaign_name : "testcamp",
          owner : userAccount1.accountName,
          choice_list : [],
          start_time : startTime.toISOString().split(".")[0] + ".000",
          end_time : endTime.toISOString().split(".")[0] + ".000"
        }])
      })
    });

    it("Should not create a campaign without auth", async function(){
      expect.assertions(2);
      await contractAcc.contract.createcamp({
        owner : userAccount1.accountName,
        campaign_name : "testcamp",
        start_time : startTime.toISOString().split(".")[0],
        end_time : endTime.toISOString().split(".")[0]
      }, [{
        actor : userAccount2.accountName,
        permission : "active"
      }])
      .catch(err => {
        expect(
          err.message
          .indexOf(
            "You are not authorized to use this account"
            ) >= 0
          )
        .toEqual(true);

        expect(
          contractAcc.getTableRowsScoped("campaign")["votingplat"]
        )
        .toEqual(undefined); //since the table isnt generated yet
      });
    });

    it("Should not create duplicate campaign", async function(){
      expect.assertions(2);
      await contractAcc.contract.createcamp({
        owner : userAccount1.accountName,
        campaign_name : "testcamp",
        start_time : startTime.toISOString().split(".")[0],
        end_time : endTime.toISOString().split(".")[0]
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])

      await contractAcc.contract.createcamp({
        owner : userAccount1.accountName,
        campaign_name : "testcamp",
        start_time : startTime.toISOString().split(".")[0],
        end_time : endTime.toISOString().split(".")[0]
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .catch(err => {
        expect(
          err.message
          .indexOf(
            "campaign exists"
            ) >= 0
          )
        .toEqual(true);

        expect(
          contractAcc.getTableRowsScoped("campaign")["votingplat"]
        )
        .toEqual([{
          id : "0",
          campaign_name : "testcamp",
          owner : userAccount1.accountName,
          choice_list : [],
          start_time : startTime.toISOString().split(".")[0] + ".000",
          end_time : endTime.toISOString().split(".")[0] + ".000"
        }]); //since the table isnt generated yet
      });
    });

    it("Should not create a campaign with later start time", async function(){ //fix this tmrw
      expect.assertions(2);
      await contractAcc.contract.createcamp({
        owner : userAccount1.accountName,
        campaign_name : "testcamp",
        end_time : startTime.toISOString().split(".")[0],
        start_time : endTime.toISOString().split(".")[0]
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .catch(err => {
        expect(
          err.message
          .indexOf(
            "Invalid timing: Start is later than End "
            ) >= 0
          )
        .toEqual(true);

        expect(
          contractAcc.getTableRowsScoped("campaign")["votingplat"]
        )
        .toEqual(undefined); //since the table isnt generated yet
      });
    });

    it("Should not create a campaign with startTime > now", async function(){ //fix this 
      expect.assertions(2);
      await contractAcc.contract.createcamp({
        owner : userAccount1.accountName,
        campaign_name : "testcamp",
        start_time : prevTime.toISOString().split(".")[0],
        end_time : endTime.toISOString().split(".")[0]
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .catch(err => {
        expect(
          err.message
          .indexOf(
            "Invalid timing: Campaign must start before the current time"
            ) >= 0
          )
        .toEqual(true);

        expect(
          contractAcc.getTableRowsScoped("campaign")["votingplat"]
        )
        .toEqual(undefined); //since the table isnt generated yet
      });
    });

    it("Should not create a campaign with no owner", async function(){
      expect.assertions(2);
      await contractAcc.contract.createcamp({
        owner : userAccount2.accountName,
        campaign_name : "testcamp",
        start_time : prevTime.toISOString().split(".")[0],
        end_time : endTime.toISOString().split(".")[0]
      }, [{
        actor : userAccount2.accountName,
        permission : "active"
      }])
      .catch(err => {
        expect(
          err.message
          .indexOf(
            "owner not exist"
            ) >= 0
          )
        .toEqual(true);

        expect(
          contractAcc.getTableRowsScoped("campaign")["votingplat"]
        )
        .toEqual(undefined); //since the table isnt generated yet
      });
    });
  });

  describe("addchoice", function(){
    beforeEach(async ()=> {
      await contractAcc.contract.createvoter({
        new_voter : userAccount1.accountName
      })

      await contractAcc.contract.createvoter({
        new_voter : userAccount2.accountName
      })

      await contractAcc.contract.createcamp({
        owner : userAccount1.accountName,
        campaign_name : "testcamp",
        start_time : startTime.toISOString().split(".")[0],
        end_time : endTime.toISOString().split(".")[0]
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])
    })

    it("should add choice1 on campaign", async function(){
      expect.assertions(1);
      await contractAcc.contract.addchoice({
        owner : userAccount1.accountName,
        campaign_id : 0,
        new_choice : "choice1"
      }, [
       { 
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .then(result => {
        expect(contractAcc.getTableRowsScoped("campaign")["votingplat"][0])
        .toEqual({
          campaign_name: "testcamp", 
          choice_list: [{
            "choice" : "choice1",
            "result" : "0"
          }], 
          end_time: endTime.toISOString().split(".")[0] + ".000", 
          id: "0", 
          owner: userAccount1.accountName, 
          start_time: startTime.toISOString().split(".")[0] + ".000"})
      })
    });

    it("should not add choice using other account", async function(){
      expect.assertions(2)

      await contractAcc.contract.addchoice({
        owner : userAccount1.accountName,
        campaign_id : 0,
        new_choice : "choice1"
      }, [
       { 
        actor : userAccount2.accountName,
        permission : "active"
      }])
      .catch(err => {
        expect(
          err.message
        .indexOf(
          "You are not authorized to use this account"
          ) >= 0
        )
        .toEqual(true)

        expect(contractAcc.getTableRowsScoped("campaign")["votingplat"][0])
        .toEqual({
          campaign_name: "testcamp", 
          choice_list: [], 
          end_time: endTime.toISOString().split(".")[0] + ".000", 
          id: "0", 
          owner: userAccount1.accountName, 
          start_time: startTime.toISOString().split(".")[0] + ".000"})
      })
    });

    it("should not add choice to invalid id campaign", async function(){
      expect.assertions(2)

      await contractAcc.contract.addchoice({
        owner : userAccount1.accountName,
        campaign_id : 10,
        new_choice : "choice1"
      }, [
       { 
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .catch(err => {
        expect(
          err.message
        .indexOf(
          "You are not the owner of this campaign"
          ) >= 0
        )
        .toEqual(true)

        expect(contractAcc.getTableRowsScoped("campaign")["votingplat"][0])
        .toEqual({
          campaign_name: "testcamp", 
          choice_list: [], 
          end_time: endTime.toISOString().split(".")[0] + ".000", 
          id: "0", 
          owner: userAccount1.accountName, 
          start_time: startTime.toISOString().split(".")[0] + ".000"})
      })
    });

    it("should not add duplicated choice", async function(){
      expect.assertions(2)
      await contractAcc.contract.addchoice({
        owner : userAccount1.accountName,
        campaign_id : 0,
        new_choice : "choice1"
      }, [
       { 
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .catch( err => {
        fail("Transaction to initialize failed")
      })

      await contractAcc.contract.addchoice({
        owner : userAccount1.accountName,
        campaign_id : 0,
        new_choice : "choice1"
      }, [
       { 
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .catch(err => {
        expect(
          err.message
        .indexOf(
          "duplicated choice"
          ) >= 0
        )
        .toEqual(true)

        expect(contractAcc.getTableRowsScoped("campaign")["votingplat"][0])
        .toEqual({
          campaign_name: "testcamp", 
          choice_list: [{
            "choice" : "choice1",
            "result" : "0"
          }], 
          end_time: endTime.toISOString().split(".")[0] + ".000", 
          id: "0", 
          owner: userAccount1.accountName, 
          start_time: startTime.toISOString().split(".")[0] + ".000"})
      })
    });

    it("should not add to invalid owner", async function(){
      expect.assertions(2)
      await contractAcc.contract.addchoice({
        owner : userAccount2.accountName,
        campaign_id : 0,
        new_choice : "choice1"
      }, [
       { 
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .catch(err => {
        expect(
          err.message
        .indexOf(
          "You are not authorized to use this account"
          ) >= 0
        )
        .toEqual(true)

        expect(contractAcc.getTableRowsScoped("campaign")["votingplat"][0])
        .toEqual(
          {
            campaign_name: "testcamp", 
            choice_list: [], 
            end_time: endTime.toISOString().split(".")[0] + ".000", 
            id: "0", 
            owner: userAccount1.accountName, 
            start_time: startTime.toISOString().split(".")[0] + ".000"})
        }
        )
    });
  });

  describe("addvoter", function(){
    beforeEach(async () => {
      await contractAcc.contract.createvoter({
        new_voter : userAccount1.accountName
      })

      await contractAcc.contract.createvoter({
        new_voter : userAccount2.accountName
      })

      await contractAcc.contract.createcamp({
        owner : userAccount1.accountName,
        campaign_name : "testcamp",
        start_time : startTime.toISOString().split(".")[0],
        end_time : endTime.toISOString().split(".")[0]
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])
    });

    it("add voter to campaign", async function(){
      expect.assertions(1);

      await contractAcc.contract.addvoter({
        campaign_id : 0,
        voter : userAccount2.accountName
      })
      .then(result => {
        expect(contractAcc.getTableRowsScoped("voter")["votingplat"])
        .toEqual(
          [
            {
              voter: 'useracc1',
              owned_campaigns: ["0"],
              votable_campaigns: [],
              is_active : true
            },
            {
              voter : 'useracc2',
              owned_campaigns : [],
              votable_campaigns : [{
                "campaign" : "0",
                "is_vote" : false
              }],
              is_active : true
            }
          ]
        )
      })
    });

    it("does not allow owner account to add voter", async ()=> {
      expect.assertions(2);

      await contractAcc.contract.addvoter({
        campaign_id : "0",
        voter : userAccount2.accountName
      }, [
        {
          actor : userAccount1.accountName,
          permission : "active"
        }
      ])
      .catch( err => {
        expect(
          err.message
          .indexOf(
            "only contract account can add vote"
            ) >= 0
          ).toEqual(true);

        expect(contractAcc.getTableRowsScoped("voter")["votingplat"])
        .toEqual([
          {
            voter: 'useracc1',
            owned_campaigns: ["0"],
            votable_campaigns: [],
            is_active : true
          },
          {
            voter : 'useracc2',
            owned_campaigns : [],
            votable_campaigns : [],
            is_active : true
          }
        ]) 
      })
    });

    it("does not allow add voter to non-existing campaign", async ()=> {
      expect.assertions(2);

      await contractAcc.contract.addvoter({
        campaign_id : 10,
        voter : userAccount2.accountName
      })
      .catch( err => {
        // console.log(err)
        expect(
          err.message
          .indexOf(
            "campaign not exist"
            ) >= 0
          ).toEqual(true);

        expect(contractAcc.getTableRowsScoped("voter")["votingplat"])
        .toEqual([
          {
            voter: 'useracc1',
            owned_campaigns: ["0"],
            votable_campaigns: [],
            is_active : true
          },
          {
            voter : 'useracc2',
            owned_campaigns : [],
            votable_campaigns : [],
            is_active : true
          }
        ]) 
      })
    });

    it("does not allow add non-exist voter", async ()=> {
      expect.assertions(2);

      await contractAcc.contract.addvoter({
        campaign_id : 0,
        voter : "randomname"
      })
      .catch( err => {
        expect(
          err.message
          .indexOf(
            "voter not exist"
            ) >= 0
          ).toEqual(true);

        expect(contractAcc.getTableRowsScoped("voter")["votingplat"])
        .toEqual([
          {
            voter: 'useracc1',
            owned_campaigns: ["0"],
            votable_campaigns: [],
            is_active : true
          },
          {
            voter : 'useracc2',
            owned_campaigns : [],
            votable_campaigns : [],
            is_active : true
          }
        ]) 
      })
    });
    
  });

  describe("voter", function(){

    beforeEach(async () => {
      await contractAcc.contract.createvoter({
        new_voter : userAccount1.accountName
      })

      await contractAcc.contract.createvoter({
        new_voter : userAccount2.accountName
      })

      await contractAcc.contract.createcamp({
        owner : userAccount1.accountName,
        campaign_name : "testcamp",
        start_time : startTime.toISOString().split(".")[0],
        end_time : endTime.toISOString().split(".")[0]
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])

      await contractAcc.contract.addvoter({ //add allowed voter
        campaign_id : 0,
        voter : userAccount2.accountName
      })

      await contractAcc.contract.addchoice({ //add choice
        owner : userAccount1.accountName,
        campaign_id : 0,
        new_choice : "choice1"
      }, [
      { 
        actor : userAccount1.accountName,
        permission : "active"
      }])
    });

    describe("voting with now > startTime", function(){

      it("should not vote on non-existent campaign", async ()=> {
        await contractAcc.contract.vote({
          campaign_id : 10,
          voter : userAccount2.accountName,
          choice_idx : 0
        }, [{
          actor : userAccount2.accountName,
          permission : "active"
        }])
        .catch( err => {
          expect(
            err.message
          .indexOf(
            "campaign not exist"
            ) >= 0
          )
          .toEqual(true)
  
          expect(contractAcc.getTableRowsScoped("campaign")["votingplat"][0])
          .toEqual(
            {
              campaign_name: "testcamp", 
              choice_list: [{
                "choice" : "choice1",
                "result" : "0"
              }], 
              end_time: endTime.toISOString().split(".")[0] + ".000", 
              id: "0", 
              owner: userAccount1.accountName, 
              start_time: startTime.toISOString().split(".")[0] + ".000"})
        })
      });

      it("should not vote on non-existent choice", async ()=> {
        await contractAcc.contract.vote({
          campaign_id : 0,
          voter : userAccount2.accountName,
          choice_idx : 1
        }, [{
          actor : userAccount2.accountName,
          permission : "active"
        }])
        .catch( err => {
          console.log(err.message)
          expect(
            err.message
          .indexOf(
            "choice not exist"
            ) >= 0
          )
          .toEqual(true)
  
          expect(contractAcc.getTableRowsScoped("campaign")["votingplat"][0])
          .toEqual(
            {
              campaign_name: "testcamp", 
              choice_list: [{
                "choice" : "choice1",
                "result" : "0"
              }], 
              end_time: endTime.toISOString().split(".")[0] + ".000", 
              id: "0", 
              owner: userAccount1.accountName, 
              start_time: startTime.toISOString().split(".")[0] + ".000"})
        })
      });

      it("should not vote on unauthorized account", async ()=> {
        await contractAcc.contract.vote({
          campaign_id : 0,
          voter : userAccount2.accountName,
          choice_idx : 0
        },[{
          actor : userAccount1.accountName,
          permission : "active"
        }])
        .catch( err => {
          console.log(err.message)
          expect(
            err.message
          .indexOf(
            "You are not authorized to use this account"
            ) >= 0
          )
          .toEqual(true)
  
          expect(contractAcc.getTableRowsScoped("campaign")["votingplat"][0])
          .toEqual(
            {
              campaign_name: "testcamp", 
              choice_list: [{
                "choice" : "choice1",
                "result" : "0"
              }], 
              end_time: endTime.toISOString().split(".")[0] + ".000", 
              id: "0", 
              owner: userAccount1.accountName, 
              start_time: startTime.toISOString().split(".")[0] + ".000"})
        })
      });

      it("should not vote when campaign hasn't started", async ()=> {
        await contractAcc.contract.vote({
          campaign_id : 0,
          voter : userAccount2.accountName,
          choice_idx : 0
        },[{
          actor : userAccount2.accountName,
          permission : "active"
        }])
        .catch( err => {
          // console.log(err.message);
          expect(
            err.message
          .indexOf(
            "Campaign has not started"
            ) >= 0
          )
          .toEqual(true)
  
          expect(contractAcc.getTableRowsScoped("campaign")["votingplat"][0])
          .toEqual(
            {
              campaign_name: "testcamp", 
              choice_list: [{
                "choice" : "choice1",
                "result" : "0"
              }], 
              end_time: endTime.toISOString().split(".")[0] + ".000", 
              id: "0", 
              owner: userAccount1.accountName, 
              start_time: startTime.toISOString().split(".")[0] + ".000"})
        })
      });

    });

    describe("Voting with startTime > now", function(){

      beforeEach(() => {
        blockchain.setCurrentTime(new Date(startTime.getTime() + 10000));
      });

      it("should vote", async () => {
        expect.assertions(1);
        await contractAcc.contract.vote({
          campaign_id : 0,
          voter : userAccount2.accountName,
          choice_idx : 0
        }, [{
          actor : userAccount2.accountName,
          permission : "active"
        }])
        .then(result => {
          expect(contractAcc.getTableRowsScoped("campaign")["votingplat"][0])
          .toEqual(
            {
              campaign_name: "testcamp", 
              choice_list: [{
                "choice" : "choice1",
                "result" : "1"
              }], 
              end_time: endTime.toISOString().split(".")[0] + ".000", 
              id: "0", 
              owner: userAccount1.accountName, 
              start_time: startTime.toISOString().split(".")[0] + ".000"})
          }
        )
        .catch(err => {
          console.log(err.message);
          
        })
      });

      it("should not allow double voting", async () => {
        expect.assertions(3);
        await contractAcc.contract.vote({
          campaign_id : 0,
          voter : userAccount2.accountName,
          choice_idx : 0
        }, [{
          actor : userAccount2.accountName,
          permission : "active"
        }])

        expect.assertions(3);
        await contractAcc.contract.vote({
          campaign_id : 0,
          voter : userAccount2.accountName,
          choice_idx : 0
        }, [{
          actor : userAccount2.accountName,
          permission : "active"
        }])
        .catch((err) => {
          expect(
            err.message
          .indexOf(
            "you have voted already"
            ) >= 0
          )
          .toEqual(true)
  
          expect(contractAcc.getTableRowsScoped("campaign")["votingplat"][0])
          .toEqual({
              campaign_name: "testcamp", 
              choice_list: [{
                "choice" : "choice1",
                "result" : "1"
              }], 
              end_time: endTime.toISOString().split(".")[0] + ".000", 
              id: "0", 
              owner: userAccount1.accountName, 
              start_time: startTime.toISOString().split(".")[0] + ".000"
            })

          expect(contractAcc.getTableRowsScoped("voter")["votingplat"])
          .toEqual([
                    {
                      voter: 'useracc1',
                      owned_campaigns: ["0"],
                      votable_campaigns: [],
                      is_active : true
                    },
                    {
                      voter : 'useracc2',
                      owned_campaigns : [],
                      votable_campaigns : [{
                        campaign : "0",
                        is_vote : true
                      }],
                      is_active : true
                    }
                  ])
          })
        })

      it("should not allow invalid voter", async () => {
        await contractAcc.contract.vote({
          campaign_id : 0,
          voter : userAccount1.accountName,
          choice_idx : 0
        }, [{
          actor : userAccount1.accountName,
          permission : "active"
        }])
        .catch(err => {
          expect(
            err.message
          .indexOf(
            "voter cannot vote this campaign"
            ) >= 0
          )
          .toEqual(true)
  
          expect(contractAcc.getTableRowsScoped("campaign")["votingplat"][0])
          .toEqual({
              campaign_name: "testcamp", 
              choice_list: [{
                "choice" : "choice1",
                "result" : "0"
              }], 
              end_time: endTime.toISOString().split(".")[0] + ".000", 
              id: "0", 
              owner: userAccount1.accountName, 
              start_time: startTime.toISOString().split(".")[0] + ".000"
            })
        })
      })

      afterEach(async () => {
        blockchain.setCurrentTime(new Date(2000, 1, 1));
      })

    });

    describe("Voting with endTime < now", function() {
      beforeEach(() => {
        blockchain.setCurrentTime(new Date( endTime.getTime() + 10000));
      })

      it("should not allow voter to vote", async () => {
        await contractAcc.contract.vote({
          campaign_id : 0,
          voter : userAccount2.accountName,
          choice_idx : 0
        }, [{
          actor : userAccount2.accountName,
          permission : "active"
        }])
        .catch(err => {
          expect(
            err.message
          .indexOf(
            "Campaign has already ended"
            ) >= 0
          )
          .toEqual(true)
  
          expect(contractAcc.getTableRowsScoped("campaign")["votingplat"][0])
          .toEqual({
              campaign_name: "testcamp", 
              choice_list: [{
                "choice" : "choice1",
                "result" : "0"
              }], 
              end_time: endTime.toISOString().split(".")[0] + ".000", 
              id: "0", 
              owner: userAccount1.accountName, 
              start_time: startTime.toISOString().split(".")[0] + ".000"
            })
        })
      })

      afterEach(async () => {
        blockchain.setCurrentTime(new Date(2000, 1, 1));
      })

    })

  });

  describe("deletecamp", function(){

    beforeEach(async () => {
      contractAcc.resetTables();
      await contractAcc.contract.createvoter({
        new_voter : userAccount1.accountName
      })

      await contractAcc.contract.createvoter({
        new_voter : userAccount2.accountName
      })

      await contractAcc.contract.createcamp({
        owner : userAccount1.accountName,
        campaign_name : "testcamp",
        start_time : startTime.toISOString().split(".")[0],
        end_time : endTime.toISOString().split(".")[0]
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])

      await contractAcc.contract.addvoter({ //add allowed voter
        campaign_id : 0,
        voter : userAccount2.accountName
      })

      await contractAcc.contract.addchoice({ //add choice
        owner : userAccount1.accountName,
        campaign_id : 0,
        new_choice : "choice1"
      }, [
      { 
        actor : userAccount1.accountName,
        permission : "active"
      }])
    });

    it("Should not allow to delete started campaign", async () => {
      expect.assertions(2)
      blockchain.setCurrentTime(new Date( startTime.getTime() + 10000));
      await contractAcc.contract.deletecamp({
        owner: userAccount1.accountName,
        campaign_id : 0
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .catch(err => {
        console.log(err.message);
        expect(
          err.message
        .indexOf(
          "Campaign has already started"
          ) >= 0
        )
        .toEqual(true)

        expect(contractAcc.getTableRowsScoped("campaign")["votingplat"][0])
        .toEqual(
          {
            campaign_name: "testcamp", 
            choice_list: [{
              "choice" : "choice1",
              "result" : "0"
            }], 
            end_time: endTime.toISOString().split(".")[0] + ".000", 
            id: "0", 
            owner: userAccount1.accountName, 
            start_time: startTime.toISOString().split(".")[0] + ".000"})
        })
      })

    it("Should not allow to delete unauthorized account", async () => {
      expect.assertions(2)
      blockchain.setCurrentTime(new Date( startTime.getTime() + 10000));
      await contractAcc.contract.deletecamp({
        owner: userAccount1.accountName,
        campaign_id : 0
      }, [{
        actor : userAccount2.accountName,
        permission : "active"
      }])
      .catch(err => {
        expect(
          err.message
        .indexOf(
          "You are not authorized to use this account"
          ) >= 0
        )
        .toEqual(true)

        expect(contractAcc.getTableRowsScoped("campaign")["votingplat"][0])
        .toEqual(
          {
            campaign_name: "testcamp", 
            choice_list: [{
              "choice" : "choice1",
              "result" : "0"
            }], 
            end_time: endTime.toISOString().split(".")[0] + ".000", 
            id: "0", 
            owner: userAccount1.accountName, 
            start_time: startTime.toISOString().split(".")[0] + ".000"})
        })
      })

    it("Should not allow to delete due to invalid owner", async () => {
      expect.assertions(2)
      blockchain.setCurrentTime(new Date( startTime.getTime() + 10000));
      await contractAcc.contract.deletecamp({
        owner: userAccount2.accountName,
        campaign_id : 0
      }, [{
        actor : userAccount2.accountName,
        permission : "active"
      }])
      .catch(err => {
        console.log(err.message)
        expect(
          err.message
        .indexOf(
          "You are not the owner"
          ) >= 0
        )
        .toEqual(true)

        expect(contractAcc.getTableRowsScoped("campaign")["votingplat"][0])
        .toEqual(
          {
            campaign_name: "testcamp", 
            choice_list: [{
              "choice" : "choice1",
              "result" : "0"
            }], 
            end_time: endTime.toISOString().split(".")[0] + ".000", 
            id: "0", 
            owner: userAccount1.accountName, 
            start_time: startTime.toISOString().split(".")[0] + ".000"})
        })
      })

    it("Should not allow to delete invalid campaign id", async () => {
      expect.assertions(2)
      blockchain.setCurrentTime(new Date( startTime.getTime() + 10000));
      await contractAcc.contract.deletecamp({
        owner: userAccount1.accountName,
        campaign_id : 10
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .catch(err => {
        expect(
          err.message
        .indexOf(
          "campaign not exist"
          ) >= 0
        )
        .toEqual(true)

        expect(contractAcc.getTableRowsScoped("campaign")["votingplat"][0])
        .toEqual(
          {
            campaign_name: "testcamp", 
            choice_list: [{
              "choice" : "choice1",
              "result" : "0"
            }], 
            end_time: endTime.toISOString().split(".")[0] + ".000", 
            id: "0", 
            owner: userAccount1.accountName, 
            start_time: startTime.toISOString().split(".")[0] + ".000"})
        })
      })

    it("Should delete campaign", async () => {
      expect.assertions(1);


      await contractAcc.contract.deletecamp({
        owner: userAccount1.accountName,
        campaign_id : 0
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .then(res => {
        expect(contractAcc.getTableRowsScoped("campaign")["votingplat"])
        .toEqual(undefined)
      })
    });

    afterEach(() => {
      blockchain.setCurrentTime(new Date(2000, 1, 1));
    })

  });

  describe("updatevoter", function(){
    const updatevoterPlaceholder = (name, active, signer) => {
      //console.log(`name : ${name.accountName} singer : ${signer.accountName}`)
      return contractAcc.contract.updatevoter({
        voter: name.accountName,
        active : active
      }, [{
        actor : signer.accountName,
        permission : "active"
      }])
    }

    beforeEach(async () => {
      contractAcc.resetTables();
      await contractAcc.contract.createvoter({
        new_voter : userAccount1.accountName
      })

      console.log(contractAcc.getTableRowsScoped("voter")["votingplat"]);
    });

    it("Should only allow admin to update", async () => {
      expect.assertions(2)
      await contractAcc.contract.updatevoter({
        voter: userAccount1.accountName,
        active : false
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .then(res => console.log(res))
      .catch(err => {
        console.log(err.message)
        expect(
          err.message
        .indexOf(
          "Only admin can update one's voting account"
          ) >= 0
        )
        .toEqual(true)

        expect(contractAcc.getTableRowsScoped("voter")["votingplat"])
        .toEqual([
          {
            voter: 'useracc1',
            owned_campaigns: [],
            votable_campaigns: [],
            is_active : true
          }
        ])
      })
    })

    it("Should not update undefined account", async () => {
      expect.assertions(2);
      await updatevoterPlaceholder(userAccount2, false, contractAcc)
      .then(res => console.log(res))
      .catch(err => {
        expect(
          err.message
        .indexOf(
          "voter not exist"
          ) >= 0
        )
        .toEqual(true)

        expect(contractAcc.getTableRowsScoped("voter")["votingplat"])
        .toEqual([
          {
            voter: 'useracc1',
            owned_campaigns: [],
            votable_campaigns: [],
            is_active : true
          }
        ])
      })
    })

    it("Should update account active status", async () => {
      expect.assertions(1)
      await updatevoterPlaceholder(userAccount1, false, contractAcc)
      .then(res => {
        expect(contractAcc.getTableRowsScoped("voter")["votingplat"])
        .toEqual([
          {
            voter: 'useracc1',
            owned_campaigns: [],
            votable_campaigns: [],
            is_active : false
          }
        ])
      })
    })

  });

  describe("deletevoter", function(){
    const deletevoterPlaceholder = (name, signer) => {
      return contractAcc.contract.deletevoter({
        voter: name.accountName,
      }, [{
        actor : signer.accountName,
        permission : "active"
      }])
    }

    beforeEach(async () => {
      await contractAcc.contract.createvoter({
        new_voter : userAccount1.accountName
      })
    });

    it("Should only allow admin to delete", async () => {
      expect.assertions(2);
      await deletevoterPlaceholder(userAccount1, userAccount1)
      .then(res => {
        console.log(res);
        console.log(contractAcc.getTableRowsScoped("voter")["votingplat"])
      })
      .catch(err => {
        expect(
          err.message
        .indexOf(
          "Only admin can update one's voting account"
          ) >= 0
        )
        .toEqual(true)

        expect(contractAcc.getTableRowsScoped("voter")["votingplat"])
        .toEqual([
          {
            voter: 'useracc1',
            owned_campaigns: [],
            votable_campaigns: [],
            is_active : true
          }
        ])
      })
    })

    it("Should not delete undefined account", async () => {
      expect.assertions(2);
      await deletevoterPlaceholder(userAccount2, contractAcc)
      .catch(err => {
        expect(
          err.message
        .indexOf(
          "voter not exist"
          ) >= 0
        )
        .toEqual(true)

        expect(contractAcc.getTableRowsScoped("voter")["votingplat"])
        .toEqual([
          {
            voter: 'useracc1',
            owned_campaigns: [],
            votable_campaigns: [],
            is_active : true
          }
        ])
      })
    })

    it("Should delete account", async () => {
      expect.assertions(1);
      await deletevoterPlaceholder(userAccount1, contractAcc)
      .then(err => {
        expect(contractAcc.getTableRowsScoped("voter")["votingplat"])
        .toEqual([])
      })
      .catch( err => console.log(err.message))
    })

  });

  afterEach(async () => {
    blockchain.setCurrentTime(new Date(2000, 1, 1));
  })


});
