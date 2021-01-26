//+------------------------------------------------------------------+
//|                                                 WillyAdvisor.mq5 |
//|                              Copyright 2020, Andre Vinicius Lima |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Gustavo de Souza Lima Baseado no Andre Vinicius"
#property link      "https://www.mql5.com"
#property version   "1.3.1"
#property indicator_chart_window
#property strict

//--- parâmetros de entrada
#property script_show_inputs

//Example 1
enum intOptionsA{
   Anos10 = 120,
   Anos5 = 60,
   Anos3 = 36,
};
  
input intOptionsA DadosHistoricos = Anos10;

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
      string OrientacaoFundoOuTopo;
      string TextoLoteDisponivel;
      string TextoMediana;
      int OrientacaoDistancia;
      int PosicaoDistanciaMediana;
       
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

      OrientacaoDistancia = 74;
      PosicaoDistanciaMediana = 85;   
      // Orientação de compra ou venda e SWAP    
      if(PrecoBid>Mediana)  
        {
         TextoMediana = "Acima Mediana:";
         MargemAteOndeOperar = Mediana + PontosAteMediana;
            if(PrecoBid>MargemAteOndeOperar)
            {
               Orientacao="VENDA";           
               OrientacaoFundoOuTopo = "Topo";
            }
            else if(PrecoBid<MargemAteOndeOperar)
            {   
               Orientacao="AGUARDE";
               OrientacaoFundoOuTopo = " ";
               OrientacaoDistancia = 55;
            } 
        }
      else if(PrecoBid<Mediana)
        {
         TextoMediana = "Abaixo Mediana:";
         MargemAteOndeOperar = Mediana - PontosAteMediana;
         DistanciaMediana = DistanciaMediana * -1;
         PosicaoDistanciaMediana = 91;
            if(PrecoBid<MargemAteOndeOperar)
            {
               Orientacao="COMPRA";        
               OrientacaoFundoOuTopo = "Fundo";
            }
            else if(PrecoBid>MargemAteOndeOperar)
            {   
               Orientacao="AGUARDE";
               OrientacaoFundoOuTopo = " ";
               OrientacaoDistancia = 55;
            }
        }
      
//+------------------------------------------------------------------+
//| Linhas desenhadas no grafico                 |
//+------------------------------------------------------------------+ 
   ResetLastError();

   if(!ObjectCreate(0,"LinhaTopoHistorico",OBJ_HLINE,0,0,Topo))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }   
   else if(!ObjectCreate(0,"LinhaMediana",OBJ_HLINE,0,0,Mediana) || GetLastError()!=0)
   {
      Print("Error creating object: ",GetLastError());
   }
   else if(!ObjectCreate(0,"LinhaFundoHistorico",OBJ_HLINE,0,0,Fundo) || GetLastError()!=0)
   {
      Print("Error creating object: ",GetLastError());
   }
   else
   
   // Cores das linhas   
   ChartRedraw(0);
   //--- set line color
   ObjectSetInteger(0,"LinhaTopoHistorico",OBJPROP_COLOR,clrDodgerBlue);
   ObjectSetInteger(0,"LinhaMediana",OBJPROP_COLOR,clrGold);
   ObjectSetInteger(0,"LinhaFundoHistorico",OBJPROP_COLOR,clrSalmon);
   //--- set line display style
   ObjectSetInteger(0,"LinhaMediana",OBJPROP_STYLE,STYLE_DASH);
   //--- set line width
   ObjectSetInteger(0,"LinhaMediana",OBJPROP_WIDTH,2);
   //Texto das linhas
   //ObjectSetString(0,"LinhaTopoHistorico",OBJPROP_TEXT,"Topo Histórico");
   //ObjectSetString(0,"LinhaMediana",OBJPROP_TEXT,"Mediana");
   //ObjectSetString(0,"LinhaFundoHistorico",OBJPROP_TEXT,"Fundo Histórico");
   //ChartSetInteger(0, CHART_SHOW_OBJECT_DESCR, false);
   
  
   //Topo Historico Label
   ObjectCreate(0,"TopoLabel",OBJ_TEXT,0,"Topo Histórico",0);
   ObjectSetString(0, "TopoLabel", OBJPROP_TEXT, "Topo Histórico");
   ObjectSetInteger(0, "TopoLabel",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,"TopoLabel",OBJPROP_XDISTANCE,20);
   ObjectSetInteger(0,"TopoLabel",OBJPROP_YDISTANCE,20);
   ObjectSetDouble(0,"TopoLabel", OBJPROP_PRICE, Topo);
   ObjectSetString(0,"TopoLabel",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"TopoLabel",OBJPROP_FONTSIZE,11);
   ObjectSetDouble(0,"TopoLabel",OBJPROP_ANGLE,0.0);
   ObjectSetInteger(0,"TopoLabel",OBJPROP_COLOR,clrDodgerBlue);
   ObjectSetInteger(0,"TopoLabel",OBJPROP_BACK,false);
   ObjectSetInteger(0,"TopoLabel",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"TopoLabel",OBJPROP_SELECTED,false);
   ObjectSetInteger(0,"TopoLabel",OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,"TopoLabel",OBJPROP_ZORDER,0);
   //Mediana Label
   ObjectCreate(0,"MedianaLabel",OBJ_TEXT,0,"Mediana",0);
   ObjectSetString(0, "MedianaLabel", OBJPROP_TEXT, "Mediana");
   ObjectSetInteger(0, "MedianaLabel",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,"MedianaLabel",OBJPROP_XDISTANCE,20);
   ObjectSetInteger(0,"MedianaLabel",OBJPROP_YDISTANCE,20);
   ObjectSetDouble(0,"MedianaLabel", OBJPROP_PRICE, Mediana);
   ObjectSetString(0,"MedianaLabel",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"MedianaLabel",OBJPROP_FONTSIZE,11);
   ObjectSetDouble(0,"MedianaLabel",OBJPROP_ANGLE,0.0);
   ObjectSetInteger(0,"MedianaLabel",OBJPROP_COLOR,clrGold);
   ObjectSetInteger(0,"MedianaLabel",OBJPROP_BACK,false);
   ObjectSetInteger(0,"MedianaLabel",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"MedianaLabel",OBJPROP_SELECTED,false);
   ObjectSetInteger(0,"MedianaLabel",OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,"MedianaLabel",OBJPROP_ZORDER,0);
   //Fundo Historico Label
   ObjectCreate(0,"FundoLabel",OBJ_TEXT,0,"Fundo Histórico",0);
   ObjectSetString(0, "FundoLabel", OBJPROP_TEXT, "Fundo Histórico");
   ObjectSetInteger(0, "FundoLabel",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,"FundoLabel",OBJPROP_XDISTANCE,20);
   ObjectSetInteger(0,"FundoLabel",OBJPROP_YDISTANCE,20);
   ObjectSetDouble(0,"FundoLabel", OBJPROP_PRICE, Fundo);
   ObjectSetString(0,"FundoLabel",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"FundoLabel",OBJPROP_FONTSIZE,11);
   ObjectSetDouble(0,"FundoLabel",OBJPROP_ANGLE,0.0);
   ObjectSetInteger(0,"FundoLabel",OBJPROP_COLOR,clrSalmon);
   ObjectSetInteger(0,"FundoLabel",OBJPROP_BACK,false);
   ObjectSetInteger(0,"FundoLabel",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"FundoLabel",OBJPROP_SELECTED,false);
   ObjectSetInteger(0,"FundoLabel",OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,"FundoLabel",OBJPROP_ZORDER,0);
   //Preco atual
   ObjectCreate(0,"PrecoAtualLabel",OBJ_TEXT,0,"Preço Atual",0);
   ObjectSetString(0, "PrecoAtualLabel", OBJPROP_TEXT, "Preço Atual");
   ObjectSetInteger(0, "PrecoAtualLabel",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,"PrecoAtualLabel",OBJPROP_XDISTANCE,20);
   ObjectSetInteger(0,"PrecoAtualLabel",OBJPROP_YDISTANCE,20);
   ObjectSetDouble(0,"PrecoAtualLabel", OBJPROP_PRICE, PrecoBid);
   ObjectSetString(0,"PrecoAtualLabel",OBJPROP_FONT,"Arial Black");
   ObjectSetInteger(0,"PrecoAtualLabel",OBJPROP_FONTSIZE,8);
   ObjectSetDouble(0,"PrecoAtualLabel",OBJPROP_ANGLE,0.0);
   ObjectSetInteger(0,"PrecoAtualLabel",OBJPROP_COLOR,clrGray);
   ObjectSetInteger(0,"PrecoAtualLabel",OBJPROP_BACK,false);
   ObjectSetInteger(0,"PrecoAtualLabel",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"PrecoAtualLabel",OBJPROP_SELECTED,false);
   ObjectSetInteger(0,"PrecoAtualLabel",OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,"PrecoAtualLabel",OBJPROP_ZORDER,0);    
      

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
      
   

//string Pair[1];
//int size=1;
//bool flag;
////ArrayResize(Pair,PositionsTotal());
//int contarRepetido = 0;
//
//ArrayResize(ParesSemDuplicados,ArraySize(ParesAbertosMomento));
//for(int i=0;i<PositionsTotal();i++) 
//{
//
//
//      
//      
//      for(int y=0;y<ArraySize(ParesAbertosMomento)-1;y++)
//      {
//         flag=false;
//         if(ParesAbertosMomento[i]==ParesAbertosMomento[y])
//         {
//         //Print(y,flag);
//            contarRepetido += 1;
//            flag=true;
//            break;
//         }
//         
//         //Print("Dentro do for: ",y);
//        //Print(i,flag); 
//         if(true)
//         {
//         
//            ParesSemDuplicados[size-1]=ParesAbertosMomento[i];
//            size += 1;
//            ArrayResize(ParesSemDuplicados,size);
//            //Print(ParesAbertosMomento[size-1]);
//         }         
//      }
//
//   
//   
//}
//
//for(int i=ArraySize(ParesAbertosMomento)-1; i>=0; i--)
//   {
//      Print("Tamanho Lista: ", ArraySize(ParesAbertosMomento), " par ",i,": ", ParesAbertosMomento[i]); 
//   }



//   bool Repitido = false;
//   int TamanhoAposLoop = 0;
//   for(int i=ArraySize(ParesAbertosMomento)-1; i>=0; i--)
//      {
//
//         //ArrayResize(ParesSemDuplicados,ArraySize(ParesAbertosMomento));            
//         for(int b=ArraySize(ParesAbertosMomento)-1; b>=0; b--)
//            {
//
//               
//               
//                  
//                     if(ParesAbertosMomento[i] == ParesAbertosMomento[b]){
//                        if(Repitido)
//                        {
//                           if(TamanhoAposLoop == 1)
//                           {
//                              ArrayRemove(ParesSemDuplicados,i,1);
//                           }  
//                        }
//                        Repitido = true;
//                        TamanhoAposLoop += 1;
//      
//                     }
//                     else
//                     {
//                        Repitido = false;
//                        TamanhoAposLoop = 0;
//       
//                     }
//                     //Print(TamanhoAposLoop);
//            
// 
//               
//               
//            }
//
//            if(Repitido){
//            //ParesSemDuplicados[i] = ParesAbertosMomento[i];
//            
//            
//            }
//            else
//            {
//            
//            //TamanhoAposLoop += 1;
//            //Print("Entrou aqui: ",TamanhoAposLoop);
//            }            
//
//            //Print("Tamanho Lista: ", ArraySize(ParesSemDuplicados), " par ",i,": ", ParesSemDuplicados[i]);  
//      }
//      //Print(ArraySize(ParesSemDuplicados));     
//
//for(int i=ArraySize(ParesSemDuplicados)-1; i>=0; i--)
//   {
//      Print("Tamanho Lista: ", ArraySize(ParesSemDuplicados), " par ",i,": ", ParesSemDuplicados[i]); 
//   }






   // CORES SWAP e SPREAD
   if(status.lots>maxLots)
   {
      ObjectSetInteger(0,"ValorLoteUso",OBJPROP_COLOR,clrSalmon);
      TextoLoteDisponivel = "Lote Disponível:";
   }
   else
   {
      ObjectSetInteger(0,"ValorLoteUso",OBJPROP_COLOR,clrSnow);   
   }
   
   if(lotsAvailable>0)
   {
      ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_COLOR,clrLimeGreen);
      TextoLoteDisponivel = "Lote Disponível:";
   }
   else
   {
      ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_COLOR,clrSalmon);
      TextoLoteDisponivel = "Ultrapassou:";
      lotsAvailable = lotsAvailable * -1;
   }
   
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

//totalpairs(PositionsTotal());

//Print(TerminalInfoInteger(TERMINAL_SCREEN_WIDTH));

      // Display do Indicador


         // Creditos
         ObjectCreate(0,"Creditos1",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"Creditos1",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"Creditos1",OBJPROP_TEXT,"4 PILARES Advisor v1.3.1");
         ObjectSetInteger(0,"Creditos1",OBJPROP_XDISTANCE,10);
         ObjectSetInteger(0,"Creditos1",OBJPROP_YDISTANCE,15);
         ObjectSetInteger(0,"Creditos1",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"Creditos1",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "Creditos1", OBJPROP_BACK, false);
         
         // Lote em Uso
         ObjectCreate(0,"LoteUso",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"LoteUso",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"LoteUso",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"LoteUso",OBJPROP_TEXT,"Lote em Uso:");
         ObjectSetInteger(0,"LoteUso",OBJPROP_XDISTANCE,7);
         ObjectSetInteger(0,"LoteUso",OBJPROP_YDISTANCE,32);
         ObjectSetInteger(0,"LoteUso",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"LoteUso",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "LoteUso", OBJPROP_BACK, false);

         // Valor Lote em Uso
         ObjectCreate(0,"ValorLoteUso",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorLoteUso",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"ValorLoteUso",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"ValorLoteUso",OBJPROP_TEXT,DoubleToString(status.lots,2));
         ObjectSetInteger(0,"ValorLoteUso",OBJPROP_XDISTANCE,74);
         ObjectSetInteger(0,"ValorLoteUso",OBJPROP_YDISTANCE,32);
         ObjectSetInteger(0,"ValorLoteUso",OBJPROP_CORNER,CORNER_LEFT_UPPER);
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
         ObjectSetString(0,"LoteDisponivel",OBJPROP_TEXT,TextoLoteDisponivel);
         ObjectSetInteger(0,"LoteDisponivel",OBJPROP_XDISTANCE,7);
         ObjectSetInteger(0,"LoteDisponivel",OBJPROP_YDISTANCE,47);
         ObjectSetInteger(0,"LoteDisponivel",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"LoteDisponivel",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "LoteDisponivel", OBJPROP_BACK, false);

         // Valor Lote Disponivel
         ObjectCreate(0,"ValorLoteDisponivel",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"ValorLoteDisponivel",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"ValorLoteDisponivel",OBJPROP_TEXT,DoubleToString(lotsAvailable,2));
         ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_XDISTANCE,87);
         ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_YDISTANCE,47);
         ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0, "ValorLoteDisponivel", OBJPROP_BACK, false);

//         // Preco Atual do Ativo
//         ObjectCreate(0,"PrecoAtualAtivo",OBJ_LABEL,0,0,0,0,0,0,0);
//         ObjectSetInteger(0,"PrecoAtualAtivo",OBJPROP_FONTSIZE,8);
//         ObjectSetString(0,"PrecoAtualAtivo",OBJPROP_FONT, "Arial");
//         ObjectSetString(0,"PrecoAtualAtivo",OBJPROP_TEXT,"Preço Atual:");
//         ObjectSetInteger(0,"PrecoAtualAtivo",OBJPROP_XDISTANCE,195);
//         ObjectSetInteger(0,"PrecoAtualAtivo",OBJPROP_YDISTANCE,112);
//         ObjectSetInteger(0,"PrecoAtualAtivo",OBJPROP_CORNER,CORNER_LEFT_UPPER);
//         ObjectSetInteger(0,"PrecoAtualAtivo",OBJPROP_COLOR,clrSnow);
//         ObjectSetInteger(0, "PrecoAtualAtivo", OBJPROP_BACK, false);
//
//         // Valor Preco Atual do Ativo
//         ObjectCreate(0,"ValorPrecoAtualAtivo",OBJ_LABEL,0,0,0,0,0,0,0);
//         ObjectSetInteger(0,"ValorPrecoAtualAtivo",OBJPROP_FONTSIZE,8);
//         ObjectSetString(0,"ValorPrecoAtualAtivo",OBJPROP_FONT, "Arial");
//         ObjectSetString(0,"ValorPrecoAtualAtivo",OBJPROP_TEXT,DoubleToString(PrecoBid,5));
//         ObjectSetInteger(0,"ValorPrecoAtualAtivo",OBJPROP_XDISTANCE,260);
//         ObjectSetInteger(0,"ValorPrecoAtualAtivo",OBJPROP_YDISTANCE,112);
//         ObjectSetInteger(0,"ValorPrecoAtualAtivo",OBJPROP_CORNER,CORNER_LEFT_UPPER);
//         ObjectSetInteger(0,"ValorPrecoAtualAtivo",OBJPROP_COLOR,clrSnow);
//         ObjectSetInteger(0, "ValorPrecoAtualAtivo", OBJPROP_BACK, false);

         // Operações nesse Par
         ObjectCreate(0,"PosicaoAberta",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"PosicaoAberta",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"PosicaoAberta",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"PosicaoAberta",OBJPROP_TEXT,"Operações nesse Par:");
         ObjectSetInteger(0,"PosicaoAberta",OBJPROP_XDISTANCE,7);
         ObjectSetInteger(0,"PosicaoAberta",OBJPROP_YDISTANCE,72);
         ObjectSetInteger(0,"PosicaoAberta",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"PosicaoAberta",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "PosicaoAberta", OBJPROP_BACK, false);

         // Valor Operações nesse Par
         ObjectCreate(0,"ValorPosicaoAberta",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorPosicaoAberta",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"ValorPosicaoAberta",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"ValorPosicaoAberta",OBJPROP_TEXT,PosicoesAbertasNoPar);
         ObjectSetInteger(0,"ValorPosicaoAberta",OBJPROP_XDISTANCE,120);
         ObjectSetInteger(0,"ValorPosicaoAberta",OBJPROP_YDISTANCE,72);
         ObjectSetInteger(0,"ValorPosicaoAberta",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"ValorPosicaoAberta",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "ValorPosicaoAberta", OBJPROP_BACK, false);

         // Lotes Operados nesse Par
         ObjectCreate(0,"LotesOperadosNoPar",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"LotesOperadosNoPar",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"LotesOperadosNoPar",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"LotesOperadosNoPar",OBJPROP_TEXT,"Lotes nesse Par:");
         ObjectSetInteger(0,"LotesOperadosNoPar",OBJPROP_XDISTANCE,7);
         ObjectSetInteger(0,"LotesOperadosNoPar",OBJPROP_YDISTANCE,88);
         ObjectSetInteger(0,"LotesOperadosNoPar",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"LotesOperadosNoPar",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "LotesOperadosNoPar", OBJPROP_BACK, false);

         // Valor Lotes Operados nesse Par
         ObjectCreate(0,"ValorLotesOperadosNoPar",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorLotesOperadosNoPar",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"ValorLotesOperadosNoPar",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"ValorLotesOperadosNoPar",OBJPROP_TEXT,LotesUsados);
         ObjectSetInteger(0,"ValorLotesOperadosNoPar",OBJPROP_XDISTANCE,94);
         ObjectSetInteger(0,"ValorLotesOperadosNoPar",OBJPROP_YDISTANCE,88);
         ObjectSetInteger(0,"ValorLotesOperadosNoPar",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"ValorLotesOperadosNoPar",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "ValorLotesOperadosNoPar", OBJPROP_BACK, false);

         // Distancia da Mediana
         ObjectCreate(0,"DistanciaMediana",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"DistanciaMediana",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"DistanciaMediana",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"DistanciaMediana",OBJPROP_TEXT,TextoMediana);
         ObjectSetInteger(0,"DistanciaMediana",OBJPROP_XDISTANCE,7);
         ObjectSetInteger(0,"DistanciaMediana",OBJPROP_YDISTANCE,112);
         ObjectSetInteger(0,"DistanciaMediana",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"DistanciaMediana",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "DistanciaMediana", OBJPROP_BACK, false);

         // Valor Distancia Mediana
         ObjectCreate(0,"ValorDistanciaMediana",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorDistanciaMediana",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"ValorDistanciaMediana",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"ValorDistanciaMediana",OBJPROP_TEXT,DistanciaMediana + " Pts");
         ObjectSetInteger(0,"ValorDistanciaMediana",OBJPROP_XDISTANCE,PosicaoDistanciaMediana);
         ObjectSetInteger(0,"ValorDistanciaMediana",OBJPROP_YDISTANCE,112);
         ObjectSetInteger(0,"ValorDistanciaMediana",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"ValorDistanciaMediana",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "ValorDistanciaMediana", OBJPROP_BACK, false);

         // Swap Compra
         ObjectCreate(0,"SwapCompra",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"SwapCompra",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"SwapCompra",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"SwapCompra",OBJPROP_TEXT,"Swap Compra:");
         ObjectSetInteger(0,"SwapCompra",OBJPROP_XDISTANCE,7);
         ObjectSetInteger(0,"SwapCompra",OBJPROP_YDISTANCE,136);
         ObjectSetInteger(0,"SwapCompra",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"SwapCompra",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "SwapCompra", OBJPROP_BACK, false);

         // Valor Swap Compra
         ObjectCreate(0,"ValorSwapCompra",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorSwapCompra",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"ValorSwapCompra",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"ValorSwapCompra",OBJPROP_TEXT,SwapCompra);
         ObjectSetInteger(0,"ValorSwapCompra",OBJPROP_XDISTANCE,83);
         ObjectSetInteger(0,"ValorSwapCompra",OBJPROP_YDISTANCE,136);
         ObjectSetInteger(0,"ValorSwapCompra",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0, "ValorSwapCompra", OBJPROP_BACK, false);

         // Swap Venda
         ObjectCreate(0,"SwapVenda",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"SwapVenda",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"SwapVenda",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"SwapVenda",OBJPROP_TEXT,"Swap Venda:");
         ObjectSetInteger(0,"SwapVenda",OBJPROP_XDISTANCE,7);
         ObjectSetInteger(0,"SwapVenda",OBJPROP_YDISTANCE,152);
         ObjectSetInteger(0,"SwapVenda",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"SwapVenda",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "SwapVenda", OBJPROP_BACK, false);

         // Valor Swap Venda
         ObjectCreate(0,"ValorSwapVenda",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorSwapVenda",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"ValorSwapVenda",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"ValorSwapVenda",OBJPROP_TEXT,SwapVenda);
         ObjectSetInteger(0,"ValorSwapVenda",OBJPROP_XDISTANCE,78);
         ObjectSetInteger(0,"ValorSwapVenda",OBJPROP_YDISTANCE,152);
         ObjectSetInteger(0,"ValorSwapVenda",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0, "ValorSwapVenda", OBJPROP_BACK, false);

         // Spread
         ObjectCreate(0,"Spread",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"Spread",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"Spread",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"Spread",OBJPROP_TEXT,"Spread:");
         ObjectSetInteger(0,"Spread",OBJPROP_XDISTANCE,7);
         ObjectSetInteger(0,"Spread",OBJPROP_YDISTANCE,167);
         ObjectSetInteger(0,"Spread",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"Spread",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "Spread", OBJPROP_BACK, false);

         // Valor Spread
         ObjectCreate(0,"ValorSpread",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorSpread",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"ValorSpread",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"ValorSpread",OBJPROP_TEXT,SpreadAtual);
         ObjectSetInteger(0,"ValorSpread",OBJPROP_XDISTANCE,52);
         ObjectSetInteger(0,"ValorSpread",OBJPROP_YDISTANCE,167);
         ObjectSetInteger(0,"ValorSpread",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0, "ValorSpread", OBJPROP_BACK, false);

         // Texto Orientacao
         ObjectCreate(0,"Orientacao1",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"Orientacao1",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"Orientacao1",OBJPROP_TEXT,"Ação:");
         ObjectSetInteger(0,"Orientacao1",OBJPROP_XDISTANCE,5);
         ObjectSetInteger(0,"Orientacao1",OBJPROP_YDISTANCE,192);
         ObjectSetInteger(0,"Orientacao1",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"Orientacao1",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "Orientacao1", OBJPROP_BACK, false);

         // Topo ou Fundo
         ObjectCreate(0,"Orientacao3",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"Orientacao3",OBJPROP_FONTSIZE,8);
         ObjectSetString(0,"Orientacao3",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"Orientacao3",OBJPROP_TEXT,OrientacaoFundoOuTopo);
         ObjectSetInteger(0,"Orientacao3",OBJPROP_XDISTANCE,39);
         ObjectSetInteger(0,"Orientacao3",OBJPROP_YDISTANCE,192);
         ObjectSetInteger(0,"Orientacao3",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"Orientacao3",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "Orientacao3", OBJPROP_BACK, false);
         
         // Orientacao Compra, Vende ou Aguarda   
         ObjectCreate(0,"Orientacao2",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"Orientacao2",OBJPROP_FONTSIZE,9);
         ObjectSetString(0,"Orientacao2",OBJPROP_FONT, "Arial Black");
         ObjectSetString(0,"Orientacao2",OBJPROP_TEXT,Orientacao);
         ObjectSetInteger(0,"Orientacao2",OBJPROP_XDISTANCE,OrientacaoDistancia);
         ObjectSetInteger(0,"Orientacao2",OBJPROP_YDISTANCE,191);
         ObjectSetInteger(0,"Orientacao2",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"Orientacao2",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "Orientacao2", OBJPROP_BACK, false);



         // *** Background
         ObjectCreate(0, "Rectangle", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Rectangle", OBJPROP_XDISTANCE, 0);
         ObjectSetInteger(0, "Rectangle", OBJPROP_YDISTANCE, 13);
         ObjectSetInteger(0, "Rectangle", OBJPROP_XSIZE, 145);
         ObjectSetInteger(0, "Rectangle", OBJPROP_YSIZE, 203);
         ObjectSetInteger(0, "Rectangle", OBJPROP_BGCOLOR, clrDarkSlateGray);
         ObjectSetInteger(0, "Rectangle", OBJPROP_BACK, true);
         //ObjectSetInteger(0, "Rectangle", OBJPROP_ZORDER, 99);

         // *** Quadro Orientacao
         ObjectCreate(0, "QuadroOrientacao", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "QuadroOrientacao", OBJPROP_XDISTANCE, 0);
         ObjectSetInteger(0, "QuadroOrientacao", OBJPROP_YDISTANCE, 13);
         ObjectSetInteger(0, "QuadroOrientacao", OBJPROP_XSIZE, 139);
         ObjectSetInteger(0, "QuadroOrientacao", OBJPROP_YSIZE, 25);
         ObjectSetInteger(0,"QuadroOrientacao",OBJPROP_XDISTANCE,2);
         ObjectSetInteger(0,"QuadroOrientacao",OBJPROP_YDISTANCE,187);
         ObjectSetInteger(0, "QuadroOrientacao", OBJPROP_BGCOLOR, clrDarkGreen);
         ObjectSetInteger(0, "QuadroOrientacao",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "QuadroOrientacao",OBJPROP_BORDER_COLOR,clrOldLace);
         ObjectSetInteger(0, "QuadroOrientacao", OBJPROP_BACK, true);

         // *** Moldura 1 Traz
         ObjectCreate(0, "Moldura1Traz", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Moldura1Traz", OBJPROP_XDISTANCE, 0);
         ObjectSetInteger(0, "Moldura1Traz", OBJPROP_YDISTANCE, 13);
         ObjectSetInteger(0, "Moldura1Traz", OBJPROP_XSIZE, 139);
         ObjectSetInteger(0, "Moldura1Traz", OBJPROP_YSIZE, 38);
         ObjectSetInteger(0,"Moldura1Traz",OBJPROP_XDISTANCE,1);
         ObjectSetInteger(0,"Moldura1Traz",OBJPROP_YDISTANCE,28);
         ObjectSetInteger(0, "Moldura1Traz", OBJPROP_BGCOLOR, clrMaroon);
         ObjectSetInteger(0, "Moldura1Traz",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Moldura1Traz", OBJPROP_BACK, true); 

         // *** Moldura 1 Frente
         ObjectCreate(0, "Moldura1Frente", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Moldura1Frente", OBJPROP_XDISTANCE, 0);
         ObjectSetInteger(0, "Moldura1Frente", OBJPROP_YDISTANCE, 13);
         ObjectSetInteger(0, "Moldura1Frente", OBJPROP_XSIZE, 133);
         ObjectSetInteger(0, "Moldura1Frente", OBJPROP_YSIZE, 34);
         ObjectSetInteger(0,"Moldura1Frente",OBJPROP_XDISTANCE,4);
         ObjectSetInteger(0,"Moldura1Frente",OBJPROP_YDISTANCE,30);
         ObjectSetInteger(0, "Moldura1Frente", OBJPROP_BGCOLOR, clrDarkSlateGray);
         ObjectSetInteger(0, "Moldura1Frente",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Moldura1Frente",OBJPROP_BORDER_COLOR,clrOldLace);
         ObjectSetInteger(0, "Moldura1Frente", OBJPROP_BACK, true);
         
         // *** Moldura 2 Traz
         ObjectCreate(0, "Moldura2Traz", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Moldura2Traz", OBJPROP_XDISTANCE, 0);
         ObjectSetInteger(0, "Moldura2Traz", OBJPROP_YDISTANCE, 13);
         ObjectSetInteger(0, "Moldura2Traz", OBJPROP_XSIZE, 139);
         ObjectSetInteger(0, "Moldura2Traz", OBJPROP_YSIZE, 38);
         ObjectSetInteger(0,"Moldura2Traz",OBJPROP_XDISTANCE,1);
         ObjectSetInteger(0,"Moldura2Traz",OBJPROP_YDISTANCE,68);
         ObjectSetInteger(0, "Moldura2Traz", OBJPROP_BGCOLOR, clrMaroon);
         ObjectSetInteger(0, "Moldura2Traz",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Moldura2Traz", OBJPROP_BACK, true);        

         // *** Moldura 2 Frente
         ObjectCreate(0, "Moldura2Frente", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Moldura2Frente", OBJPROP_XDISTANCE, 0);
         ObjectSetInteger(0, "Moldura2Frente", OBJPROP_YDISTANCE, 13);
         ObjectSetInteger(0, "Moldura2Frente", OBJPROP_XSIZE, 133);
         ObjectSetInteger(0, "Moldura2Frente", OBJPROP_YSIZE, 34);
         ObjectSetInteger(0,"Moldura2Frente",OBJPROP_XDISTANCE,4);
         ObjectSetInteger(0,"Moldura2Frente",OBJPROP_YDISTANCE,70);
         ObjectSetInteger(0, "Moldura2Frente", OBJPROP_BGCOLOR, clrDarkSlateGray);
         ObjectSetInteger(0, "Moldura2Frente",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Moldura2Frente",OBJPROP_BORDER_COLOR,clrOldLace);
         ObjectSetInteger(0, "Moldura2Frente", OBJPROP_BACK, true);  

         // *** Moldura 3 Traz
         ObjectCreate(0, "Moldura3Traz", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Moldura3Traz", OBJPROP_XDISTANCE, 0);
         ObjectSetInteger(0, "Moldura3Traz", OBJPROP_YDISTANCE, 13);
         ObjectSetInteger(0, "Moldura3Traz", OBJPROP_XSIZE, 139);
         ObjectSetInteger(0, "Moldura3Traz", OBJPROP_YSIZE, 23);
         ObjectSetInteger(0,"Moldura3Traz",OBJPROP_XDISTANCE,1);
         ObjectSetInteger(0,"Moldura3Traz",OBJPROP_YDISTANCE,108);
         ObjectSetInteger(0, "Moldura3Traz", OBJPROP_BGCOLOR, clrMaroon);
         ObjectSetInteger(0, "Moldura3Traz",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Moldura3Traz", OBJPROP_BACK, true);        

         // *** Moldura 3 Frente
         ObjectCreate(0, "Moldura3Frente", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Moldura3Frente", OBJPROP_XDISTANCE, 0);
         ObjectSetInteger(0, "Moldura3Frente", OBJPROP_YDISTANCE, 13);
         ObjectSetInteger(0, "Moldura3Frente", OBJPROP_XSIZE, 133);
         ObjectSetInteger(0, "Moldura3Frente", OBJPROP_YSIZE, 19);
         ObjectSetInteger(0,"Moldura3Frente",OBJPROP_XDISTANCE,4);
         ObjectSetInteger(0,"Moldura3Frente",OBJPROP_YDISTANCE,110);
         ObjectSetInteger(0, "Moldura3Frente", OBJPROP_BGCOLOR, clrDarkSlateGray);
         ObjectSetInteger(0, "Moldura3Frente",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Moldura3Frente",OBJPROP_BORDER_COLOR,clrOldLace);
         ObjectSetInteger(0, "Moldura3Frente", OBJPROP_BACK, true); 
 
         // *** Moldura 4 Traz
         ObjectCreate(0, "Moldura4Traz", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Moldura4Traz", OBJPROP_XDISTANCE, 0);
         ObjectSetInteger(0, "Moldura4Traz", OBJPROP_YDISTANCE, 13);
         ObjectSetInteger(0, "Moldura4Traz", OBJPROP_XSIZE, 139);
         ObjectSetInteger(0, "Moldura4Traz", OBJPROP_YSIZE, 51);
         ObjectSetInteger(0,"Moldura4Traz",OBJPROP_XDISTANCE,1);
         ObjectSetInteger(0,"Moldura4Traz",OBJPROP_YDISTANCE,133);
         ObjectSetInteger(0, "Moldura4Traz", OBJPROP_BGCOLOR, clrMaroon);
         ObjectSetInteger(0, "Moldura4Traz",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Moldura4Traz", OBJPROP_BACK, true);        

         // *** Moldura 4 Frente
         ObjectCreate(0, "Moldura4Frente", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Moldura4Frente", OBJPROP_XDISTANCE, 0);
         ObjectSetInteger(0, "Moldura4Frente", OBJPROP_YDISTANCE, 13);
         ObjectSetInteger(0, "Moldura4Frente", OBJPROP_XSIZE, 133);
         ObjectSetInteger(0, "Moldura4Frente", OBJPROP_YSIZE, 47);
         ObjectSetInteger(0,"Moldura4Frente",OBJPROP_XDISTANCE,4);
         ObjectSetInteger(0,"Moldura4Frente",OBJPROP_YDISTANCE,135);
         ObjectSetInteger(0, "Moldura4Frente", OBJPROP_BGCOLOR, clrDarkSlateGray);
         ObjectSetInteger(0, "Moldura4Frente",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Moldura4Frente",OBJPROP_BORDER_COLOR,clrOldLace);
         ObjectSetInteger(0, "Moldura4Frente", OBJPROP_BACK, true);      
    

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



