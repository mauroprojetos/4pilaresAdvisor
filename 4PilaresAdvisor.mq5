//+------------------------------------------------------------------+
//|                                                 WillyAdvisor.mq5 |
//|                              Copyright 2020, Andre Vinicius Lima |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Gustavo de Souza Lima Baseado no Andre Vinicius"
#property link      "https://www.mql5.com"
#property version   "1.2"
#property indicator_chart_window
#include <Controls\Dialog.mqh>

CAppDialog AppWindow;

int QtdeMesesHistoricos = 60; //5 ultimos anos, 60 candles

enum CalculusBaseType { 
   CapitalLiquido=0, //Capital Líquido
   Balanca=1 //Saldo
};

double CalculaMediaUltimosAnos(int iBar=0, int count=61) //5 ultimos anos, 60 candles
{
   double sum = 0.0;
   for(int iEnd = iBar+count; iBar < iEnd; ++iBar) sum += iClose(NULL,PERIOD_MN1,iBar);
   
   return sum/QtdeMesesHistoricos;
}


string listaParesAbertos[];
string listaPrimeiraMoedaPar[];
string ParesOperados[];


int totalpairs(int total)
  {
   //Print(total);
   ArrayResize(listaParesAbertos,total);
   ArrayResize(listaPrimeiraMoedaPar,total);
   ArrayResize(ParesOperados,total);   
   
   for(int i=0; i<PositionsTotal(); i++) {
   
      listaParesAbertos[i] = PositionGetSymbol(i);
      string compare = StringSubstr(listaParesAbertos[i],0,3);

      int comp_2 = 0;
      int contagem = 0;
      
         for(int xx=0;xx<=PositionsTotal()-1;xx++){
            if(compare==StringSubstr(listaParesAbertos[xx],0,3)){
               comp_2=comp_2+1;                             
            }

            ParesOperados[i] = compare;
            //Print(compare,"  repeats  ",comp_2, " times");
         }
      }

   return(total);
  
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

//--- create application dialog
   //if(!AppWindow.Create(0,"AppWindow",0,20,20,360,324))
   //   return(INIT_FAILED);
//--- run application
   //AppWindow.Run();
//--- succeed
   
   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy dialog
   AppWindow.Destroy(reason);
  }
//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type
  {
   AppWindow.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
  
  
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
      
// Variaveis

      double Topo;
      double Fundo;
      double Mediana;
      double MargemAteOndeOperar;
      double PontosAteMediana;
      double PrecoAsk = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
      double PrecoBid = NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_BID),5);
      int DistanciaMediana;
      string Orientacao;
      double SwapVenda = SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT);
      double SwapCompra = SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG);
      double SpreadAtual = SymbolInfoInteger(Symbol(),SYMBOL_SPREAD);
      bool IsJPY;
      double MediaUltimosAnos;
       
//+------------------------------------------------------------------+
//| Calculo Topo e Fundo                 |
//+------------------------------------------------------------------+ 
        
      int MenorCandle, MaiorCandle;
      double ArrayPrecosHistoricos[60];
      
      // Array com os preços dos ultimos 5 anos
      for(int i=QtdeMesesHistoricos-1; i>=0; i--){
         ArrayPrecosHistoricos[i] = NormalizeDouble(iClose(_Symbol,PERIOD_MN1,i),5);
      }
      
      MenorCandle = ArrayMinimum(ArrayPrecosHistoricos,0,QtdeMesesHistoricos);
      MaiorCandle = ArrayMaximum(ArrayPrecosHistoricos,0,QtdeMesesHistoricos);
     
      Topo = ArrayPrecosHistoricos[MaiorCandle];
      Fundo= ArrayPrecosHistoricos[MenorCandle];
        
      PontosAteMediana = 0.0100; // em pontos
      Mediana = (Topo + Fundo) / 2;
      MargemAteOndeOperar = Mediana - PontosAteMediana;
      
      Mediana = NormalizeDouble(Mediana,5);
      DistanciaMediana = (PrecoBid - Mediana)*100000;

      // Media de Preço que a moeda ficou nos ultimos anos
      MediaUltimosAnos = NormalizeDouble(CalculaMediaUltimosAnos(),5);

      // Se a moeda operada for JPY      
      if(StringFind(Symbol(), "JPY") >= 0)
        {
         IsJPY = true;
         DistanciaMediana = (PrecoBid - MargemAteOndeOperar)*1000;
         Mediana = NormalizeDouble(Mediana,3);
         MediaUltimosAnos = NormalizeDouble(CalculaMediaUltimosAnos(),3);
        }


      // Orientação de compra ou venda e SWAP    
      if(PrecoBid>Mediana && PrecoBid>MargemAteOndeOperar)
        {
         Orientacao="VENDA";

         ObjectSetString(0,"Orientacao3",OBJPROP_TEXT,"Topo");
         ObjectSetString(0,"Orientacao2",OBJPROP_TEXT,Orientacao);
         
        }
      else if(PrecoBid<Mediana && PrecoBid<MargemAteOndeOperar)
        {
         Orientacao="COMPRA";

         ObjectSetString(0,"Orientacao3",OBJPROP_TEXT,"Fundo");
         ObjectSetInteger(0,"Orientacao2",OBJPROP_XDISTANCE,290);
         ObjectSetString(0,"Orientacao2",OBJPROP_TEXT,Orientacao);     
        }
      else if(PrecoBid<Mediana && PrecoBid>MargemAteOndeOperar)
        {   
         Orientacao="AGUARDE";
        }
      else if(PrecoBid>Mediana && PrecoBid<MargemAteOndeOperar)
        {   
         Orientacao="AGUARDE";
        }
      else Print("ERROR ORIENTACAO");

//+------------------------------------------------------------------+
//| Mostra se o par esta aberto no momento                 |
//+------------------------------------------------------------------+    

   int PosicoesAbertasNoPar = 0;
   double LotesUsados = 0.0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      {
         string ParOperado = PositionGetSymbol(i);
         
         if(Symbol()==ParOperado)
         {
            PosicoesAbertasNoPar += 1; // Quantidade do par operado no momento
            LotesUsados += PositionGetDouble(POSITION_VOLUME); // lotes operados no momento no par
         }
      
      }


//totalpairs(PositionsTotal());



      // Display do Indicador


         // Creditos
         ObjectCreate(0,"Creditos1",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"Creditos1",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"Creditos1",OBJPROP_TEXT,"4 PILARES Advisor v1.2");
         ObjectSetInteger(0,"Creditos1",OBJPROP_XDISTANCE,10);
         ObjectSetInteger(0,"Creditos1",OBJPROP_YDISTANCE,15);
         ObjectSetInteger(0,"Creditos1",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"Creditos1",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "Creditos1", OBJPROP_BACK, false);
         
         // Texto Orientacao
         ObjectCreate(0,"Orientacao1",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"Orientacao1",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"Orientacao1",OBJPROP_TEXT,"Orientação:");
         ObjectSetInteger(0,"Orientacao1",OBJPROP_XDISTANCE,3);
         ObjectSetInteger(0,"Orientacao1",OBJPROP_YDISTANCE,205);
         ObjectSetInteger(0,"Orientacao1",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"Orientacao1",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "Orientacao1", OBJPROP_BACK, false);
         
         // Compra, Vende ou Aguarda   
         ObjectCreate(0,"Orientacao2",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"Orientacao2",OBJPROP_FONTSIZE,9);
         ObjectSetString(0,"Orientacao2",OBJPROP_FONT, "Arial Black");
         ObjectSetString(0,"Orientacao2",OBJPROP_TEXT,Orientacao);
         ObjectSetInteger(0,"Orientacao2",OBJPROP_XDISTANCE,97);
         ObjectSetInteger(0,"Orientacao2",OBJPROP_YDISTANCE,204);
         ObjectSetInteger(0,"Orientacao2",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"Orientacao2",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "Orientacao2", OBJPROP_BACK, false);

         // Topo ou Fundo
         ObjectCreate(0,"Orientacao3",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"Orientacao3",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"Orientacao3",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"Orientacao3",OBJPROP_TEXT,"Fundo");
         ObjectSetInteger(0,"Orientacao3",OBJPROP_XDISTANCE,63);
         ObjectSetInteger(0,"Orientacao3",OBJPROP_YDISTANCE,205);
         ObjectSetInteger(0,"Orientacao3",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"Orientacao3",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "Orientacao3", OBJPROP_BACK, false);

         // Lote em Uso
         ObjectCreate(0,"LoteUso",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"LoteUso",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"LoteUso",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"LoteUso",OBJPROP_TEXT,"Lote em Uso:");
         ObjectSetInteger(0,"LoteUso",OBJPROP_XDISTANCE,7);
         ObjectSetInteger(0,"LoteUso",OBJPROP_YDISTANCE,62);
         ObjectSetInteger(0,"LoteUso",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"LoteUso",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "LoteUso", OBJPROP_BACK, false);

         // Valor Lote em Uso
         ObjectCreate(0,"ValorLoteUso",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorLoteUso",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"ValorLoteUso",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"ValorLoteUso",OBJPROP_TEXT,DoubleToString(status.lots,2));
         ObjectSetInteger(0,"ValorLoteUso",OBJPROP_XDISTANCE,82);
         ObjectSetInteger(0,"ValorLoteUso",OBJPROP_YDISTANCE,62);
         ObjectSetInteger(0,"ValorLoteUso",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"ValorLoteUso",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "ValorLoteUso", OBJPROP_BACK, false);

//         // Lote Maximo
//         ObjectCreate(0,"LoteMaximo",OBJ_LABEL,0,0,0,0,0,0,0);
//         ObjectSetInteger(0,"LoteMaximo",OBJPROP_FONTSIZE,8);
//         ObjectSetString(0,"LoteMaximo",OBJPROP_FONT, "Arial");
//         ObjectSetString(0,"LoteMaximo",OBJPROP_TEXT,"Lote Máximo:");
//         ObjectSetInteger(0,"LoteMaximo",OBJPROP_XDISTANCE,200);
//         ObjectSetInteger(0,"LoteMaximo",OBJPROP_YDISTANCE,77);
//         ObjectSetInteger(0,"LoteMaximo",OBJPROP_CORNER,CORNER_LEFT_UPPER);
//         ObjectSetInteger(0,"LoteMaximo",OBJPROP_COLOR,clrSnow);
//         ObjectSetInteger(0, "LoteMaximo", OBJPROP_BACK, false);
//
//         // Valor Lote Maximo
//         ObjectCreate(0,"ValorLoteMaximo",OBJ_LABEL,0,0,0,0,0,0,0);
//         ObjectSetInteger(0,"ValorLoteMaximo",OBJPROP_FONTSIZE,8);
//         ObjectSetString(0,"ValorLoteMaximo",OBJPROP_FONT, "Arial");
//         ObjectSetString(0,"ValorLoteMaximo",OBJPROP_TEXT,DoubleToString(maxLots,2));
//         ObjectSetInteger(0,"ValorLoteMaximo",OBJPROP_XDISTANCE,276);
//         ObjectSetInteger(0,"ValorLoteMaximo",OBJPROP_YDISTANCE,77);
//         ObjectSetInteger(0,"ValorLoteMaximo",OBJPROP_CORNER,CORNER_LEFT_UPPER);
//         ObjectSetInteger(0,"ValorLoteMaximo",OBJPROP_COLOR,clrSnow);
//         ObjectSetInteger(0, "ValorLoteMaximo", OBJPROP_BACK, false);

         // Lote Disponivel
         ObjectCreate(0,"LoteDisponivel",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"LoteDisponivel",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"LoteDisponivel",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"LoteDisponivel",OBJPROP_TEXT,"Lote Disponível:");
         ObjectSetInteger(0,"LoteDisponivel",OBJPROP_XDISTANCE,7);
         ObjectSetInteger(0,"LoteDisponivel",OBJPROP_YDISTANCE,82);
         ObjectSetInteger(0,"LoteDisponivel",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"LoteDisponivel",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "LoteDisponivel", OBJPROP_BACK, false);

         // Valor Lote Disponivel
         ObjectCreate(0,"ValorLoteDisponivel",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"ValorLoteDisponivel",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"ValorLoteDisponivel",OBJPROP_TEXT,DoubleToString(lotsAvailable <= 0 ? 0 : lotsAvailable, 2) + (lotsAvailable < 0 ? " (Ultrapassou: " + DoubleToString(lotsAvailable * -1, 2) + ")": ""));
         ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_XDISTANCE,86);
         ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_YDISTANCE,82);
         ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "ValorLoteDisponivel", OBJPROP_BACK, false);

         // Preco Atual do Ativo
         ObjectCreate(0,"PrecoAtualAtivo",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"PrecoAtualAtivo",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"PrecoAtualAtivo",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"PrecoAtualAtivo",OBJPROP_TEXT,"Preço Atual:");
         ObjectSetInteger(0,"PrecoAtualAtivo",OBJPROP_XDISTANCE,195);
         ObjectSetInteger(0,"PrecoAtualAtivo",OBJPROP_YDISTANCE,112);
         ObjectSetInteger(0,"PrecoAtualAtivo",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"PrecoAtualAtivo",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "PrecoAtualAtivo", OBJPROP_BACK, false);

         // Valor Preco Atual do Ativo
         ObjectCreate(0,"ValorPrecoAtualAtivo",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorPrecoAtualAtivo",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"ValorPrecoAtualAtivo",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"ValorPrecoAtualAtivo",OBJPROP_TEXT,DoubleToString(PrecoBid,5));
         ObjectSetInteger(0,"ValorPrecoAtualAtivo",OBJPROP_XDISTANCE,260);
         ObjectSetInteger(0,"ValorPrecoAtualAtivo",OBJPROP_YDISTANCE,112);
         ObjectSetInteger(0,"ValorPrecoAtualAtivo",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"ValorPrecoAtualAtivo",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "ValorPrecoAtualAtivo", OBJPROP_BACK, false);

         // Distancia da Mediana
         ObjectCreate(0,"DistanciaMediana",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"DistanciaMediana",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"DistanciaMediana",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"DistanciaMediana",OBJPROP_TEXT,"Até a Mediana:");
         ObjectSetInteger(0,"DistanciaMediana",OBJPROP_XDISTANCE,195);
         ObjectSetInteger(0,"DistanciaMediana",OBJPROP_YDISTANCE,130);
         ObjectSetInteger(0,"DistanciaMediana",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"DistanciaMediana",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "DistanciaMediana", OBJPROP_BACK, false);

         // Valor Distancia Mediana
         ObjectCreate(0,"ValorDistanciaMediana",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorDistanciaMediana",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"ValorDistanciaMediana",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"ValorDistanciaMediana",OBJPROP_TEXT,DistanciaMediana + " Pontos");
         ObjectSetInteger(0,"ValorDistanciaMediana",OBJPROP_XDISTANCE,270);
         ObjectSetInteger(0,"ValorDistanciaMediana",OBJPROP_YDISTANCE,130);
         ObjectSetInteger(0,"ValorDistanciaMediana",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"ValorDistanciaMediana",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "ValorDistanciaMediana", OBJPROP_BACK, false);

         // Posicoes Abertas nesse Par
         ObjectCreate(0,"PosicaoAberta",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"PosicaoAberta",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"PosicaoAberta",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"PosicaoAberta",OBJPROP_TEXT,"Operações nesse Par:");
         ObjectSetInteger(0,"PosicaoAberta",OBJPROP_XDISTANCE,195);
         ObjectSetInteger(0,"PosicaoAberta",OBJPROP_YDISTANCE,150);
         ObjectSetInteger(0,"PosicaoAberta",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"PosicaoAberta",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "PosicaoAberta", OBJPROP_BACK, false);

         // Valor Posicoes Abertas nesse Par
         ObjectCreate(0,"ValorPosicaoAberta",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorPosicaoAberta",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"ValorPosicaoAberta",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"ValorPosicaoAberta",OBJPROP_TEXT,PosicoesAbertasNoPar);
         ObjectSetInteger(0,"ValorPosicaoAberta",OBJPROP_XDISTANCE,310);
         ObjectSetInteger(0,"ValorPosicaoAberta",OBJPROP_YDISTANCE,150);
         ObjectSetInteger(0,"ValorPosicaoAberta",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"ValorPosicaoAberta",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "ValorPosicaoAberta", OBJPROP_BACK, false);

         // Lotes Operados nesse Par
         ObjectCreate(0,"LotesOperadosNoPar",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"LotesOperadosNoPar",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"LotesOperadosNoPar",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"LotesOperadosNoPar",OBJPROP_TEXT,"Lotes nesse Par:");
         ObjectSetInteger(0,"LotesOperadosNoPar",OBJPROP_XDISTANCE,195);
         ObjectSetInteger(0,"LotesOperadosNoPar",OBJPROP_YDISTANCE,167);
         ObjectSetInteger(0,"LotesOperadosNoPar",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"LotesOperadosNoPar",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "LotesOperadosNoPar", OBJPROP_BACK, false);

         // Valor Lotes Operados nesse Par
         ObjectCreate(0,"ValorLotesOperadosNoPar",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorLotesOperadosNoPar",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"ValorLotesOperadosNoPar",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"ValorLotesOperadosNoPar",OBJPROP_TEXT,LotesUsados);
         ObjectSetInteger(0,"ValorLotesOperadosNoPar",OBJPROP_XDISTANCE,285);
         ObjectSetInteger(0,"ValorLotesOperadosNoPar",OBJPROP_YDISTANCE,167);
         ObjectSetInteger(0,"ValorLotesOperadosNoPar",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"ValorLotesOperadosNoPar",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "ValorLotesOperadosNoPar", OBJPROP_BACK, false);


         // *** Background
         ObjectCreate(0, "Rectangle", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Rectangle", OBJPROP_XDISTANCE, 0);
         ObjectSetInteger(0, "Rectangle", OBJPROP_YDISTANCE, 13);
         ObjectSetInteger(0, "Rectangle", OBJPROP_XSIZE, 356);
         ObjectSetInteger(0, "Rectangle", OBJPROP_YSIZE, 175);
         ObjectSetInteger(0, "Rectangle", OBJPROP_BGCOLOR, clrDarkSlateGray);
         ObjectSetInteger(0, "Rectangle", OBJPROP_BACK, true);
         //ObjectSetInteger(0, "Rectangle", OBJPROP_ZORDER, 99);


         // *** Quadro1
         ObjectCreate(0, "Quadro1", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Quadro1", OBJPROP_XDISTANCE, 0);
         ObjectSetInteger(0, "Quadro1", OBJPROP_YDISTANCE, 13);
         ObjectSetInteger(0, "Quadro1", OBJPROP_XSIZE, 159);
         ObjectSetInteger(0, "Quadro1", OBJPROP_YSIZE, 25);
         ObjectSetInteger(0,"Quadro1",OBJPROP_XDISTANCE,1);
         ObjectSetInteger(0,"Quadro1",OBJPROP_YDISTANCE,200);
         ObjectSetInteger(0, "Quadro1", OBJPROP_BGCOLOR, clrDarkGreen);
         ObjectSetInteger(0, "Quadro1",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Quadro1",OBJPROP_BORDER_COLOR,clrOldLace);
         ObjectSetInteger(0, "Quadro1", OBJPROP_BACK, true);

         // *** Quadro2
         ObjectCreate(0, "Quadro2", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Quadro2", OBJPROP_XDISTANCE, 0);
         ObjectSetInteger(0, "Quadro2", OBJPROP_YDISTANCE, 13);
         ObjectSetInteger(0, "Quadro2", OBJPROP_XSIZE, 159);
         ObjectSetInteger(0, "Quadro2", OBJPROP_YSIZE, 54);
         ObjectSetInteger(0,"Quadro2",OBJPROP_XDISTANCE,1);
         ObjectSetInteger(0,"Quadro2",OBJPROP_YDISTANCE,28);
         ObjectSetInteger(0, "Quadro2", OBJPROP_BGCOLOR, clrMaroon);
         ObjectSetInteger(0, "Quadro2",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Quadro2", OBJPROP_BACK, true);

         // *** Quadro3
         ObjectCreate(0, "Quadro3", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Quadro3", OBJPROP_XDISTANCE, 0);
         ObjectSetInteger(0, "Quadro3", OBJPROP_YDISTANCE, 13);
         ObjectSetInteger(0, "Quadro3", OBJPROP_XSIZE, 153);
         ObjectSetInteger(0, "Quadro3", OBJPROP_YSIZE, 50);
         ObjectSetInteger(0,"Quadro3",OBJPROP_XDISTANCE,4);
         ObjectSetInteger(0,"Quadro3",OBJPROP_YDISTANCE,30);
         ObjectSetInteger(0, "Quadro3", OBJPROP_BGCOLOR, clrDarkSlateGray);
         ObjectSetInteger(0, "Quadro3",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Quadro3",OBJPROP_BORDER_COLOR,clrOldLace);
         ObjectSetInteger(0, "Quadro3", OBJPROP_BACK, true);         
    

   const string line = "+-----------------------------------------------------------+\n";
   const string lineMenor = "#-------------------------------------#";
   
//   Comment(
//      //+isAnMainCurrency
//      //availableLotsWarn  
//      //+lineMenor
//      
//      "\n"+      
//     
//      "Topo Histórico: " + DoubleToString(Topo,5)
//      
//      +"\n"+
//      
//      "Fundo Histórico: " + DoubleToString(Fundo,5)  
//      
//      +"\n"+
//      
//      "Mediana: " + DoubleToString(Mediana,5)
//      
//      +"\n"+   
//      
//      "Média Ultimos Anos: " + DoubleToString(MediaUltimosAnos,5)  
//      
//      
//      +"\n"+
//      
//      lineMenor
//      
//      +"\n"+
//      
//      "Spread Atual: " + SpreadAtual
//      
//      +"  (30 Pontos ideal)"
//      
//      +"\n"+
//      
//      "Swap de Compra: "+ SwapCompra
//
//      +"\n"+
//      
//      "Swap de Venda: "+ SwapVenda
//      
//      );

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+



