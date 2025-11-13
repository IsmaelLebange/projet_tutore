const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const Utilisateur = require('./utilisateur');
const Transaction = require('./Transaction');

const Notification = sequelize.define('Notification', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    allowNull: false,
  },
  titre: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  message: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  type_notification: {
    type: DataTypes.ENUM('commande_recue', 'commande_confirmee', 'paiement_requis', 'transaction_validee'),
    allowNull: false,
  },
  est_lu: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    allowNull: false,
  },
  id_utilisateur: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: Utilisateur, key: 'id' }
  },
  id_transaction: {
    type: DataTypes.INTEGER,
    allowNull: true, // Nullable car pas toutes les notifs sont liées à une transaction
    references: { model: Transaction, key: 'id' }
  },
}, {
  timestamps: true,
});

// Relations
Notification.belongsTo(Utilisateur, { foreignKey: 'id_utilisateur', as: 'utilisateur' });
Utilisateur.hasMany(Notification, { foreignKey: 'id_utilisateur', as: 'notifications' });

Notification.belongsTo(Transaction, { foreignKey: 'id_transaction', as: 'transaction' });
Transaction.hasMany(Notification, { foreignKey: 'id_transaction', as: 'notifications' });

module.exports = Notification;