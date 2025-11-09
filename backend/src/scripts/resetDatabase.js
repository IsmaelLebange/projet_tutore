const { sequelize } = require('../config/database');

async function resetDatabase() {
  try {
    console.log('⚠️  ATTENTION : Suppression TOTALE de la base de données...');
    console.log('⏳ Attente 3 secondes...');
    
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    console.log('🗑️  Suppression des tables...');
    await sequelize.drop({ cascade: true });
    
    console.log('🔨 Recréation des tables...');
    await sequelize.sync({ force: true });
    
    console.log('✅ Base de données réinitialisée avec succès !');
    console.log('ℹ️  Relance "node server.js" pour recréer l\'admin (id=1)');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Erreur reset:', error);
    process.exit(1);
  }
}

resetDatabase();