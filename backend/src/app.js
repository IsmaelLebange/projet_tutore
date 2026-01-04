const express = require('express');
const path = require('path');
const setupExpress = require('./config/express');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes'); 
const adminRoutes = require('./routes/adminRoutes');
const annonceRoutes = require('./routes/annonceRoutes');
const categorieRoutes = require('./routes/categorieRoutes');
const produitRoutes = require('./routes/produitRoutes'); 
const serviceRoutes = require('./routes/serviceRoutes');
const panierRoutes = require('./routes/panierRoutes');
const comptePaiementRoutes = require('./routes/comptePaiementRoutes');
const notificationRoutes=require('./routes/notificationRoutes');
const transactionRoutes = require('./routes/transactionRoutes');
const accueiRoutes=require('./routes/accueilRoutes');
const rechercheRoutes=require('./routes/rechercheRoutes');


const app = express();

setupExpress(app);
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);
app.use('/api/admin', adminRoutes); 
app.use('/api/annonces', annonceRoutes);
app.use('/api/categories', categorieRoutes);
app.use('/api/produits', produitRoutes);
app.use('/api/services', serviceRoutes); 
app.use('/api/panier', panierRoutes); 
app.use('/api/notifications', notificationRoutes); 
app.use('/api/comptes-paiement', comptePaiementRoutes);
app.use('/api/transactions', transactionRoutes);
app.use('/api/accueil', accueiRoutes);
app.use('/api/recherche',rechercheRoutes);


app.use((req, res, next) => {
    res.status(404).json({ message: 'Route non trouvée. Vérifiez l\'URL.' });
});


module.exports = app;