import 'package:get_it/get_it.dart';
import '../database_helper.dart';
import '../../features/transaction/data/transaction_repository_impl.dart';
import '../../features/transaction/data/transaction_repository.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  // Database
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // Transaction repository
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(getIt<DatabaseHelper>()),
  );
}
