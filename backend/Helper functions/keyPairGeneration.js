const {ecc} = require("eosjs/dist/eosjs-ecc-migration")

const generateKeyPair = async () => {
    const tempPrivate = await ecc.randomKey(undefined,{secureEnv : true});
    return {
        private : `${tempPrivate}`,
        public : `${ecc.privateToPublic(tempPrivate)}`
    };
}

module.exports = generateKeyPair;