pragma ever-solidity ^0.63.0;

import "./Certificate.sol";
import "./Collection.sol";

import "tip4/contracts/implementation/4_2/JSONMetadataDynamicBase.sol";
import "tip4/contracts/implementation/4_3/NFTBase4_3.sol";


abstract contract NFTCertificate is NFTBase4_3, JSONMetadataDynamicBase, Certificate {

    modifier onlyManager() {
        require(msg.sender == _manager, ErrorCodes.IS_NOT_MANAGER);
        _;
    }

    function _initNFT(address owner, address manager, TvmCell indexCode, address creator) internal {
        _onInit4_3(owner, manager, indexCode);
        Collection(_root).onMint{
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED,
            bounce: false
        }(_id, _owner, _manager, creator);
    }


    // TIP 4.1
    function changeOwner(
        address newOwner, address sendGasTo, mapping(address => CallbackParams) callbacks
    ) public virtual override onlyManager onActive {
        super.changeOwner(newOwner, sendGasTo, callbacks);
    }

    // TIP 4.1
    function changeManager(
        address newManager, address sendGasTo, mapping(address => CallbackParams) callbacks
    ) public virtual override onlyManager onActive {
        super.changeManager(newManager, sendGasTo, callbacks);
    }

    // TIP 4.1
    function transfer(
        address to, address sendGasTo, mapping(address => CallbackParams) callbacks
    ) public virtual override onlyManager onActive {
        super.transfer(to, sendGasTo, callbacks);
    }

    // TIP 4.2
    function getJson() public view responsible override returns (string json) {
        string targetStr = _target.isNone() ? "<not set>" : format("{}", _target);
        string ipfsStr = _ipfs.empty() ? "<not set>" : format("{}", _ipfs);
        string avatarStr = _avatar.empty() ? "<not set>" : format("{}", _avatar);
        string ethStr = _eth.empty() ? "<not set>" : format("{}", _eth);
        string headerStr = _header.empty() ? "<not set>" : format("{}", _header);
        string locationStr = _location.empty() ? "<not set>" : format("{}", _location);
        string displayStr = _display.empty() ? "<not set>" : format("{}", _display);
        string noticeStr = _notice.empty() ? "<not set>" : format("{}", _notice);
        string stylesStr = _styles.empty() ? "<not set>" : format("{}", _styles);
        string description = _description.empty() ? format("Venom ID Domain '{}' → {}", _path, targetStr) : format("{}", _description);
        string source = _avatar.empty() ? format("https://img.venomid.network/api/{}", _path) : format("{}", _avatar); 
        string external_url = "https://venomid.link/" + _path;
        json = format(
            "{\"type\":\"Venom Domain\",\"name\":\"{}\",\"avatar\":\"{}\",\"eth\":\"{}\",\"header\":\"{}\",\"location\":\"{}\",\"display\":\"{}\",\"notice\":\"{}\",\"styles\":\"{}\",\"description\":\"{}\",\"preview\":{\"source\":\"{}\",\"mimetype\":\"image/jpg\"},\"files\":[],\"external_url\":\"{}\",\"target\":\"{}\",\"init_time\":{},\"expire_time\":{},\"hash\":\"{}\"}",
            _path,          // name
            avatarStr,    // avatar
            ethStr,    // eth
            headerStr,    // header
            locationStr,    // location
            displayStr,    // display
            noticeStr,    // notice
            stylesStr,    // styles
            description,    // description
            source,         // source
            external_url,   // external_url
            targetStr,      // target
            _initTime,      // init_time
            _expireTime,     // expire_time
            ipfsStr     // expire_time
        );

        return {value: 0, flag: MsgFlag.REMAINING_GAS, bounce: false} json;
    }

    // TIP6
    function supportsInterface(
        bytes4 interfaceID
    ) public view responsible override(NFTBase4_3, JSONMetadataDynamicBase) returns (bool support) {
        return {value: 0, flag: MsgFlag.REMAINING_GAS, bounce: false} (
            NFTBase4_3.supportsInterface(interfaceID) ||
            JSONMetadataDynamicBase.supportsInterface(interfaceID)
        );
    }

    function confiscate(address newOwner) public override onlyRoot {
        _reserve();
        _transfer(newOwner);
        IOwner(newOwner).onConfiscated{
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED,
            bounce: false
        }(_path);
    }

    function expire() public override onStatus(CertificateStatus.EXPIRED) {
        tvm.accept();
        _destroy();
    }


    function _getId() internal view override returns (uint256) {
        return _id;
    }

    function _getCollection() internal view override returns (address) {
        return _root;
    }

    function _getOwner() internal view override returns (address) {
        return _owner;
    }

    function _destroy() internal {
        Collection(_root).onBurn{
            value: Gas.ON_BURN_VALUE,
            flag: MsgFlag.SENDER_PAYS_FEES,
            bounce: false
        }(_id, _owner, _manager);
        _onBurn(_owner);
    }

    function _reserve() internal view override(NFTBase4_1, TransferUtils) {
        TransferUtils._reserve();
    }

    function _targetBalance() internal view inline virtual override returns (uint128);

}
