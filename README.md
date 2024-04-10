<p align="center">
  <a href="https://github.com/venom-blockchain/developer-program">
    <img src="https://raw.githubusercontent.com/venom-blockchain/developer-program/main/vf-dev-program.png" alt="Logo" width="366.8" height="146.4">
  </a>
</p>

# Venom ID

Venom ID Domains (.venom) is a distributed, open, and extensible naming system based on The Open Network Virtual Machine (TVM)-compatible blockchains.

## Table of Contents

- [About](#about)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## About

Venom ID's primary function is to map human-readable names like 'sam.venom' to machine-readable identifiers, including wallet addresses, IP or ADNL addresses, traditional domain names, and other DNS protocol records. Venom ID also supports reverse resolution , enabling the association of metadata, such as canonical names or interface descriptions, with wallet addresses.

reverse resolution currently is in the form of listing names, primary names are coming soon

.venom domains are implemented as Non-Fungible Tokens (NFTs) using the TIP-4 token standard, which allows the owner to manage records and create subdomains as child NFTs.

Venom ID operates on a system of dot-separated hierarchical names called domains, with the owner of a domain having full control over subdomains. Top-level domains, like '.venom' and '.test', are managed by the Root smart contract, which deploys new domain and subdomain certificates and ensures seamless integration between various components and interfaces.


## Deployed domains

| tld   | network | Address                                                             |
|-------|---------|---------------------------------------------------------------------|
| venom | mainnet | 0:2b353a0c36c4c86a48b0392c69017a109c8941066ed1747708fc63b1ac79e408  |
|  vid  | testnet | 0:5475e9e7b9d178f4c35cd1136e83a100ca95e28b38c5c52d0689771372ba43ec  |


## Getting Started

Venom Domains smart contracts are a modification of [DeNS](https://github.com/tonred/DeNS) - at [EverName](https://evername.io/), you can view the contracts structure and information at [Evername Docs](https://ever-name-docs.netlify.app/).

you can see the changes done on venom id at the end of this page.

You can call Venom ID from ton-solidity contracts or client/backend environments!
Currently , our guides provide coverage of client in React and Next.js. As we continue to expand, we will incorporate additional tools and libraries to enhance our documents.

### Prerequisites

The code examples given in this document assumes that it is executed within a DApp browser environment, such as Chrome with the [Venom Wallet](https://venomwallet.com/) extension installed. This environment provides access to the provider object. For additional information on how to connect to the venom blockchain please refer to [venom documentation](https://venom.guide/frontend/connect) 

### Installing

To begin, let's establish a connection between our app and the Venom Wallet. 

To accomplish this, we will utilize the [Venom-Connect](https://www.npmjs.com/package/venom-connect) library. This library offers a convenient interface for creating a connect popup within our app for the Venom wallet, and also provides an interface for interacting with the Venom network. 

hint: 
For detailed information on how to use Venom-Connect, please refer to [Venom Docs](https://docs.venom.foundation/build/development-guides/how-to-create-your-own-fungible-tip-3-token/venom-in-action/extend-our-tokensale-with-frontend).

First, make sure to install the [`venom-connect`](https://www.npmjs.com/package/venom-connect) , [everscale-inpage-provider](https://www.npmjs.com/package/everscale-inpage-provider) and [everscale-standalone-client](https://www.npmjs.com/package/everscale-standalone-client) packages.


```bash
npm install --save venom-connect everscale-inpage-provider everscale-standalone-client
```

or 


```bash
yarn add --dev venom-connect everscale-inpage-provider everscale-standalone-client
```

## Usage

{% hint style="info" %}
If you already have access to the provider object ( ProviderRpcClient ) in your environment, then you can ignore this step.
{% endhint %}

```jsx
import { VenomConnect } from "venom-connect";
import { ProviderRpcClient } from "everscale-inpage-provider";

const venomConnect = new VenomConnect({
  // venom connect config
  // check out https://codesandbox.io/p/devbox/venom-id-lookup-address-v95v7c
});

venomConnect.connect() // open pop up for venom wallet connection

const provider = await venomConnect.checkAuth(); 
// we need the provider instance for later

```

## Resolve Domain


The goal here is to take a name, such as `sam.venom`, and convert it to an address, such as `0:4bc69a8c3889adee39f6f1e3b2353c86f960c9b835e93397a2015a62a4823765`


&#x20;`sam.venom`➡️ `0:4bc6...3765`&#x20;

## Using Contract Methods And Abi

<pre class="language-typescript"><code class="lang-typescript">import { Address, ProviderRpcClient } from "everscale-inpage-provider";
const { VENOMID_ROOT_CONTRACT_ADDRESS } from "./constants";
// mainnet : 0:2b353a0c36c4c86a48b0392c69017a109c8941066ed1747708fc63b1ac79e408

import RootAbi from "abi/Root.abi.json"; 
// https://github.com/sam-shariat/venomidapp/blob/main/abi/Root.abi.json
import DomainAbi from "abi/Domain.abi.json";
// https://github.com/sam-shariat/venomidapp/blob/main/abi/Domain.abi.json

async function lookupAddress
(provider: ProviderRpcClient,path: string) 
{
  if (!provider) return;
  
<strong>  const rootContract = new provider.Contract(
</strong>      RootAbi,
      new Address(ROOT_CONTRACT_ADDRESS)
    );
    
  const certificateAddr: { certificate: Address } = await rootContract.methods
    .resolve({ path: path, answerId: 0 } as never)
    .call({ responsible: true });

  const domainContract = new provider.Contract(
    DomainAbi,
    certificateAddr.certificate
  );
  
  try {
  
    const { target } = await domainContract.methods.resolve({ answerId: 0 } as never)
      .call({ responsible: true });
    
    if (target) {
      return String(target);
    } else {
      return "";
    }
  } catch (e) {
    return ""
  }
}

const targetAddress = await lookupAddress(provider,"sam.venom");
console.log(targetAddress);
// output : 0:4bc6...3765 
</code></pre>


### To get a dns record for a specific domain:
On root contract :

`resolve(string path) public view responsible returns (address certificate)`.
example path : sam.venom

This method will return the address of the domain certificate. Check if such account exists and then call methods for obtaining DNS records from it:

`query(uint32 key) public view responsible returns (optional(TvmCell))`

| Key | description                                | ABI     |
|-----|--------------------------------------------|---------|
| 0   | Venom account address (target address)     | address |
| 1   | ETH address                                | string  |
| -   |                                            |         |
| 11  | Avatar (NFT Image)                         | string  |
| 12  | Header                                     | string  |
| 13  | Location                                   | string  |
| 14  | URL                                        | string  |
| 15  | Description (NFT Description)              | string  |
| 16  | Color                                      | string  |
| 17  | BG                                         | string  |
| 18  | TextColor                                  | string  |
| 19  | Styles                                     | string  |
| 20  | Twitter                                    | string  |
| -   |                                            |         |
| 30  | Links                                      | string  |
| -   |                                            |         |
| 33  | IPFS                                       | string  |



## Methods
### [Root](contracts/Root.sol)
1) Find certificate address by full path
2) Create new domain
3) Renew exist domains
4) Confiscate domain via DAO voting ( later )
5) Reserve and unreserve domain via DAO voting ( later )
6) Execute any action via DAO voting ( later )
7) Activate or deactivate root contracts (only admin)

&#43; All TIP4 (TIP4.1, TIP4.2, TIP4.3) methods

### [Domain](contracts/Domain.sol)
1) Resolve domain
2) Query record(s)
3) Change target or record
4) Create subdomain

&#43; All TIP4 (TIP4.1, TIP4.2, TIP4.3) methods


## Workflow

### [Certificate statuses](contracts/enums/CertificateStatus.sol)

0) `RESERVED` - reserved by dao
1) `NEW` - first N days domain is new, anybody can start auction
2) `IN_ZERO_AUCTION` - new domain that in auction new
3) `COMMON` - common certificate, nothing special
4) `EXPIRING` - domain will be expired in N days, user cannot create auction for it
5) `GRACE` - N days after expiring, where user can renew it for additional fee
6) `EXPIRED` - domain is fully expired (after grace period), anybody can destroy it

### Register new domain

Anyone can call

1) Get price via `expectedRegisterAmount` in root
2) Build payload via `buildRegisterPayload` in root
3) Send tokens and payload to root via `register`
4) Sender will receive
    * `onMinted` callback if success
    * Get tokens back with `TransferBackReason.ALREADY_EXIST` reason if domain already exist
    * Get tokens back with `TransferBackReason.*` reason in case of another errors

### Renew exist domain

Only domain owner can call

1) Get `expectedRenewAmount` in domain
2) Build payload via `buildRenewPayload` in root
3) Send tokens and payload to root via `register`
4) Sender will receive
    * `onRenewed` callback if success
    * Get tokens back with `TransferBackReason.DURATION_OVERFLOW` reason if duration is too big
    * Get tokens back with `TransferBackReason.*` reason in case of another errors


### Create subdomain

1) Call `createSubdomain` in domain/subdomain, where:
    * `name` - name of subdomain
    * `owner` - owner of new subdomain
    * `renewable` - a flag that marks if owner of subdomain can renew it in any time
2) `owner` received:
    * `onMinted` callback if success
    * `onCreateSubdomainError` with `TransferBackReason.*` reason callback in case of error

## Contributing

- Fork the project
- Create a topic branch from master
- Make commits to improve the project and push your branch
- Open a Pull Request

## License:
Apache 2.0 license.


### changes

major changes from [DeNS](https://github.com/tonred/DeNS) to Venom Domains

- Vault and TIP3 wallet is removed from the contract
- Registration : Send tokens and payload to root via `register` function instead of sending to TIP3 wallet
- Domain Certificate and NFT Json Changes

please check [Certificate.sol](contracts/abstract/Certificate.sol)  and [NFTCertificate.sol](contracts/abstract/NFTCertificate.sol) 

following keys are defined as constants and are being returned in the domain json

<pre class="language-typescript"><code class="lang-typescript">
uint32 constant TARGET_RECORD_ID = 0;
uint32 constant TARGET_ETH_RECORD_ID = 1;
uint32 constant DISPLAY_RECORD_ID = 10;
uint32 constant AVATAR_RECORD_ID = 11;
uint32 constant HEADER_RECORD_ID = 12;
uint32 constant LOCATION_RECORD_ID = 13;
uint32 constant URL_RECORD_ID = 14;
uint32 constant DESCRIPTION_RECORD_ID = 15;
uint32 constant COLOR_RECORD_ID = 16;
uint32 constant BG_RECORD_ID = 17;
uint32 constant TEXTCOLOR_RECORD_ID = 18;
uint32 constant STYLES_RECORD_ID = 19;

uint32 constant TWITTER_RECORD_ID = 20;
uint32 constant LINKS_RECORD_ID = 30;
uint32 constant IPFS_RECORD_ID = 33;
</code></pre>

-All other functions are the same