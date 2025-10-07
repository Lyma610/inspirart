import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Container(
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _isSearching = value.isNotEmpty;
              });
            },
            decoration: InputDecoration(
              hintText: 'Pesquisar',
              hintStyle: TextStyle(color: AppTheme.textSecondaryColor),
              prefixIcon: Icon(Icons.search, color: AppTheme.textSecondaryColor, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: AppTheme.textSecondaryColor, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _isSearching = false;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
      ),
      body: _isSearching ? _buildSearchResults() : _buildExploreGrid(),
    );
  }

  Widget _buildSearchResults() {
    return Consumer2<PostProvider, UserProvider>(
      builder: (context, postProvider, userProvider, child) {
        final posts = postProvider.getFilteredPosts(_searchQuery, null);
        final users = userProvider.searchUsers(_searchQuery);
        
        if (posts.isEmpty && users.isEmpty) {
          return _buildEmptyState();
        }
        
        return ListView(
          children: [
            if (users.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Contas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                ),
              ),
              ...users.map((user) => _buildUserTile(user)),
              const Divider(),
            ],
            if (posts.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Posts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 1),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return GestureDetector(
                    onTap: () => context.go('/post'),
                    child: Image.network(
                      post.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildUserTile(User user) {
    return ListTile(
      leading: GestureDetector(
        onTap: () => context.go('/user/${user.id}'),
        child: CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(user.avatar),
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        ),
      ),
      title: GestureDetector(
        onTap: () => context.go('/user/${user.id}'),
        child: Text(
          user.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      subtitle: Text(
        user.bio,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppTheme.textSecondaryColor,
        ),
      ),
      onTap: () => context.go('/user/${user.id}'),
    );
  }

  Widget _buildExploreGrid() {
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        final posts = postProvider.posts;
        
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return GestureDetector(
              onTap: () => context.go('/post'),
              child: Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
              ),
            );
          },
        );
      },
    );
  }



  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum resultado encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente pesquisar algo diferente',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 