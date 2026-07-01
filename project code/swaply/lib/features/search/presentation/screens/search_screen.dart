import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swaply/core/constants/app_colors.dart';
import 'package:swaply/core/constants/extensions/theme_extention.dart';
import 'package:swaply/features/mentor_details/presentation/screens/mentor_details_screen.dart';
import 'package:swaply/features/search/data/models/search_model.dart';
import 'package:swaply/features/search/data/repositories/search_repository_firebase.dart';
import 'package:swaply/features/search/presentation/cubit/search_cubit.dart';
import 'package:swaply/features/search/presentation/cubit/search_state.dart';
import 'package:swaply/l10n/app_localizations.dart';

class SearchScreen extends StatelessWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = SearchCubit(FirebaseSearchRepository());
        final q = initialQuery?.trim();
        if (q != null && q.isNotEmpty) {
          cubit.search(q);
        } else {
          cubit.loadPopularSkills();
        }
        return cubit;
      },
      child: SearchView(initialQuery: initialQuery),
    );
  }
}

class SearchView extends StatefulWidget {
  final String? initialQuery;
  const SearchView({super.key, this.initialQuery});

  @override
  State<SearchView> createState() => SearchViewState();
}

class SearchViewState extends State<SearchView> {
  late final searchCtrl = TextEditingController(
    text: widget.initialQuery ?? '',
  );
  String sortTab = 'All';
  late bool isSearching = (widget.initialQuery ?? '').trim().isNotEmpty;

  final sortTabs = ['All', 'Latest', 'Most Popular', 'Cheapest'];

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  void onQueryChanged(String val) {
    setState(() => isSearching = val.trim().isNotEmpty);
    if (val.trim().isEmpty) {
      context.read<SearchCubit>().clearSearch();
    } else {
      context.read<SearchCubit>().search(val);
    }
  }

  void onSubmit(String val) {
    context.read<SearchCubit>().addRecentSearch(val);
    setState(() => sortTab = 'All');
  }

  void clearSearch() {
    searchCtrl.clear();
    setState(() => isSearching = false);
    context.read<SearchCubit>().clearSearch();
  }

  List<SearchMentorModel> _sort(List<SearchMentorModel> list) {
    final sorted = List<SearchMentorModel>.from(list);
    switch (sortTab) {
      case 'Most Popular':
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
      case 'Cheapest':
        sorted.sort((a, b) {
          final aP =
              int.tryParse(a.rate.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          final bP =
              int.tryParse(b.rate.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          return aP.compareTo(bP);
        });
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.border),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: colors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isSearching ? colors.primary : colors.border,
                          width: isSearching ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: isSearching
                                ? colors.primary
                                : colors.mutedFg,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: searchCtrl,
                              autofocus: true,
                              enableSuggestions:
                                  false, // disables predictive suggestions
                              enableIMEPersonalizedLearning:
                                  false, // disables learning/composing highlight in some keyboards
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.text,
                              ),

                              cursorColor: colors.primary,
                              decoration: InputDecoration(
                                hintText: 'Search skills, mentors...',
                                hintStyle: TextStyle(
                                  color: colors.mutedFg,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: onQueryChanged,
                              onSubmitted: onSubmit,
                            ),
                          ),
                          if (isSearching)
                            GestureDetector(
                              onTap: clearSearch,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: colors.mutedFg,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ──
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  return switch (state) {
                    SearchLoadingSkills() => Center(
                      child: CircularProgressIndicator(color: colors.primary),
                    ),
                    SearchIdle(:final popularSkills, :final recentSearches) =>
                      SearchIdleView(
                        popularSkills: popularSkills,
                        recentSearches: recentSearches,
                        onSelectQuery: (q) {
                          searchCtrl.text = q;
                          onQueryChanged(q);
                        },
                        onRemoveRecent: (q) =>
                            context.read<SearchCubit>().removeRecentSearch(q),
                        onClearAll: () =>
                            context.read<SearchCubit>().clearRecentSearches(),
                      ),
                    SearchLoading() => Center(
                      child: CircularProgressIndicator(color: colors.primary),
                    ),
                    SearchLoaded(:final results) => SearchResultsView(
                      results: _sort(results),
                      sortTab: sortTab,
                      onTabChange: (t) => setState(() => sortTab = t),
                      sortTabs: sortTabs,
                    ),
                    SearchError(:final message) => Center(
                      child: Text(
                        message,
                        style: TextStyle(color: colors.mutedFg),
                      ),
                    ),
                    _ => const SizedBox(),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Idle View ────────────────────────────
class SearchIdleView extends StatelessWidget {
  final List<SkillModel> popularSkills;
  final List<String> recentSearches;
  final ValueChanged<String> onSelectQuery;
  final ValueChanged<String> onRemoveRecent;
  final VoidCallback onClearAll;

  const SearchIdleView({
    super.key,
    required this.popularSkills,
    required this.recentSearches,
    required this.onSelectQuery,
    required this.onRemoveRecent,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.recentSearches,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const Spacer(),
            if (recentSearches.isNotEmpty)
              GestureDetector(
                onTap: onClearAll,
                child: Text(
                  AppLocalizations.of(context)!.clearAll,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentSearches.isEmpty)
          Text(
            'No recent searches.',
            style: TextStyle(fontSize: 12, color: colors.mutedFg),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches
                .map(
                  (s) => GestureDetector(
                    onTap: () => onSelectQuery(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            s,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => onRemoveRecent(s),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: colors.mutedFg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 24),

        Text(
          AppLocalizations.of(context)!.popularSkills,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        const SizedBox(height: 12),
        ...popularSkills.map(
          (p) => GestureDetector(
            onTap: () => onSelectQuery(p.name),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.star_outline_rounded,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          ),
                        ),
                        Text(
                          p.count,
                          style: TextStyle(fontSize: 11, color: colors.mutedFg),
                        ),
                      ],
                    ),
                  ),
                  SkillTagBadge(tag: p.tag),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Results View ─────────────────────────
class SearchResultsView extends StatelessWidget {
  final List<SearchMentorModel> results;
  final String sortTab;
  final ValueChanged<String> onTabChange;
  final List<String> sortTabs;

  const SearchResultsView({
    super.key,
    required this.results,
    required this.sortTab,
    required this.onTabChange,
    required this.sortTabs,
  });

  String _getLocalizedTab(BuildContext context, String tab) {
    final l10n = AppLocalizations.of(context)!;
    switch (tab) {
      case 'All':
        return l10n.filterAll;
      case 'Latest':
        return l10n.filterLatest;
      case 'Most Popular':
        return l10n.filterMostPopular;
      case 'Cheapest':
        return l10n.filterCheapest;
      default:
        return tab;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        // Sort tabs
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: sortTabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final active = sortTab == sortTabs[i];
              return GestureDetector(
                onTap: () => onTabChange(sortTabs[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: active ? colors.primary : colors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active ? colors.primary : colors.border,
                    ),
                  ),
                  child: Text(
                    _getLocalizedTab(context, sortTabs[i]),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      // was hardcoded `searchDark` (#1A1A2E) — invisible in dark mode
                      color: active ? Colors.white : colors.text,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: results.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.noResultsFound,
                    style: TextStyle(color: colors.mutedFg),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: results.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (_, i) => SearchMentorCard(mentor: results[i]),
                ),
        ),
      ],
    );
  }
}

// ── Mentor Card ──────────────────────────
class SearchMentorCard extends StatelessWidget {
  final SearchMentorModel mentor;
  const SearchMentorCard({super.key, required this.mentor});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MentorDetailsScreen(mentorId: mentor.id),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: mentor.avatarUrl.isNotEmpty
                      ? Image.network(
                          mentor.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _AvatarPlaceholder(colors: colors),
                        )
                      : _AvatarPlaceholder(colors: colors),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mentor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                  Text(
                    mentor.skill,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: colors.mutedFg),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFC107),
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        mentor.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.text,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        mentor.rate,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
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
}

class _AvatarPlaceholder extends StatelessWidget {
  final AppColorTheme colors;
  const _AvatarPlaceholder({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.primarySoft,
      child: Icon(CupertinoIcons.person_fill, color: colors.primary, size: 44),
    );
  }
}

// ── Tag Badge ────────────────────────────
class SkillTagBadge extends StatelessWidget {
  final SkillTag tag;
  const SkillTagBadge({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final map = {
      SkillTag.hot: (
        l10n.tagHot,
        const Color(0xFFFFEBEE),
        const Color(0xFFE53935),
      ),
      SkillTag.newSkill: (
        l10n.tagNew,
        const Color(0xFFFFF3E0),
        const Color(0xFFF57C00),
      ),
      SkillTag.popular: (
        l10n.tagPopular,
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
      ),
    };

    final (label, bg, fg) = map[tag]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
