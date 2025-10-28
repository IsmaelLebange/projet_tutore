const jwt = require('jsonwebtoken');

const SECRET_JWT = process.env.JWT_SECRET;

const authentifier = (req, res, next) => {
    const enteteAuth = req.headers['authorization'];
    
    if (!enteteAuth || !enteteAuth.startsWith('Bearer ')) {
        return res.status(401).json({ message: 'Accès refusé. Token manquant ou mal formaté.' });
    }

    const token = enteteAuth.split(' ')[1];

    try {
        const donneesDecodees = jwt.verify(token, SECRET_JWT);
        // L'ID utilisateur est stocké dans req.idUtilisateur pour le contrôleur
        req.idUtilisateur = donneesDecodees.idUtilisateur;
        next();
    } catch (erreur) {
        res.status(403).json({ message: 'Token invalide ou expiré.' });
    }
};

module.exports = authentifier;