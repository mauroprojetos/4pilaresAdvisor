//--- parâmetros de entrada
#property script_show_inputs

input string Comment_1="====================";     //==CONFIGURAÇÃO DO INDICADOR==
//Configurar anos historico
enum OpcaoMesesHistoricos{
   Anos10 = 120, // Dados 10 Anos 
   Anos8 = 96, // Dados 8 Anos
   Anos6 = 72, // Dados 6 Anos
   Anos5 = 60, // Dados 5 Anos
   Anos3 = 36, // Dados 3 Anos
};
input OpcaoMesesHistoricos MesesHistoricos = Anos5; //Tempo de Calculo TOPO, FUNDO

//Configurar Distancia Mediana
enum OpcaoDistanciaPontos{
   Distancia50 = 5000, // 5000 pontos
   Distancia40 = 4000, // 4000 pontos
   Distancia30 = 3000, // 3000 pontos
   Distancia20 = 2000, // 2000 pontos
   Distancia15 = 1500, // 1500 pontos
   Distancia10 = 1000, // 1000 pontos
};

input OpcaoDistanciaPontos PontosAteMediana = Distancia20;  //Orientação Distancia da Mediana

//Configurar lotes pelo saldo
enum OpcaoLotesProporcionais{
   Cada300 = 300, // 300 Dólares
   Cada250 = 250, // 250 Dólares
   Cada200 = 200, // 200 Dólares
   Cada150 = 150, // 150 Dólares
   Cada100 = 100, // 100 Dólares
};
input OpcaoLotesProporcionais LoteProporcional = Cada100; //Lotes Proporcionais a cada

//Configurar Dias Movimentação Média do Par
enum OpcaoDiasMovMedia{
   dias365 = 365, // 365 Dias
   dias120 = 120, // 120 Dias
   dias60 = 60, // 60 Dias
   dias30 = 30, // 30 Dias
   dias20 = 20, // 20 Dias
   dias14 = 14, // 14 Dias
};
input OpcaoDiasMovMedia DiasMovMedia = dias60; //Cálculo Mov. Média Diária do Par
input string LetrasFinalPares = ".a"; //Adicionar no final dos Pares
input string CustomParesNames = ""; //Ativos Painel Editável(separados por ",")
input bool PularPandemiaTopoFundo=true;  //Pular Pandemia p/ Calculo Topo e Fundo?

input bool EnablePainelForca=false; //Mostrar Painel de força ao recarregar
//Configurar TimeFrame Padrão da Força
enum OpcaoPadraoForca{
   TFMN1 = 9, // Mensal
   TFW1 = 8, // Semanal
   TFD1 = 7, // Diário
   TFH4 = 6, // 4 Horas
   TFH1 = 5, // 1 Hora
   TFM30 = 4, // 30 Minutos
   TFM15 = 3, // 15 Minutos
   TFM5 = 2, // 5 Minutos
   TFM1 = 1 // 1 Minuto
};
input OpcaoPadraoForca PadraoForca = TFD1; //TimeFrame Padrão da Força

input string Comment_2="====================";     //==CONFIGURAÇÃO VISUAL==
//--- input parameters

//Ajustar o Layout Embolado em alguns monitores
enum OpcaoCorrigirLayout{
   Size60 = 60, // 60 pixels
   Size55 = 55, // 55 pixels
   Size50 = 50, // 50 pixels
   Size45 = 45, // 45 pixels
   Size40 = 40, // 40 pixels
   Size35 = 35, // 35 pixels
   Size30 = 30, // 30 pixels
   Size25 = 25, // 25 pixels
   Size20 = 20, // 20 pixels
   Size15 = 15, // 15 pixels
   Size10 = 10, // 10 pixels
   Size5 = 5, // 5 pixels
   Size0 = 0 // Não Corrigir
};
input OpcaoCorrigirLayout CorrigirPixels = Size0; //Ajustar Layout Embolado

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
input bool     mostrarPrecoMedio=true;      // Mostrar Linha Preco Medio?

input string Comment_3="====================";     //====NOTIFICAÇÕES====
//Configurar alerta de lucro
enum OpcaoAlertaLucro{
   Lucro500 = 500, // 500 Dolares
   Lucro400 = 400, // 400 Dolares
   Lucro300 = 300, // 300 Dolares
   Lucro250 = 250, // 250 Dolares
   Lucro200 = 200, // 200 Dolares
   Lucro150 = 150, // 150 Dolares
   Lucro100 = 100, // 100 Dolares
   Lucro80 = 80, // 80 Dolares
   Lucro50 = 50, // 50 Dolares
   Lucro40 = 40, // 40 Dolares
   Lucro30 = 30, // 30 Dolares
   Lucro25 = 25, // 25 Dolares
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
input OpcaoAlertaLucroTempo AlertaLucroTempoEscolha = SegundosLucro30; //Notificação de lucro a cada

////--- input parameters
//input bool     bln_mail=false;      // Notificar por E-mail
//input bool     bln_push=false;      // Notificar por Push
//input bool     bln_alert=true;      // Notificar por Alerta

enum ENUM_CANDLE_TO_CHECK{
   CURRENT_CANDLE=0,    //CURRENT CANDLE
   CLOSED_CANDLE=1      //PREVIOUS CANDLE
};

input string Comment_4="====================";     //==CONFIGURAÇÃO MÉDIAS MÓVEIS==
input bool HabilitarLinhasMoveis=false;                   //HABILITAR LINHAS MÓVEIS
input int MAFastPeriod=6;                                 //Período da Média Móvel rápida
input int MAFastShift=0;                                  //Shift da Média Móvel rápida
input ENUM_MA_METHOD MAFastMethod=MODE_SMA;               //Método da Média Móvel rápida
input ENUM_APPLIED_PRICE MAFastAppliedPrice=PRICE_CLOSE;  //Preço Aplicado Média Móvel rápida
input int MASlowPeriod=21;                                //Período da Média Móvel lenta
input int MASlowShift=0;                                  //Shift da Média Móvel lenta
input ENUM_MA_METHOD MASlowMethod=MODE_SMA;               //Método da Média Móvel lenta
input ENUM_APPLIED_PRICE MASlowAppliedPrice=PRICE_CLOSE;  //Preço Aplicado Média Móvel lenta
//input ENUM_ALERT_SIGNAL AlertSignal=ON_BREAK_OUT;       //Alert Signal When
input ENUM_CANDLE_TO_CHECK CandleToCheck=CURRENT_CANDLE;    //Vela para usar na análise
input int BarsToScan=200;                                   //Número de velas para analisar

input string Comment_5="====================";      //Opções de Notificação
input bool EnableNotify=false;                      //Habilitar recurso de notificações
input bool SendAlert=true;                          //Enviar Notificação de Alerta
//input bool SendApp=true;                          //Send Notification to Mobile
//input bool SendEmail=true;                        //Send Notification via Email
input int WaitTimeNotify=5;                         //Tempo entre notificações (Minutos)

input string Comment_6="====================";     //Opções de Desenho
input bool EnableDrawArrows=true;                  //Desenhar setas de sinal
input bool EnableDrawLines=true;                  //Desenhar linhas móveis

int ArrowBuy=233;                            //Buy Arrow Code
int ArrowSell=234;                           //Sell Arrow Code
int ArrowSize=3;                             //Arrow Size (1-5)