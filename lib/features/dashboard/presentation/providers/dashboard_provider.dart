import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talabati/features/dashboard/data/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider((ref) => DashboardRepository());

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(
  DashboardNotifier.new,
);

class DashboardState {
  final bool isLoading;
  final int totalOrders;
  final int todaysOrders;
  final int pendingConfirmation;
  final int withCourier;
  final int deliveredAwaitingCollection;
  final double monthlyRevenue;
  final double monthlyProfit;
  final double pendingRevenue;
  final int returnsThisMonth;
  final List<TopReturningClientStat> topReturningClients;
  final List<RecentOrderStat> recentOrders;

  const DashboardState({
    this.isLoading = false,
    this.totalOrders = 0,
    this.todaysOrders = 0,
    this.pendingConfirmation = 0,
    this.withCourier = 0,
    this.deliveredAwaitingCollection = 0,
    this.monthlyRevenue = 0,
    this.monthlyProfit = 0,
    this.pendingRevenue = 0,
    this.returnsThisMonth = 0,
    this.topReturningClients = const [],
    this.recentOrders = const [],
  });

  DashboardState copyWith({
    bool? isLoading,
    int? totalOrders,
    int? todaysOrders,
    int? pendingConfirmation,
    int? withCourier,
    int? deliveredAwaitingCollection,
    double? monthlyRevenue,
    double? monthlyProfit,
    double? pendingRevenue,
    int? returnsThisMonth,
    List<TopReturningClientStat>? topReturningClients,
    List<RecentOrderStat>? recentOrders,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      totalOrders: totalOrders ?? this.totalOrders,
      todaysOrders: todaysOrders ?? this.todaysOrders,
      pendingConfirmation: pendingConfirmation ?? this.pendingConfirmation,
      withCourier: withCourier ?? this.withCourier,
      deliveredAwaitingCollection:
          deliveredAwaitingCollection ?? this.deliveredAwaitingCollection,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      monthlyProfit: monthlyProfit ?? this.monthlyProfit,
      pendingRevenue: pendingRevenue ?? this.pendingRevenue,
      returnsThisMonth: returnsThisMonth ?? this.returnsThisMonth,
      topReturningClients: topReturningClients ?? this.topReturningClients,
      recentOrders: recentOrders ?? this.recentOrders,
    );
  }
}

class DashboardNotifier extends Notifier<DashboardState> {
  DashboardRepository get _repository => ref.read(dashboardRepositoryProvider);

  @override
  DashboardState build() {
    loadDashboard();
    return const DashboardState(isLoading: true);
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true);

    final totalOrdersFuture = _repository.getTotalOrdersCount();
    final todaysOrdersFuture = _repository.getTodaysOrdersCount();
    final pendingConfirmationFuture = _repository.getPendingConfirmationCount();
    final withCourierFuture = _repository.getWithCourierCount();
    final deliveredAwaitingCollectionFuture = _repository
        .getDeliveredAwaitingCollectionCount();
    final monthlyRevenueFuture = _repository.getMonthlyRevenue();
    final monthlyProfitFuture = _repository.getMonthlyProfit();
    final pendingRevenueFuture = _repository.getPendingRevenue();
    final returnsThisMonthFuture = _repository.getReturnsThisMonthCount();
    final topReturningClientsFuture = _repository.getTopReturningClients();
    final recentOrdersFuture = _repository.getRecentOrders();

    await Future.wait([
      totalOrdersFuture,
      todaysOrdersFuture,
      pendingConfirmationFuture,
      withCourierFuture,
      deliveredAwaitingCollectionFuture,
      monthlyRevenueFuture,
      monthlyProfitFuture,
      pendingRevenueFuture,
      returnsThisMonthFuture,
      topReturningClientsFuture,
      recentOrdersFuture,
    ]);

    state = DashboardState(
      totalOrders: await totalOrdersFuture,
      todaysOrders: await todaysOrdersFuture,
      pendingConfirmation: await pendingConfirmationFuture,
      withCourier: await withCourierFuture,
      deliveredAwaitingCollection: await deliveredAwaitingCollectionFuture,
      monthlyRevenue: await monthlyRevenueFuture,
      monthlyProfit: await monthlyProfitFuture,
      pendingRevenue: await pendingRevenueFuture,
      returnsThisMonth: await returnsThisMonthFuture,
      topReturningClients: await topReturningClientsFuture,
      recentOrders: await recentOrdersFuture,
    );
  }
}
