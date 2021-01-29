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

//Configurar lotes pelo saldo
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

input group           "Notificação de Lucro"
//Configurar alerta de lucro
enum OpcaoAlertaLucro{
   Lucro200 = 200, // 200 Dolares
   Lucro100 = 100, // 100 Dolares
   Lucro50 = 50, // 50 Dolares
   Lucro20 = 20, // 20 Dolares
   Lucro15 = 15, // 15 Dolares
   Lucro10 = 10, // 10 Dolares
   Lucro8 = 8, // 8 Dolares
   Lucro5 = 5, // 5 Dolares
   Lucro4 = 4, // 4 Dolares
   Lucro3 = 3, // 3 Dolares
   Lucro2 = 2, // 2 Dolares
   Lucro1 = 1, // 1 Dolar
   Lucro0 = 0, // Não Notificar
};
input OpcaoAlertaLucro AlertaLucroEscolha = Lucro0; //Alerta o Lucro de

//Configurar alerta de lucro
enum OpcaoAlertaLucroTempo{
   SegundosLucro600 = 600, // 10 Minutos
   SegundosLucro300 = 300, // 5 Minutos
   SegundosLucro60 = 60, // 1 Minuto
   SegundosLucro30 = 30, // 30 Segundos
   SegundosLucro10 = 10, // 10 Segundos
};
input OpcaoAlertaLucroTempo AlertaLucroTempoEscolha = SegundosLucro10; //Notificação de lucro a cada
////--- input parameters
//input bool     bln_mail=false;      // Notificar por E-mail
//input bool     bln_push=false;      // Notificar por Push
//input bool     bln_alert=true;      // Notificar por Alerta


