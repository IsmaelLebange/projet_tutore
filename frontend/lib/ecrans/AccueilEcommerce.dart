import 'package:flutter/material.dart';
import '../utils/constantes.dart';
import '../composants/ComposantsUI.dart';

class AccueilEcommerce extends StatefulWidget {
  @override
  _AccueilEcommerceState createState() => _AccueilEcommerceState();
}

class _AccueilEcommerceState extends State<AccueilEcommerce> with SingleTickerProviderStateMixin {
  int _currentBannerIndex = 0;
  int? _hoveredNavIndex;
  int? _hoveredGridIndex;
  int? _pressedGridIndex;

  late final AnimationController _salePulseController;
  late final Animation<double> _salePulse;

  @override
  void initState() {
    super.initState();
    _salePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _salePulse = CurvedAnimation(parent: _salePulseController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _salePulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: couleurFond,
      body: CustomScrollView(
        slivers: [
          // AppBar moderne avec recherche
          _buildModernAppBar(),
          
          // Hero Banner avec carousel
          _buildHeroBanner(),
          
          // Catégories horizontales
          _buildCategoriesSection(),
          
          // Offres spéciales
          _buildSpecialOffersSection(),
          
          // Produits populaires
          _buildPopularProductsSection(),
          
          // Nouvelles collections
          _buildNewCollectionsSection(),
          
          // Section marques
          _buildBrandsSection(),
        ],
      ),
      // Panier flottant
      floatingActionButton: _buildFloatingCart(),
    );
  }

  // AppBar moderne
  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 170,
      floating: true,
      pinned: true,
      toolbarHeight: 0,
      backgroundColor: Colors.white,
      elevation: 2,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 40, left: espacementM, right: espacementM, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: espacementM, vertical: espacementS),
                      decoration: BoxDecoration(
                        gradient: gradientPrincipal,
                        borderRadius: BorderRadius.circular(rayonBordureS),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.shopping_bag, color: Colors.white, size: 24),
                          SizedBox(width: espacementS),
                          Text(
                            'BusyKin',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: couleurFond,
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(color: const Color(0xFF000080), width: 2),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: espacementM),
                          const Icon(Icons.search, color: Color(0xFF000080), size: 22),
                          const SizedBox(width: espacementS),
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Rechercher un produit, une marque...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: couleurTexteSecondaire,
                                  fontSize: 14,
                                ),
                              ),
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(3),
                            padding: const EdgeInsets.symmetric(horizontal: espacementL, vertical: espacementS),
                            decoration: BoxDecoration(
                              color: const Color(0xFF000080),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Text(
                              'Rechercher',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: espacementL),
                  _buildHeaderButton(
                    icon: Icons.person_outline,
                    label: 'Se connecter',
                    onTap: () => Navigator.of(context).pushNamed('/connexion'),
                  ),
                  const SizedBox(width: espacementM),
                  _buildHeaderButton(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Magasin',
                    onTap: () => Navigator.of(context).pushNamed('/panier'),
                  ),
                ],
              ),
              const SizedBox(height: espacementS),
              const BarreNavigationPrincipale(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    String? badge,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: espacementM, vertical: espacementS),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(rayonBordureS),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A90E2).withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  if (badge != null)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: espacementS),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryMenu() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: espacementM),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 45),
        color: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rayonBordureS)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: espacementM, vertical: espacementS),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(rayonBordureS),
          ),
          child: Row(
            children: const [
              Icon(Icons.menu, color: Color(0xFF000080), size: 20),
              SizedBox(width: espacementS),
              Text(
                'TOUTES LES CATÉGORIES',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Color(0xFF000080),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: espacementXS),
              Icon(Icons.arrow_drop_down, color: Color(0xFF000080), size: 20),
            ],
          ),
        ),
        itemBuilder: (context) => [
          _buildMenuItem(Icons.devices, 'Électronique', '/catalogueProduits'),
          _buildMenuItem(Icons.checkroom, 'Mode & Vêtements', '/catalogueProduits'),
          _buildMenuItem(Icons.home, 'Maison & Jardin', '/catalogueProduits'),
          _buildMenuItem(Icons.sports_soccer, 'Sports & Loisirs', '/catalogueProduits'),
          _buildMenuItem(Icons.toys, 'Jouets & Enfants', '/catalogueProduits'),
          _buildMenuItem(Icons.face, 'Beauté & Santé', '/catalogueProduits'),
          _buildMenuItem(Icons.directions_car, 'Auto & Moto', '/catalogueProduits'),
          _buildMenuItem(Icons.book, 'Livres & Médias', '/catalogueProduits'),
          _buildMenuItem(Icons.build, 'Services', '/catalogueServices'),
        ],
        onSelected: (route) {
          Navigator.of(context).pushNamed(route);
        },
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(IconData icon, String label, String route) {
    return PopupMenuItem<String>(
      value: route,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: espacementXS),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF000080), size: 18),
            const SizedBox(width: espacementM),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: couleurTexte,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {required VoidCallback onTap}) {
    final bool hovered = _hoveredNavIndex == index;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredNavIndex = index),
      onExit: (_) => setState(() => _hoveredNavIndex = null),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: dureeAnimationMoyenne,
          padding: const EdgeInsets.symmetric(horizontal: espacementM, vertical: espacementS),
          decoration: BoxDecoration(
            color: hovered ? Colors.white.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(rayonBordureS),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: espacementXS),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontWeight: hovered ? FontWeight.bold : FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hero Banner avec carousel
  Widget _buildHeroBanner() {
    return SliverToBoxAdapter(
      child: Container(
        height: 300,
        margin: const EdgeInsets.all(espacementM),
        child: PageView.builder(
          itemCount: 3,
          onPageChanged: (index) {
            setState(() => _currentBannerIndex = index);
          },
          itemBuilder: (context, index) {
            return _buildBannerItem(index);
          },
        ),
      ),
    );
  }

  Widget _buildBannerItem(int index) {
    final banners = [
      {
        'title': "Méga Soldes d'été",
        'subtitle': "Jusqu'à 70% de réduction",
        'gradient': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF5722), Color(0xFFFF3D68)],
        ),
        'image': '🛒',
      },
      {
        'title': 'Nouvelle Collection',
        'subtitle': 'Découvrez les tendances',
        'gradient': gradientAccent,
        'image': '🛍️',
      },
      {
        'title': 'Livraison Gratuite',
        'subtitle': 'Sur toutes vos commandes',
        'gradient': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
        ),
        'image': '🚚',
      },
    ];
    final banner = banners[index];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: espacementS),
      decoration: BoxDecoration(
        gradient: banner['gradient'] as LinearGradient,
        borderRadius: BorderRadius.circular(rayonBordureL),
        boxShadow: ombreMoyenne,
      ),
      child: Stack(
        children: [
          // Motif décoratif
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Contenu
          Padding(
            padding: const EdgeInsets.all(espacementL),
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (index == 0)
                    AnimatedScale(
                      scale: 1 + (_salePulse.value * 0.05),
                      duration: dureeAnimationCourte,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white70, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.local_fire_department, color: Colors.yellowAccent, size: 16),
                            SizedBox(width: 6),
                            ShimmerText(
                              text: "Méga soldes d'été",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (index == 0) const SizedBox(height: espacementS),
                  Text(
                    banner['image'] as String,
                    style: const TextStyle(fontSize: 54),
                  ),
                  const SizedBox(height: espacementM),
                  Text(
                    banner['title'] as String,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: espacementS),
                  Text(
                    banner['subtitle'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _AnimatedGradientButton(
                    onPressed: () {},
                    label: 'Acheter maintenant',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section catégories
  Widget _buildCategoriesSection() {
    final categories = [
      {'name': 'Électronique', 'icon': Icons.devices, 'color': Color(0xFF4A90E2)},
      {'name': 'Mode', 'icon': Icons.checkroom, 'color': Color(0xFFE91E63)},
      {'name': 'Maison', 'icon': Icons.home, 'color': Color(0xFF4CAF50)},
      {'name': 'Sports', 'icon': Icons.sports_soccer, 'color': Color(0xFFFF9800)},
      {'name': 'Beauté', 'icon': Icons.face, 'color': Color(0xFF9C27B0)},
      {'name': 'Véhicules', 'icon': Icons.directions_car, 'color': Color(0xFF607D8B)},
    ];

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(espacementM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Catégories',
                  style: TextStyle(
                    fontSize: tailleTexteSousTitre,
                    fontWeight: FontWeight.bold,
                    color: couleurTexte,
                  ),
                ),

              ],
            ),
          ),
          Center(
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: espacementM),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(
                  category['name'] as String,
                  category['icon'] as IconData,
                  category['color'] as Color,
                );
              },
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String name, IconData icon, Color color) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: espacementM),
      child: CarteModerne(
        onTap: () {},
        padding: const EdgeInsets.all(espacementS),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(espacementM),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(rayonBordure),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: espacementS),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: tailleTexteSmall,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Section offres spéciales
  Widget _buildSpecialOffersSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(espacementM),
        padding: const EdgeInsets.all(espacementL),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(rayonBordureL),
          boxShadow: ombreMoyenne,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚡ Flash Sale',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: espacementS),
                  const Text(
                    'Offre limitée dans le temps',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: espacementM),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: espacementM,
                      vertical: espacementS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(rayonBordureS),
                    ),
                    child: const Text(
                      '02:45:30',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Text('🎯', style: TextStyle(fontSize: 80)),
          ],
        ),
      ),
    );
  }

  // Section produits populaires
  Widget _buildPopularProductsSection() {
    final List<Map<String, dynamic>> products = [
      // Téléphones
      {"name": "iPhone 15 Pro Max", "price": 1199, "icon": "📱"},
      {"name": "Samsung Galaxy S24 Ultra", "price": 1299, "icon": "📱"},
      {"name": "Google Pixel 9 Pro", "price": 999, "icon": "📱"},
      {"name": "Xiaomi 14T Pro", "price": 799, "icon": "📱"},
      {"name": "OnePlus 12", "price": 699, "icon": "📱"},
      // Ordinateurs portables
      {"name": "MacBook Pro M3", "price": 1999, "icon": "💻"},
      {"name": "Dell XPS 15", "price": 1599, "icon": "💻"},
      {"name": "HP Spectre x360", "price": 1399, "icon": "💻"},
      {"name": "Asus ROG Zephyrus", "price": 1799, "icon": "💻"},
      {"name": "Lenovo ThinkPad X1", "price": 1699, "icon": "💻"},
      // Casques audio
      {"name": "Sony WH-1000XM5", "price": 349, "icon": "🎧"},
      {"name": "Bose QC Ultra", "price": 299, "icon": "🎧"},
      {"name": "Apple AirPods Max", "price": 549, "icon": "🎧"},
      {"name": "JBL Live Pro 2", "price": 149, "icon": "🎧"},
      {"name": "Sennheiser Momentum 4", "price": 349, "icon": "🎧"},
      // Drones
      {"name": "DJI Mavic 3 Pro", "price": 2199, "icon": "🚁"},
      {"name": "Parrot Anafi", "price": 699, "icon": "🚁"},
      {"name": "Autel EVO Lite+", "price": 1199, "icon": "🚁"},
      {"name": "Ryze Tello", "price": 99, "icon": "🚁"},
      {"name": "DJI Mini 4K", "price": 299, "icon": "🚁"},
      // Divers
      {"name": "Apple Watch Ultra 2", "price": 799, "icon": "⌚"},
      {"name": "Samsung Galaxy Watch 6", "price": 299, "icon": "⌚"},
      {"name": "GoPro Hero 12", "price": 399, "icon": "📷"},
      {"name": "Canon EOS R8", "price": 1499, "icon": "📸"},
      {"name": "Nintendo Switch OLED", "price": 349, "icon": "🎮"},
      {"name": "PlayStation 5", "price": 499, "icon": "🎮"},
      {"name": "Xbox Series X", "price": 499, "icon": "🎮"},
      {"name": "Kindle Paperwhite", "price": 139, "icon": "📚"},
      {"name": "Samsung Galaxy Tab S9", "price": 799, "icon": "📲"},
      {"name": "iPad Pro 13", "price": 1299, "icon": "📲"},
    ];
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(espacementM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Produits populaires',
                  style: TextStyle(
                    fontSize: tailleTexteSousTitre,
                    fontWeight: FontWeight.bold,
                    color: couleurTexte,
                  ),
                ),

              ],
            ),
          ),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: espacementM),
              itemCount: products.length,
              itemBuilder: (context, index) => _buildAnimatedProductCard(products[index], index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedProductCard(Map<String, dynamic> product, int index) {
    // Animation AOS: Zoom pour pair, Flip pour impair
    final animationType = index % 2 == 0 ? 'zoom' : 'flip';
    return TweenAnimationBuilder<double>(
      key: ValueKey('product_$index'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index % 8) * 100),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        // Contraindre la valeur entre 0.0 et 1.0
        final clampedValue = value.clamp(0.0, 1.0);
        Widget animatedChild = child!;
        if (animationType == 'zoom') {
          // Animation de zoom avec opacité
          animatedChild = Opacity(
            opacity: clampedValue,
            child: Transform.scale(
              scale: 0.3 + (clampedValue * 0.7),
              child: child,
            ),
          );
        } else {
          // Animation de flip (rotation Y) avec opacité
          animatedChild = Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateY((1 - clampedValue) * 3.14 / 2),
            child: Opacity(
              opacity: clampedValue,
              child: child,
            ),
          );
        }
        return animatedChild;
      },
      child: _buildProductCardData(product, index),
    );
  }

  Widget _buildProductCardData(Map<String, dynamic> product, int index) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: espacementM),
      child: CarteModerne(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/detailProduit',
            arguments: product,
          );
        },
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image produit
            Stack(
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        couleurPrincipale.withOpacity(0.3),
                        couleurSecondaire.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(rayonBordure),
                      topRight: Radius.circular(rayonBordure),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      product['icon'] ?? '📦',
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                ),
                Positioned(
                  top: espacementS,
                  right: espacementS,
                  child: Container(
                    padding: const EdgeInsets.all(espacementXS),
                    decoration: BoxDecoration(
                      color: couleurAccent,
                      borderRadius: BorderRadius.circular(rayonBordureS),
                    ),
                    child: const Text(
                      '-30%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: tailleTexteSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: espacementS,
                  left: espacementS,
                  child: Container(
                    padding: const EdgeInsets.all(espacementXS),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      size: 20,
                      color: couleurAccent,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(espacementS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: tailleTexteCaption,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: espacementXS),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                      const SizedBox(width: espacementXS),
                      Text(
                        (4.5 + (index % 5) * 0.1).toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: tailleTexteSmall,
                          color: couleurTexteSecondaire,
                        ),
                      ),
                      const SizedBox(width: espacementXS),
                      Text(
                        '(${120 + index * 3})',
                        style: const TextStyle(
                          fontSize: tailleTexteSmall,
                          color: couleurTexteSecondaire,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: espacementS),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${product['price']} \$',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: couleurPrincipale,
                            ),
                          ),
                          Text(
                            '${(product['price'] * 1.43).round()} \$',
                            style: const TextStyle(
                              fontSize: tailleTexteSmall,
                              decoration: TextDecoration.lineThrough,
                              color: couleurTexteSecondaire,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(espacementXS),
                        decoration: BoxDecoration(
                          gradient: gradientPrincipal,
                          borderRadius: BorderRadius.circular(rayonBordureS),
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  // Section nouvelles collections
  Widget _buildNewCollectionsSection() {
    // Section vide pour l’instant, en attente de nouveaux produits
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  Widget _buildGridProductCard(int index) {
    final bool hovered = _hoveredGridIndex == index;
    final bool pressed = _pressedGridIndex == index;
    final double scale = pressed ? 0.98 : (hovered ? 1.02 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredGridIndex = index),
      onExit: (_) => setState(() => _hoveredGridIndex = null),
      child: GestureDetector(
        onTap: () {},
        onTapDown: (_) => setState(() => _pressedGridIndex = index),
        onTapUp: (_) => setState(() => _pressedGridIndex = null),
        onTapCancel: () => setState(() => _pressedGridIndex = null),
        child: AnimatedScale(
          scale: scale,
          duration: dureeAnimationMoyenne,
          curve: Curves.easeOut,
          child: CarteModerne(
            onTap: () {},
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          couleurSecondaire.withOpacity(0.3),
                          couleurAccent.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(rayonBordure),
                        topRight: Radius.circular(rayonBordure),
                      ),
                    ),
                    child: const Center(
                      child: Text('🎧', style: TextStyle(fontSize: 50)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(espacementS),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Casque Audio Premium',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: tailleTexteCaption,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: espacementXS),
                      Text(
                        '\$249',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: couleurPrincipale,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Section marques
  Widget _buildBrandsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(espacementM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Marques populaires',
              style: TextStyle(
                fontSize: tailleTexteSousTitre,
                fontWeight: FontWeight.bold,
                color: couleurTexte,
              ),
            ),
            const SizedBox(height: espacementM),
            Wrap(
              spacing: espacementM,
              runSpacing: espacementM,
              children: List.generate(
                6,
                (index) => Container(
                  width: 100,
                  height: 60,
                  decoration: BoxDecoration(
                    color: couleurCarte,
                    borderRadius: BorderRadius.circular(rayonBordureS),
                    boxShadow: ombreLegere,
                  ),
                  child: Center(
                    child: Text(
                      'BRAND',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: couleurTexteSecondaire,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: espacementXL),
          ],
        ),
      ),
    );
  }

  // Panier flottant
  Widget _buildFloatingCart() {
    return FloatingActionButton.extended(
      onPressed: () {},
      backgroundColor: couleurPrincipale,
      icon: const Icon(Icons.shopping_cart),
      label: const Text('Panier (3)'),
    );
  }
}

// Bouton animé moderne pour la bannière
class _AnimatedGradientButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  const _AnimatedGradientButton({required this.onPressed, required this.label});

  @override
  State<_AnimatedGradientButton> createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<_AnimatedGradientButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.96 : (_hovered ? 1.06 : 1.0);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() { _hovered = false; _pressed = false; }),
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFFD54F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Transform.translate(
              offset: const Offset(0, -3), // Légère remontée du contenu pour éviter la coupe
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Effet shimmer sur texte promotionnel
class ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration period;
  const ShimmerText({super.key, required this.text, required this.style, this.period = const Duration(seconds: 2)});

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shimmerGradient = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white,
            Colors.white.withOpacity(0.2),
          ],
          stops: const [0.1, 0.5, 0.9],
          begin: Alignment(-1 + _controller.value * 2, 0),
          end: Alignment(1 + _controller.value * 2, 0),
        );
        return ShaderMask(
          shaderCallback: (rect) => shimmerGradient.createShader(rect),
          blendMode: BlendMode.srcATop,
          child: Text(widget.text, style: widget.style),
        );
      },
    );
  }
}



