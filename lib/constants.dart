import 'dart:io';
//alexandre
// String baseUrl = "http://3a85b15efde5.ngrok.io";
//alexandre 2
// String baseUrl = "http://192.168.0.8";

//augusto
// String baseUrl = "http://192.168.0.104:8080";
//augusto 2
// String baseUrl = "http://192.168.1.101:8080";

//estagiario
// String baseUrl = "http://192.168.100.14:8080";

//stage
// String baseUrl = "https://dandelin-server-stage.dandelin.io";

//development
String baseUrl = "https://dandelin-server-development.dandelin.io";

const WS = "https://dandelin.livetouchdev.com.br";

//
//PRODUÇÃO
//!##################################################
//String baseUrl = "https://dandelin-server.dandelin.io";
//!##################################################

String kOnSocketException = "Conexão perdida, tente novamente.";
String kExpertiseBase = "Nome ou Especialidade do médico";
String kLaboratoryBase = "Todos os exames";
String kLocalidadeBase = "Médicos próximos de você";
String kAppVersion = Platform.isAndroid ? "1.7.5" : "1.4.5";
String kAppVersionCode = Platform.isAndroid ? "97" : "124";
