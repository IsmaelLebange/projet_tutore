// ...existing code...
const { sequelize } = require('../config/database');
const fs = require('fs');
const path = require('path');
const https = require('https');

// Models
const Utilisateur = require('../models/utilisateur');
const Adresse = require('../models/Adresse');
const Annonce = require('../models/Annonce');
const Produit = require('../models/Produit');
const Service = require('../models/Service');
const PhotoProduit = require('../models/PhotoProduit');
const PhotoService = require('../models/PhotoService');
const CategorieProduit = require('../models/CategorieProduit');
const CategorieService = require('../models/CategorieService');
const TypeProduit = require('../models/TypeProduit');
const TypeService = require('../models/TypeService');
const ComptePaiement = require('../models/ComptePaiement');
const Transaction = require('../models/Transaction');
const LigneCommande = require('../models/LigneCommande');
const Notation = require('../models/Notation');
const Message = require('../models/Message');

const COUNT = {
  utilisateurs: 150,
  annonces: 500,
  messages: 300,
  transactions: 100,
};

const communes = [
  'Gombe','Barumbu','Kasa-Vubu','Kalamu','Lingwala','Bandalungwa',
  'Ngiri-Ngiri','Selembao','Bumbu','Makala','Kintambo','Ngaliema','Mont Ngafula',
  'Lemba','Ngaba','Matete','Kisenso','Kimbanseke','Nsele','Maluku','Masina','Ndjili','Limete'
];

const quartiers = [
  'Résidentiel','Industriel','Commercial','Populaire','Cité Verte',
  'Cité Universitaire','Cité du Fleuve','Quartier Latin','Camp Luka'
];

const prenoms = ['Jean','Marie','Pierre','Sophie','Luc','Emma','Paul','Julie','Marc','Alice','David','Merveille','Grâce','Joseph'];
const noms = ['Kabila','Tshisekedi','Katumbi','Ngoma','Mukendi','Kasongo','Mbuyi','Nzuzi','Kabongo','Ilunga','Muamba'];
const produitsLib = ['iPhone','Samsung Galaxy','MacBook','HP Laptop','Table en bois','Chaise bureau','Frigo LG','Écran Dell','Clavier Logitech','Vélo route'];
const servicesLib = ['Plomberie','Électricité','Ménage','Cours de maths','Peinture','Jardinage','Garde d’enfants','Dépannage PC'];

const imagesAPIs = {
  loremflickr: (w, h, keywords) => `https://loremflickr.com/${w}/${h}/${encodeURIComponent(keywords)}`,
  picsum: (w, h, id) => `https://picsum.photos/${w}/${h}?random=${id}`
};

const categoriesImages = {
  'Téléphone': 'iphone,smartphone',
  'Ordinateur': 'laptop,computer',
  'Écran': 'monitor,screen',
  'Clavier': 'keyboard',
  'Table': 'table,furniture,wood',
  'Chaise': 'chair,office',
  'Canapé': 'sofa,couch',
  'Armoire': 'wardrobe,closet',
  'Frigo': 'refrigerator,fridge',
  'Micro-ondes': 'microwave',
  'Vélo': 'bicycle,bike',
};

const rand = (arr) => arr[Math.floor(Math.random() * arr.length)];
const rint = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;

// ...existing code...
function telechargerImage(url, destination) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(destination);

    const requester = (u, baseOrigin) => {
      let parsed;
      try {
        parsed = new URL(u);
      } catch (err) {
        // u est peut‑être relatif => résout avec baseOrigin ou fallback
        const base = baseOrigin || 'https://loremflickr.com';
        return requester(new URL(u, base).href, base);
      }

      const client = parsed.protocol === 'https:' ? require('https') : require('http');
      const req = client.get(parsed.href, (res) => {
        if (res.statusCode === 301 || res.statusCode === 302) {
          const loc = res.headers.location;
          if (!loc) return reject(new Error('Redirect sans location'));
          const next = loc.startsWith('http') ? loc : new URL(loc, parsed.origin).href;
          return requester(next, parsed.origin);
        }

        if (res.statusCode >= 400) {
          return reject(new Error(`HTTP ${res.statusCode} pour ${parsed.href}`));
        }

        res.pipe(file);
        file.on('finish', () => {
          file.close();
          resolve(destination);
        });
      });

      req.on('error', (err) => {
        try { fs.unlinkSync(destination); } catch {}
        reject(err);
      });
    };

    requester(url);
  });
}
// ...existing code...

async function preparerDossiers() {
  const uploadDir = path.join(__dirname, '../../uploads');
  if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
  }
  return uploadDir;
}

async function ensureTaxonomies(t) {
  const cpCount = await CategorieProduit.count({ transaction: t });
  if (cpCount === 0) {
    const cps = await CategorieProduit.bulkCreate([
      { nom_categorie: 'Électronique' },
      { nom_categorie: 'Meubles' },
      { nom_categorie: 'Électroménager' },
      { nom_categorie: 'Sport' },
    ], { transaction: t, returning: true });

    await TypeProduit.bulkCreate([
      { nom_type: 'Téléphone', id_categorie: cps[0].id },
      { nom_type: 'Ordinateur', id_categorie: cps[0].id },
      { nom_type: 'Écran', id_categorie: cps[0].id },
      { nom_type: 'Clavier', id_categorie: cps[0].id },
      { nom_type: 'Table', id_categorie: cps[1].id },
      { nom_type: 'Chaise', id_categorie: cps[1].id },
      { nom_type: 'Canapé', id_categorie: cps[1].id },
      { nom_type: 'Armoire', id_categorie: cps[1].id },
      { nom_type: 'Frigo', id_categorie: cps[2].id },
      { nom_type: 'Micro-ondes', id_categorie: cps[2].id },
      { nom_type: 'Vélo', id_categorie: cps[3].id },
    ], { transaction: t });
  }

  const csCount = await CategorieService.count({ transaction: t });
  if (csCount === 0) {
    const css = await CategorieService.bulkCreate([
      { nom_categorie: 'Plomberie' },
      { nom_categorie: 'Électricité' },
      { nom_categorie: 'Nettoyage' },
      { nom_categorie: 'Informatique' },
    ], { transaction: t, returning: true });

    await TypeService.bulkCreate([
      { nom_type: 'Réparation fuite', id_categorie: css[0].id },
      { nom_type: 'Installation électrique', id_categorie: css[1].id },
      { nom_type: 'Ménage complet', id_categorie: css[2].id },
      { nom_type: 'Dépannage PC', id_categorie: css[3].id },
    ], { transaction: t });
  }
}

function safeGet(fn, fallback) {
  try {
    const v = fn();
    if (v === undefined || v === null) return fallback();
    return v;
  } catch {
    return fallback();
  }
}

async function main() {
  // Import dynamique de faker (ESM) — si présent on l'utilise, sinon on fallback aux listes simples
  let faker = null;
  try {
    const mod = await import('@faker-js/faker');
    faker = mod?.faker || mod?.default || null;
    if (faker && faker.locale) {
      try { faker.locale = 'fr'; } catch {}
    }
  } catch {
    faker = null;
  }

  // helpers utilisant faker si dispo
  const genFirst = () => safeGet(() => faker.person.firstName(), () => rand(prenoms));
  const genLast = () => safeGet(() => faker.person.lastName(), () => rand(noms));
  const genEmail = (first, last, i) => safeGet(() => faker.internet.email(first, last).toLowerCase(),
    () => `${first.toLowerCase()}.${last.toLowerCase()}.${i}@busykin.com`);
  const genPhone = () => safeGet(() => faker.phone.number('+243 9## ### ###'), () => `+243 9${rint(10,99)} ${rint(100,999)} ${rint(100,999)}`);
  const genStreet = (last) => safeGet(() => faker.address.streetAddress(), () => `${rint(1,999)} Avenue ${last}`);
  const genCity = () => safeGet(() => faker.address.city(), () => rand(communes));
  const genQuartier = () => safeGet(() => faker.address.cityName(), () => rand(quartiers));
  const genProductName = () => safeGet(() => faker.commerce.productName(), () => rand(produitsLib));
  const genDescription = () => safeGet(() => faker.commerce.productDescription(), () => rand(['En très bon état','Neuf','Occasion','Prix négociable','Livraison possible']));
  const genPrice = () => safeGet(() => parseFloat(faker.commerce.price(50, 8000, 0)), () => rint(50, 8000));

  await sequelize.authenticate();
  console.log('✅ DB connectée\n');

  const uploadDir = await preparerDossiers();
  let imageCounter = 0;

  await sequelize.transaction(async (t) => {
    console.log('🚀 SEED START avec Faker (si dispo) + images publiques\n');

    await ensureTaxonomies(t);
    console.log('📚 Catégories/types OK\n');

    // Admin existant
    const admin = await Utilisateur.findByPk(1, { transaction: t });
    if (!admin) {
      throw new Error('❌ Admin (id=1) introuvable ! Lance "node server.js" d\'abord.');
    }
    console.log(`👑 Admin: ${admin.email}\n`);

    // Adresses
    console.log('📍 Adresses...');
    const adresses = [];
    if (admin.id_adresse_fixe) {
      const adrAdmin = await Adresse.findByPk(admin.id_adresse_fixe, { transaction: t });
      if (adrAdmin) adresses.push(adrAdmin);
    }

    for (let i = 0; i < 60; i++) {
      const last = genLast();
      const adr = await Adresse.create({
        rue: genStreet(last),
        ville: genCity(),
        quartier: genQuartier(),
        latitude: -4 + Math.random() * 2,
        longitude: 15 + Math.random() * 10,
      }, { transaction: t });
      adresses.push(adr);
    }
    console.log(`   ✅ ${adresses.length} adresses\n`);

    // Utilisateurs
    console.log('👥 Utilisateurs...');
    const users = [admin];
    for (let i = 0; i < COUNT.utilisateurs; i++) {
      const first = genFirst();
      const last = genLast();
      const u = await Utilisateur.create({
        prenom: first,
        nom: last,
        email: genEmail(first, last, i),
        mot_de_passe: '$2b$10$dummyHash',
        telephone: genPhone(),
        date_inscription: new Date(Date.now() - rint(0, 365)*86400000),
        reputation: rint(0, 100),
        type_connexion: 'classique',
        etat: rand(['Actif','Actif','Actif','Bloqué']),
        role: 'utilisateur',
        id_adresse_fixe: rand(adresses).id,
      }, { transaction: t });
      users.push(u);
    }
    console.log(`   ✅ ${users.length} utilisateurs\n`);

    // Comptes paiement
    console.log('🏦 Comptes paiement...');
    const comptes = [];
    const compteAdmin = await ComptePaiement.create({
      id_utilisateur: admin.id,
      numero_compte: '243-9999999',
      entreprise: 'M-Pesa',
      est_principal: true,
    }, { transaction: t });
    comptes.push(compteAdmin);

    for (let i = 0; i < Math.floor(users.length * 0.6); i++) {
      const u = users[i + 1];
      const c = await ComptePaiement.create({
        id_utilisateur: u.id,
        numero_compte: safeGet(() => faker.finance.account(10), () => `ACC${rint(1000000,9999999)}`),
        entreprise: rand(['M-Pesa','Airtel Money','Orange Money','Rawbank']),
        est_principal: true,
      }, { transaction: t });
      comptes.push(c);
    }
    console.log(`   ✅ ${comptes.length} comptes\n`);

    // Types
    const typesP = await TypeProduit.findAll({ transaction: t });
    const typesS = await TypeService.findAll({ transaction: t });

    // Annonces + images (LoremFlickr)
    console.log('📢 Annonces + images LoremFlickr...');
    const produitsCrees = [];
    const servicesCrees = [];

    for (let i = 0; i < COUNT.annonces; i++) {
      const vendeur = rand(users);
      const adr = rand(adresses);
      const isProduit = Math.random() < 0.7;

      const annonce = await Annonce.create({
        titre: genProductName(),
        description: genDescription(),
        prix: genPrice(),
        date_publication: new Date(Date.now() - rint(0, 90)*86400000),
        statut_annonce: rand(['Active','Active','Active','En attente']),
        id_utilisateur: vendeur.id,
        id_adresse: adr.id,
      }, { transaction: t });

      if (isProduit && typesP.length > 0) {
        const tp = rand(typesP);
        const produit = await Produit.create({
          id_annonce: annonce.id,
          id_type: tp.id,
          etat: rand(['Neuf','Occasion','Reconditionné']),
        }, { transaction: t });
        produitsCrees.push(produit);

        const motsCles = categoriesImages[tp.nom_type] || 'product';
        const nbPhotos = rint(1, 2);
        for (let j = 0; j < nbPhotos; j++) {
          imageCounter++;
          const fileName = `produit_${imageCounter}.jpg`;
          const filePath = path.join(uploadDir, fileName);
          try {
            const imgUrl = imagesAPIs.loremflickr(640, 480, motsCles);
            await telechargerImage(imgUrl, filePath);
            await PhotoProduit.create({
              id_produit: produit.id,
              url: `/uploads/${fileName}`,
            }, { transaction: t });
          } catch (err) {
            // skip image if fail
          }
          await new Promise(r => setTimeout(r, 150));
        }
      } else if (typesS.length > 0) {
        const ts = rand(typesS);
        const service = await Service.create({
          id_annonce: annonce.id,
          id_type: ts.id,
          type_service: ts.nom_type,
          disponibilite: rand(['Disponible','Occupé']),
        }, { transaction: t });
        servicesCrees.push(service);

        imageCounter++;
        const fileName = `service_${imageCounter}.jpg`;
        const filePath = path.join(uploadDir, fileName);
        try {
          const imgUrl = imagesAPIs.loremflickr(640, 480, 'worker,tools,repair');
          await telechargerImage(imgUrl, filePath);
          await PhotoService.create({
            id_service: service.id,
            url: `/uploads/${fileName}`,
          }, { transaction: t });
        } catch (err) {}
        await new Promise(r => setTimeout(r, 150));
      }

      if ((i + 1) % 50 === 0) console.log(`   ⏳ ${i + 1}/${COUNT.annonces}...`);
    }
    console.log(`   ✅ ${COUNT.annonces} annonces\n`);

    // Messages
    console.log('✉️  Messages...');
    for (let i = 0; i < COUNT.messages; i++) {
      const exp = rand(users);
      let rec = rand(users);
      while (rec.id === exp.id) rec = rand(users);
      await Message.create({
        contenu: safeGet(() => faker.lorem.sentence(), () => 'Bonjour, disponible ?'),
        date_envoi: new Date(Date.now() - rint(0, 30)*86400000),
        id_expediteur: exp.id,
        id_recepteur: rec.id,
      }, { transaction: t });
    }
    console.log(`   ✅ ${COUNT.messages} messages\n`);

    // Transactions + Lignes + Notations
    console.log('💳 Transactions...');
    for (let i = 0; i < COUNT.transactions; i++) {
      const vendeur = rand(users);
      let acheteur = rand(users);
      while (acheteur.id === vendeur.id) acheteur = rand(users);

      const compte = await ComptePaiement.findOne({
        where: { id_utilisateur: vendeur.id },
        transaction: t,
      });
      if (!compte) continue;

      const montant = safeGet(() => faker.datatype.number({ min: 100, max: 5000 }), () => rint(100,5000));
      const trans = await Transaction.create({
        date_transaction: new Date(Date.now() - rint(0, 60)*86400000),
        montant,
        statut_transaction: rand(['Payée','En cours']),
        commission: Math.floor(montant * 0.05),
        id_acheteur: acheteur.id,
        id_vendeur: vendeur.id,
        id_compte_paiement_vendeur: compte.id,
      }, { transaction: t });

      if (Math.random() < 0.6 && produitsCrees.length > 0) {
        const p = rand(produitsCrees);
        await LigneCommande.create({
          quantite: safeGet(() => faker.datatype.number({ min: 1, max: 3 }), () => rint(1,3)),
          etat: rand(['Confirmée','Livrée']),
          id_transaction: trans.id,
          id_produit: p.id,
          id_service: null,
        }, { transaction: t });
      } else if (servicesCrees.length > 0) {
        const s = rand(servicesCrees);
        await LigneCommande.create({
          quantite: 1,
          etat: rand(['Planifiée','Réalisée']),
          id_transaction: trans.id,
          id_produit: null,
          id_service: s.id,
        }, { transaction: t });
      }

      if (Math.random() < 0.8) {
        await Notation.create({
          note: safeGet(() => faker.datatype.number({ min: 3, max: 5 }), () => rint(3,5)),
          commentaire: safeGet(() => faker.lorem.sentence(), () => rand(['Très bien','Parfait','Recommandé'])),
          date_notation: new Date(),
          id_noteur: acheteur.id,
          id_note_a_qui: vendeur.id,
          id_transaction: trans.id,
        }, { transaction: t });
      }
    }
    console.log(`   ✅ ${COUNT.transactions} transactions\n`);

    console.log('✅ COMMIT\n');
  });

  console.log(`🎉 TERMINÉ ! images (si téléchargées) dans: backend/uploads/`);
  process.exit(0);
}

main().catch(e => {
  console.error('❌ Erreur:', e);
  process.exit(1);
});
// ...existing code...