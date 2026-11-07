import 'package:get_it/get_it.dart';
import 'package:restauran_menu/core/database/category_repository.dart';
import 'package:restauran_menu/core/database/hive_service.dart';
import 'package:restauran_menu/core/database/menu_repository.dart';
import 'package:restauran_menu/core/database/order_repository.dart';
import 'package:restauran_menu/core/database/table_repository.dart';
import 'package:restauran_menu/core/network/envi_services.dart';
import 'package:restauran_menu/core/network/sse/sse_client.dart';
import 'package:restauran_menu/features/admin/data/datasources/dashboard_remote_datasource.dart';
import 'package:restauran_menu/features/admin/data/repositories/dashboard_repository_impl.dart';
import 'package:restauran_menu/features/admin/domain/repositories/dashboard_repositories.dart';
import 'package:restauran_menu/features/admin/domain/usecases/get_my_tenant_usecase.dart';
import 'package:restauran_menu/features/admin/domain/usecases/get_orders_admin_usecase.dart';
import 'package:restauran_menu/features/admin/domain/usecases/update_my_tenant_usecase.dart';
import 'package:restauran_menu/features/admin/presentation/provider/admin_provider.dart';
import 'package:restauran_menu/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:restauran_menu/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:restauran_menu/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:restauran_menu/features/auth/domain/repositories/auth_repositories.dart';
import 'package:restauran_menu/features/auth/domain/usecases/auth_login_usecase.dart';
import 'package:restauran_menu/features/auth/domain/usecases/auth_logout_usecase.dart';
import 'package:restauran_menu/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:restauran_menu/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:restauran_menu/features/auth/domain/usecases/get_token_usecase.dart';
import 'package:restauran_menu/features/auth/presentation/provider/auth_provider.dart';
import 'package:restauran_menu/features/customers/data/datasources/public_menu_remote_datasource.dart';
import 'package:restauran_menu/features/customers/data/repositories/public_menu_repository_impl.dart';
import 'package:restauran_menu/features/customers/domain/repositories/public_menu_repository.dart';
import 'package:restauran_menu/features/customers/domain/usecases/cancel_public_order_usecase.dart';
import 'package:restauran_menu/features/customers/domain/usecases/create_public_order_usecase.dart';
import 'package:restauran_menu/features/customers/domain/usecases/get_public_menu_usecase.dart';
import 'package:restauran_menu/features/customers/domain/usecases/get_public_order_usecase.dart';
import 'package:restauran_menu/features/customers/presentation/provider/public_menu_provider.dart';
import 'package:restauran_menu/features/home/data/datasources/home_remote_datasource.dart';
import 'package:restauran_menu/features/home/data/repositories/home_repositories_impl.dart';
import 'package:restauran_menu/features/home/domain/repositories/home_repositories.dart';
import 'package:restauran_menu/features/home/domain/usecases/get_all_users_usecase.dart';
import 'package:restauran_menu/features/home/presentation/provider/home_provider.dart';
import 'package:restauran_menu/features/kasir/presentation/provider/kasir_provider.dart';
import 'package:restauran_menu/features/kitchen/presentation/provider/kitchen_provider.dart';
import 'package:restauran_menu/features/members/data/datasources/member_remote_datasource.dart';
import 'package:restauran_menu/features/members/data/repositories/member_repository_impl.dart';
import 'package:restauran_menu/features/members/domain/repositories/member_repository.dart';
import 'package:restauran_menu/features/members/domain/usecases/create_member_usecase.dart';
import 'package:restauran_menu/features/members/domain/usecases/delete_member_usecase.dart';
import 'package:restauran_menu/features/members/domain/usecases/get_members_usecase.dart';
import 'package:restauran_menu/features/members/domain/usecases/update_member_usecase.dart';
import 'package:restauran_menu/features/members/domain/usecases/validate_member_by_phone_usecase.dart';
import 'package:restauran_menu/features/members/presentation/provider/member_provider.dart';
import 'package:restauran_menu/features/menu/data/datasources/menu_remote_datasource.dart';
import 'package:restauran_menu/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:restauran_menu/features/menu/domain/repositories/menu_repositories.dart';
import 'package:restauran_menu/features/menu/domain/usecases/create_category_usecase.dart';
import 'package:restauran_menu/features/menu/domain/usecases/create_menu_item_usecase.dart';
import 'package:restauran_menu/features/menu/domain/usecases/delete_category_usecase.dart';
import 'package:restauran_menu/features/menu/domain/usecases/delete_menu_item_usecase.dart';
import 'package:restauran_menu/features/menu/domain/usecases/get_categories_usecase.dart';
import 'package:restauran_menu/features/menu/domain/usecases/get_menu_items_usecase.dart';
import 'package:restauran_menu/features/menu/domain/usecases/update_category_usecase.dart';
import 'package:restauran_menu/features/menu/domain/usecases/update_menu_item_usecase.dart';
import 'package:restauran_menu/features/menu/presentation/provider/menu_provider.dart';
import 'package:restauran_menu/features/notifications/data/datasources/order_stream_remote_datasource.dart';
import 'package:restauran_menu/features/notifications/data/repositories/order_stream_repository_impl.dart';
import 'package:restauran_menu/features/notifications/domain/repositories/order_stream_repository.dart';
import 'package:restauran_menu/features/notifications/domain/usecases/watch_order_stream_usecase.dart';
import 'package:restauran_menu/features/notifications/presentation/provider/order_stream_provider.dart';
import 'package:restauran_menu/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:restauran_menu/features/orders/data/repositories/order_repository_impl.dart';
import 'package:restauran_menu/features/orders/domain/repositories/order_data_repositories.dart';
import 'package:restauran_menu/features/orders/domain/usecases/create_order_usecase.dart';
import 'package:restauran_menu/features/orders/domain/usecases/get_available_menu_items_usecase.dart';
import 'package:restauran_menu/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:restauran_menu/features/orders/domain/usecases/update_order_status_usecase.dart';
import 'package:restauran_menu/features/orders/presentation/providers/create_order_provider.dart';
import 'package:restauran_menu/features/orders/presentation/providers/orders_provider.dart';
import 'package:restauran_menu/features/permissions/data/datasources/permission_remote_datasource.dart';
import 'package:restauran_menu/features/permissions/data/repositories/permission_repository_impl.dart';
import 'package:restauran_menu/features/permissions/domain/repositories/permission_repositories.dart';
import 'package:restauran_menu/features/permissions/domain/usecases/get_my_permissions_usecase.dart';
import 'package:restauran_menu/features/permissions/domain/usecases/get_permission_matrix_usecase.dart';
import 'package:restauran_menu/features/permissions/domain/usecases/reset_role_permissions_usecase.dart';
import 'package:restauran_menu/features/permissions/domain/usecases/update_role_permissions_usecase.dart';
import 'package:restauran_menu/features/permissions/presentation/provider/permission_provider.dart';
import 'package:restauran_menu/features/promos/data/datasources/promo_remote_datasource.dart';
import 'package:restauran_menu/features/promos/data/repositories/promo_repository_impl.dart';
import 'package:restauran_menu/features/promos/domain/repositories/promo_repository.dart';
import 'package:restauran_menu/features/promos/domain/usecases/create_promo_usecase.dart';
import 'package:restauran_menu/features/promos/domain/usecases/delete_promo_usecase.dart';
import 'package:restauran_menu/features/promos/domain/usecases/get_promo_stats_usecase.dart';
import 'package:restauran_menu/features/promos/domain/usecases/get_promos_usecase.dart';
import 'package:restauran_menu/features/promos/domain/usecases/toggle_promo_status_usecase.dart';
import 'package:restauran_menu/features/promos/domain/usecases/update_promo_usecase.dart';
import 'package:restauran_menu/features/promos/domain/usecases/validate_promo_usecase.dart';
import 'package:restauran_menu/features/promos/presentation/provider/promo_provider.dart';
import 'package:restauran_menu/features/staff/data/datasources/staff_remote_datasource.dart';
import 'package:restauran_menu/features/staff/data/repositories/staff_repository_impl.dart';
import 'package:restauran_menu/features/staff/domain/repositories/staff_repositories.dart';
import 'package:restauran_menu/features/staff/domain/usecases/get_staff_usecase.dart';
import 'package:restauran_menu/features/staff/domain/usecases/invite_staff_usecase.dart';
import 'package:restauran_menu/features/staff/domain/usecases/remove_staff_usecase.dart';
import 'package:restauran_menu/features/staff/presentation/providers/staff_provider.dart';
import 'package:restauran_menu/features/stock/data/datasources/remote/stock_remote_data_source.dart';
import 'package:restauran_menu/features/stock/data/repositories/stock_repository_impl.dart';
import 'package:restauran_menu/features/stock/domain/repositories/stock_repository.dart';
import 'package:restauran_menu/features/stock/domain/usecases/create_category.dart';
import 'package:restauran_menu/features/stock/domain/usecases/create_stock_item.dart';
import 'package:restauran_menu/features/stock/domain/usecases/create_unit.dart';
import 'package:restauran_menu/features/stock/domain/usecases/delete_stock_item.dart';
import 'package:restauran_menu/features/stock/domain/usecases/get_categories.dart';
import 'package:restauran_menu/features/stock/domain/usecases/get_stock_items.dart';
import 'package:restauran_menu/features/stock/domain/usecases/get_units.dart';
import 'package:restauran_menu/features/stock/domain/usecases/update_stock_item.dart';
import 'package:restauran_menu/features/stock/presentation/provider/category_provider.dart';
import 'package:restauran_menu/features/stock/presentation/provider/stock_provider.dart';
import 'package:restauran_menu/features/stock/presentation/provider/unit_provider.dart';
import 'package:restauran_menu/features/waiters/presentation/provider/waiter_provider.dart';

import '../network/dio_client.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // DIO
  sl.registerLazySingleton<DioClient>(() => DioClient.instance..init());

  // Auth
  // ---------------------------
  // ------------  datasource ---------------
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(dioClient: sl()),
  );
  // ------------  repository ---------------
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  // ------------ provider ---------------------
  sl.registerLazySingleton(() => AuthProvider(sl(), sl(), sl(), sl(), sl()));
  // ------------  usecase ---------------
  sl.registerLazySingleton<CheckAuthUsecase>(() => CheckAuthUsecase(sl()));
  sl.registerLazySingleton<GetProfileUsecase>(() => GetProfileUsecase(sl()));
  sl.registerLazySingleton<AuthLoginUsecase>(() => AuthLoginUsecase(sl()));
  sl.registerLazySingleton<AuthLogoutUsecase>(() => AuthLogoutUsecase(sl()));

  // Home
  // ---------------------------
  // ------------  datasource ---------------
  sl.registerLazySingleton<HomeRemoteDatasource>(
    () => HomeRemoteDatasourceImpl(),
  );
  // ------------  repository ---------------
  sl.registerLazySingleton<HomeRepositories>(() => HomeRepositoriesImpl(sl()));
  // ------------ provider ---------------------
  sl.registerFactory(() => HomeProvider(sl()));
  // ------------  usecase ---------------
  sl.registerLazySingleton<GetAllUsersUsecase>(() => GetAllUsersUsecase(sl()));
  // ---------------------------

  // ---------------------------
  // Local Database (Hive) — shared by Customers / Kasir / Kitchen / Waiters
  // ---------------------------
  await HiveService.open();

  sl.registerLazySingleton(() => CategoryRepository(HiveService.categoryBox));
  sl.registerLazySingleton(() => MenuRepository(HiveService.menuBox));
  sl.registerLazySingleton(() => OrderRepository(HiveService.orderBox));
  sl.registerLazySingleton(() => TableRepository(HiveService.tableBox));

  // // Categories must be seeded before menu items.
  // final seededCategories = await sl<CategoryRepository>().seedIfEmpty([
  //   'Makanan',
  //   'Minuman',
  // ]);
  // final makananId = seededCategories
  //     .firstWhere(
  //       (c) => c.name == 'Makanan',
  //       orElse: () => seededCategories.first,
  //     )
  //     .id;
  // final minumanId = seededCategories
  //     .firstWhere(
  //       (c) => c.name == 'Minuman',
  //       orElse: () => seededCategories.first,
  //     )
  //     .id;
  // // Seed once on first run so the app isn't empty out of the box.
  // await sl<MenuRepository>().seedIfEmpty(
  //   DummyMenuData.buildItems(
  //     makananCategoryId: makananId,
  //     minumanCategoryId: minumanId,
  //   ),
  // );
  // await sl<OrderRepository>().seedIfEmpty([
  //   ...DummyOrderData.activeOrders,
  //   ...DummyOrderData.history,
  // ]);
  await sl<TableRepository>().seedIfEmpty(4);
  // // Reconcile seeded tables with seeded active orders.
  // for (final order in DummyOrderData.activeOrders) {
  //   if (order.tableNumber == null) continue;
  //   await sl<TableRepository>().occupyTable(
  //     order.tableNumber!,
  //     orderNumber: order.orderNumber,
  //     guestCount: 2,
  //   );
  // }

  // ---------------------------
  // Dashboard
  // ---------------------------
  // ------------ datasource ---------------
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(),
  );
  // ------------ repository ---------------
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl()),
  );
  // ------------ usecase ---------------
  sl.registerLazySingleton(() => GetMyTenantUsecase(sl()));
  sl.registerLazySingleton(() => GetOrdersAdminUsecase(sl()));
  sl.registerLazySingleton(() => UpdateMyTenantUsecase(sl()));
  //sl.registerLazySingleton(() => GetMenuItemsUsecase(sl()));
  // ------------ provider (state management) ---------------
  // factory - instance baru tiap DashboardScreen dibuka, biar datanya selalu segar
  sl.registerFactory(() => AdminProvider(sl(), sl(), sl()));

  // ---------------------------
  // Menu
  // ---------------------------
  // ------------ datasource ---------------
  sl.registerLazySingleton<MenuRemoteDataSource>(
    () => MenuRemoteDataSourceImpl(),
  );
  // ------------ repository ---------------
  sl.registerLazySingleton<MenuDataRepository>(() => MenuRepositoryImpl(sl()));
  // ------------ usecase ---------------
  sl.registerLazySingleton(() => GetCategoriesUsecase(sl()));
  sl.registerLazySingleton(() => CreateCategoryUsecase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUsecase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUsecase(sl()));
  sl.registerLazySingleton(() => GetMenuItemsUsecase(sl()));
  sl.registerLazySingleton(() => CreateMenuItemUsecase(sl()));
  sl.registerLazySingleton(() => UpdateMenuItemUsecase(sl()));
  sl.registerLazySingleton(() => DeleteMenuItemUsecase(sl()));
  // ------------ provider (state management) ---------------
  sl.registerFactory(
    () => MenuProvider(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()),
  );

  // ---------------------------
  // Staff
  // ---------------------------
  // ------------ datasource ---------------
  sl.registerLazySingleton<StaffRemoteDataSource>(
    () => StaffRemoteDataSourceImpl(),
  );
  // ------------ repository ---------------
  sl.registerLazySingleton<StaffRepository>(() => StaffRepositoryImpl(sl()));
  // ------------ usecase ---------------
  sl.registerLazySingleton(() => GetStaffUsecase(sl()));
  sl.registerLazySingleton(() => InviteStaffUsecase(sl()));
  sl.registerLazySingleton(() => DeleteStaffUsecase(sl()));
  // ------------ provider (state management) ---------------
  sl.registerFactory(() => StaffProvider(sl(), sl(), sl()));

  // ---------------------------
  // Permissions (Hak Akses)
  // ---------------------------
  // ------------ datasource ---------------
  sl.registerLazySingleton<PermissionRemoteDataSource>(
    () => PermissionRemoteDataSourceImpl(),
  );
  // ------------ repository ---------------
  sl.registerLazySingleton<PermissionRepository>(
    () => PermissionRepositoryImpl(sl()),
  );
  // ------------ usecase ---------------
  sl.registerLazySingleton(() => GetPermissionMatrixUsecase(sl()));
  sl.registerLazySingleton(() => GetMyPermissionsUsecase(sl()));
  sl.registerLazySingleton(() => UpdateRolePermissionsUsecase(sl()));
  sl.registerLazySingleton(() => ResetRolePermissionsUsecase(sl()));
  // ------------ provider (state management) ---------------
  sl.registerFactory(() => PermissionProvider(sl(), sl(), sl(), sl()));

  // ---------------------------
  // Orders
  // ---------------------------
  // ------------ datasource ---------------
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(),
  );
  // ------------ repository ---------------
  sl.registerLazySingleton<OrderDataRepository>(
    () => OrderRepositoryImpl(sl()),
  );
  // ------------ usecase ---------------
  sl.registerLazySingleton(() => GetOrdersUsecase(sl()));
  sl.registerLazySingleton(() => CreateOrderUsecase(sl()));
  sl.registerLazySingleton(() => UpdateOrderStatusUsecase(sl()));
  sl.registerLazySingleton(() => GetAvailableMenuItemsUsecase(sl()));
  // ------------ provider (state management) ---------------
  sl.registerFactory(() => OrdersProvider(sl(), sl()));
  sl.registerFactory(() => CreateOrderProvider(sl(), sl()));
  // ---------------------------
  // Kasir / Kitchen / Waiters
  // ---------------------------
  sl.registerFactory(() => KasirProvider(sl(), sl(), sl(), sl(), sl()));
  sl.registerFactory(() => KitchenProvider(sl(), sl(), sl()));
  sl.registerLazySingleton(() => WaiterProvider(sl(), sl(), sl(), sl()));
  // ---------------------------

  // Register Stock Datasource, Repository, UseCases, Provider
  sl.registerLazySingleton(() => StockRemoteDataSource());
  sl.registerLazySingleton<StockRepository>(
    () => StockRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton(() => GetStockItems(sl()));
  sl.registerLazySingleton(() => CreateStockItem(sl()));
  sl.registerLazySingleton(() => UpdateStockItem(sl()));
  sl.registerLazySingleton(() => DeleteStockItem(sl()));
  sl.registerFactory(() => StockProvider(sl(), sl(), sl(), sl()));

  // Register Unit UseCases and Provider
  sl.registerLazySingleton(() => GetUnits(sl()));
  sl.registerLazySingleton(() => CreateUnit(sl()));
  sl.registerFactory(() => UnitProvider(sl(), sl()));

  // Register Category UseCases and Provider
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => CreateCategory(sl()));
  sl.registerFactory(() => CategoryProvider(sl(), sl()));

  // Notifications (SSE realtime order)
  // ---------------------------
  sl.registerLazySingleton<SseClient>(
    () => SseClient(baseUrl: EnviServices.baseUrl),
  );
  sl.registerLazySingleton<OrderStreamRemoteDataSource>(
    () => OrderStreamRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<OrderStreamRepository>(
    () => OrderStreamRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetTokenUsecase(sl()));
  sl.registerLazySingleton(() => WatchOrderStreamUsecase(sl(), sl()));
  sl.registerFactory(() => OrderStreamProvider(sl(), sl()));
  // ---------------------------
  // Public Customer (Self-Order tanpa login)
  // GET api/menu/:slug + POST api/menu/:slug/order
  // ---------------------------
  sl.registerLazySingleton<PublicMenuRemoteDataSource>(
    () => PublicMenuRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<PublicMenuRepository>(
    () => PublicMenuRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<GetPublicMenuUsecase>(
    () => GetPublicMenuUsecase(sl()),
  );
  sl.registerLazySingleton<CreatePublicOrderUsecase>(
    () => CreatePublicOrderUsecase(sl()),
  );
  sl.registerLazySingleton<GetPublicOrderUsecase>(
    () => GetPublicOrderUsecase(sl()),
  );
  sl.registerLazySingleton<CancelPublicOrderUsecase>(
    () => CancelPublicOrderUsecase(sl()),
  );
  sl.registerLazySingleton<PublicMenuProvider>(
    () => PublicMenuProvider(sl(), sl(), sl(), sl()),
  );
  // ---------------------------

  // ------------ datasource ---------------
  sl.registerLazySingleton<PromoRemoteDataSource>(
    () => PromoRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<MemberRemoteDataSource>(
    () => MemberRemoteDataSourceImpl(),
  );
  // ------------ repository ---------------
  sl.registerLazySingleton<PromoRepository>(() => PromoRepositoryImpl(sl()));
  sl.registerLazySingleton<MemberRepository>(() => MemberRepositoryImpl(sl()));

  // ------------ usecase ---------------
  sl.registerLazySingleton<GetPromosUsecase>(() => GetPromosUsecase(sl()));
  sl.registerLazySingleton<CreatePromoUsecase>(() => CreatePromoUsecase(sl()));
  sl.registerLazySingleton<UpdatePromoUsecase>(() => UpdatePromoUsecase(sl()));
  sl.registerLazySingleton<DeletePromoUsecase>(() => DeletePromoUsecase(sl()));
  sl.registerLazySingleton<TogglePromoStatusUsecase>(
    () => TogglePromoStatusUsecase(sl()),
  );
  sl.registerLazySingleton<GetPromoStatsUsecase>(
    () => GetPromoStatsUsecase(sl()),
  );
  sl.registerLazySingleton<ValidatePromoUsecase>(
    () => ValidatePromoUsecase(sl()),
  );
  // ------------ provider ---------------
  sl.registerFactory<PromoProvider>(
    () => PromoProvider(sl(), sl(), sl(), sl(), sl(), sl(), sl()),
  );

  // Member usecases
  sl.registerLazySingleton<GetMembersUsecase>(() => GetMembersUsecase(sl()));
  sl.registerLazySingleton<CreateMemberUsecase>(
    () => CreateMemberUsecase(sl()),
  );
  sl.registerLazySingleton<UpdateMemberUsecase>(
    () => UpdateMemberUsecase(sl()),
  );
  sl.registerLazySingleton<DeleteMemberUsecase>(
    () => DeleteMemberUsecase(sl()),
  );
  sl.registerLazySingleton<ValidateMemberByPhoneUsecase>(
    () => ValidateMemberByPhoneUsecase(sl()),
  );
  // Member provider
  sl.registerFactory<MemberProvider>(
    () => MemberProvider(sl(), sl(), sl(), sl()),
  );
}
