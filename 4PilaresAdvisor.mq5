//+---------------------------------------------------------------------+
//|                                                4PilaresAdvisor.mq5  |
//|                              Copyright 2021, Gustavo de Souza Lima  |
//|                                               https://www.mql5.com  |
//+---------------------------------------------------------------------+
#property copyright "Copyright 2021, Gustavo de Souza Lima"
#property link      "https://www.mql5.com"
#property version   "1.3.4"
#property indicator_chart_window
#property description "      "
#property description "Um Indicador para auxiliar quem opera baseado nos 4 Pilares do Willy sem Stop Loss."
#include "PainelConfiguracao.mq5"
#include "Estilos.mq5";

// Variaveis

int QtdeMesesHistoricos = DadosHistoricos;
color CorQuadroOrientacao;
int FonteBase1 = 8;
int FonteBase2 = 9;
int FontePaddingLeft = 7;
int PosicaoDistanciaMediana = 87;
string TextoMediana;
double Topo;
double Fundo;
double Mediana;
double MargemAteOndeOperar;
int MenorCandle, MaiorCandle;
double ArrayPrecosHistoricos[120];
double DistanciaMediana;
string Orientacao;
bool IsJPY;
double MediaUltimosAnos;
string OrientacaoFundoOuTopo;
string TextoLoteDisponivel;
static datetime TimerAguardar;
int AlertaLucro = 0;
double PositionProfit = 0.0;
bool EsconderDisplay = false;
      MqlDateTime Time;
      

// Variaveis Dinamicas
double PrecoAsk;
double PrecoBid;
double SwapVenda;
double SwapCompra;
int SpreadAtual;
double MovimentacaoPar;
double FechamentoDiaAnteriorPar;

double CalculoMovimentacaoPar(){
   
   double PontosHoje = PrecoBid - iClose(_Symbol,PERIOD_D1,1); // Fechamento Dia Anterior
   return(PontosHoje);
}

// funcao que pega as variaveis dinamicas
bool PegaVariaveisDinamicas(){
   PrecoAsk = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   PrecoBid = SymbolInfoDouble(Symbol(),SYMBOL_BID);
   SwapVenda = SymbolInfoDouble(Symbol(),SYMBOL_SWAP_SHORT);
   SwapCompra = SymbolInfoDouble(Symbol(),SYMBOL_SWAP_LONG);
   SpreadAtual = SymbolInfoInteger(Symbol(),SYMBOL_SPREAD);
   
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

double CalculaMediaUltimosAnos(int iBar=0) // ultimos anos
{
   double sum = 0.0;
   int count = DadosHistoricos+1;
   for(int iEnd = iBar+count; iBar < iEnd; ++iBar) sum += iClose(NULL,PERIOD_MN1,iBar);
   
   return sum/QtdeMesesHistoricos;
}

bool EscondeOuMostra(){

   if(EsconderDisplay==false)
     {
      ChamaVisualDisplay();    
      }
      else
        {
         ObjectDelete(0, "Rectangle");
         ObjectDelete(0, "Moldura1Traz");
         ObjectDelete(0, "Moldura1Frente");
         ObjectDelete(0, "Moldura2Traz");
         ObjectDelete(0, "Moldura2Frente");
         ObjectDelete(0, "Moldura3Traz");
         ObjectDelete(0, "Moldura3Frente");
         ObjectDelete(0, "Moldura4Traz");
         ObjectDelete(0, "Moldura4Frente");
         ObjectDelete(0, "QuadroOrientacao");
         ObjectDelete(0, "QuadroOrientacao");
         ObjectDelete(0, "Creditos1");
         ObjectDelete(0, "LoteUso");
         ObjectDelete(0, "ValorLoteUso");
         ObjectDelete(0, "LoteDisponivel");
         ObjectDelete(0, "ValorLoteDisponivel");
         ObjectDelete(0, "PosicaoAberta");
         ObjectDelete(0, "ValorPosicaoAberta");
         ObjectDelete(0, "LotesOperadosNoPar");
         ObjectDelete(0, "ValorLotesOperadosNoPar");
         ObjectDelete(0, "DistanciaMediana");
         ObjectDelete(0, "ValorDistanciaMediana");
         ObjectDelete(0, "MovimentacaoPar");
         ObjectDelete(0, "ValorMovimentacaoPar");
         ObjectDelete(0, "SwapCompra");
         ObjectDelete(0, "ValorSwapCompra");
         ObjectDelete(0, "SwapVenda");
         ObjectDelete(0, "ValorSwapVenda");
         ObjectDelete(0, "Spread");
         ObjectDelete(0, "ValorSpread");
         ObjectDelete(0, "OrientacaoTopoFundo");
         ObjectDelete(0, "OrientacaoCompraVenda");
        }    
return(true);
}

bool ChamaAlertaLucro(string NomePares){
   if(PositionProfit !=0)
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
      for(int i=QtdeMesesHistoricos-1; i>=0; i--){
         ArrayPrecosHistoricos[i] = NormalizeDouble(iClose(_Symbol,PERIOD_MN1,i),5);
      }
      
      MenorCandle = ArrayMinimum(ArrayPrecosHistoricos,0,QtdeMesesHistoricos);
      MaiorCandle = ArrayMaximum(ArrayPrecosHistoricos,0,QtdeMesesHistoricos);
     
      Topo = ArrayPrecosHistoricos[MaiorCandle];
      Fundo= ArrayPrecosHistoricos[MenorCandle];
        
      Mediana = (Topo + Fundo) / 2;
                         
      Mediana = NormalizeDouble(Mediana,5);

      // Media de Preço que a moeda ficou nos ultimos anos
      //MediaUltimosAnos = NormalizeDouble(CalculaMediaUltimosAnos(),5);

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
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+


int OnInit()
  {
      //--- indicator buffers mapping
         ChartSetInteger(0,CHART_FOREGROUND,false);
      //---
      
      TimeCurrent(Time);
      
      // carrega variaveis dinamicas
      PegaVariaveisDinamicas();
      // chama Orientacao de Compra ou Venda ou Neutra
      ChamaOrientacao();
      
      // calcula Topo e Fundo Historicos
      CalculoTopoFundo();
      // carrega parte visual do Display do arquivo Estilos
      ChamaVisualDisplay();
          
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
   double maxLots = NormalizeDouble(timesBiggerThanHundredDollarBalance * 0.01, 2);
   
   /*
   string marginWarn = status.marginLevel>minMarginLevel ?
    "Seu nível de margem está SAUDÁVEL (acima do min. " + minMarginLevel +"%): " + NormalizeDouble(status.marginLevel, 2) + "%" :
    "Seu nível de margem NÃO ESTÁ SAUDÁVEL (abaixo do min. " + minMarginLevel +"%): " + NormalizeDouble(status.marginLevel, 2) + "%" ;
    */
    
   string availableLotsWarn = status.lots>maxLots ? 
   "Você está utilizando mais lots do que sua conta suporta!\n"
   : "Saldo Disponível ("+ DoubleToString(status.money,2) + " " + status.currency +") \n";

   double lotsAvailable = maxLots - status.lots;
   
   
//+------------------------------------------------------------------+
//| Chama Novamente Funcoes                 |
//+------------------------------------------------------------------+
         
      PegaVariaveisDinamicas(); // pega dinamicamente
      DistanciaMediana = (PrecoBid - Mediana)*100000;
      MovimentacaoPar = CalculoMovimentacaoPar()*100000;
      CalculoTopoFundo();
      
      // chama Orientacao de Compra ou Venda ou Neutra
      ChamaOrientacao();
      // Se a moeda operada for JPY      
      if(StringFind(Symbol(), "JPY") >= 0)
        {
         IsJPY = true;
         DistanciaMediana = (PrecoBid - MargemAteOndeOperar)*1000;
         Mediana = NormalizeDouble(Mediana,3);
         MovimentacaoPar = CalculoMovimentacaoPar()*1000;
         
         //MediaUltimosAnos = NormalizeDouble(CalculaMediaUltimosAnos(),3);
        }
      
   

         
      
//+------------------------------------------------------------------+
//| Mostra se o par esta aberto no momento                 |
//+------------------------------------------------------------------+    

   int PosicoesAbertasNoPar = 0;
   double LotesUsados = 0.0;
   string ParesAbertosMomento[];
   string ParesSemDuplicados[];
      
   
   for(int i=PositionsTotal()-1; i>=0; i--)
      {
         string ParOperado = PositionGetSymbol(i);
         ArrayResize(ParesAbertosMomento,PositionsTotal());
         ArrayResize(ParesSemDuplicados,PositionsTotal());
         PositionProfit = PositionGetDouble(POSITION_PROFIT);
           
         ChamaAlertaLucro(Symbol());                 

         if(Symbol()==ParOperado)
         {
            PosicoesAbertasNoPar += 1; // Quantidade do par operado no momento
            LotesUsados += PositionGetDouble(POSITION_VOLUME); // lotes operados no momento no par   
         }
         ParesAbertosMomento[i] = PositionGetSymbol(i);
              
       }
      
   

//Print(TerminalInfoInteger(TERMINAL_SCREEN_WIDTH));



      // Variaveis do Display do Indicador

         // Valor Lote em Uso DINÂMICO
         ObjectSetString(0,"ValorLoteUso",OBJPROP_TEXT,DoubleToString(status.lots,2));

         // Valor Lote Disponivel DINÂMICO
         ObjectSetString(0,"ValorLoteDisponivel",OBJPROP_TEXT,DoubleToString(lotsAvailable,2));

         // Valor Operações nesse Par DINÂMICO
         ObjectSetString(0,"ValorPosicaoAberta",OBJPROP_TEXT,DoubleToString(PosicoesAbertasNoPar,0));

         // Valor Lotes Operados nesse Par DINÂMICO
         ObjectSetString(0,"ValorLotesOperadosNoPar",OBJPROP_TEXT,DoubleToString(LotesUsados,2));
  
         // Valor Distancia Mediana DINÂMICO
         ObjectSetString(0,"DistanciaMediana",OBJPROP_TEXT,TextoMediana);
         ObjectSetString(0,"ValorDistanciaMediana",OBJPROP_TEXT,DoubleToString(DistanciaMediana,0) + " Pts");
         
         // Valor Movimentacao Par DINÂMICO
         ObjectSetString(0,"ValorMovimentacaoPar",OBJPROP_TEXT,DoubleToString(MovimentacaoPar,0) + " Pts");    
         
         // Valor Swap Compra DINÂMICO
         ObjectSetString(0,"ValorSwapCompra",OBJPROP_TEXT,DoubleToString(SwapCompra,2));
        
         // Valor Swap Venda DINÂMICO
         ObjectSetString(0,"ValorSwapVenda",OBJPROP_TEXT,DoubleToString(SwapVenda,2));

         // Valor Spread DINÂMICO
         ObjectSetString(0,"ValorSpread",OBJPROP_TEXT,SpreadAtual);

         // Topo ou Fundo DINÂMICO
         ObjectSetString(0,"OrientacaoTopoFundo",OBJPROP_TEXT,OrientacaoFundoOuTopo);
         
         // Orientacao Compra, Vende ou Aguarda
         ObjectSetString(0,"OrientacaoCompraVenda",OBJPROP_TEXT,Orientacao);
         ObjectSetInteger(0, "QuadroOrientacao", OBJPROP_BGCOLOR, CorQuadroOrientacao);

         // CORES SWAP e SPREAD
         if(lotsAvailable<0 && status.lots>maxLots)
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

              
      // BOTAO ESCONDER DISPLAY
      if(ObjectFind(0, "EsconderDisplay")>=0) ObjectDelete(0, "EsconderDisplay");   
      ObjectCreate(0,"EsconderDisplay", OBJ_BUTTON,0,0,0);
      ObjectSetString(0, "EsconderDisplay", OBJPROP_TEXT,"Esconder");
      ObjectSetInteger(0,"EsconderDisplay",OBJPROP_FONTSIZE,7);
      ObjectSetInteger(0, "EsconderDisplay", OBJPROP_XSIZE,44);
      ObjectSetInteger(0, "EsconderDisplay", OBJPROP_YSIZE,20);
      ObjectSetInteger(0, "EsconderDisplay", OBJPROP_XDISTANCE,240);
      ObjectSetInteger(0, "EsconderDisplay", OBJPROP_YDISTANCE,0);
      ObjectSetInteger(0, "EsconderDisplay", OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,"EsconderDisplay", OBJPROP_BGCOLOR,clrDarkGray);
      ObjectSetInteger(0,"EsconderDisplay", OBJPROP_COLOR,clrBlack);


//      //availableLotsWarn  

   // Media Moveis e seu cruzamento 6 x 21
//   double MovingAverageArray1[],MovingAverageArray2[];
//   
//   int MovingAverageDefinition1 = iMA(_Symbol,_Period,6,0,MODE_EMA,PRICE_CLOSE);
//   int MovingAverageDefinition2 = iMA(_Symbol,_Period,21,0,MODE_EMA,PRICE_CLOSE);
//   
//   
//   ArraySetAsSeries(MovingAverageArray1,true);
//   ArraySetAsSeries(MovingAverageArray2,true);
//   
//   CopyBuffer(MovingAverageDefinition1,0,0,3,MovingAverageArray1);
//   CopyBuffer(MovingAverageDefinition2,0,0,3,MovingAverageArray2);
//
//   if((MovingAverageArray1[0]>MovingAverageArray2[0]) && (MovingAverageArray1[1]<MovingAverageArray2[1]))
//     {
//      Print(_Period," Compre");
//     }  
//
//   if((MovingAverageArray1[0]<MovingAverageArray2[0]) && (MovingAverageArray1[1]>MovingAverageArray2[1]))
//     {
//      Print("Venda");
//     } 


   


   //TotalProfit();
   return(rates_total);   
  }
//+------------------------------------------------------------------+

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
  {
   // pega as variaveis dinamicas  
   PegaVariaveisDinamicas();
   // chama Orientacao de Compra ou Venda ou Neutra
   ChamaOrientacao();
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
  }
  

//bool TotalProfit()
//   {
//   double PositionProfit = 0;
//     if(PositionSelect(_Symbol)==true)
//      {
//        
//   
//         //double pft=0;
//         
//         for(int i=PositionsTotal()-1;i>=0;i--)
//           {
//            ulong ticket=PositionGetTicket(i);
//            
//            if(ticket>0)
//              {
//              Print(ticket);
//               //if(PositionGetInteger(POSITION_MAGIC)==magic && PositionGetString(POSITION_SYMBOL)==Symbol())
//                 //{
//                  //pft+=PositionGetDouble(POSITION_PROFIT);
//                  double PositionProfit = PositionGetDouble(POSITION_PROFIT);
//                 //}
//                 Print(PositionProfit);
//              }
//           }
//      }
//      
//      return(true);
//   }