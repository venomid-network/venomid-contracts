pragma ever-solidity ^0.63.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "./abstract/NFTCertificate.sol";


contract Subdomain is ISubdomain, NFTCertificate {

    event Renewed(uint32 now, uint32 newExpireTime);

    DurationConfig public _durationConfig;
    address public _parent;
    bool public _renewable;


    modifier onlyParent() {
        require(msg.sender == _parent, ErrorCodes.IS_NOT_PARENT);
        _;
    }

    modifier onlyRenewable() {
        require(_renewable, ErrorCodes.IS_NOT_RENEWABLE);
        _;
    }


    function onDeployRetry(TvmCell /*code*/, TvmCell params) public functionID(0x4A2E4FD6) override onlyRoot {
        (/*path*/, /*durationConfig*/, SubdomainSetup setup, /*indexCode*/)
            = abi.decode(params, (string, DurationConfig, SubdomainSetup, TvmCell));
        IOwner(setup.creator).onCreateSubdomainError{
            value: 0,
            flag: MsgFlag.REMAINING_GAS,
            bounce: false
        }(_path, TransferBackReason.ALREADY_EXIST);
        if (_status() == CertificateStatus.EXPIRED) {
            _destroy();
        }
    }

    function _init(TvmCell params) internal override {
        _reserve();
        _initVersion(Constants.SUBDOMAIN_SID, Version(Constants.SUBDOMAIN_VERSION_MAJOR, Constants.SUBDOMAIN_VERSION_MINOR));
        SubdomainSetup setup;
        address creator;
        (_path, _durationConfig, setup, _indexCode) =
            abi.decode(params, (string, DurationConfig, SubdomainSetup, TvmCell));
        (_owner, creator, _expireTime, _parent, _renewable) = setup.unpack();
        IOwner(creator).onSubdomainCreated{
            value: Gas.RENEW_SUBDOMAIN_VALUE,
            flag: MsgFlag.SENDER_PAYS_FEES,
            bounce: false
        }(_path, _owner);
        _initNFT(_owner, _owner, _indexCode, creator);
    }


    function getDurationConfig() public view responsible override returns (DurationConfig durationConfig) {
        return {value: 0, flag: MsgFlag.REMAINING_GAS, bounce: false} _durationConfig;
    }

    function requestRenew() public view override onlyOwner onlyRenewable cashBack {
        ICertificate(_parent).renewSubdomain{
            value: Gas.RENEW_SUBDOMAIN_VALUE,
            flag: MsgFlag.SENDER_PAYS_FEES,
            bounce: false
        }(address(this));
    }

    function renew(uint32 expireTime) public override onlyParent onlyRenewable {
        _reserve();
        if (_expireTime != expireTime) {
            _expireTime = expireTime;
            emit Renewed(now, _expireTime);
        }
        IOwner(_owner).onRenewed{
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED,
            bounce: false
        }(_path, _expireTime);
    }

    function destroy() public override onlyOwner {
        _destroy();
    }


    function _status() internal view override returns (CertificateStatus) {
        int64 left = int64(_expireTime) - now;
        if (left < -_durationConfig.grace) {
            return CertificateStatus.EXPIRED;
        } else if (left < 0) {
            return CertificateStatus.GRACE;
        } else if (left < _durationConfig.expiring) {
            return CertificateStatus.EXPIRING;
        } else {
            return CertificateStatus.COMMON;
        }
    }

    function _targetBalance() internal view inline override returns (uint128) {
        return Gas.SUBDOMAIN_TARGET_BALANCE;
    }


    function _encodeContractData() internal override returns (TvmCell) {
        return abi.encode(
            _owner, _manager, _indexCode,  // NFTBase4_1 + NFTBase4_3
            _sid, _version,  // BaseSlave
            _id, _root, _path, _initTime, _expireTime, _target, _records,  // Certificate
            _durationConfig, _parent, _renewable  // Subdomain
        );
    }

}
