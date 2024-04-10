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

You can call Venom ID from ton-solidity contracts or client/backend!
Currently , our guides provide coverage of client in React and Next.js. As we continue to expand, we will incorporate additional tools and libraries to enhance our documents.

### Prerequisites

List any prerequisites required to use the project.

### Installing

Step-by-step instructions on how to install and set up the project.


## Usage

## Resolve Domain
### To get a dns record for a specific domain:

On root contract for specific TLD call:

`resolve(string path) public view responsible returns (address certificate)`.

This method will return the address of the domain certificate. Check if such account exists and then call methods for obtaining DNS records from it:

`query(uint32 key) public view responsible returns (optional(TvmCell))`

| ID  | description                                | ABI     |
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
### [Root] (contracts/Root.sol)
1) Find certificate address by full path
2) Create new domain
3) Renew exist domains
4) Confiscate domain via DAO voting ( later )
5) Reserve and unreserve domain via DAO voting ( later )
6) Execute any action via DAO voting ( later )
7) Activate or deactivate root contracts (only admin)

&#43; All TIP4 (TIP4.1, TIP4.2, TIP4.3) methods

### [Domain] (contracts/Domain.sol)
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

Instructions on how to contribute to the project, including guidelines for pull requests and code reviews.

License:
Apache 2.0 license.