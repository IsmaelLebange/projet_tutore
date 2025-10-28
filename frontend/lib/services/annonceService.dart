import '../models/Annonce.dart';

class AnnonceService {
  void ajouterAnnonce(Annonce annonce) {
    print("Annonce envoyée au backend : ${annonce.toJson()}");
  }
}
