import 'package:get_it/get_it.dart';
import 'package:messaging_ui/core/core_service.dart';

/// Service locator
final getIt = GetIt.instance;

Future<void> init() async {
  getIt.registerLazySingleton(() => CoreService());

  // getIt.registerLazySingleton(() => CallDS(firebaseFunctions: FirebaseFunctions.instance));
  // getIt.registerLazySingleton(() => TypingDS(firestore: FirebaseFirestore.instance, authService: getIt.get<AuthService>()));
  // getIt.registerLazySingleton(() => GroupsDS(firestore: FirebaseFirestore.instance, authService: getIt.get<AuthService>()));
  // getIt.registerLazySingleton(() => NotificationsService(usersDs: getIt.get<UsersDS>(), messaging: FirebaseMessaging.instance, onMessage: FirebaseMessaging.onMessage, onMessageOpenedApp: FirebaseMessaging.onMessageOpenedApp,));
  // getIt.registerLazySingleton(() => UsersDS(authDS: getIt.get<AuthDS>()));
  // getIt.registerLazySingleton(() => AuthDS(firebaseAuth: FirebaseAuth.instance));
  // getIt.registerLazySingleton(() => MessagesDS(authService: getIt.get<AuthService>(), firestore: FirebaseFirestore.instance, typingDs: getIt.get<TypingDS>()));

  // getIt.registerLazySingleton(() => CallService(callDS: getIt.get<CallDS>()));
  // getIt.registerLazySingleton(() => GroupsService(groupsDS: getIt.get<GroupsDS>(), authService: getIt.get<AuthService>()));
  // getIt.registerLazySingleton(() => MessagesService(usersService: getIt.get<UsersService>(), authService: getIt.get<AuthService>(), messagesDatasource: getIt.get<MessagesDS>()));
  // getIt.registerLazySingleton(() => UsersService(usersRemoteDataSource: getIt.get<UsersDS>(),));
  // getIt.registerLazySingleton(() => AuthService(authDS: getIt.get<AuthDS>(), notificationsController: getIt.get<NotificationsService>(), usersDS: getIt.get<UsersDS>(),));
}
