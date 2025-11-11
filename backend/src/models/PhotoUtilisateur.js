const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const Utilisateur = require('./utilisateur');

const PhotoUtilisateur = sequelize.define('PhotoUtilisateur', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  id_utilisateur: { type: DataTypes.INTEGER, allowNull: false },
  url: { type: DataTypes.STRING, allowNull: false },
  est_principale: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: false },
}, {
  tableName: 'PhotoUtilisateurs',
  timestamps: false,
});



Utilisateur.hasMany(PhotoUtilisateur, { foreignKey: 'id_utilisateur', as: 'photos' });
PhotoUtilisateur.belongsTo(Utilisateur, { foreignKey: 'id_utilisateur', as: 'utilisateur' });
// ...existing code...
module.exports = PhotoUtilisateur;