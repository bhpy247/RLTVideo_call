import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:videocall/backend/user_list/user_list_controller.dart';
import 'package:videocall/backend/user_list/user_list_provider.dart';

import '../../models/user_model/user_list_model.dart';
import '../authentication/screens/login_screen.dart';
import '../video_call/video_call_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late UserListController userListController;
  late UserListProvider userListProvider;

  @override
  void initState() {
    super.initState();
    userListProvider = UserListProvider();
    userListController = UserListController(userListProvider: userListProvider);

    // Fetch users on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userListController.fetchUsers();
    });
  }

  Future<void> _logout() async {
    bool? isSuccess = await showCupertinoDialog(
      context: context,
      builder: (BuildContext) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: Text("Yes"),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              icon: Text("No"),
            ),
          ],
        );
      },
    );
    if (isSuccess == null) return;
    if (isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
      );
    }
  }

  Future<void> _refreshUsers() async {
    await userListController.refreshUsers();
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserListProvider>.value(
      value: userListProvider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Users'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshUsers,
              tooltip: 'Refresh',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: Consumer<UserListProvider>(
          builder: (context, provider, child) {
            final isLoading = provider.isLoading.get();
            final errorMessage = provider.errorMessage.get();
            final userList = provider.userList.get();

            // Loading state
            if (isLoading && userList.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state with cached data info
            if (errorMessage.isNotEmpty && userList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _logout,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Success state with user list
            return Column(
              children: [
                // Show offline mode banner if applicable
                if (errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.orange.shade100,
                    child: Row(
                      children: [
                        Icon(Icons.cloud_off, color: Colors.orange.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // User list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _logout,
                    child: ListView.builder(
                      itemCount: userList.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        final user = userList[index];
                        return _buildUserListItem(user);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserListItem(UserListModel user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey.shade300,
          child: user.avatar.isNotEmpty
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: user.avatar,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              : Icon(Icons.person, size: 30, color: Colors.grey.shade600),
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${user.id}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.videocam, color: Colors.blue),
          onPressed: () {
            // Navigate to video call with this user
            _startVideoCallWithUser(user);
          },
          tooltip: 'Start video call',
        ),
      ),
    );
  }

  void _startVideoCallWithUser(UserListModel user) {
    // Generate a unique channel name
    final channelName = 'channel_${user.id}';
    final TextEditingController channelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Join Channel(Channel name should be the same for another user to join)'),
        content: TextField(
          controller: channelController,
          decoration: InputDecoration(
            labelText: 'Channel Name',
            hintText: 'e.g., channel_123',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToVideoCall(
                channelController.text.trim(),
                'Guest',
                user.id,
              );
            },
            child: Text('Join'),
          ),
        ],
      ),
    );
    // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: const Text('Start Video Call'),
    //     content: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text('Start a video call with ${user.fullName}?'),
    //         const SizedBox(height: 16),
    //         Container(
    //           padding: const EdgeInsets.all(12),
    //           decoration: BoxDecoration(
    //             color: Colors.grey.shade100,
    //             borderRadius: BorderRadius.circular(8),
    //           ),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text(
    //                 'Channel Name:',
    //                 style: TextStyle(
    //                   fontSize: 12,
    //                   color: Colors.grey.shade600,
    //                   fontWeight: FontWeight.bold,
    //                 ),
    //               ),
    //               const SizedBox(height: 4),
    //               Text(
    //                 channelName,
    //                 style: const TextStyle(
    //                   fontSize: 12,
    //                   fontFamily: 'monospace',
    //                 ),
    //               ),
    //               const SizedBox(height: 12),
    //               Text(
    //                 'Share this channel name with ${user.firstName} to connect!',
    //                 style: TextStyle(
    //                   fontSize: 11,
    //                   color: Colors.grey.shade600,
    //                   fontStyle: FontStyle.italic,
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(context),
    //         child: const Text('Cancel'),
    //       ),
    //       ElevatedButton(
    //         onPressed: () {
    //           Navigator.pop(context);
    //           _navigateToVideoCall(channelName, user.fullName);
    //         },
    //         child: const Text('Start Call'),
    //       ),
    //     ],
    //   ),
    // );
  }

  void _navigateToVideoCall(String channelName, String userName, int useriD) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(
          channelName: channelName,
          userName: userName,
          uid: useriD, // Agora will auto-assign if 0
        ),
      ),
    );
  }
}
