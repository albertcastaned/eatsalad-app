import 'package:EatSalad/providers/address.dart';
import 'package:EatSalad/providers/auth.dart';
import 'package:EatSalad/providers/profile.dart';
import 'package:EatSalad/screens/address_setup_screen.dart';
import 'package:EatSalad/screens/profile_setup_screen.dart';
import 'package:EatSalad/widgets/app_card.dart';
import 'package:EatSalad/widgets/content_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  Future<void> logOut(BuildContext context) async {
    await Provider.of<Auth>(context, listen: false).logout();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContentLoader(
              future: Provider.of<MyProfile>(context, listen: false).fetch,
              widget: Consumer<MyProfile>(
                builder: (ctx, profile, _) => UserProfileInfo(
                  profile:
                      Provider.of<MyProfile>(context, listen: false).myProfile,
                ),
              ),
            ),
            SizedBox(
              height: 100,
            ),
            ContentLoader(
              future: Provider.of<SelectedAddress>(context, listen: false)
                  .fetchSelectedAddress,
              widget: Consumer<SelectedAddress>(
                builder: (ctx, address, _) => AddressInfo(
                  address: address.selectedAddress.direction,
                ),
              ),
            ),
            Spacer(),
            Align(
              alignment: Alignment.center,
              child: RaisedButton(
                child: Text('Cerrar sesion'),
                onPressed: () => logOut(context),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AddressInfo extends StatelessWidget {
  final String address;
  AddressInfo({this.address});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text(
                  "Mi Direccion",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.yellow,
                child: IconButton(
                  color: Colors.black,
                  icon: Icon(
                    Icons.edit,
                  ),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(AddressSetupScreen.routeName),
                ),
              ),
            ],
          ),
          Divider(),
          Text(
            address,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class UserProfileInfo extends StatelessWidget {
  final Profile profile;
  UserProfileInfo({this.profile});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text(
                  "Mi Perfil",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.yellow,
                child: IconButton(
                  color: Colors.black,
                  icon: Icon(
                    Icons.edit,
                  ),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(ProfileConfigScreen.routeName),
                ),
              ),
            ],
          ),
          Divider(),
          Text(
            "${profile.firstName} ${profile.lastName}",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          Divider(),
          Text(
            "${profile.phoneNumber}",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          Divider(),
          Text(
            "${profile.email}",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
