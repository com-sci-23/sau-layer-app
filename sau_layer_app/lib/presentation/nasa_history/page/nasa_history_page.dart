import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sau_layer_app/presentation/model/nasa_history_model.dart';
import 'package:sau_layer_app/presentation/nasa_history/bloc/nasa_history_bloc.dart';
import 'package:sau_layer_app/presentation/nasa_history/page/nasa_detail_page.dart';
import 'package:sau_layer_app/utils/AppColors.dart';
import 'package:google_fonts/google_fonts.dart';

class NasaHistoryPage extends StatefulWidget {
  const NasaHistoryPage({super.key});

  @override
  _NasaHistoryPageState createState() => _NasaHistoryPageState();
}

class _NasaHistoryPageState extends State<NasaHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<NasaHistoryBloc>().add(const NasaHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gradientStartColor, AppColors.gradientEndColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 100,
              floating: false,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "NASA Space Gallery",
                  style: GoogleFonts.poppins(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                centerTitle: true,
              ),
            ),
            SliverFillRemaining(
              child: BlocBuilder<NasaHistoryBloc, NasaHistoryState>(
                builder: (context, state) {
                  if (state is NasaHistoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is NasaHistoryError) {
                    return Center(child: Text("Error: ${state.message}"));
                  } else if (state is NasaHistoryHasData) {
                    final data = state.model.items; // Access the list property
                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return _buildImageCard(data[index]);
                      },
                    );
                  } else {
                    return const Center(child: Text("No data available"));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(NasaHistoryModel item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NasaDetailPage(
              nasaHistoryModel: item,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        AppColors.imageGradientStartColor,
                        AppColors.imageGradientEndColor
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcOver,
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                          child: child,
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.cardGradientStartColor,
                        AppColors.cardGradientEndColor
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Text(
                    item.title,
                    style: GoogleFonts.roboto(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
