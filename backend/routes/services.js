const express = require('express');
const router = express.Router();
const serviceController = require('../controllers/serviceController');

router.get('/', serviceController.getTousServices);
router.get('/:id', serviceController.getServiceParId);
router.post('/', serviceController.creerService);
router.put('/:id', serviceController.modifierService);
router.delete('/:id', serviceController.supprimerService);

module.exports = router;