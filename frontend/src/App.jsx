
import React from 'react'
import { InjectedConnector } from "@web3-react/injected-connector"

const injected = new InjectedConnector({supportedChainIds: [0xA869]})
const AVALANCHE_TESTNET_PARAMS = {
  chainId: '0xA869',
  chainName: 'Avalanche Testnet C-Chain',
  nativeCurrency: {
      name: 'Avalanche',
      symbol: 'AVAX',
      decimals: 18
  },
  rpcUrls: ['https://api.avax-test.network/ext/bc/C/rpc'],
  blockExplorerUrls: ['https://cchain.explorer.avax-test.network/']
}

const addAvalancheNetwork = () => {
  injected.getProvider().then(provider => {
    provider
      .request({
        method: 'wallet_addEthereumChain',
        params: [AVALANCHE_TESTNET_PARAMS]
      })
  })
}

class App extends React.Component {

  constructor() {
    super()
    this.state = {
      clicked: false,
      value: "connect to metamask"
    }
    this.handleClick = this.handleClick.bind(this)

  }

  handleClick() {
    if (this.state.clicked === true) {
      this.setState = {value: "already connected"}
    }
    this.setState = {clicked: true}
    addAvalancheNetwork()
  }
  render() {
    return <button onClick={this.handleClick}>{this.state.value}</button>
  }
}

export default App
