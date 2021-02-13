import 'package:flutter/material.dart';

class ContentLoader extends StatefulWidget {
  final Future<dynamic> Function() future;
  final Widget widget;
  final bool allowRefresh;
  ContentLoader(
      {@required this.future, @required this.widget, this.allowRefresh = true});

  @override
  _ContentLoaderState createState() => _ContentLoaderState();
}

class _ContentLoaderState extends State<ContentLoader> {
  Future _future;
  @override
  void initState() {
    _future = widget.future();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingWidget();
        } else {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Ocurrio un error de conexion.",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        _future = widget.future();
                      });
                    },
                    child: Text('Reintentar'),
                  )
                ],
              ),
            );
          } else {
            if (widget.allowRefresh) {
              return RefreshIndicator(
                child: widget.widget,
                onRefresh: () {
                  setState(
                    () {
                      _future = widget.future();
                    },
                  );
                  return _future;
                },
              );
            } else {
              return widget.widget;
            }
          }
        }
      },
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
