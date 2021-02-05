//+---------------------------------------------------------------------+
//|                                                4PilaresAdvisor.mq5  |
//|                              Copyright 2021, Gustavo de Souza Lima  |
//|                                               https://www.mql5.com  |
//+---------------------------------------------------------------------+
#property copyright "Copyright 2021, Gustavo de Souza Lima"
#property link      "https://www.mql5.com"
#property version   "1.3.5"
#property description "      "
#property description "Um Indicador para auxiliar quem opera baseado nos 4 Pilares do Willy sem Stop Loss."
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_width1  2
#property indicator_width2  2
#property indicator_label1  "Fast MA"
#property indicator_label2  "Slow MA"
#include <Arrays\ArrayString.mqh>

#include "Estilos.mqh";
#include "ErrorHandling.mqh"
#include "Utils.mqh"

//+------------------------------------------------------------------+  
// Inicio Variaveis Moveis  
//+------------------------------------------------------------------+
string IndicatorName="4PILARES-MEDIA-MOVEIS";

enum ENUM_TRADE_SIGNAL{
   SIGNAL_BUY=1,     //BUY
   SIGNAL_SELL=-1,   //SELL
   SIGNAL_NEUTRAL=0  //NEUTRAL
};

enum ENUM_CANDLE_TO_CHECK{
   CURRENT_CANDLE=0,    //CURRENT CANDLE
   CLOSED_CANDLE=1      //PREVIOUS CANDLE
};

enum ENUM_ALERT_SIGNAL{

};

#include "PainelConfiguracao.mqh"

double BufferMASlow[];
double BufferMAFast[];


int BufferMASlowHandle,BufferMAFastHandle;

double Open[],Close[],High[],Low[];
datetime Time[];

datetime LastNotificationTime;
int Shift=0;
//+------------------------------------------------------------------+  
// Fim Variaveis Moveis  
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int OnInit()
  {
      //--- indicator buffers mapping
      ChartSetInteger(0,CHART_FOREGROUND,false);
      //---
      
      TimeCurrent(Tempo);
      
      // carrega variaveis dinamicas
      PegaVariaveisDinamicas();
      // chama Orientacao de Compra ou Venda ou Neutra
      ChamaOrientacao();
      
      // calcula Topo e Fundo Historicos
      CalculoTopoFundo();
      
      // BOTAO ESCONDER DISPLAY
      if(ObjectFind(0, "EsconderDisplay")>=0) ObjectDelete(0, "EsconderDisplay");   
      ObjectCreate(0,"EsconderDisplay", OBJ_BUTTON,0,0,0);
      ObjectSetString(0, "EsconderDisplay", OBJPROP_TEXT,"-");
      ObjectSetInteger(0,"EsconderDisplay",OBJPROP_FONTSIZE,7);
      ObjectSetInteger(0, "EsconderDisplay", OBJPROP_XSIZE,20);
      ObjectSetInteger(0, "EsconderDisplay", OBJPROP_YSIZE,10);
      ObjectSetInteger(0, "EsconderDisplay", OBJPROP_XDISTANCE,125);
      ObjectSetInteger(0, "EsconderDisplay", OBJPROP_YDISTANCE,3);
      ObjectSetInteger(0,"EsconderDisplay", OBJPROP_BGCOLOR,C'57,83,108');
      ObjectSetInteger(0,"EsconderDisplay", OBJPROP_COLOR,clrSnow); 
      ObjectSetInteger(0,"EsconderDisplay",OBJPROP_BORDER_COLOR,C'57,83,108');

      // carrega parte visual do Display do arquivo Estilos
      ChamaVisualDisplay();
      
      ChartRedraw();

//+------------------------------------------------------------------+  
// Inicio Linhas Moveis OnInit  
//+------------------------------------------------------------------+
   IndicatorSetString(INDICATOR_SHORTNAME,IndicatorName);

   OnInitInitialization();
   if(!OnInitPreChecksPass()){
      return(INIT_FAILED);
   }   

   InitialiseHandles();
   InitialiseBuffers();
//+------------------------------------------------------------------+  
// Fim Linhas Moveis OnInit  
//+------------------------------------------------------------------+
                       
   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   account status;
   getStats(status);
 
   //double timesBiggerThanHundredDollarBalance = MathFloor(getMoney(status) / LoteProporcional);
   //double maxLots = NormalizeDouble(timesBiggerThanHundredDollarBalance * LoteProporcional/10000, 2);

   double timesBiggerThanHundredDollarBalance = MathFloor(getMoney(status) / LoteProporcional);
   maxLots = NormalizeDouble(timesBiggerThanHundredDollarBalance * 0.01, 2);
   
   /*
   string marginWarn = status.marginLevel>minMarginLevel ?
    "Seu nível de margem está SAUDÁVEL (acima do min. " + minMarginLevel +"%): " + NormalizeDouble(status.marginLevel, 2) + "%" :
    "Seu nível de margem NÃO ESTÁ SAUDÁVEL (abaixo do min. " + minMarginLevel +"%): " + NormalizeDouble(status.marginLevel, 2) + "%" ;
    */

   string availableLotsWarn = status.lots>maxLots ? 
   "Você está utilizando mais lots do que sua conta suporta!\n"
   : "Saldo Disponível ("+ DoubleToString(status.money,2) + " " + status.currency +") \n";
   LotesUsadosTotal = status.lots;
   lotsAvailable = maxLots - LotesUsadosTotal;
   NiveldeMargem = status.marginLevel;
   
   
//+------------------------------------------------------------------+
//| Chama Novamente Funcoes                 |
//+------------------------------------------------------------------+
         
      PegaVariaveisDinamicas(); // pega dinamicamente
      DistanciaMediana = (PrecoBid - Mediana)*100000;
      MovimentacaoParHoje = PontosHoje*100000;
      CalculoTopoFundo();
      
      // chama Orientacao de Compra ou Venda ou Neutra
      ChamaOrientacao();

      
//+------------------------------------------------------------------+
//| Mostra se o par esta aberto no momento                 |
//+------------------------------------------------------------------+    

   
   string ParesAbertosMomento[];
   string ParesSemDuplicados[];
   string ParOperado;
   PosicoesAbertasNoPar = 0;
   LotesUsadosNoPar = 0.0;
   
   for(int i=PositionsTotal()-1; i>=0; i--)
      {
         ParOperado = PositionGetSymbol(i);
         ArrayResize(ParesAbertosMomento,PositionsTotal());
         ArrayResize(ParesSemDuplicados,PositionsTotal());
         PositionProfit = PositionGetDouble(POSITION_PROFIT);
           
         ChamaAlertaLucro(Symbol());                 

         if(ChartSymbol(0)==ParOperado)
         {
            PosicoesAbertasNoPar += 1; // Quantidade do par operado no momento
            LotesUsadosNoPar += PositionGetDouble(POSITION_VOLUME); // lotes operados no momento no par   
         }
         ParesAbertosMomento[i] = PositionGetSymbol(i);
              
       }

//+------------------------------------------------------------------+
//| Mostra a Media de Pontos Movimentados pelo Par no Dia            |
//+------------------------------------------------------------------+
   // Media de Pontos que a Moeda Faz por Dia
   int PeriodoHistorico = DiasMovMedia;
   double MovDiario = CalculaMediaParPorDia(PeriodoHistorico);
   MediaMovDiario = MovDiario*100000;

   double MovNoMomento = iHigh(Symbol(),PERIOD_D1,0)-iLow(Symbol(),PERIOD_D1,0);
   if(!MovNoMomento==0)
     {
      PorcMovNoMomento = (MovNoMomento/MovDiario)*100;
     }
   else
     {
      PorcMovNoMomento =0.0;
     }

//+------------------------------------------------------------------+
//| Se a moeda operada for JPY                                       |
//+------------------------------------------------------------------+ 
   if(StringFind(Symbol(), "JPY") >= 0)
     {
      IsJPY = true;
      DistanciaMediana = (PrecoBid - MargemAteOndeOperar)*1000;
      Mediana = NormalizeDouble(Mediana,3);
      MovimentacaoParHoje = PontosHoje*1000;
      MediaMovDiario = MovDiario*1000;
     }
       
//+------------------------------------------------------------------+
//| Mostra a Diversificação de Pares Diferentes Operados             |
//+------------------------------------------------------------------+    
   CArrayString array; //uso de biblioteca à parte para poder ordenar array de strings 
   string ParesDiferentes[];

   for(int i=0;i<PositionsTotal();i++)
   {
      PositionGetTicket(i);
      array.Add(PositionGetString(POSITION_SYMBOL));    
   }
   array.Sort();
   int n = array.Total();
   int j = 0;
   ArrayResize(ParesDiferentes,n);  
   
   for(int i=0;i<n-1;i++)
   {
      if(array[i] != array[i+1])
      {
         ParesDiferentes[j++] = array[i]; 
      }
   }
   //ParesDiferentes[j++] = array[n-1];
   ArrayResize(ParesDiferentes,j);
   DiversificacaoPares = ArraySize(ParesDiferentes);
   
   // Funcao que chama variaveis constantemente alimentadas
   EscreveInformacoesDinamicas(
   LotesUsadosTotal,
   lotsAvailable,
   PosicoesAbertasNoPar,
   DiversificacaoPares,
   LotesUsadosNoPar,
   TextoMediana,
   DistanciaMediana,
   MediaMovDiario,
   MovimentacaoParHoje,
   PorcMovNoMomento,
   SwapCompra,
   SwapVenda,
   SpreadAtual,
   OrientacaoFundoOuTopo,
   Orientacao,
   CorQuadroOrientacao,
   TextoLoteDisponivel,
   maxLots
   );



//+------------------------------------------------------------------+  
// Inicio Linhas Moveis Oncalculate  
//+------------------------------------------------------------------+
   if(rates_total<=MASlowPeriod || MASlowPeriod<=0)
      return(0);
   
   if(rates_total<=MAFastPeriod || MAFastPeriod<=0)
      return(0);
      
   if(MAFastPeriod>MASlowPeriod)
      return(0);
   
   bool IsNewCandle=CheckIfNewCandle();
   int i,pos,upTo;

   pos=0;
   if(prev_calculated==0 || IsNewCandle)
      upTo=BarsToScan-1;
   else
      upTo=0;

   if(IsStopped()) return(0);
   if(CopyBuffer(BufferMAFastHandle,0,-MAFastShift,upTo+1,BufferMAFast)<=0 ||
      CopyBuffer(BufferMASlowHandle,0,-MASlowShift,upTo+1,BufferMASlow)<=0
   ){
      Print("Failed to create the Indicator! Error ",GetLastErrorText(GetLastError())," - ",GetLastError());
      return(0);
   }

   for(i=pos; i<=upTo && !IsStopped(); i++){
      Open[i]=iOpen(Symbol(),PERIOD_CURRENT,i);
      Low[i]=iLow(Symbol(),PERIOD_CURRENT,i);
      High[i]=iHigh(Symbol(),PERIOD_CURRENT,i);
      Close[i]=iClose(Symbol(),PERIOD_CURRENT,i);
      Time[i]=iTime(Symbol(),PERIOD_CURRENT,i);
   }  
  
   if(IsNewCandle || prev_calculated==0){
      if(EnableDrawArrows) DrawArrows();
   }
   
   if(EnableDrawArrows)
      DrawArrow(0);

   if(EnableNotify)
      NotifyHit();
//+------------------------------------------------------------------+  
// Fim Linhas Moveis Oncalculate  
//+------------------------------------------------------------------+


   //TotalProfit();
   
   return(rates_total);   
  }
  
//+------------------------------------------------------------------+  
// Fim Oncalculate  
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll(0,0);
   CleanChart();
   ChartRedraw();
  }


void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
  { 
   // esconder o display
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam=="EsconderDisplay")
        {
        if(EsconderDisplay==false){
         EsconderDisplay = true;
         EscondeOuMostra();        
        }
        else
          {
           EsconderDisplay = false;
           EscondeOuMostra();
          }
        }
     }
   //Macete pra resolver erro de alguns ativos com historico grande que o
   //iClose demora pra carregar, eu recarrego o grafico mudando o timeframe
   if(MovimentacaoParHoje==DistanciaMediana)
      {
      ChartSetSymbolPeriod(0,NULL,PERIOD_M30); 
      }

  }

// Variaveis

int QtdeMesesHistoricos = DadosHistoricos;
color CorQuadroOrientacao;
int FonteBase1 = 8;
int FonteBase2 = 9;
int FontePaddingLeft = 7;
int PosicaoDistanciaMediana = 88;
string TextoMediana;
double Topo;
double Fundo;
double Mediana;
double MargemAteOndeOperar;
int MenorCandle, MaiorCandle;
double ArrayPrecosHistoricos[120];
double DistanciaMediana;
double PontosHoje;
string Orientacao;
bool IsJPY;
double MediaMovDiario;
string OrientacaoFundoOuTopo;
string TextoLoteDisponivel;
static datetime TimerAguardar;
int AlertaLucro = 0;
double PositionProfit = 0.0;
bool EsconderDisplay = false;
MqlDateTime Tempo;
int PosicoesAbertasNoPar;
double LotesUsadosNoPar;
double lotsAvailable;
int DiversificacaoPares;
double maxLots;
double LotesUsadosTotal;      
static ENUM_TIMEFRAMES TimeFrameCopy;
// Variaveis Dinamicas
double PrecoAsk;
double PrecoBid;
double SwapVenda;
double SwapCompra;
int SpreadAtual;
double NiveldeMargem;
double MovimentacaoParHoje;
double PorcMovNoMomento;
double FechamentoDiaAnteriorPar;


// funcao que pega as variaveis dinamicas
bool PegaVariaveisDinamicas(){
   PrecoAsk = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   PrecoBid = SymbolInfoDouble(Symbol(),SYMBOL_BID);
   SwapVenda = SymbolInfoDouble(Symbol(),SYMBOL_SWAP_SHORT);
   SwapCompra = SymbolInfoDouble(Symbol(),SYMBOL_SWAP_LONG);
   SpreadAtual = SymbolInfoInteger(Symbol(),SYMBOL_SPREAD);
   PontosHoje = PrecoBid - iClose(_Symbol,PERIOD_D1,1); // Fechamento Dia Anterior

   return(true);
}

// Orientação de compra ou venda e SWAP
bool ChamaOrientacao(){    
   if(PrecoBid>Mediana)  
     {
      TextoMediana = "Acima Mediana:";
      MargemAteOndeOperar = Mediana + PontosAteMediana;
         if(PrecoBid>MargemAteOndeOperar)
         {
            Orientacao="VENDA";           
            OrientacaoFundoOuTopo = "Topo:";
            CorQuadroOrientacao = clrCrimson;
         }
         else if(PrecoBid<MargemAteOndeOperar)
         {   
            Orientacao="NEUTRO";
            OrientacaoFundoOuTopo = " ";
            CorQuadroOrientacao = clrBlack;
         } 
     }
   else if(PrecoBid<Mediana)
     {
      TextoMediana = "Abaixo Mediana:";
      MargemAteOndeOperar = Mediana - PontosAteMediana;
      DistanciaMediana = DistanciaMediana * -1;
         if(PrecoBid<MargemAteOndeOperar)
         {
            Orientacao="COMPRA";        
            OrientacaoFundoOuTopo = "Fundo:";
            CorQuadroOrientacao = clrMediumBlue;
         }
         else if(PrecoBid>MargemAteOndeOperar)
         {   
            Orientacao="NEUTRO";
            OrientacaoFundoOuTopo = " ";
            CorQuadroOrientacao = clrBlack;
         }     
     }
   return(true);  
   }

enum CalculusBaseType { 
   CapitalLiquido=0, //Capital Líquido
   Balanca=1 //Saldo
};

double CalculaMediaParPorDia(int iPeriodo)
{ 
   double pontos = 0.0;
   for(int i=0;i<iPeriodo;i++)
     {
      pontos += iHigh(Symbol(),PERIOD_D1,i)-iLow(Symbol(),PERIOD_D1,i);
     }
   
   return pontos/iPeriodo;
}

double CalculaMovParMomento(int iPeriodo)
{ 

   double MovParMomento = iHigh(Symbol(),PERIOD_D1,0)-iLow(Symbol(),PERIOD_D1,0);
   
   return MovParMomento;
}

bool EscondeOuMostra(){

   if(EsconderDisplay==false)
      {
         ChamaVisualDisplay();
         
         // Informacoes que sao constantemente alimentadas
         EscreveInformacoesDinamicas(
         LotesUsadosTotal,
         lotsAvailable,
         PosicoesAbertasNoPar,
         DiversificacaoPares,
         LotesUsadosNoPar,
         TextoMediana,
         DistanciaMediana,
         MediaMovDiario,
         MovimentacaoParHoje,
         PorcMovNoMomento,
         SwapCompra,
         SwapVenda,
         SpreadAtual,
         OrientacaoFundoOuTopo,
         Orientacao,
         CorQuadroOrientacao,
         TextoLoteDisponivel,
         maxLots
         );  
      }
      else
        {
        ObjectsDeleteAll(0,0,OBJ_TEXT);
        ObjectsDeleteAll(0,0,OBJ_RECTANGLE_LABEL);
        ObjectsDeleteAll(0,0,OBJ_LABEL);
        }
   ChartRedraw();        
   return(true);
}

bool ChamaAlertaLucro(string NomePares){
   if(AlertaLucroEscolha !=0)
     {
      if(TimeCurrent() >= TimerAguardar && PositionProfit>=AlertaLucroEscolha)
      {
         Alert("Lucro no ",NomePares," de: $",DoubleToString(PositionProfit,2));
         TimerAguardar = TimeCurrent() + AlertaLucroTempoEscolha; // alertas em segundos
      }      
     }
   
   return(true);
}

bool CalculoTopoFundo(){

//+------------------------------------------------------------------+
//| Calculo Topo e Fundo                 |
//+------------------------------------------------------------------+ 
            
      // Array com os preços dos ultimos anos
      for(int i=0;i<QtdeMesesHistoricos;i++)
      {

         ArrayPrecosHistoricos[i] = NormalizeDouble(iClose(_Symbol,PERIOD_MN1,i),5);
      }
      
      MenorCandle = ArrayMinimum(ArrayPrecosHistoricos,0,QtdeMesesHistoricos);
      MaiorCandle = ArrayMaximum(ArrayPrecosHistoricos,0,QtdeMesesHistoricos);
     
      Topo = ArrayPrecosHistoricos[MaiorCandle];
      Fundo= ArrayPrecosHistoricos[MenorCandle];
        
      Mediana = (Topo + Fundo) / 2;
                         
      Mediana = NormalizeDouble(Mediana,5);

return(true);
}

struct account {
   double lots;
   double money;
   double balance;
   string currency;
   double marginLevel;
};



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
account getStats(account &stats) {

   double money= 0;
   double lots = 0;

   for(int i=0; i<PositionsTotal(); i++) {
      ulong ticket;
      if((ticket=PositionGetTicket(i))>0) {// if the position is selected
         double positionLosts = PositionGetDouble(POSITION_VOLUME);
         lots=lots+positionLosts;
     }
   }
   
   stats.balance = AccountInfoDouble(ACCOUNT_BALANCE);
   stats.money = AccountInfoDouble(ACCOUNT_EQUITY);
   stats.currency = AccountInfoString(ACCOUNT_CURRENCY);
   stats.lots= NormalizeDouble(lots, 2);
   stats.marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   
   return stats;
}
//+------------------------------------------------------------------+

double getMoney(account &stats) {
   //return calculusBaseType == 0 ? stats.balance : stats.money;
   return stats.balance;
}


// Saber a moeda base operada
//Print(SymbolInfoString(_Symbol,SYMBOL_CURRENCY_BASE));


//input CalculusBaseType calculusBaseType; // Base do calculos de lote:

//input int minMarginLevel = 1100; //Nível de Margem Mínima (Em %)

// funcao seta variasveis dinamicas
bool  EscreveInformacoesDinamicas(
   double lotes,
   double lotsAvailable,
   double PosicoesAbertasNoPar,
   int DiversificacaoPares,
   double LotesUsadosNoPar,
   string TextoMediana,
   double DistanciaMediana,
   double MediaMovDiario,
   double MovimentacaoParHoje,
   double PorcMovNoMomento,
   double SwapCompra,
   double SwapVenda,
   int SpreadAtual,
   string OrientacaoFundoOuTopo,
   string Orientacao,
   color CorQuadroOrientacao,
   string TextoLoteDisponivel,
   double maxLots 
 
)
   {
      // Variaveis do Display do Indicador

      // CORES MOV. PONTOS
      string SubidaQueda;
      if(MovimentacaoParHoje<0)
        {
         SubidaQueda = "Queda ";
         MovimentacaoParHoje = MovimentacaoParHoje*-1;
         ObjectSetInteger(0,"ValorMovimentacaoParHoje",OBJPROP_COLOR,clrSalmon);
        }
      else
        {
         SubidaQueda = "Subida ";
         ObjectSetInteger(0,"ValorMovimentacaoParHoje",OBJPROP_COLOR,clrLimeGreen);
        }
   
      // Valor Lote em Uso DINÂMICO
      ObjectSetString(0,"ValorLoteUso",OBJPROP_TEXT,DoubleToString(lotes,2));
   
      // Valor Lote Disponivel DINÂMICO
      ObjectSetString(0,"ValorLoteDisponivel",OBJPROP_TEXT,DoubleToString(lotsAvailable,2));

      // Valor Diversificacao Pares Diferentes Operados DINÂMICO
      ObjectSetString(0,"ValorDiversificacaoPares",OBJPROP_TEXT,DiversificacaoPares+" Pares");
   
      // Valor Quantidade de Posicoes Abertas nesse Par DINÂMICO
      ObjectSetString(0,"ValorQtdPosicaoAberta",OBJPROP_TEXT,DoubleToString(PosicoesAbertasNoPar,0));
   
      // Valor Lotes Operados nesse Par DINÂMICO
      ObjectSetString(0,"ValorLotesOperadosNoPar",OBJPROP_TEXT,DoubleToString(LotesUsadosNoPar,2));
   
      // Valor Distancia Mediana DINÂMICO
      ObjectSetString(0,"DistanciaMediana",OBJPROP_TEXT,TextoMediana);
      ObjectSetString(0,"ValorDistanciaMediana",OBJPROP_TEXT,DoubleToString(DistanciaMediana,0) + " Pts");
      
      // Valor Movimentacao Par DINÂMICO
      ObjectSetString(0,"MovimentacaoParHoje",OBJPROP_TEXT,"Mov. Hoje:");
      ObjectSetString(0,"ValorMovimentacaoParHoje",OBJPROP_TEXT,SubidaQueda + DoubleToString(MovimentacaoParHoje,0) + " Pts");        

      // Valor Media Pontos Por Dia Par DINÂMICO
      ObjectSetString(0,"ValorMediaMovDiario",OBJPROP_TEXT,DoubleToString(MediaMovDiario,0) + " Pts("+DoubleToString(PorcMovNoMomento,1)+"%)"); 
      
      // Valor Swap Compra DINÂMICO
      ObjectSetString(0,"ValorSwapCompra",OBJPROP_TEXT,DoubleToString(SwapCompra,2));
     
      // Valor Swap Venda DINÂMICO
      ObjectSetString(0,"ValorSwapVenda",OBJPROP_TEXT,DoubleToString(SwapVenda,2));
   
      // Valor Spread DINÂMICO
      ObjectSetString(0,"ValorSpread",OBJPROP_TEXT,SpreadAtual);

      // Valor Nível de Margem DINÂMICO
      ObjectSetString(0,"ValorNiveldeMargem",OBJPROP_TEXT,DoubleToString(NiveldeMargem,2)+"%");   

      // Topo ou Fundo DINÂMICO
      ObjectSetString(0,"OrientacaoTopoFundo",OBJPROP_TEXT,OrientacaoFundoOuTopo);
      
      // Orientacao Compra, Vende ou Aguarda
      ObjectSetString(0,"OrientacaoCompraVenda",OBJPROP_TEXT,Orientacao);
      ObjectSetInteger(0, "QuadroOrientacao", OBJPROP_BGCOLOR, CorQuadroOrientacao);
   
      // CORES SWAP e SPREAD
      if(lotsAvailable<0 && lotes>maxLots)
      {
         ObjectSetInteger(0,"ValorLoteUso",OBJPROP_COLOR,clrSalmon);
         ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_COLOR,clrSalmon);
         ObjectSetInteger(0,"LoteDisponivel",OBJPROP_COLOR,clrSalmon);
         TextoLoteDisponivel = "Ultrapassou:";
         lotsAvailable = lotsAvailable * -1;        
      }
      else
      {
         ObjectSetInteger(0,"ValorLoteUso",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0,"LoteDisponivel",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_COLOR,clrLimeGreen);
         TextoLoteDisponivel = "Lote Disponível:";               
      }
      ObjectSetString(0,"LoteDisponivel",OBJPROP_TEXT,TextoLoteDisponivel);
      
      if(SwapCompra>0.0)
      {
         ObjectSetInteger(0,"ValorSwapCompra",OBJPROP_COLOR,clrDodgerBlue);
      }
      else
      {
         ObjectSetInteger(0,"ValorSwapCompra",OBJPROP_COLOR,clrSalmon);
      }
      
      if(SwapVenda>0.0)
      {
         ObjectSetInteger(0,"ValorSwapVenda",OBJPROP_COLOR,clrDodgerBlue);
      }
      else
      {
         ObjectSetInteger(0,"ValorSwapVenda",OBJPROP_COLOR,clrSalmon);
      }
      
      if(SpreadAtual>=50)
      {
         ObjectSetInteger(0,"ValorSpread",OBJPROP_COLOR,clrSalmon);
      }
      else if(SpreadAtual<50 && SpreadAtual>30)
      {
         ObjectSetInteger(0,"ValorSpread",OBJPROP_COLOR,clrDodgerBlue);
      }
      else if(SpreadAtual<=30)
      {
         ObjectSetInteger(0,"ValorSpread",OBJPROP_COLOR,clrLimeGreen);
      }
            
      return(true);
   }
              
//      //availableLotsWarn  

//+------------------------------------------------------------------+
//| Inicio Logica Media Moveis e seu cruzamento 6 x 21               |
//+------------------------------------------------------------------+ 
void OnInitInitialization(){
   LastNotificationTime=TimeCurrent();
   Shift=CandleToCheck;
}


bool OnInitPreChecksPass(){
   if(MASlowPeriod<=0 || MAFastPeriod<=0 || MAFastPeriod>MASlowPeriod){
      Print("Wrong input parameter");
      return false;
   }   
   if(Bars(Symbol(),PERIOD_CURRENT)<MASlowPeriod+MASlowShift){
      Print("Not Enough Historical Candles");
      return false;
   }   
   return true;
}


void CleanChart(){
   int Window=0;
   for(int i=ObjectsTotal(ChartID(),Window,-1)-1;i>=0;i--){
      if(StringFind(ObjectName(0,i),IndicatorName,0)>=0){
         ObjectDelete(0,ObjectName(0,i));
      }
   }
}


void InitialiseHandles(){
   BufferMAFastHandle=iMA(Symbol(),PERIOD_CURRENT,MAFastPeriod,MAFastShift,MAFastMethod,MAFastAppliedPrice);
   BufferMASlowHandle=iMA(Symbol(),PERIOD_CURRENT,MASlowPeriod,MASlowShift,MASlowMethod,MASlowAppliedPrice);
   ArrayResize(Open,BarsToScan);
   ArrayResize(High,BarsToScan);
   ArrayResize(Low,BarsToScan);
   ArrayResize(Close,BarsToScan);
   ArrayResize(Time,BarsToScan);
}

void InitialiseBuffers(){
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   ArraySetAsSeries(BufferMAFast,true);
   ArraySetAsSeries(BufferMASlow,true);
   SetIndexBuffer(0,BufferMAFast,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMASlow,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_SHIFT,MAFastShift);
   PlotIndexSetInteger(1,PLOT_SHIFT,MASlowShift);
}


datetime NewCandleTime=TimeCurrent();
bool CheckIfNewCandle(){
   if(NewCandleTime==iTime(Symbol(),0,0)) return false;
   else{
      NewCandleTime=iTime(Symbol(),0,0);
      return true;
   }
}


//Check if it is a trade Signla 0 - Neutral, 1 - Buy, -1 - Sell
ENUM_TRADE_SIGNAL IsSignal(int i){
   int j=i+Shift;
   if(BufferMAFast[j+1+MAFastShift]<BufferMASlow[j+1+MASlowShift] && BufferMAFast[j+MAFastShift]>BufferMASlow[j+MASlowShift]) return SIGNAL_BUY;
   if(BufferMAFast[j+1+MAFastShift]>BufferMASlow[j+1+MASlowShift] && BufferMAFast[j+MAFastShift]<BufferMASlow[j+MASlowShift]) return SIGNAL_SELL;

   return SIGNAL_NEUTRAL;
}


datetime LastNotification=TimeCurrent()-WaitTimeNotify*60;

void NotifyHit(){
   if(!EnableNotify || TimeCurrent()<(LastNotification+WaitTimeNotify*60)) return;
   if(!SendAlert && !SendApp && !SendEmail) return;
   if(Time[0]==LastNotificationTime) return;
   ENUM_TRADE_SIGNAL Signal=IsSignal(0);
   if(Signal==SIGNAL_NEUTRAL) return;
   string EmailSubject=IndicatorName+" "+Symbol()+" Notification ";
//   string EmailBody="\r\n"+AccountCompany()+" - "+AccountName()+" - "+IntegerToString(AccountNumber())+"\r\n\r\n"+IndicatorName+" Notification for "+Symbol()+"\r\n\r\n";
   string AlertText=Symbol()+" Cruzou as linhas Moveis Sinal de ";
//   string AppText=AccountCompany()+" - "+AccountName()+" - "+IntegerToString(AccountNumber())+" - "+IndicatorName+" - "+Symbol()+" - ";
   //string Text="";
//   
   if(Signal!=SIGNAL_NEUTRAL){
      if(Signal==SIGNAL_BUY)
         {     
            AlertText+="COMPRA";
         }
      else
        {
            AlertText+="VENDA";
        }
   }
//   
//   EmailBody+=Text+"\r\n\r\n";
   //AlertText+=Text+"\r\n";
//   AppText+=Text+"";
   if(SendAlert) Alert(AlertText);
//   if(SendEmail){
//      if(!SendMail(EmailSubject,EmailBody)) Print("Error sending email "+IntegerToString(GetLastError()));
//   }
//   if(SendApp){
//      if(!SendNotification(AppText)) Print("Error sending notification "+IntegerToString(GetLastError()));
//   }
   LastNotification=TimeCurrent();
   Print(Symbol()+"Cruzou as Linhas Moveis em: "+TimeToString(LastNotification));
}


void DrawArrows(){
   RemoveArrows();
   if(!EnableDrawArrows || BarsToScan==0) return;
   int MaxBars=Bars(Symbol(),PERIOD_CURRENT);
   if(MaxBars>BarsToScan) MaxBars=BarsToScan;
   for(int i=MaxBars-2;i>=1;i--){
      DrawArrow(i);
   }
}


void RemoveArrows(){
   int Window=-1;
   for(int i=ObjectsTotal(ChartID(),Window,-1)-1;i>=0;i--){
      if(StringFind(ObjectName(0,i),IndicatorName+"-SETAS-",0)>=0){
         ObjectDelete(0,ObjectName(0,i));
      }
   }
}

int SignalWidth=0;

void DrawArrow(int i){
   RemoveArrowCurr();
   if(!EnableDrawArrows){
      RemoveArrows();
      return;
   }
   ENUM_TRADE_SIGNAL Signal=IsSignal(i);
   if(Signal==SIGNAL_NEUTRAL) return;
   datetime ArrowDate=iTime(Symbol(),0,i);
   string ArrowName=IndicatorName+"-SETAS-"+IntegerToString(ArrowDate);
   double ArrowPrice=0;
   ENUM_OBJECT ArrowType=OBJ_ARROW;
   color ArrowColor=0;
   int ArrowAnchor=0;
   string ArrowDesc="";
   if(Signal==SIGNAL_BUY){
      ArrowPrice=Low[i];
      ArrowType = (ENUM_OBJECT)ArrowBuy; 
      ArrowColor=clrGreen;  
      ArrowAnchor=ANCHOR_TOP;
      ArrowDesc="BUY";
   }
   if(Signal==SIGNAL_SELL){
      ArrowPrice=High[i];
      ArrowType = (ENUM_OBJECT)ArrowSell;
      ArrowColor=clrRed;
      ArrowAnchor=ANCHOR_BOTTOM;
      ArrowDesc="SELL";
   }
   ObjectCreate(0,ArrowName,OBJ_ARROW,0,ArrowDate,ArrowPrice);
   ObjectSetInteger(0,ArrowName,OBJPROP_COLOR,ArrowColor);
   ObjectSetInteger(0,ArrowName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,ArrowName,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,ArrowName,OBJPROP_ANCHOR,ArrowAnchor);
   ObjectSetInteger(0,ArrowName,OBJPROP_ARROWCODE,ArrowType);
   SignalWidth=ArrowSize;
   ObjectSetInteger(0,ArrowName,OBJPROP_WIDTH,SignalWidth);
   ObjectSetInteger(0,ArrowName,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,ArrowName,OBJPROP_BGCOLOR,ArrowColor);
   ObjectSetString(0,ArrowName,OBJPROP_TEXT,ArrowDesc);
   ObjectSetInteger(0,ArrowName,OBJPROP_BACK,true);
   datetime CurrTime=iTime(Symbol(),0,0);

}


void RemoveArrowCurr(){
   datetime ArrowDate=iTime(Symbol(),0,Shift);
   string ArrowName=IndicatorName+"-SETAS-"+IntegerToString(ArrowDate);
   ObjectDelete(0,ArrowName);
}

//+------------------------------------------------------------------+
//| Fim Logica Media Moveis e seu cruzamento 6 x 21               |
//+------------------------------------------------------------------+ 