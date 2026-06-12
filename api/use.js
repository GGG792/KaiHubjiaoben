// KaiHub Key Verification API - Use endpoint
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
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }

    const { searchParams } = new URL(req.url, `https://${req.headers.host}`);
    const key = searchParams.get('key') || '';
    const device = searchParams.get('device') || 'unknown';
    const player = searchParams.get('player') || 'unknown';

    if (usedKeys[key]) {
        return res.json({
            success: false,
            message: "Key already used by another device",
            device: usedKeys[key].device
        });
    } else if (VALID_KEYS.includes(key)) {
        usedKeys[key] = {
            device: device,
            player: player,
            time: new Date().toISOString(),
            used: true
        };
        return res.json({
            success: true,
            message: "Key activated successfully"
        });
    } else {
        return res.json({
            success: false,
            message: "Invalid key"
        });
    }
};
