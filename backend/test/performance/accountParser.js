const fs = require('fs')

const extractAccountData = (filename) => {
    let accountData = [];
    try {
    const data = fs.readFileSync(filename, 'utf8').split("\r\n");
        for(let i = 0; i < (data.length / 2) ; i++){
            accountData.push({
                accname : data[i*2],
                key : data[i*2 + 1]
            });
        }
    } catch (err) {
    console.error(err)
    } finally {
        return accountData;
    }
}

module.exports = extractAccountData