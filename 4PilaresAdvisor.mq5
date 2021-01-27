//+------------------------------------------------------------------+
//|                                                 WillyAdvisor.mq5 |
//|                              Copyright 2020, Andre Vinicius Lima |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Gustavo de Souza Lima Baseado no Andre Vinicius"
#property link      "https://www.mql5.com"
#property version   "1.3.2"
#property indicator_chart_window
#include "PainelConfiguracao.mq5"

// Variaveis

int QtdeMesesHistoricos = DadosHistoricos;
color CorQuadroOrientacao;
int FonteBase1 = 8;
int FonteBase2 = 9;
int FontePaddingLeft = 7;
int OrientacaoDistanciaEsquerda;
int PosicaoDistanciaMediana = 87;
string TextoMediana;
double Topo;
double Fundo;
double Mediana;
double MargemAteOndeOperar;
int MenorCandle, MaiorCandle;
double ArrayPrecosHistoricos[120];
int DistanciaMediana;
string Orientacao;
bool IsJPY;
double MediaUltimosAnos;
string OrientacaoFundoOuTopo;
string TextoLoteDisponivel;

// Variaveis Dinamicas

double PrecoAsk;
double PrecoBid;
double SwapVenda;
double SwapCompra;
double SpreadAtual;

bool PegaVariaveisDinamicas(){
   PrecoAsk = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   PrecoBid = NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_BID),5);
   SwapVenda = SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT);
   SwapCompra = SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG);
   SpreadAtual = SymbolInfoInteger(Symbol(),SYMBOL_SPREAD);
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
MqlDateTime Time;
TimeCurrent(Time);

// carrega variaveis dinamicas
PegaVariaveisDinamicas();  

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
      MargemAteOndeOperar = Mediana - PontosAteMediana;
      
      
      Mediana = NormalizeDouble(Mediana,5);

      // Media de Preço que a moeda ficou nos ultimos anos
      MediaUltimosAnos = NormalizeDouble(CalculaMediaUltimosAnos(),5);

// carrega parte visual do Display
#include "Estilos.mq5"

          
   return(INIT_SUCCEEDED);
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
 
   double timesBiggerThanHundredDollarBalance = MathFloor(getMoney(status) / 100);
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
//| Modificação pra pegar o Maior Valor                 |
//+------------------------------------------------------------------+   
      PegaVariaveisDinamicas(); // pega dinamicamente
      DistanciaMediana = (PrecoBid - Mediana)*100000;
      // Se a moeda operada for JPY      
      if(StringFind(Symbol(), "JPY") >= 0)
        {
         IsJPY = true;
         DistanciaMediana = (PrecoBid - MargemAteOndeOperar)*1000;
         Mediana = NormalizeDouble(Mediana,3);
         MediaUltimosAnos = NormalizeDouble(CalculaMediaUltimosAnos(),3);
        }


      OrientacaoDistanciaEsquerda = 70;  
      // Orientação de compra ou venda e SWAP    
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
               OrientacaoDistanciaEsquerda = 50;
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
               OrientacaoDistanciaEsquerda = 50;
               CorQuadroOrientacao = clrBlack;
            }     
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
                 
         if(Symbol()==ParOperado)
         {
            PosicoesAbertasNoPar += 1; // Quantidade do par operado no momento
            LotesUsados += PositionGetDouble(POSITION_VOLUME); // lotes operados no momento no par
         }
         ParesAbertosMomento[i] = PositionGetSymbol(i);
              
       }
      
   

//Print(TerminalInfoInteger(TERMINAL_SCREEN_WIDTH));



      // Display do Indicador
    

         // Valor Lote em Uso DINÂMICO
         ObjectSetString(0,"ValorLoteUso",OBJPROP_TEXT,DoubleToString(status.lots,2));


         // Valor Lote Disponivel DINÂMICO
         ObjectSetString(0,"ValorLoteDisponivel",OBJPROP_TEXT,DoubleToString(lotsAvailable,2));


         // Valor Operações nesse Par DINÂMICO
         ObjectSetString(0,"ValorPosicaoAberta",OBJPROP_TEXT,DoubleToString(PosicoesAbertasNoPar,0));


         // Valor Lotes Operados nesse Par DINÂMICO
         ObjectSetString(0,"ValorLotesOperadosNoPar",OBJPROP_TEXT,DoubleToString(LotesUsados,2));

  
         // Valor Distancia Mediana DINÂMICO
         ObjectSetString(0,"ValorDistanciaMediana",OBJPROP_TEXT,DoubleToString(DistanciaMediana,0) + " Pts");
         ObjectSetString(0,"DistanciaMediana",OBJPROP_TEXT,TextoMediana);
         
         
         // Valor Swap Compra DINÂMICO
         ObjectSetString(0,"ValorSwapCompra",OBJPROP_TEXT,DoubleToString(SwapCompra,2));

        
         // Valor Swap Venda DINÂMICO
         ObjectSetString(0,"ValorSwapVenda",OBJPROP_TEXT,DoubleToString(SwapVenda,2));


         // Valor Spread DINÂMICO
         ObjectSetString(0,"ValorSpread",OBJPROP_TEXT,DoubleToString(SpreadAtual,0));


         // Topo ou Fundo DINÂMICO
         ObjectSetString(0,"OrientacaoTopoFundo",OBJPROP_TEXT,OrientacaoFundoOuTopo);
         
         // Orientacao Compra, Vende ou Aguarda
         ObjectSetString(0,"OrientacaoCompraVenda",OBJPROP_TEXT,Orientacao);
         ObjectSetInteger(0,"OrientacaoCompraVenda",OBJPROP_XDISTANCE,OrientacaoDistanciaEsquerda);
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
         
         if(SpreadAtual>=50.0)
         {
            ObjectSetInteger(0,"ValorSpread",OBJPROP_COLOR,clrSalmon);
         }
         else if(SpreadAtual<50.0 && SpreadAtual>30)
         {
            ObjectSetInteger(0,"ValorSpread",OBJPROP_COLOR,clrDodgerBlue);
         }
         else if(SpreadAtual<=30.0)
         {
            ObjectSetInteger(0,"ValorSpread",OBJPROP_COLOR,clrLimeGreen);
         }
              

//      //availableLotsWarn  


   return(rates_total);
  }
//+------------------------------------------------------------------+

