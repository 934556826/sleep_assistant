import 'package:flutter/material.dart';

class TermsOfUserPage extends StatefulWidget {
  const TermsOfUserPage({super.key});

  @override
  State<TermsOfUserPage> createState() => _TermsOfUserPageState();
}

class _TermsOfUserPageState extends State<TermsOfUserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('利用規約'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: buildForm(context),
      ),
    );
  }

  Widget buildForm(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'スマートフォン用アプリご利用規約',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.blue),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 8),
              child: Text(
                '第1条　本サービスの内容',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ),
            Text(
                '本サービスとは、つくばイノベーションキャピタル株式会社（以下「当社」という。）所定のスマートフォン用アプリケーション（以下「本アプリ」という。）を用いてご利用いただく、当社が提供するサービスをいいます。'),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 8),
              child: Text(
                '第2条　規約への同意',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ),
            Text('お客さまは、本規約に同意のうえ、本アプリのダウンロードおよび使用、ならびに本サービスの利用を行うものとします。'),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 8),
              child: Text(
                '第3条　権利の帰属等',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ),
            Text('1. 本アプリの著作権その他本アプリに関する一切の権利は、当社または当社が許諾を受ける権利者に帰属します。'),
            Text(
                '2. お客さまは、当社指定の用途に限り、本アプリを使用できるものとします。なお、当社から請求があった場合、お客さまは、すみやかに本アプリの使用を中止し、または本アプリをお客さまのスマートフォンから削除するものとします。'),
            Text(
                '3. お客さまは、本アプリ、および本サービスにおいてお客さまのスマートフォンにダウンロードされた情報の転載・複製・転送・改変またはリバースエンジニアリング等を自ら行ってはならないものとし、また、第三者に当該行為を行わせてはならないものとします。'),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 8),
              child: Text(
                '第4条　本サービスまたは本アプリ提供の休止、変更等',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ),
            Text(
                '当社は、お客さまの承諾およびお客さまへの通知なしに、いつでも本サービスまたは本アプリ提供の一時休止または終了、本サービスの内容変更および本アプリの改変等を行うことができるものとします。'),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 8),
              child: Text(
                '第5条　免責事項等',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ),
            Text(
                '1.	本アプリの瑕疵、本アプリの動作に係る不具合（表示情報の誤謬・逸脱を含みます。）、本サービスまたは本アプリがスマートフォンに与える影響およびお客さまが本サービスまたは本アプリを正常に利用できないことにより被る不利益、データ消失の不利益、その他一切の不利益について、当社は一切その責任を負いません。'),
            Text(
                '2.	前項のほか、次の各号に定める場合における本サービスまたは本アプリの利用不能、ならびにこれによって生じた損害について、当社は、一切の責任を負いません。'),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('①	天災地変、裁判所等の公的機関の措置等のやむをえない事由が生じた場合'),
                  Text('②	通信回線またはシステム等に障害が生じた場合'),
                  Text('③	指紋認証やパスコード認証等が不正に実行された場合'),
                  Text('④	当社以外の第三者の責に帰すべき事由による場合'),
                ],
              ),
            ),
            Text(
                '3. お客さまが本アプリを使用して情報のアップロード、ダウンロードその他の授受を行った場合、お客さまは、当該情報の授受を電磁的方法により行うことを当社に対して同意したものとします。'),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 8),
              child: Text(
                '第6条　利用環境の整備等',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ),
            Text(
                '1.	お客さまは、本サービスの利用および本アプリの使用（本アプリのダウンロードを含みます。）に必要となる通信機器、ソフトウェア、通信回線その他の環境を、お客さまの責任と負担において準備するものとします。なお、必要な利用環境については、当社所定のインターネットホームページに掲載します。'),
            Text(
                '2.	本サービスの利用または本アプリの使用（本アプリのダウンロードを含みます。）に伴い発生する通信料は、お客さまの負担とします。'),
            Text(
                '3.	お客さまは、当社または関係官庁等が提供する情報を参考にして、自己の利用環境に応じ、コンピューター・ウイルスの感染、不正アクセスおよび情報漏洩の防止等の適切な情報セキュリティを保持するものとします。'),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 8),
              child: Text(
                '第7条　規約の変更',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ),
            Text(
                '1.	本規約の各条項その他の条件は、社会情勢その他状況の変化等相応の事由があると認められる場合には、民法548条の4の規定に基づき、変更するものとします。'),
            Text(
                '2.	前項の変更は、変更を行う旨、変更後の規定の内容、その効力発生時期を、インターネット、またはその他相当の方法で公表することにより周知します。'),
            Text(
                '3.	前二項の変更は、公表の際に定める適用開始日から適用されるものとし、公表の日から適用開始日までは変更の内容に応じて相当の期間をおくものとします。'),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 10, 15),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text('以上'),
              ),
            )
          ],
        ));
  }
}
