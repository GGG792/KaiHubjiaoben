// KaiHub Key Verification API - List endpoint (admin)
const VALID_KEYS = [
    "KAIHUB-TEST-001",
    "KAIHUB-TEST-002",
    "KAIHUB-TEST-003",
    "KAIHUB-VIP-001",
    "KAIHUB-VIP-002"
];

let usedKeys = {};

module.exports = async (req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    return res.json({
        used_keys: usedKeys,
        valid_keys: VALID_KEYS
    });
};
