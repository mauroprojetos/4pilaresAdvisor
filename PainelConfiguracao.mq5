//--- parâmetros de entrada
#property script_show_inputs

input group           "Configuração dos Dados"
//Configurar anos historico
enum OpcaoDadosHistoricos{
   Anos10 = 120, // Dados Históricos 10 Anos 
   Anos8 = 96, // Dados Históricos 8 Anos
   Anos6 = 72, // Dados Históricos 6 Anos
   Anos5 = 60, // Dados Históricos 5 Anos
   Anos3 = 36, // Dados Históricos 3 Anos
};
input OpcaoDadosHistoricos DadosHistoricos = Anos5; //Escolha o tempo Histórico

//Configurar Distancia Mediana
enum OpcaoDistanciaPontos{
   Distancia50 = 50, // Distancia de 5000 pontos
   Distancia40 = 40, // Distancia de 4000 pontos
   Distancia30 = 30, // Distancia de 5000 pontos
   Distancia20 = 20, // Distancia de 2000 pontos
   Distancia15 = 15, // Distancia de 1500 pontos
   Distancia10 = 10, // Distancia de 1000 pontos
};

input OpcaoDistanciaPontos DistanciaOperar = Distancia15;  //Orientação para Operar
double PontosAteMediana = DistanciaOperar * 1. / 1000 ; // int * double = double. double / int = double

input group           "Personalização Visual"
//--- input parameters

//input ENUM_BASE_CORNER LocalizacaoDisplay = CORNER_LEFT_UPPER; // Localizacao do Painel

//Configurar Distancia Mediana
enum OpcaoTamanhoDisplay{
   //DisplayGigante = 4, // Tamanho Gigante
   //DisplayGrande = 3, // Tamanho Grande
   DisplayMedio = 2, // Tamanho Medio
   DisplayPequeno = 1, // Tamanho Pequeno
};

input OpcaoTamanhoDisplay TamanhoDisplay = DisplayPequeno; //Tamanho do Display

input bool     titulo_TopoMedianaFundo=true;      // Mostrar Títulos das Linhas?
input bool     mostrarPrecoAtual=true;      // Mostrar Título do Preço Atual?

//input group           "Notificações"
////--- input parameters
//input bool     bln_mail=false;      // Notificar por E-mail
//input bool     bln_push=false;      // Notificar por Push
//input bool     bln_alert=true;      // Notificar por Alerta


