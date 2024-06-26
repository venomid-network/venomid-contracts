pragma ever-solidity ^0.63.0;

import "@broxus/contracts/contracts/libraries/MsgFlag.tsol";


abstract contract TransferUtils {
    uint16 constant _LOW_MSG_VALUE = 500;

    modifier minValue(uint128 value) {
        require(msg.value >= value, _LOW_MSG_VALUE);
        _;
    }

    modifier cashBack() {
        _reserve();
        _;
        msg.sender.transfer({value: 0, flag: MsgFlag.ALL_NOT_RESERVED, bounce: false});
    }

    function _reserve() internal view virtual {
        tvm.rawReserve(_targetBalance(), 0);
    }

    function _targetBalance() internal view inline virtual returns (uint128);

}
