import React, { useState } from 'react';
import { useAccount, useConnect, useDisconnect, useBalance, useReadContract, useWriteContract, useChainId, useSwitchChain } from 'wagmi';
import { injected } from 'wagmi/connectors';
import { formatEther } from 'viem';
import { arbitrumSepolia } from 'wagmi/chains';

const GOVERNOR_ADDRESS = '0x0000000000000000000000000000000000000000';
const TOKEN_ADDRESS = '0x0000000000000000000000000000000000000000';

const governorABI = [
  {
    name: 'propose',
    type: 'function',
    stateMutability: 'nonpayable',
    inputs: [
      { name: 'targets', type: 'address[]' },
      { name: 'values', type: 'uint256[]' },
      { name: 'calldatas', type: 'bytes[]' },
      { name: 'description', type: 'string' },
    ],
    outputs: [{ name: 'proposalId', type: 'uint256' }],
  },
  {
    name: 'castVote',
    type: 'function',
    stateMutability: 'nonpayable',
    inputs: [
      { name: 'proposalId', type: 'uint256' },
      { name: 'support', type: 'uint8' },
    ],
    outputs: [{ name: '', type: 'uint256' }],
  },
  {
    name: 'state',
    type: 'function',
    stateMutability: 'view',
    inputs: [{ name: 'proposalId', type: 'uint256' }],
    outputs: [{ name: '', type: 'uint8' }],
  },
];

const tokenABI = [
  {
    name: 'delegate',
    type: 'function',
    stateMutability: 'nonpayable',
    inputs: [{ name: 'delegatee', type: 'address' }],
    outputs: [],
  },
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
];

const styles = {
  container: {
    minHeight: '100vh',
    background: 'linear-gradient(135deg, #e8f5e9 0%, #c8e6c9 50%, #a5d6a7 100%)',
    fontFamily: 'Inter, system-ui, sans-serif',
  },
  header: {
    background: 'rgba(255, 255, 255, 0.85)',
    backdropFilter: 'blur(10px)',
    padding: '20px 40px',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderBottom: '1px solid rgba(129, 199, 132, 0.3)',
    boxShadow: '0 2px 20px rgba(129, 199, 132, 0.15)',
  },
  logo: {
    fontSize: '24px',
    fontWeight: '700',
    color: '#2e7d32',
    letterSpacing: '-0.5px',
  },
  card: {
    background: 'rgba(255, 255, 255, 0.9)',
    backdropFilter: 'blur(10px)',
    borderRadius: '20px',
    padding: '30px',
    margin: '20px',
    boxShadow: '0 8px 32px rgba(129, 199, 132, 0.1)',
    border: '1px solid rgba(129, 199, 132, 0.2)',
  },
  button: {
    background: 'linear-gradient(135deg, #66bb6a 0%, #43a047 100%)',
    color: 'white',
    border: 'none',
    padding: '14px 32px',
    borderRadius: '12px',
    fontSize: '16px',
    fontWeight: '600',
    cursor: 'pointer',
    transition: 'all 0.3s ease',
    boxShadow: '0 4px 15px rgba(76, 175, 80, 0.3)',
  },
  buttonOutline: {
    background: 'transparent',
    color: '#2e7d32',
    border: '2px solid #66bb6a',
    padding: '12px 28px',
    borderRadius: '12px',
    fontSize: '14px',
    fontWeight: '600',
    cursor: 'pointer',
    transition: 'all 0.3s ease',
  },
  input: {
    width: '100%',
    padding: '14px 18px',
    borderRadius: '12px',
    border: '2px solid #c8e6c9',
    fontSize: '16px',
    outline: 'none',
    transition: 'border 0.3s ease',
    background: 'rgba(255, 255, 255, 0.8)',
    boxSizing: 'border-box' as const,
  },
  badge: {
    background: 'linear-gradient(135deg, #a5d6a7 0%, #81c784 100%)',
    color: '#1b5e20',
    padding: '6px 16px',
    borderRadius: '20px',
    fontSize: '12px',
    fontWeight: '600',
    display: 'inline-block',
  },
  grid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))',
    gap: '20px',
    padding: '20px',
  },
  statLabel: {
    fontSize: '13px',
    color: '#66bb6a',
    fontWeight: '600',
    textTransform: 'uppercase' as const,
    letterSpacing: '1px',
    marginBottom: '8px',
  },
  statValue: {
    fontSize: '28px',
    fontWeight: '700',
    color: '#1b5e20',
  },
  address: {
    fontSize: '12px',
    color: '#81c784',
    fontFamily: 'monospace',
    marginTop: '4px',
  },
  nav: {
    display: 'flex',
    gap: '30px',
    alignItems: 'center',
  },
  navLink: {
    color: '#2e7d32',
    textDecoration: 'none',
    fontSize: '15px',
    fontWeight: '500',
    cursor: 'pointer',
    padding: '8px 16px',
    borderRadius: '8px',
    transition: 'all 0.2s ease',
  },
  proposalCard: {
    background: 'rgba(255, 255, 255, 0.9)',
    borderRadius: '16px',
    padding: '20px',
    marginBottom: '15px',
    border: '1px solid rgba(129, 199, 132, 0.2)',
  },
  statusBadge: {
    padding: '6px 14px',
    borderRadius: '20px',
    fontSize: '12px',
    fontWeight: '600',
    display: 'inline-block',
    marginLeft: '10px',
  },
};

export default function App() {
  const { address, isConnected, chain } = useAccount();
  const { connect } = useConnect();
  const { disconnect } = useDisconnect();
  const { data: balance } = useBalance({ address });
  const { writeContract } = useWriteContract();
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
      <div style={styles.container}>
        <div style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          minHeight: '100vh',
          padding: '20px',
        }}>
          <div style={{
            fontSize: '60px',
            marginBottom: '20px',
          }}>
            🌿
          </div>
          <h1 style={{
            fontSize: '42px',
            fontWeight: '800',
            color: '#1b5e20',
            marginBottom: '10px',
            textAlign: 'center',
          }}>
            RWA Tokenization
          </h1>
          <p style={{
            fontSize: '18px',
            color: '#4caf50',
            marginBottom: '40px',
            textAlign: 'center',
            maxWidth: '500px',
            lineHeight: '1.6',
          }}>
            A decentralized protocol for tokenizing real-world assets with governance, yielding vaults, and institutional-grade security.
          </p>
          <button
            onClick={() => connect({ connector: injected() })}
            style={{
              ...styles.button,
              padding: '18px 48px',
              fontSize: '18px',
              borderRadius: '16px',
            }}
          >
            Connect Wallet
          </button>
          <div style={{
            display: 'flex',
            gap: '30px',
            marginTop: '60px',
            color: '#66bb6a',
            fontSize: '14px',
          }}>
            <span>🔒 Secure</span>
            <span>⚡ Fast</span>
            <span>🌐 L2 Powered</span>
          </div>
        </div>
      </div>
    );
  }

  if (chainId !== arbitrumSepolia.id) {
    return (
      <div style={styles.container}>
        <div style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          minHeight: '100vh',
        }}>
          <div style={styles.card}>
            <h2 style={{ color: '#e65100', marginBottom: '20px' }}>Wrong Network</h2>
            <p style={{ color: '#666', marginBottom: '30px' }}>
              Please switch to Arbitrum Sepolia
            </p>
            <button
              onClick={() => switchChain({ chainId: arbitrumSepolia.id })}
              style={styles.button}
            >
              Switch to Arbitrum Sepolia
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div style={styles.container}>
      <header style={styles.header}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
          <span style={{ fontSize: '28px' }}>🌿</span>
          <div style={styles.logo}>RWA Platform</div>
        </div>
        <div style={styles.nav}>
          <div
            style={{
              ...styles.navLink,
              background: activeTab === 'dashboard' ? 'rgba(129, 199, 132, 0.2)' : 'transparent',
            }}
            onClick={() => setActiveTab('dashboard')}
          >
            Dashboard
          </div>
          <div
            style={{
              ...styles.navLink,
              background: activeTab === 'proposals' ? 'rgba(129, 199, 132, 0.2)' : 'transparent',
            }}
            onClick={() => setActiveTab('proposals')}
          >
            Proposals
          </div>
          <div
            style={{
              ...styles.navLink,
              background: activeTab === 'vault' ? 'rgba(129, 199, 132, 0.2)' : 'transparent',
            }}
            onClick={() => setActiveTab('vault')}
          >
            Vault
          </div>
          <button onClick={() => disconnect()} style={styles.buttonOutline}>
            Disconnect
          </button>
        </div>
      </header>

      <div style={{ maxWidth: '1200px', margin: '0 auto' }}>
        {activeTab === 'dashboard' && (
          <>
            <div style={styles.grid}>
              <div style={styles.card}>
                <div style={styles.statLabel}>Wallet Address</div>
                <div style={{ ...styles.address, fontSize: '14px' }}>{address}</div>
              </div>
              <div style={styles.card}>
                <div style={styles.statLabel}>ETH Balance</div>
                <div style={styles.statValue}>
                  {balance ? parseFloat(formatEther(balance.value)).toFixed(4) : '0'} ETH
                </div>
              </div>
              <div style={styles.card}>
                <div style={styles.statLabel}>GOV Balance</div>
                <div style={styles.statValue}>
                  {tokenBalance ? parseFloat(formatEther(tokenBalance as bigint)).toFixed(2) : '0'} GOV
                </div>
              </div>
              <div style={styles.card}>
                <div style={styles.statLabel}>Voting Power</div>
                <div style={styles.statValue}>
                  {votingPower ? parseFloat(formatEther(votingPower as bigint)).toFixed(2) : '0'} GOV
                </div>
              </div>
            </div>

            <div style={styles.card}>
              <h2 style={{ color: '#2e7d32', marginTop: 0, marginBottom: '20px' }}>Quick Actions</h2>
              <div style={{ display: 'flex', gap: '15px', flexWrap: 'wrap' }}>
                <button style={styles.button}>
                  Delegate Votes
                </button>
                <button style={styles.buttonOutline}>
                  Deposit to Vault
                </button>
                <button style={styles.buttonOutline}>
                  Create Proposal
                </button>
              </div>
            </div>
          </>
        )}

        {activeTab === 'proposals' && (
          <div style={{ padding: '20px' }}>
            <h2 style={{ color: '#2e7d32', fontSize: '28px', marginBottom: '25px' }}>
              Governance Proposals
            </h2>
            <div style={styles.proposalCard}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div>
                  <h3 style={{ color: '#1b5e20', margin: 0 }}>Proposal #1</h3>
                  <p style={{ color: '#666', margin: '8px 0' }}>Add new asset type to the platform</p>
                </div>
                <span style={{ ...styles.statusBadge, background: '#e8f5e9', color: '#2e7d32' }}>
                  Active
                </span>
              </div>
              <div style={{ display: 'flex', gap: '10px', marginTop: '15px' }}>
                <button style={styles.button}>Vote For</button>
                <button style={styles.buttonOutline}>Vote Against</button>
              </div>
            </div>
            <div style={styles.proposalCard}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div>
                  <h3 style={{ color: '#1b5e20', margin: 0 }}>Proposal #2</h3>
                  <p style={{ color: '#666', margin: '8px 0' }}>Adjust LTV ratio for real estate assets</p>
                </div>
                <span style={{ ...styles.statusBadge, background: '#fff3e0', color: '#e65100' }}>
                  Pending
                </span>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'vault' && (
          <div style={{ padding: '20px' }}>
            <h2 style={{ color: '#2e7d32', fontSize: '28px', marginBottom: '25px' }}>
              Yield Vault
            </h2>
            <div style={styles.grid}>
              <div style={styles.card}>
                <div style={styles.statLabel}>Total Value Locked</div>
                <div style={styles.statValue}>$0.00</div>
              </div>
              <div style={styles.card}>
                <div style={styles.statLabel}>APY</div>
                <div style={{ ...styles.statValue, color: '#43a047' }}>5.2%</div>
              </div>
              <div style={styles.card}>
                <div style={styles.statLabel}>Your Deposit</div>
                <div style={styles.statValue}>$0.00</div>
              </div>
            </div>
            <div style={styles.card}>
              <div style={{ display: 'flex', gap: '15px' }}>
                <input placeholder="Amount to deposit" style={styles.input} />
                <button style={styles.button}>Deposit</button>
                <button style={styles.buttonOutline}>Withdraw</button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
