const { json } = require('sequelize');
const accueilService=require('../services/accueilService');

class AccueilController{
    async obtenirDonneesAccueil(req,res){
        try {
            const options={
                limiteTendance:req.query.limiteTendance,
                limiteRecente:req.query.limiteRecente
            }

            const resultat=await accueilService.obtenirDonneesAccueil(options);
            res.json(resultat);
        }
        catch(error){
            res.status(500).json({
                message:'Erreur lors de la recuperation des données d\'accueil',
                error:error.message
            })
        }
    }

    async obteniCategorie(req,res){
        try{
            const resultat=await accueilService.obtenirCategories();
            res.json(resultat);
        }
        catch(error){
            res.status(500).json({
                message:"Erreur lors de la recuperation des categories(accueil)",
                error:error.message
            })
        }
    }
}

module.exports=new (AccueilController);