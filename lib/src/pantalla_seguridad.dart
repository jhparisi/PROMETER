import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'menu.dart';

const String politica="La aceptación de las presentes condiciones generales de materia de política de privacidad y protección de datos personales supone para el usuario su conformidad y consentimiento expreso al tratamiento de los datos facilitados a EZSA SANIDAD AMBIENTAL S.L. a través del portal www.ezsa.es.";

const String identificativo ="La empresa titular de dominio web es Ezsa Sanidad Ambiental S.L. (en adelante “EZSA”), con domicilio a estos efectos en Calle Azorín, 10, 09005 (Burgos) número de C.I.F.: B09321928 y con correo electrónico de contacto: ezsa@ezsa.es del sitio web.\nUSUARIOS: El acceso y/o uso de este portal de EZSA atribuye la condición de USUARIO, que acepta, desde dicho acceso y/o uso, la Condiciones Legales aquí reflejadas. Las citadas Condiciones serán de aplicación independientemente de las Condiciones Generales de Uso que en su caso resulten de obligado cumplimiento.\nUSO DEL PORTAL:  www.ezsa.es proporciona el acceso a multitud de informaciones, servicios, programas o datos (en adelante, «los contenidos») en Internet.  El USUARIO asume la responsabilidad del uso del portal. Dicha responsabilidad se extiende al registro que fuese necesario para acceder a determinados servicios o contenidos. En dicho registro el USUARIO será responsable de aportar información veraz y lícita. Como consecuencia de este registro, al USUARIO se le puede proporcionar una contraseña de la que será responsable, comprometiéndose a hacer un uso diligente y confidencial de la misma.\nEl USUARIO se compromete a hacer un uso adecuado de los contenidos y servicios (como por ejemplo servicios de chat, foros de discusión o grupos de noticias) que Nombre de la empresa creadora del sitio web ofrece a través de su portal y con carácter enunciativo pero no limitativo, a no emplearlos para (i) incurrir en actividades ilícitas, ilegales o contrarias a la buena fe y al orden público; (ii) difundir contenidos o propaganda de carácter racista, xenófobo, pornográfico-ilegal, de apología del terrorismo o atentatorio contra los derechos humanos; (iii) provocar daños en los sistemas físicos y lógicos de Avanzadi Digital Solutions S.L., de sus proveedores o de terceras personas, introducir o difundir en la red virus informáticos o cualesquiera otros sistemas físicos o lógicos que sean susceptibles de provocar los daños anteriormente mencionados; (iv) intentar acceder y, en su caso, utilizar las cuentas de correo electrónico de otros usuarios y modificar o manipular sus mensajes. EZSA se reserva el derecho de retirar todos aquellos comentarios y aportaciones que vulneren el respeto a la dignidad de la persona, que sean discriminatorios, xenófobos, racistas, pornográficos, que atenten contra la juventud o la infancia, el orden o la seguridad pública o que, a su juicio, no resultaran adecuados para su publicación. En cualquier caso, EZSA no será responsable de las opiniones vertidas por los usuarios a través de los foros, chats, u otras herramientas de participación.";

const String proteccion="EZSA cumple con las directrices de la Ley Orgánica 15/1999 de 13 de diciembre de Protección de Datos de Carácter Personal, el Real Decreto 1720/2007 de 21 de diciembre por el que se aprueba el Reglamento de desarrollo de la Ley Orgánica y demás normativa vigente en cada momento, y vela por garantizar un correcto uso y tratamiento de los datos personales del usuario también informando a todos los usuarios del sitio web que faciliten o vayan a facilitar sus datos personales, que estos serán incorporados en un fichero automatizado de tratamiento de Datos Personales. La finalidad de dicho fichero será la recogida de Datos de Carácter Personal únicamente a modo de gestión y administración para el desarrollo propio del funcionamiento del negocio.\nPara ello, junto a cada formulario de recabo de datos de carácter personal, en los servicios que el usuario pueda solicitar a EZSA hará saber al usuario de la existencia y aceptación de las condiciones particulares del tratamiento de sus datos en cada caso, informándole de la responsabilidad del fichero creado, la dirección del responsable, la posibilidad de ejercer sus derechos de acceso, rectificación, cancelación u oposición, la finalidad del tratamiento y las comunicaciones de datos a terceros en su caso.\nA través del registro en www.ezsa.es el Usuario proporciona a EZSA SANIDAD AMBIENTAL S.L. los siguientes datos de carácter personal como pueden ser Nombre completo y apellidos; Dirección de correo electrónico y teléfonos de contacto.";

const String derechos ="EZSA garantiza en todo caso al usuario el ejercicio de los derechos de acceso, rectificación, cancelación, información y oposición, en los términos dispuestos en la legislación vigente. Por ello, de conformidad con lo dispuesto en la Ley Orgánica 15/1999, de Protección de Datos de Carácter Personal (LOPD) podrá ejercer sus derechos remitiendo una solicitud expresa, junto a una copia de su DNI, a través de ezsa@ezsa.es";

const String comunicaciones= "El usuario acepta que EZSA puede comunicar, en su caso, los Datos Personales al resto de Sociedades del Grupo cualquiera que sea su domicilio con las mismas finalidades que se han indicado en el párrafo anterior. En todo caso, EZSA garantiza el mantenimiento de la confidencialidad y el tratamiento seguro de los Datos Personales en estos movimientos internacionales. El uso de los Datos Personales por las sociedades extranjeras del grupo se circunscribirá a los fines contenidos en este documento.\nEn ningún momento se comunicarán Datos de Carácter Personal a otras Entidades o Mercantiles ajenas a las establecidas en el párrafo anterior.";

const String consentimiento ="Mediante la aceptación a estas Condiciones Legales, se expresa el consentimiento para que los Datos Personales sean incorporados al Fichero de Datos Personales y sean objeto de tratamiento automatizado por EZSA según lo indicado anteriormente. Asimismo, expresa la aceptación y autorización para que EZSA pueda ceder los Datos Personales como se mostraba en el punto anterior.";

const String propiedad="EZSA por sí o como cesionaria, es titular de todos los derechos de propiedad intelectual e industrial de su página web, así como de los elementos contenidos en la misma (a título enunciativo, imágenes, sonido, audio, vídeo, software o textos; marcas o logotipos, combinaciones de colores, estructura y diseño, selección de materiales usados, programas de ordenador necesarios para su funcionamiento, acceso y uso, etc.), titularidad de Nombre de la empresa creadora del sitio web o bien de sus licenciantes. Todos los derechos reservados. En virtud de lo dispuesto en los artículos 8 y 32.1, párrafo segundo, de la Ley de Propiedad Intelectual, quedan expresamente prohibidas la reproducción, la distribución y la comunicación pública, incluida su modalidad de puesta a disposición, de la totalidad o parte de los contenidos de esta página web, con fines comerciales, en cualquier soporte y por cualquier medio técnico, sin la autorización de EZSA. El USUARIO se compromete a respetar los derechos de Propiedad Intelectual e Industrial titularidad de EZSA. Podrá visualizar los elementos del portal e incluso imprimirlos, copiarlos y almacenarlos en el disco duro de su ordenador o en cualquier otro soporte físico siempre y cuando sea, única y exclusivamente, para su uso personal y privado. El USUARIO deberá abstenerse de suprimir, alterar, eludir o manipular cualquier dispositivo de protección o sistema de seguridad que estuviera instalado en el las páginas de Avanzadi Digital Solutions S.L.";

const String exclusion ="Avanzadi Digital Solutions S.L. no se hace responsable, en ningún caso, de los daños y perjuicios de cualquier naturaleza que pudieran ocasionar, a título enunciativo: falta de disponibilidad del portal o la transmisión de virus o programas maliciosos o lesivos, a pesar de haber adoptado todas las medidas tecnológicas necesarias para evitarlo.";

const String modificaciones ="EZSA se reserva el derecho de efectuar sin previo aviso las modificaciones que considere oportunas en su portal, pudiendo cambiar, suprimir o añadir tanto los contenidos y servicios que se presten a través de la misma como la forma en la que éstos aparezcan presentados o localizados en su portal.";

const String enlaces="En el caso de que en nombre del dominio se dispusiesen enlaces o hipervínculos hacía otros sitios de Internet, Avanzadi Digital Solutions S.L. no ejercerá ningún tipo de control sobre dichos sitios y contenidos. En ningún caso Avanzadi Digital Solutions S.L. asumirá responsabilidad alguna por los contenidos de algún enlace perteneciente a un sitio web ajeno, ni garantizará la disponibilidad técnica, calidad, fiabilidad, exactitud, amplitud, veracidad, validez y constitucionalidad de cualquier material o información contenida en ninguno de dichos hipervínculos u otros sitios de Internet. Igualmente la inclusión de estas conexiones externas no implicará ningún tipo de asociación, fusión o participación con las entidades conectadas.";

const String derechosE = "EZSA se reserva el derecho a denegar o retirar el acceso a portal y/o los servicios ofrecidos sin necesidad de preaviso, a instancia propia o de un tercero, a aquellos usuarios que incumplan las presentes Condiciones Legales.";

const String generalidades ="EZSA perseguirá el incmplimiento de las presentes condiciones así como cualquier utilización indebida de su portal ejerciendo todas las acciones civiles y penales que le puedan corresponder en derecho.";

const String modificacionP ="EZSA web podrá modificar en cualquier momento las condiciones aquí determinadas, siendo debidamente publicadas como aquí aparecen. La vigencia de las citadas condiciones irá en función de su exposición y estarán vigentes hasta que sean modificadas por otras debidamente publicadas.";

const String legislacion ="Las relaciones establecidas entre el Usuario y el titular de la página web se regirán por lo dispuesto en la normativa vigente acerca de la legislación aplicable y la jurisdicción competente. No obstante, para los casos en los que la normativa permita la posibilidad a las partes de someterse voluntariamente a un fuero. EZSA SANIDAD AMBIENTAL S.L. y el Usuario, con renuncia expresa a cualquier otro fuero que pudiera corresponderles, se someten a los Juzgados y Tribunales competentes conforme al Art 90.2 del Real Decreto Legislativo 1/2007, de 16 de Noviembre por el que se aprueba el texto refundido de la Ley General Para la Defensa de los Consumidores y Usuarios y con Leyes Complementarias."; 

Menu _menu = new Menu();

class PTSeguridad extends StatefulWidget {
  static const String routeName = "/pantalla_seguridad";
  PTSeguridad({Key key}) : super(key: key);
  @override
  _PTSeguridadState createState() => new _PTSeguridadState();
}

class _PTSeguridadState extends State<PTSeguridad> {

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Seguridad y Privacidad", textAlign: TextAlign.center),
      ),
      drawer: _menu.getDrawer(context),
      body: new Container(
        padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
        alignment: new FractionalOffset(0.5, 0.0),
        child: Container(
          child: ListView(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("Politica de Privacidad",style:TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),textAlign: TextAlign.left, ),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("$politica",style:TextStyle(fontSize: 10.0),textAlign: TextAlign.left),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),              
              Text("DATOS IDENTIFICATIVOS",style:TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),textAlign: TextAlign.left, ),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("$identificativo",style:TextStyle(fontSize: 10.0),textAlign: TextAlign.left),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),              
              Text("PROTECCIÓN DE DATOS",style:TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),textAlign: TextAlign.left, ),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("$proteccion",style:TextStyle(fontSize: 10.0),textAlign: TextAlign.left),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("DERECHOS DE ACCESO, CANCELACIÓN, RECTIFICACIÓN Y OPOSICIÓN DE LOS USUARIOS",style:TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),textAlign: TextAlign.left, ),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("$derechos",style:TextStyle(fontSize: 10.0),textAlign: TextAlign.left),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("COMUNICACIONES",style:TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),textAlign: TextAlign.left, ),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("$comunicaciones",style:TextStyle(fontSize: 10.0),textAlign: TextAlign.left),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("CONSENTIMIENTO",style:TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),textAlign: TextAlign.left, ),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("$consentimiento",style:TextStyle(fontSize: 10.0),textAlign: TextAlign.left),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("PROPIEDAD INTELECTUAL E INDUSTRIAL",style:TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),textAlign: TextAlign.left, ),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("$propiedad",style:TextStyle(fontSize: 10.0),textAlign: TextAlign.left),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("EXCLUSIÓN DE GARANTÍAS Y RESPONSABILIDAD",style:TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),textAlign: TextAlign.left, ),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("$exclusion",style:TextStyle(fontSize: 10.0),textAlign: TextAlign.left),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("MODIFICACIONES",style:TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),textAlign: TextAlign.left, ),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("$modificaciones",style:TextStyle(fontSize: 10.0),textAlign: TextAlign.left),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("ENLACES",style:TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),textAlign: TextAlign.left, ),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("$enlaces",style:TextStyle(fontSize: 10.0),textAlign: TextAlign.left),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("DERECHO DE EXCLUSIÓN",style:TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),textAlign: TextAlign.left, ),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("$derechosE",style:TextStyle(fontSize: 10.0),textAlign: TextAlign.left),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("GENERALIDADES",style:TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),textAlign: TextAlign.left, ),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("$generalidades",style:TextStyle(fontSize: 10.0),textAlign: TextAlign.left),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("MODIFICACIÓN DE LAS PRESENTES CONDICIONES Y DURACIÓN",style:TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),textAlign: TextAlign.left, ),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("$modificacionP",style:TextStyle(fontSize: 10.0),textAlign: TextAlign.left),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("LEGISLACIÓN APLICABLE Y JURISDICCIÓN",style:TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),textAlign: TextAlign.left, ),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Text("$legislacion",style:TextStyle(fontSize: 10.0),textAlign: TextAlign.left), 
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
              Center(
                child: InkWell(
                  child: new Text('Seguir leyendo', style:  TextStyle(color: Colors.blue, fontSize: 12.0),),
                  onTap: () => launch('https://www.ezsa.es/politica-de-privacidad/')
                ),
              ),
              Padding(padding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0)),
            ]
          )
        ),
      )
    );
  }
}