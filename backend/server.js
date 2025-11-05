// server.js
const app = require('./src/app');
const { connectDB } = require('./src/config/database');
const initialiserAdmin = require('./src/scripts/initialSetup');
const initialCategories=require('./src/scripts/initialCategories');
const path = require('path');


const PORT = process.env.PORT || 8080;

connectDB()
    .then(async () => {
        // ✅ UTILISE LE FICHIER TAMPON
        await initialiserAdmin();
        await initialCategories();
        
        app.listen(PORT, () => {
            console.log(`🚀 Serveur sur port ${PORT}`);
        });
    })
    .catch((error) => {
        console.error('❌ ERREUR FATALE:', error);
        process.exit(1);
    });