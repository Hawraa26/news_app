import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/news_provider.dart';
import '../widgets/article_card.dart';
import '../services/auth_service.dart';

import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _searchController =
  TextEditingController();

  void _searchNews() {
    final query = _searchController.text.trim();

    context.read<NewsProvider>().searchNews(query);
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();

    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;

    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200) {
      context.read<NewsProvider>().fetchMoreNews();
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = context.watch<NewsProvider>();

    return Scaffold(
      drawer: _buildDrawer(context),

      appBar: AppBar(
        title: const Text(
          'آخر الأخبار',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),

            _buildSectionTitle(),

            _buildCategoryBar(newsProvider),

            const SizedBox(height: 6),

            Expanded(
              child: _buildBody(newsProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final user = AuthService().currentUser;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                25,
                20,
                25,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person_rounded,
                      size: 38,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'مرحبًا بك 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    user?.email ?? 'غير معروف',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            ListTile(
              leading: const Icon(
                Icons.home_outlined,
              ),
              title: const Text(
                'الرئيسية',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.star_outline_rounded,
              ),
              title: const Text(
                'الأخبار المفضلة',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const FavoritesScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.person_outline_rounded,
              ),
              title: const Text(
                'الملف الشخصي',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const ProfileScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.settings_outlined,
              ),
              title: const Text(
                'الإعدادات',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const SettingsScreen(),
                  ),
                );
              },
            ),

            const Divider(
              height: 30,
            ),

            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
              ),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);

                _confirmLogout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _searchNews(),
        decoration: InputDecoration(
          hintText: 'ابحث عن خبر...',
          prefixIcon: const Icon(
            Icons.search_rounded,
          ),
          suffixIcon:
          _searchController.text.isNotEmpty
              ? IconButton(
            tooltip: 'مسح البحث',
            icon: const Icon(
              Icons.clear_rounded,
            ),
            onPressed: () {
              _searchController.clear();

              setState(() {});

              context
                  .read<NewsProvider>()
                  .fetchInitialNews();
            },
          )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
        ),
        onChanged: (_) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildSectionTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        6,
      ),
      child: Text(
        'استكشف الأخبار',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryBar(NewsProvider provider) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        itemCount: NewsProvider.categories.length,
        itemBuilder: (context, index) {
          final key =
          NewsProvider.categories.keys.elementAt(index);

          final label =
          NewsProvider.categories.values.elementAt(index);

          final isSelected =
              provider.selectedCategory == key;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              showCheckmark: false,
              avatar: isSelected
                  ? const Icon(
                Icons.check,
                size: 16,
              )
                  : null,
              onSelected: (_) {
                provider.changeCategory(key);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(NewsProvider provider) {
    if (provider.isLoading &&
        provider.articles.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.hasError &&
        provider.articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 65,
                color: Colors.grey,
              ),

              const SizedBox(height: 18),

              Text(
                provider.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: provider.fetchInitialNews,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'إعادة المحاولة',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.articles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 65,
              color: Colors.grey,
            ),

            SizedBox(height: 14),

            Text(
              'لا توجد أخبار مطابقة لبحثك',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.fetchInitialNews,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(
          top: 4,
          bottom: 20,
        ),
        itemCount: provider.articles.length + 1,
        itemBuilder: (context, index) {
          if (index == provider.articles.length) {
            return _buildFooter(provider);
          }

          return ArticleCard(
            article: provider.articles[index],
          );
        },
      ),
    );
  }

  Widget _buildFooter(NewsProvider provider) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          vertical: 24,
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!provider.hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          vertical: 24,
        ),
        child: Center(
          child: Text(
            'وصلت لآخر الأخبار المتاحة',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return const SizedBox(
      height: 20,
    );
  }

  Future<void> _confirmLogout(
      BuildContext context,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'تسجيل الخروج',
          ),
          content: const Text(
            'هل أنتِ متأكدة من رغبتك بتسجيل الخروج؟',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'إلغاء',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text(
                'تسجيل الخروج',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await AuthService().logout();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );
    }
  }
}