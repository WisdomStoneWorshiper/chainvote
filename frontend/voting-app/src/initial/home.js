/* eslint-disable react-hooks/rules-of-hooks */
import {Link} from 'react-router-dom';
import React, { useState, useEffect } from 'react';
const { Api, JsonRpc } = require('eosjs');
const { JsSignatureProvider } = require('eosjs/dist/eosjs-jssig');  // development only


const Home = () => {
    const testnet_http = "http://127.0.0.1:8888"

    // const signatureProvider = new JsSignatureProvider([process.env.REACT_APP_OWNER_PRIVATE]);
    const rpc = new JsonRpc(testnet_http, { fetch }); //required to read blockchain state
    // const api = new Api({ rpc, signatureProvider, textDecoder: new TextDecoder(), textEncoder: new TextEncoder() }); //required to submit transactions

    const [person, setPerson] = useState("");
    const [data, setData] = useState([]);

    //ACCOUNT SETTINGS
    const [api, setApi] = useState(null);
    const [acc, setAcc] = useState("");
    const [pkey, setPkey] = useState("");
    
    const show_table = async () => {
        const table = await rpc.get_table_rows({
            json: true,               // Get the response as json
            code: 'main',      // Contract that we target
            scope: 'main',         // Account that owns the data
            table: 'votingresult',        // Table name
            limit: 10,                // Maximum number of rows that we want to get
          });
        console.log(table)
        setData(table.rows);
    }

    const vote = async () => {
      console.log({
        account: 'main',
        name: 'vote',
        authorization: [{
          actor: acc,
          permission: 'owner',
        }],
        data: {
          voter: acc,
          candidate : person
        },
      })
        const transaction = await api.transact({
            actions: [{
              account: 'main',
              name: 'vote',
              authorization: [{
                actor: acc,
                permission: 'owner',
              }],
              data: {
                voter: acc,
                candidate : person
              },
            }]
           }, {
            blocksBehind: 3,
            expireSeconds: 30,
           });
        show_table();
    }

    useEffect(() => {
        show_table();
    }, []);

    return (
        <div>
            <h1> Welcome to the blockchain based voting system </h1>
            <div>
              <div>
                <a>Account name</a>
                <input type="text" onChange={e => setAcc(e.target.value)}/>
              </div>
              <div>
                <a>Public key</a>
                <input type="text" onChange={e => setPkey(e.target.value)}/>
              </div>
              <button onClick={e => {
                e.preventDefault()
                const signatureProvider = new JsSignatureProvider([pkey]);
                const api = new Api({ rpc, signatureProvider, textDecoder: new TextDecoder(), textEncoder: new TextEncoder() });
                console.log(`Set api with name ${acc} and pkey ${pkey}`)
                setApi(api);
              }}>Login</button>
            </div>

            <form onSubmit={e => {
                e.preventDefault()
                vote()
            }}>
                <label>
                Pick your favorite flavor:
                <select value={person} onChange={ e => {
                    console.log(e)
                    setPerson(e.target.value)
                }}>
                    {data.map((value, index) => 
                        <option value={value.candidate}>{value.candidate}</option>)}
                </select>
                </label>
                {api == null ? null : <input type="submit" value="Cast Vote" />}
            </form>
            {/* <button onClick={show_table}>
                Cast Vote
            </button> */}
            <div>
                <h1>Current result</h1>
                {data.map((value, index) => 
                        <p>{`Name : ${value.candidate} count : ${value.vote_count}`}</p>)}
            </div>
        </div>

        
    )
}


export default Home;