const multer = require('multer');
const path = require('path');
const fs = require('fs');

// ✅ Création automatique du dossier uploads si inexistant
const uploadDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir, { recursive: true });

// ✅ Configuration du stockage multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    const filename = `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`;
    cb(null, filename);
  },
});

// ✅ Autoriser seulement les images (avec logs détaillés)
const fileFilter = (req, file, cb) => {
  console.log('📄 Upload reçu:', {
    fieldname: file.fieldname,
    originalname: file.originalname,
    mimetype: file.mimetype,
    size: file.size,
  });

  // Liste étendue des types d'images acceptés
  const allowedMimetypes = [
    'image/jpeg',
    'image/jpg', 
    'image/png',
    'image/gif',
    'image/webp',
    'image/bmp',
    'image/svg+xml'
  ];

  if (file.mimetype && allowedMimetypes.includes(file.mimetype)) {
    console.log('✅ Fichier accepté:', file.originalname);
    cb(null, true);
  } else {
    console.error('❌ Type rejeté:', file.mimetype, '- Fichier:', file.originalname);
    cb(new Error(`Seules les images sont autorisées. Type reçu: ${file.mimetype}`), false);
  }
};

// ✅ Export du middleware
const upload = multer({ 
  storage, 
  fileFilter, 
  limits: { fileSize: 5 * 1024 * 1024 } // max 5 Mo
});

module.exports = upload;