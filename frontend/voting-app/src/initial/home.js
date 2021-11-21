/* eslint-disable react-hooks/rules-of-hooks */
import {Link} from 'react-router-dom';
import React, { useState, useEffect } from 'react';
const { Api, JsonRpc } = require('eosjs');
const { JsSignatureProvider } = require('eosjs/dist/eosjs-jssig');  // development only


const home = () => {
    const signatureProvider = new JsSignatureProvider([process.env.REACT_APP_OWNER_PRIVATE]);
    const rpc = new JsonRpc(process.env.REACT_APP_TESTNET_HTTP, { fetch }); //required to read blockchain state
    const api = new Api({ rpc, signatureProvider, textDecoder: new TextDecoder(), textEncoder: new TextEncoder() }); //required to submit transactions

    const [person, setPerson] = useState("");
    const [data, setData] = useState([]);

    const add_candidate = async () => {
        const transaction = await api.transact({
            actions: [{
              account: 'eimeutmhpudu',
              name: 'addcandidate',
              authorization: [{
                actor: 'eimeutmhpudu',
                permission: 'owner',
              }],
              data: {
                new_candidate : "test12"
              },
            }]
           }, {
            blocksBehind: 3,
            expireSeconds: 30,
           });
        console.log(transaction);
    }
    
    const show_table = async () => {
        const table = await rpc.get_table_rows({
            json: true,               // Get the response as json
            code: 'eimeutmhpudu',      // Contract that we target
            scope: 'eimeutmhpudu',         // Account that owns the data
            table: 'votingresult',        // Table name
            limit: 10,                // Maximum number of rows that we want to get
          });
        console.log(table)
        setData(table.rows);
    }

    const vote = async () => {
        const transaction = await api.transact({
            actions: [{
              account: 'eimeutmhpudu',
              name: 'vote',
              authorization: [{
                actor: 'eimeutmhpudu',
                permission: 'owner',
              }],
              data: {
                candidate : person
              },
            }]
           }, {
            blocksBehind: 3,
            expireSeconds: 30,
           });
        console.log(transaction);
        show_table();
    }

    useEffect(() => {
        show_table();
    }, []);

    return (
        <div>
            <h1> Welcome to the blockchain based voting system </h1>
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
                <input type="submit" value="Cast Vote" />
            </form>
            <button onClick={show_table}>
                Cast Vote
            </button>
            <div>
                <h1>Current result</h1>
                {data.map((value, index) => 
                        <p>{`Name : ${value.candidate} count : ${value.vote_count}`}</p>)}
            </div>
        </div>

        
    )
}


export default home;