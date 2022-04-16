import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snp_view/view/app_blocking_loading_view.dart';
import 'package:snp_view/view/request_component.dart';

import '../injection.dart';
import '../state/home_page_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<HomePageCubit>(),
      child: const HomePageView(),
    );
  }
}

class HomePageView extends StatelessWidget {
  const HomePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Snp Demonstration', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<HomePageCubit>().reset(),
        ),
      ),
      body: BlocConsumer<HomePageCubit, HomePageState>(
        listener: (context, state) {
          if (state.connectionStatus == ConnectionStatus.failed) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                state.failure!,
                textAlign: TextAlign.center,
              ),
            ));
          }
        },
        builder: (context, state) {
          final isLoading = state.connectionStatus == ConnectionStatus.loading;

          return AppBlockingLoadingView(
            isBlocking: isLoading,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.authenticated
                      ? 'You are authenticated '
                      : state.connected
                          ? 'You are connected!'
                          : 'You are not connected'),
                  const SizedBox(height: 10),
                  InkWell(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                      ),
                      child: const Text('Connect', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    onTap: !isLoading
                        ? () {
                            context.read<HomePageCubit>().connect();
                          }
                        : null,
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                      ),
                      child: const Text('Authenticate',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    onTap: !isLoading
                        ? () {
                            context.read<HomePageCubit>().authenticate();
                          }
                        : null,
                  ),
                  const SizedBox(height: 10),
                  const RequestComponent(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
