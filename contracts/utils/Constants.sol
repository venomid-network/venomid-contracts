pragma ever-solidity ^0.63.0;


library Constants {

    // Domain price duration unit
    // For example, 1 year means that all prices are for 1 year
    uint128 constant DURATION_UNIT = 60 * 60 * 24 * 365;  // 1 year

    // Denominator of all percents (see Configs.sol)
    uint128 constant PERCENT_DENOMINATOR = 100_000;

    // Expire time for reserved certificates (max uint32 value)
    uint32 constant RESERVED_EXPIRE_TIME = 60 * 60 * 24 * 7;  // 1 week

    // CERTIFICATE (see Certificate.sol)
    // Max record cell size
    uint16 constant MAX_CELLS = 8;
    // Exact size of address var
    uint16 constant ADDRESS_SIZE = 267;
    // Record id of "target" record
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

    // VERSIONABLE
    uint16 constant DOMAIN_SID = 1;
    uint16 constant DOMAIN_VERSION_MAJOR = 1;
    uint16 constant DOMAIN_VERSION_MINOR = 7;
    uint16 constant SUBDOMAIN_SID = 2;
    uint16 constant SUBDOMAIN_VERSION_MAJOR = 1;
    uint16 constant SUBDOMAIN_VERSION_MINOR = 3;

    // Vault
    //uint256 constant WEVER_VAULT_VALUE = 0x2c3a2ff6443af741ce653ae4ef2c85c2d52a9df84944bbe14d702c3131da3f14;
    //uint256 constant BLACK_HOLE_VALUE = 0xefd5a14409a8a129686114fc092525fddd508f1ea56d1b649a3a695d3a5b188c;

}
