import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snp_view/state/request_componet_cubit.dart';

import '../injection.dart';
import 'response_viewer_page.dart';

class RequestComponent extends StatelessWidget {
  const RequestComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<RequestComponentCubit>(),
      child: const RequestComponentView(),
    );
  }
}

class RequestComponentView extends StatefulWidget {
  const RequestComponentView({Key? key}) : super(key: key);

  @override
  State<RequestComponentView> createState() => _RequestComponentState();
}

class _RequestComponentState extends State<RequestComponentView> {
  final TextEditingController _methodController = TextEditingController();
  final TextEditingController _pathController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RequestComponentCubit, RequestComponentState>(listener: ((context, state) {
      if (state.content != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ResponseViewerPage(data: state.content!)));
      }
    }), builder: ((context, state) {
      if (state.content != null) {}
      if (state.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          children: [
            Column(
              children: [
                const SizedBox(height: 10),
                TextField(
                  controller: _methodController,
                  decoration: const InputDecoration(
                    fillColor: Color(0xFFF3F3F3),
                    focusColor: Color(0xFFF3F3F3),
                    border: InputBorder.none,
                    hintText: 'Enter your request method',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _pathController,
                  decoration: const InputDecoration(
                    fillColor: Color(0xFFF3F3F3),
                    border: InputBorder.none,
                    hintText: 'Enter your request path',
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: const Text('SEND', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  onTap: () {
                    !state.isLoading
                        ? context.read<RequestComponentCubit>().send(
                              method: _methodController.text,
                              path: _pathController.text,
                            )
                        : null;
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }));
  }
}
