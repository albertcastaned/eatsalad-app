import 'dart:async';
import 'dart:io';

import 'package:EatSalad/screens/address_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/profile.dart';
import '../utils/dialog_utils.dart';
import '../widgets/app_body.dart';
import '../widgets/app_card.dart';
import '../widgets/submit_button.dart';

class ProfileConfigScreen extends StatefulWidget {
  static const routeName = '/profile_settings';

  final bool firstTime;
  ProfileConfigScreen({this.firstTime = false});
  @override
  _ProfileConfigScreenState createState() => _ProfileConfigScreenState();
}

class _ProfileConfigScreenState extends State<ProfileConfigScreen> {
  final _formKey = GlobalKey<FormState>();

  final EdgeInsets formFieldMargin = EdgeInsets.symmetric(vertical: 15);

  final TextEditingController nameController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  var _loaded = false;

  void _initControllers(BuildContext context) {
    final profile = Provider.of<MyProfile>(context, listen: false).myProfile;
    if (profile == null) return;
    nameController.text =
        (profile.firstName == null) ? "" : "${profile.firstName}";

    lastNameController.text =
        (profile.lastName == null) ? "" : "${profile.lastName}";

    emailController.text = (profile.email == null) ? "" : "${profile.email}";

    phoneController.text =
        (profile.phoneNumber == null) ? "" : "${profile.phoneNumber}";
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      _initControllers(context);
      _loaded = true;
    }

    Future<void> submitProfile() async {
      final loadingDialog =
          buildLoadingDialog(context, 'Actualizando perfil...');
      await loadingDialog.show();
      try {
        final response =
            await Provider.of<MyProfile>(context, listen: false).update(
          profile: Profile(
            firstName: nameController.text,
            lastName: lastNameController.text,
            email: emailController.text,
            phoneNumber: phoneController.text,
            firstTime: false,
          ),
        );
        await loadingDialog.hide();
        print(response);
        await showSuccesfulDialog(
          context,
          widget.firstTime
              ? 'Se ha creado tu perfil exitosamente'
              : 'Se ha actualizado el perfil exitosamente',
        );

        if (widget.firstTime) {
          Navigator.of(context).popAndPushNamed(
            AddressSetupScreen.routeName,
            arguments: {
              'firstTime': true,
            },
          );
        } else {
          Navigator.of(context).pop();
        }
      } on HttpException catch (error) {
        print(error.message);
        await loadingDialog.hide();
        buildFlashBar(context, error.message);
      } on TimeoutException catch (error) {
        print(error.message);
        await loadingDialog.hide();
        buildFlashBar(context, Errors.timeout);
      } catch (error) {
        print(error);
        await loadingDialog.hide();
        buildFlashBar(context, Errors.connectionError);
      }
    }

    return AppBody(
      title: widget.firstTime ? "Bienvenido" : 'Configuracion de perfil',
      child: Container(
        width: double.infinity,
        child: AppCard(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: ListView(
              children: [
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    widget.firstTime ? 'Crear perfil' : 'Cambiar perfil',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: formFieldMargin,
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return Errors.emptyField;
                            }
                            return null;
                          },
                          controller: nameController,
                          decoration: const InputDecoration(
                              icon: Icon(
                                Icons.person,
                              ),
                              hintText: 'Juan',
                              labelText: 'Nombre(s) *'),
                        ),
                      ),
                      Container(
                        margin: formFieldMargin,
                        child: TextFormField(
                          controller: lastNameController,
                          decoration: const InputDecoration(
                              icon: Icon(
                                Icons.person,
                              ),
                              hintText: 'Perez',
                              labelText: 'Apellido(s) *'),
                        ),
                      ),
                      Container(
                        margin: formFieldMargin,
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return Errors.emptyField;
                            }
                            if (!RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value)) {
                              return Errors.invalidEmail;
                            }
                            return null;
                          },
                          controller: emailController,
                          decoration: const InputDecoration(
                              icon: Icon(
                                Icons.email,
                              ),
                              hintText: 'miguel@gmail.com',
                              labelText: 'Correo Electronico *'),
                        ),
                      ),
                      Container(
                        margin: formFieldMargin,
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return Errors.emptyField;
                            }
                            if (!RegExp(
                                    r"^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$")
                                .hasMatch(value)) {
                              return Errors.invalidPhone;
                            }
                            return null;
                          },
                          keyboardType: TextInputType.phone,
                          controller: phoneController,
                          decoration: const InputDecoration(
                              icon: Icon(
                                Icons.phone,
                              ),
                              hintText: '442 125 2020',
                              labelText: 'Telefono *'),
                        ),
                      ),
                      SubmitButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            submitProfile();
                          }
                        },
                        text: widget.firstTime
                            ? 'Crear perfil'
                            : 'Actualizar perfil',
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
