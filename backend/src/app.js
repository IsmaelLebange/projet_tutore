const express = require('express');
const setupExpress = require('./config/express');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes'); // <-- NOUVEL IMPORT
const adminRoutes = require('./routes/adminRoutes');
const annonceRoutes = require('./routes/annonceRoutes');

const app = express();

setupExpress(app);

app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);
app.use('/api/admin', adminRoutes); 
app.use('/api/annonces', annonceRoutes);
app.use((req, res, next) => {
    res.status(404).json({ message: 'Route non trouvée. Vérifiez l\'URL.' });
});


module.exports = app;