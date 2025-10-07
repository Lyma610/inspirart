import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/post_card.dart';
import '../../widgets/bottom_navigation.dart';
import '../menu/drawer_menu_screen.dart';
import 'search_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import '../post/select_media_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
              drawer: DrawerMenuScreen(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildFeedPage(),
          _buildSearchPage(),
          _buildCreatePage(),
          _buildNotificationsPage(),
          _buildProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildFeedPage() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: true,
          backgroundColor: AppTheme.surfaceColor,
          elevation: 0,
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.brush,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Inspirart',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _currentIndex = 1;
                });
                _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                setState(() {
                  _currentIndex = 4;
                });
                _pageController.animateToPage(4, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<PostProvider>(
              builder: (context, postProvider, child) {
                return Column(
                  children: [
                    // Filtros de categoria
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: postProvider.getCategories().length,
                        itemBuilder: (context, index) {
                          final category = postProvider.getCategories()[index];
                          final isSelected = postProvider.selectedCategory == category;
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                postProvider.filterByCategory(category);
                              },
                              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                              checkmarkColor: AppTheme.primaryColor,
                              labelStyle: TextStyle(
                                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Lista de posts
                    ...postProvider.filteredPosts.map((post) => PostCard(post: post)),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchPage() {
    return const SearchScreen();
  }

  Widget _buildCreatePage() {
    return const SelectMediaScreen();
  }

  Widget _buildNotificationsPage() {
    return NotificationsScreen();
  }

  Widget _buildProfilePage() {
    return ProfileScreen();
  }
} 