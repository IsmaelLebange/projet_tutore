const jwt = require('jsonwebtoken');

const SECRET_JWT = process.env.JWT_SECRET;

const authentifier = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    
    console.log('🔍 === MIDDLEWARE AUTH ===');
    console.log('Headers reçus:', req.headers);
    console.log('Authorization header:', authHeader);
    
    if (!authHeader) {
        console.log('❌ Header Authorization manquant');
        return res.status(401).json({ message: 'Accès refusé. Token manquant.' });
    }

    if (!authHeader.startsWith('Bearer ')) {
        console.log('❌ Format Bearer manquant');
        return res.status(401).json({ message: 'Format de token invalide. Utilisez "Bearer <token>"' });
    }
    
    const token = authHeader.substring(7); // Enlève "Bearer "
    console.log('🔑 Token extrait:', token.substring(0, 20) + '...');
    
    try {
        const decoded = jwt.verify(token, SECRET_JWT);
        console.log('✅ Token valide, user ID:', decoded.idUtilisateur);
        req.idUtilisateur = decoded.idUtilisateur;
        next();
    } catch (error) {
        console.error('❌ Erreur vérification JWT:', error.message);
        return res.status(403).json({ message: 'Token invalide ou expiré.' });
    }
};

module.exports = authentifier;