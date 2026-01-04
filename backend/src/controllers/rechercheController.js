const rechercheService = require("../services/rechercheService");

class RechercheController {
    async rechercheProduits(req, res) {
        try {
            
            const recherche = await rechercheService.rechercherProduit(req.query.q);
            res.json(recherche);
        }
        catch (e) {
            console.log("erreur :", e);
            if (error.message === 'Produit introuvable') {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({
                message: 'Erreur lors de la récupération du produit',
                error: error.message
            });
        }
    }

    async rechercheServices(req,res){
        try{
            const recherche=await rechercheService.rechercherService(req.query.q);
            res.json(recherche);
        }
        catch(e){
            console.log("erreur :",e)
            if (error.message === 'Service introuvable') {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({
                message: 'Erreur lors de la récupération du produit',
                error: error.message
            });
        }
    }

    async rechercheAnnonces(req,res){
        try{
            const recherche=await rechercheService.rechercherAnnonce(req.query.q);
            res.json(recherche);
        }
        catch(e){
            console.log("erreur :",e)
            if (error.message === 'Service introuvable') {
                return res.status(404).json({ message: error.message });
            }
            res.status(500).json({
                message: 'Erreur lors de la récupération du produit',
                error: error.message
            });
        }
    }
}

module.exports=new RechercheController();