// KaiHub Key Verification API - Vercel Serverless Function
// GET /api/check?key=xxx - 检查卡密状态
// GET /api/use?key=xxx&device=xxx - 使用卡密
// GET /api/list - 查看所有卡密

const VALID_KEYS = [
    "KAIHUB-TEST-001",
    "KAIHUB-TEST-002",
    "KAIHUB-TEST-003",
    "KAIHUB-VIP-001",
    "KAIHUB-VIP-002"
];

// 使用 Vercel KV 或者简单的全局变量（演示用）
// 注意：Vercel 无状态，每次冷启动会重置
// 生产环境建议连接数据库
let usedKeys = {};

module.exports = async (req, res) => {
    // CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }

    const { searchParams } = new URL(req.url, `https://${req.headers.host}`);
    const action = req.url.split('?')[0].replace('/api/', '');

    if (action === 'check') {
        const key = searchParams.get('key') || '';
        
        if (usedKeys[key]) {
            return res.json({
                valid: false,
                used: true,
                device: usedKeys[key].device,
                message: "Key already used"
            });
        } else if (VALID_KEYS.includes(key)) {
            return res.json({
                valid: true,
                used: false,
                message: "Key is valid"
            });
        } else {
            return res.json({
                valid: false,
                used: false,
                message: "Invalid key"
            });
        }
    }

    if (action === 'use') {
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
    }

    if (action === 'list') {
        return res.json({
            used_keys: usedKeys,
            valid_keys: VALID_KEYS
        });
    }

    return res.json({
        message: "KaiHub Key Verification API",
        endpoints: [
            "/api/check?key=YOUR_KEY",
            "/api/use?key=YOUR_KEY&device=DEVICE_ID&player=PLAYER_NAME",
            "/api/list"
        ]
    });
};
