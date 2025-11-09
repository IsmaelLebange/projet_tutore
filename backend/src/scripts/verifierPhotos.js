const fs = require('fs');
const path = require('path');
const { sequelize } = require('../config/database');
const PhotoProduit = require('../models/PhotoProduit');
const PhotoService = require('../models/PhotoService');

(async () => {
  await sequelize.authenticate();
  const baseDir = path.join(__dirname, '../../uploads');
  const manquants = [];

  async function check(Model, label) {
    const rows = await Model.findAll({ raw: true });
    for (const r of rows) {
      let rel = r.url || '';
      if (rel.startsWith('/')) rel = rel.slice(1);
      const full = path.join(baseDir, path.basename(rel));
      if (!fs.existsSync(full)) {
        manquants.push({ type: label, id: r.id, url: r.url });
      }
    }
  }

  await check(PhotoProduit, 'produit');
  await check(PhotoService, 'service');

  console.log('--- Résumé ---');
  console.log('Fichiers présents dans uploads:', fs.readdirSync(baseDir).length);
  console.log('Références manquantes:', manquants.length);
  if (manquants.length) {
    console.table(manquants.slice(0, 20));
    console.log('> Total manquants:', manquants.length);
  } else {
    console.log('OK aucune incohérence');
  }
  process.exit(0);
})();