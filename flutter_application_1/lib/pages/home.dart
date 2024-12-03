import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'event_setup.dart';
import 'account.dart';
import 'friends.dart';
import 'event_dashboard.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    Home(),
    EventDashboard(),
    EventPage(),
    FriendPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height; // Get screen height

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top text section
              Center(
                child: Column(
                  children: [
                    Text(
                      'BNDR',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      FirebaseAuth.instance.currentUser?.email ?? 'No email available',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // "Places Near You" section
              Text(
                'Places Near You',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),

              // Horizontal scrolling list of cards
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Card 1
                    buildCard(
                      theme,
                      screenHeight,
                      icon: Icons.liquor,
                      title: 'Fred\'s in Tigerland',
                      description: 'Fred\'s in Tigerland is a lively bar and nightclub near LSU, known for its vibrant nightlife and energetic atmosphere. A favorite among college students and locals, it offers themed nights, live music, and DJ sets, along with a spacious outdoor patio.',
                      imagePath: 'assets/freds.jpg',
                      stars: 5,
                      priceLevel: 2,
                    ),
                    // Card 2
                    buildCard(
                      theme,
                      screenHeight,
                      icon: Icons.music_note_outlined,
                      title: 'Chelsea\'s Live',
                      description: 'Chelsea\'s Live is a premier music venue in Baton Rouge, offering a dynamic space for live performances by local and touring artists and known for its excellent acoustics and intimate setting.',
                      imagePath: 'assets/chelseas.jpg',
                      stars: 4.0,
                      priceLevel: 2,
                    ),
                    // Card 3
                    buildCard(
                      theme,
                      screenHeight,
                      icon: Icons.restaurant,
                      title: 'Raising Canes',
                      description: 'Raising Cane\'s Chicken Fingers is a casual fast-food spot famous for its fresh, hand-battered chicken fingers, crinkle-cut fries, buttery Texas toast, and signature Cane\'s Sauce. ',
                      imagePath: 'assets/canes.png',
                      stars: 5,
                      priceLevel: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget buildCard(
    ThemeData theme,
    double screenHeight, {
    required IconData icon,
    required String title,
    required String description,
    required String imagePath,
    required double stars,
    required int priceLevel,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Card(
        elevation: 3,
        child: SizedBox(
          height: screenHeight - 150,
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top icon and title
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Image placeholder
              Container(
                height: 100, // Smaller image height
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
                width: double.infinity,
              ),
              // Bottom description
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                  ),
                ),
              ),
              // Stars and Price Level
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: Row(
                  children: [
                    // Stars
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < stars.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: theme.colorScheme.primary,
                        );
                      }),
                    ),
                    const Spacer(),
                    // Price Level ($ signs)
                    Row(
                      children: List.generate(4, (index) {
                        return Text(
                          index < priceLevel ? '\$' : '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              // Learn More Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Handle button action
                  },
                  child: Text('Learn More'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  // Widget _logout(BuildContext context) {
  //   return ElevatedButton(
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: const Color(0xff0D6EFD),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(14),
  //       ),
  //       minimumSize: const Size(double.infinity, 60),
  //       elevation: 0,
  //     ),
  //     onPressed: () async {
  //       await AuthService().signout(context: context);
  //     },
  //     child: const Text("Sign Out"),
  //   );
  // }