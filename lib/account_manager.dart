import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'main.dart';
import 'store.dart';
import 'backup.dart';
import 'generated/l10n.dart';

import 'about.dart';

class AccountManagerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AccountManagerState();
}

class AccountManagerState extends State<AccountManagerPage> {
  var _accountNameController = TextEditingController();

  @override
  initState() {
    super.initState();
    Future.microtask(() async {
      await accounts.refresh();
      await accounts.updateTBalance();
    });
    showAboutOnce(this.context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).selectAccount), actions: [
          PopupMenuButton<String>(
              itemBuilder: (context) => [
                    PopupMenuItem(
                        child: Text(S.of(context).settings), value: "Settings"),
                    PopupMenuItem(
                        child: Text(S.of(context).about), value: "About"),
                  ],
              onSelected: _onMenu)
        ]),
        body: Padding(padding: EdgeInsets.all(8), child: Observer(
            builder: (context) {
              final _1 = accounts.epoch;
              return accounts.list.isEmpty
                  ? Center(child: NoAccount())
                  : ListView.builder(
                      itemCount: accounts.list.length,
                      itemBuilder: (BuildContext context, int index) {
                      final a = accounts.list[index];
                      final weight = settings.coins[a.coin].active == a.id ? FontWeight.bold : FontWeight.normal;
                      final zbal = a.balance / ZECUNIT;
                      final tbal = a.tbalance / ZECUNIT;
                      final balance = zbal + tbal;
                      return Card(
                          child: Dismissible(
                        key: Key(a.name),
                        child: ListTile(
                          title: Text(a.name,
                              style: theme.textTheme.headline5
                                ?.merge(TextStyle(fontWeight: weight))
                                .apply(color: a.coin == 0 ? theme.colorScheme.primary : theme.colorScheme.secondary,
                              )),
                          subtitle: Text("${decimalFormat(zbal, 3)} + ${decimalFormat(tbal, 3)}"),
                          trailing: Text(decimalFormat(balance, 3)),
                          onTap: () {
                            _selectAccount(a);
                          },
                          onLongPress: () {
                            _editAccount(a);
                          },
                        ),
                        confirmDismiss: (d) => _onAccountDelete(a),
                        onDismissed: (d) =>
                            _onDismissed(index, a),
                      ));
                    });},
                )),
        floatingActionButton: GestureDetector(onLongPress: _onFullRestore, child: FloatingActionButton(
            onPressed: _onRestore, child: Icon(Icons.add))));
  }

  Future<bool> _onAccountDelete(Account account) async {
    final confirm1 = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
          title: Text(S.of(context).deleteAccount),
          content: Text(S.of(context).confirmDeleteAccount),
          actions: confirmButtons(context, () {
            Navigator.of(context).pop(true);
          }, okLabel: S.of(context).delete, cancelValue: false)),
    );
    final confirm2 = confirm1 ?? false;
    if (!confirm2) return false;

    final zbal = account.balance;
    final tbal = account.tbalance;
    if (zbal + tbal > 0) {
      final confirm3 = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
            title: Text(S.of(context).deleteAccount),
            content: Text(S.of(context).accountHasSomeBalanceAreYouSureYouWantTo),
            actions: confirmButtons(context, () {
              Navigator.of(context).pop(true);
            }, okLabel: S.of(context).delete, cancelValue: false)),
      );
      return confirm3 ?? false;
    }
    return true;
  }

  void _onDismissed(int index, Account account) async {
    await accounts.delete(account.coin, account.id);
    accounts.refresh();
  }

  _selectAccount(Account account) async {
    await active.setActiveAccount(account.coin, account.id);
    if (syncStatus.accountRestored) {
      syncStatus.setAccountRestored(false);
      final approved = await rescanDialog(context);
      if (approved)
        syncStatus.rescan(context);
    }

    final navigator = Navigator.of(context);
    navigator.pushNamedAndRemoveUntil('/account', (route) => false);
  }

  _editAccount(Account account) async {
    _accountNameController.text = account.name;
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: Text(S.of(context).changeAccountName),
            content: TextField(controller: _accountNameController),
            actions: confirmButtons(context, () { _changeAccountName(account); })));
  }

  _changeAccountName(Account account) {
    accounts.changeAccountName(account.coin, account.id, _accountNameController.text);
    Navigator.of(context).pop();
  }

  _onRestore() {
    Navigator.of(context).pushNamed('/restore');
  }

  _onMenu(String choice) {
    switch (choice) {
      case "Settings":
        _settings();
        break;
      case "About":
        showAbout(this.context);
        break;
    }
  }

  _settings() {
    Navigator.of(this.context).pushNamed('/settings');
  }

  _onFullRestore() {
    Navigator.of(this.context).pushNamed('/fullRestore');
  }
}

class NoAccount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Widget wallet = SvgPicture.asset('assets/wallet.svg',
        color: Theme.of(context).primaryColor, semanticsLabel: 'Wallet');

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(child: wallet, height: 150, width: 150),
      Padding(padding: EdgeInsets.symmetric(vertical: 16)),
      Text(S.of(context).noAccount,
          style: Theme.of(context).textTheme.headline5),
      Padding(padding: EdgeInsets.symmetric(vertical: 8)),
      Text(S.of(context).createANewAccount,
          style: Theme.of(context).textTheme.bodyText1),
    ]);
  }
}
