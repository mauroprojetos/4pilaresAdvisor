//--- parâmetros de entrada
#property script_show_inputs

input group           "Configuração dos Dados"
//Configurar anos historico
enum OpcaoDadosHistoricos{
   Anos10 = 120, // Dados 10 Anos 
   Anos8 = 96, // Dados 8 Anos
   Anos6 = 72, // Dados 6 Anos
   Anos5 = 60, // Dados 5 Anos
   Anos3 = 36, // Dados 3 Anos
};
input OpcaoDadosHistoricos DadosHistoricos = Anos5; //Tempo de Calculo TOPO, FUNDO

//Configurar Distancia Mediana
enum OpcaoDistanciaPontos{
   Distancia50 = 50, // 5000 pontos
   Distancia40 = 40, // 4000 pontos
   Distancia30 = 30, // 5000 pontos
   Distancia20 = 20, // 2000 pontos
   Distancia15 = 15, // 1500 pontos
   Distancia10 = 10, // 1000 pontos
};

input OpcaoDistanciaPontos DistanciaOperar = Distancia15;  //Orientação Distancia da Mediana
double PontosAteMediana = DistanciaOperar * 1. / 1000 ; // int * double = double. double / int = double

//Configurar anos historico
enum OpcaoLotesProporcionais{
   Cada300 = 300, // 300 Dólares
   Cada250 = 250, // 250 Dólares
   Cada200 = 200, // 200 Dólares
   Cada150 = 150, // 150 Dólares
   Cada100 = 100, // 100 Dólares
};
input OpcaoLotesProporcionais LoteProporcional = Cada100; //Lotes Proporcionais a cada

input group           "Personalização Visual"
//--- input parameters


//Configurar Localização Display
enum OpcaoLocalizacaoDisplay{
   CantoDireitoSuperior = 4, // Canto Direito Superior
   //CantoDireitoInferior = 3, // Canto Direito Inferior
   CantoEsquerdoSuperior = 2, // Canto Esquerdo Superior
   //CantoEsquerdoInferior = 1, // Canto Esquerdo Inferior
};

input OpcaoLocalizacaoDisplay LocalizacaoDisplay = CantoEsquerdoSuperior; //Localização do Display

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


