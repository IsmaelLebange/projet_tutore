const express = require('express');
const router = express.Router();

// Route de bienvenue simple
router.get('/', (req, res) => {
    res.json({ 
        message: 'Bonjour! Bienvenue sur l\'API BusyKin',
        status: 'ok',
        timestamp: new Date().toISOString()
    });
});

module.exports = router;
