import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/data/sliderdata.dart';
import '../../data/model/slidermodel.dart';
import '../../conf/const.dart';

class SliderWidget extends StatefulWidget {
  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  PageController _pageController = PageController();
  Timer? _timer;
  List<SliderModel> sliders = [];
  bool isLoading = true;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    loadSliders();
  }

  Future<void> loadSliders() async {
    try {
      SliderData sliderData = SliderData();
      sliders = await sliderData.loadData();
      setState(() {
        isLoading = false;
      });
      startAutoScroll();
    } catch (e) {
      print('Error loading sliders: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void startAutoScroll() {
    if (sliders.isEmpty) return;
    
    _timer = Timer.periodic(Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients) {
        setState(() {
          currentPage = (currentPage + 1) % sliders.length;
        });
        
        _pageController.animateToPage(
          currentPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget buildSliderItem(SliderModel slider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          '$uri_slider_img${slider.image}',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[300],
              child: Icon(
                Icons.image,
                size: 60,
                color: Colors.grey[600],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        sliders.length,
        (index) => Container(
          width: currentPage == index ? 12 : 8,
          height: 8,
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: currentPage == index 
                ? Colors.brown[600] 
                : Colors.grey[400],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (sliders.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Text('Không có slider nào'),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Slider chính
          Container(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemCount: sliders.length,
              itemBuilder: (context, index) {
                return buildSliderItem(sliders[index]);
              },
            ),
          ),
          SizedBox(height: 16),
          // Chỉ báo trang (dots)
          buildPageIndicator(),
        ],
      ),
    );
  }
}