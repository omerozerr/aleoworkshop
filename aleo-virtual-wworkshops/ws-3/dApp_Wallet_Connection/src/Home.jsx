import { useConnect, useDisconnect, useSelect } from 'aleo-hooks';
import React from 'react';

const Home = () => {

    return (
        <div style={{ textAlign: 'center', marginTop: '50px' }}>
            <h1>Hey! Nice to meet you!</h1>
            <button style={{ marginTop: '20px', padding: '10px 20px', fontSize: '16px' }}>
                Connect Wallet
            </button>
        </div>
    );
};

export default Home;