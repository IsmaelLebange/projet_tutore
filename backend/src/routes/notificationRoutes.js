const { Router } = require('express');
const router = Router();
const authMiddleware = require('../middlewares/authMiddleware');
const notificationController = require('../controllers/notificationController');

router.use(authMiddleware);

router.get('/', notificationController.obtenirNotifications);
router.post('/transaction/:transactionId/confirmer', notificationController.confirmerTransaction);
router.put('/:notificationId/lu', notificationController.marquerLu);

module.exports = router;