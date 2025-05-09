import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intouch/features/presentation/cubit/auth/auth_cubit.dart';
import 'package:intouch/features/presentation/cubit/credentail/credential_cubit.dart';
import 'package:intouch/features/presentation/cubit/user/get_single_other_user/get_single_other_user_cubit.dart';
import 'package:intouch/features/presentation/page/credential/sign_in_page.dart';
import 'package:intouch/features/presentation/page/main_screen/main_screen.dart';
import 'features/presentation/cubit/user/get_single_user/get_single_user_cubit.dart';
import 'features/presentation/cubit/user/user_cubit.dart';
import 'on_generate_route.dart';
import 'injection_container.dart' as di;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()..appStarted(context)),
        BlocProvider(create: (_) => di.sl<CredentialCubit>()),
        BlocProvider(create: (_) => di.sl<UserCubit>()),
        BlocProvider(create: (_) => di.sl<GetSingleUserCubit>()),
        BlocProvider(create: (_) => di.sl<GetSingleOtherUserCubit>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        darkTheme: ThemeData.dark(),
        onGenerateRoute: OnGenerateRoute.route,
        initialRoute: "/",
        routes: {
          "/": (context) {
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                if (authState is Authenticated) {
                  // إذا كان المستخدم قد تم التوثيق وكان البريد الإلكتروني مفعل
                  if (FirebaseAuth.instance.currentUser!.emailVerified) {
                    // انتقل مباشرة إلى MainScreen
                    return MainScreen(uid: authState.uid);
                  } else {
                    return SignInPage(); // صفحة التحقق من البريد الإلكتروني
                  }
                } else {
                  // إذا كان المستخدم غير موثق، عرض صفحة تسجيل الدخول
                  return SignInPage();
                }
              },
            );
          }
        },
      ),
    );
  }
}
