import 'package:attendance_practice/core/dependency_injection/di_container.dart';
import 'package:attendance_practice/core/enum/state_status.enum.dart';
import 'package:attendance_practice/features/attendance/domain/class_info_bloc/class_info_bloc.dart';
import 'package:attendance_practice/features/auth/domain/bloc/auth/auth_bloc.dart';
import 'package:attendance_practice/features/attendance/presentation/homepage.dart';
import 'package:attendance_practice/features/auth/presentation/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  late AuthBloc _authBloc;
  final DIContainer diContainer = DIContainer();

  @override
  void initState() {
    super.initState();
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _authBloc.add(AuthAutoLoginEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
        bloc: _authBloc,
        listener: _authListener,
        child: Container(
          color: Colors.transparent,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ));
  }

  void _authListener(BuildContext context, AuthState state) {
    if (state.stateStatus == StateStatus.error ||
        state.authUserModel == null &&
            state.stateStatus == StateStatus.loaded) {
      ///proceed to loginpage
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BlocProvider.value(
                  value: _authBloc,
                  child: const LoginScreen(),
                )),
      );
      return;
    }

    if (state.authUserModel != null &&
        state.stateStatus == StateStatus.loaded) {
      ///proceed to home page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>(
                    create: (BuildContext context) => diContainer.authBloc),
                BlocProvider<ClassInfoBloc>(
                  create: (BuildContext context) => diContainer.classInfoBloc,
                ),
              ],
              child: HomePage(
                authUserModel: state.authUserModel!,
              )),
        ),
      );
      return;
    }
  }
}
