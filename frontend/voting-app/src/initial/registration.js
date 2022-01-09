import React, {useEffect, useState} from 'react'

const Registration = () => {

    async function postData(url = '', data = {}) {
        // Default options are marked with *
        return fetch(url, {
          method: 'POST', // *GET, POST, PUT, DELETE, etc.
          mode: 'cors', // no-cors, *cors, same-origin
          cache: 'no-cache', // *default, no-cache, reload, force-cache, only-if-cached
          credentials: 'same-origin', // include, *same-origin, omit
          headers: {
            'Content-Type': 'application/json'
            // 'Content-Type': 'application/x-www-form-urlencoded',
          },
          redirect: 'follow', // manual, *follow, error
          referrerPolicy: 'no-referrer', // no-referrer, *no-referrer-when-downgrade, origin, origin-when-cross-origin, same-origin, strict-origin, strict-origin-when-cross-origin, unsafe-url
          body: JSON.stringify(data) // body data type must match "Content-Type" header
        });
        
    }

    async function getData(url = '', data = {}) {
        // Default options are marked with *
        return fetch(url, {
          method: 'GET', // *GET, POST, PUT, DELETE, etc.
          mode: 'cors', // no-cors, *cors, same-origin
          cache: 'no-cache', // *default, no-cache, reload, force-cache, only-if-cached
          credentials: 'same-origin', // include, *same-origin, omit
          redirect: 'follow', // manual, *follow, error
          referrerPolicy: 'no-referrer', // no-referrer, *no-referrer-when-downgrade, origin, origin-when-cross-origin, same-origin, strict-origin, strict-origin-when-cross-origin, unsafe-url
        });
        
    }
    //KEYPAIR DATA
    const [pair, setPair] = useState({
        private : "",
        public : ""
    });

    //REGISTRATION DATA
    const [itsc, setItsc] = useState("");
    const [ckey, setCkey] = useState("");
    const [rconfirm, setRconfirm] = useState("");

    //CONFIRMATION DATA
    const [name, setName] = useState("");
    const [confirm, setConfirm] = useState("")

    const getKeyPair = () => {
        getData("http://localhost:3000/account/generate")
        .then(result => {
            // console.log(result)
            return result.json()
        })
        .then(result => {
            setPair(result)
        })
        .catch(err => {
            console.log("error in getting keypair")
            console.log(err.message);
        })
    }

    const registerName = (itsc) => {
        postData("http://localhost:3000/registration", {itsc : itsc})
        .then(result => result.json())
        .then(result => {
            if(!result.error){
                setRconfirm("Success")
            }
            else{
                setRconfirm(result.message)
            }
        })
        .catch(err => {
            setRconfirm("Unexpected error in registration")
        })
    }

    const confirmAccount = () => {
        postData("http://localhost:3000/confirmation",
         {
            itsc : itsc,
            key : ckey,
            accname : name,
            pkey : pair.public
        })
        .then(result => {
            if(!result.error){
                setConfirm("Account successfully created")
            }
            else{
                setConfirm(result.message)
            }
        })
        .catch(err => {
            console.log(err.message)
            console.log("Error in confirming")
            setConfirm("Account confirmation failed")

        })
    }

    return (
        <div>
            <h3>Keypair Generator</h3>
            <div>
                <div>
                    <a>Private key : {pair.private}</a>
                </div>
                <div>
                    <a>Public key : {pair.public}</a>
                </div>
                <button onClick={(e) => {
                    e.preventDefault();
                    console.log("entering keypair generation");
                    getKeyPair();
                }}>
                    Get Pair
                </button>
            </div>

            <h3>Registration form</h3>
            <div>
                <form onSubmit={(e) => {
                    e.preventDefault()
                    registerName(itsc)
                }}>
                    Enter ITSC: 
                    <input type="text" value={itsc} onChange={(e) => {
                        setItsc(e.target.value)
                    }}/>@connect.ust.hk
                    <input type="submit" value="Register"/>
                </form>
            </div>
            <h3>Registration Status: {rconfirm}</h3>

            <h3>Confirmation form</h3>
            <div>
                <form onSubmit={e => {
                    e.preventDefault()
                    confirmAccount()
                }}>
                    <div>
                        ITSC:
                        <input type="text" value={itsc} onChange={(e) => {
                            setItsc(e.target.value)
                        }}/>
                    </div>
                    <div>
                        Confirmation Key:
                        <input type="text" value={ckey} onChange={(e) => {
                            setCkey(e.target.value)
                        }}/>
                    </div>
                    <div>
                        Public Key:
                        <input type="text" value={pair.public} onChange={(e) => {
                            let temp = {
                                private : pair.private,
                                public : e.target.value
                            }
                            setPair(temp)
                        }}/>
                    </div>
                    <div>
                        Acc Name:
                        <input type ="text" value={name} onChange={ e => {
                        setName(e.target.value)
                    }}/>
                    </div>
                    <input type="submit" value="Confirm form"/>
                </form>
            </div>
            <h3>Confirmation Status : {confirm}</h3>
        </div>
    )
}

export default Registration
