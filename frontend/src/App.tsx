import React, { useState } from 'react';
import { useAccount, useConnect, useDisconnect, useBalance, useReadContract, useChainId, useSwitchChain } from 'wagmi';
import { injected } from 'wagmi/connectors';
import { formatEther } from 'viem';
import { arbitrumSepolia } from 'wagmi/chains';

const TOKEN_ADDRESS = '0x0000000000000000000000000000000000000000';

const tokenABI = [
  {
    name: 'getVotes',
    type: 'function',
    stateMutability: 'view',
    inputs: [{ name: 'account', type: 'address' }],
    outputs: [{ name: '', type: 'uint256' }],
  },
  {
    name: 'balanceOf',
    type: 'function',
    stateMutability: 'view',
    inputs: [{ name: 'account', type: 'address' }],
    outputs: [{ name: '', type: 'uint256' }],
  },
  {
    name: 'delegate',
    type: 'function',
    stateMutability: 'nonpayable',
    inputs: [{ name: 'delegatee', type: 'address' }],
    outputs: [],
  },
];

export default function App() {
  const { address, isConnected } = useAccount();
  const { connect } = useConnect();
  const { disconnect } = useDisconnect();
  const { data: balance } = useBalance({ address });
  const chainId = useChainId();
  const { switchChain } = useSwitchChain();
  const [activeTab, setActiveTab] = useState('dashboard');

  const { data: votingPower } = useReadContract({
    address: TOKEN_ADDRESS,
    abi: tokenABI,
    functionName: 'getVotes',
    args: [address!],
  });

  const { data: tokenBalance } = useReadContract({
    address: TOKEN_ADDRESS,
    abi: tokenABI,
    functionName: 'balanceOf',
    args: [address!],
  });

  if (!isConnected) {
    return (
      <div style={{
        minHeight: '100vh',
        background: 'linear-gradient(135deg, #e8f5e9, #c8e6c9, #a5d6a7)',
        display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
        fontFamily: 'system-ui, sans-serif', padding: 20
      }}>
        <div style={{ fontSize: 60, marginBottom: 20 }}>🌿</div>
        <h1 style={{ fontSize: 42, fontWeight: 800, color: '#1b5e20', marginBottom: 10 }}>RWA Tokenization</h1>
        <p style={{ fontSize: 18, color: '#4caf50', marginBottom: 40, textAlign: 'center', maxWidth: 500 }}>
          Decentralized protocol for tokenizing real-world assets
        </p>
        <button onClick={() => connect({ connector: injected() })} style={{
          background: 'linear-gradient(135deg, #66bb6a, #43a047)', color: 'white', border: 'none',
          padding: '18px 48px', borderRadius: 16, fontSize: 18, fontWeight: 600, cursor: 'pointer',
          boxShadow: '0 4px 15px rgba(76,175,80,0.3)'
        }}>Connect Wallet</button>
      </div>
    );
  }

  if (chainId !== arbitrumSepolia.id) {
    return (
      <div style={{
        minHeight: '100vh', background: 'linear-gradient(135deg, #e8f5e9, #c8e6c9)',
        display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: 'system-ui, sans-serif'
      }}>
        <div style={{ background: 'white', borderRadius: 20, padding: 40, textAlign: 'center' }}>
          <h2 style={{ color: '#e65100' }}>Wrong Network</h2>
          <p>Please switch to Arbitrum Sepolia</p>
          <button onClick={() => switchChain({ chainId: arbitrumSepolia.id })} style={{
            background: '#66bb6a', color: 'white', border: 'none', padding: '14px 32px',
            borderRadius: 12, fontSize: 16, fontWeight: 600, cursor: 'pointer', marginTop: 20
          }}>Switch Network</button>
        </div>
      </div>
    );
  }

  const tabs = ['dashboard', 'proposals', 'vault'];
  const styles = {
    container: { minHeight: '100vh', background: 'linear-gradient(135deg, #e8f5e9, #c8e6c9, #a5d6a7)', fontFamily: 'system-ui, sans-serif' },
    header: { background: 'rgba(255,255,255,0.85)', padding: '20px 40px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid rgba(129,199,132,0.3)' },
    card: { background: 'rgba(255,255,255,0.9)', borderRadius: 20, padding: 30, margin: 20, boxShadow: '0 8px 32px rgba(129,199,132,0.1)' },
    btn: { background: 'linear-gradient(135deg, #66bb6a, #43a047)', color: 'white', border: 'none', padding: '12px 28px', borderRadius: 12, fontWeight: 600, cursor: 'pointer' },
    btnOut: { background: 'transparent', color: '#2e7d32', border: '2px solid #66bb6a', padding: '12px 28px', borderRadius: 12, fontWeight: 600, cursor: 'pointer' },
  };

  return (
    <div style={styles.container}>
      <header style={styles.header}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 15 }}>
          <span style={{ fontSize: 28 }}>🌿</span>
          <div style={{ fontSize: 24, fontWeight: 700, color: '#2e7d32' }}>RWA Platform</div>
        </div>
        <div style={{ display: 'flex', gap: 20, alignItems: 'center' }}>
          {tabs.map(tab => (
            <div key={tab} onClick={() => setActiveTab(tab)} style={{
              color: '#2e7d32', cursor: 'pointer', padding: '8px 16px', borderRadius: 8,
              background: activeTab === tab ? 'rgba(129,199,132,0.2)' : 'transparent',
              fontWeight: 500, textTransform: 'capitalize'
            }}>{tab}</div>
          ))}
          <button onClick={() => disconnect()} style={styles.btnOut}>Disconnect</button>
        </div>
      </header>

      {activeTab === 'dashboard' && (
        <div style={{ maxWidth: 1200, margin: '0 auto' }}>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: 20, padding: 20 }}>
            <div style={styles.card}><div style={{ fontSize: 13, color: '#66bb6a', fontWeight: 600 }}>Address</div><div style={{ fontSize: 12, color: '#81c784', fontFamily: 'monospace', marginTop: 8 }}>{address}</div></div>
            <div style={styles.card}><div style={{ fontSize: 13, color: '#66bb6a', fontWeight: 600 }}>ETH Balance</div><div style={{ fontSize: 28, fontWeight: 700, color: '#1b5e20' }}>{balance ? parseFloat(formatEther(balance.value)).toFixed(4) : '0'} ETH</div></div>
            <div style={styles.card}><div style={{ fontSize: 13, color: '#66bb6a', fontWeight: 600 }}>GOV Balance</div><div style={{ fontSize: 28, fontWeight: 700, color: '#1b5e20' }}>{tokenBalance ? parseFloat(formatEther(tokenBalance as bigint)).toFixed(2) : '0'} GOV</div></div>
            <div style={styles.card}><div style={{ fontSize: 13, color: '#66bb6a', fontWeight: 600 }}>Voting Power</div><div style={{ fontSize: 28, fontWeight: 700, color: '#1b5e20' }}>{votingPower ? parseFloat(formatEther(votingPower as bigint)).toFixed(2) : '0'} GOV</div></div>
          </div>
        </div>
      )}

      {activeTab === 'proposals' && (
        <div style={{ maxWidth: 1200, margin: '0 auto', padding: 20 }}>
          <h2 style={{ color: '#2e7d32', fontSize: 28 }}>Governance Proposals</h2>
          <div style={{ ...styles.card, marginTop: 20 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div><h3 style={{ color: '#1b5e20', margin: 0 }}>Proposal #1</h3><p style={{ color: '#666' }}>Add new asset type</p></div>
              <span style={{ background: '#e8f5e9', color: '#2e7d32', padding: '6px 14px', borderRadius: 20, fontSize: 12, fontWeight: 600 }}>Active</span>
            </div>
            <div style={{ display: 'flex', gap: 10, marginTop: 15 }}>
              <button style={styles.btn}>Vote For</button>
              <button style={styles.btnOut}>Vote Against</button>
            </div>
          </div>
        </div>
      )}

      {activeTab === 'vault' && (
        <div style={{ maxWidth: 1200, margin: '0 auto', padding: 20 }}>
          <h2 style={{ color: '#2e7d32', fontSize: 28 }}>Yield Vault</h2>
          <div style={styles.card}><div style={{ fontSize: 13, color: '#66bb6a', fontWeight: 600 }}>APY</div><div style={{ fontSize: 28, fontWeight: 700, color: '#43a047' }}>5.2%</div></div>
          <div style={{ ...styles.card, display: 'flex', gap: 15 }}><input placeholder="Amount" style={{ flex: 1, padding: 14, borderRadius: 12, border: '2px solid #c8e6c9', fontSize: 16 }} /><button style={styles.btn}>Deposit</button><button style={styles.btnOut}>Withdraw</button></div>
        </div>
      )}
    </div>
  );
}
