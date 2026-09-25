import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:booking_appointments/core/cache/shared_preferences_helper.dart';
import 'package:booking_appointments/core/cache/shared_preferences_service.dart';
import 'package:booking_appointments/core/services/settings_cubit.dart';
import 'package:booking_appointments/data/repositories/booking_repository.dart';
import 'package:booking_appointments/data/repositories/booking_repository_impl.dart';
import 'package:booking_appointments/domain/services/booking_validator.dart';
import 'package:booking_appointments/presentation/cubit/booking_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  //! ========= External =========
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  //! ========= Core Storage Helpers =========
  getIt.registerLazySingleton<SharedPreferencesHelper>(
    () => SharedPreferencesHelper(getIt()),
  );

  //! ========= Core Services =========
  getIt.registerLazySingleton<SharedPreferencesService>(
    () => SharedPreferencesService(getIt()),
  );

  //! ========= Services =========
  getIt.registerLazySingleton<SettingsCubit>(
    () => SettingsCubit(getIt()),
  );

  //! ========= Booking =========
  getIt.registerLazySingleton<BookingRepository>(BookingRepositoryImpl.new);
  getIt.registerLazySingleton<BookingValidator>(BookingValidator.new);
  getIt.registerFactory<BookingCubit>(
    () => BookingCubit(repository: getIt(), validator: getIt()),
  );
}

