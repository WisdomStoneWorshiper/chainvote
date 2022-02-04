const  ecc = require('eosjs-ecc')

const accountPlaceholder = (name, publicKey) => {
    return (
        {
            account: 'eosio',
            name: `newaccount`, // new account name
            authorization: [{
              actor: `${process.env.ACC_NAME}`, // which account generates it
              permission: 'active',
            }],
            data: {
              creator: `${process.env.ACC_NAME}`,
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

const addVoterPlaceholder = (name) => {
    return         {
        account: `${process.env.ACC_NAME}`,
        name: `createvoter`, // new account name
        authorization: [{
          actor: `${process.env.ACC_NAME}`, // which account generates it
          permission: 'active',
        }],
        data: {
            new_voter: `${name}`
        }
      }
}

let regex = new RegExp('[a-z]([a-z]|\.|[1-5]){10}[^\.]');

const eosNameValidation = (name) => {
  return regex.test(name) & name.length == 12;
}

// const eosPublicKeyValidation = (publicKey) => {
//   console.log(publicKey)
//   console.log(ecc.isValidPublic(publicKey))
//   return ecc.isValidPublic(publicKey) === true;
// }

module.exports = {
  accountPlaceholder, 
  addVoterPlaceholder, 
  eosNameValidation, 
  // eosPublicKeyValidation
}