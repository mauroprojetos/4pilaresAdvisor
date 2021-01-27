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
         // *** Background
         if(ObjectFind(0, "Rectangle")>=0) ObjectDelete(0, "Rectangle");
         ObjectCreate(0, "Rectangle", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Rectangle", OBJPROP_XDISTANCE, 0);
         ObjectSetInteger(0, "Rectangle", OBJPROP_YDISTANCE, 13);
         ObjectSetInteger(0, "Rectangle", OBJPROP_XSIZE, 145);
         ObjectSetInteger(0, "Rectangle", OBJPROP_YSIZE, 203);
         ObjectSetInteger(0, "Rectangle", OBJPROP_BGCOLOR, clrDarkSlateGray);
         ObjectSetInteger(0, "Rectangle", OBJPROP_BACK, false);
         //ObjectSetInteger(0, "Rectangle", OBJPROP_ZORDER, 99);

         // *** Moldura 1 Traz
         if(ObjectFind(0, "Moldura1Traz")>=0) ObjectDelete(0, "Moldura1Traz");
         ObjectCreate(0, "Moldura1Traz", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Moldura1Traz", OBJPROP_XSIZE, 139);
         ObjectSetInteger(0, "Moldura1Traz", OBJPROP_YSIZE, 38);
         ObjectSetInteger(0, "Moldura1Traz", OBJPROP_XDISTANCE,1);
         ObjectSetInteger(0, "Moldura1Traz", OBJPROP_YDISTANCE,28);
         ObjectSetInteger(0, "Moldura1Traz", OBJPROP_BGCOLOR, clrMaroon);
         ObjectSetInteger(0, "Moldura1Traz",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Moldura1Traz", OBJPROP_BACK, false); 

         // *** Moldura 1 Frente
         if(ObjectFind(0, "Moldura1Frente")>=0) ObjectDelete(0, "Moldura1Frente");
         ObjectCreate(0, "Moldura1Frente", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Moldura1Frente", OBJPROP_XSIZE, 133);
         ObjectSetInteger(0, "Moldura1Frente", OBJPROP_YSIZE, 34);
         ObjectSetInteger(0,"Moldura1Frente",OBJPROP_XDISTANCE,4);
         ObjectSetInteger(0,"Moldura1Frente",OBJPROP_YDISTANCE,30);
         ObjectSetInteger(0, "Moldura1Frente", OBJPROP_BGCOLOR, clrDarkSlateGray);
         ObjectSetInteger(0, "Moldura1Frente",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Moldura1Frente",OBJPROP_BORDER_COLOR,clrOldLace);
         ObjectSetInteger(0, "Moldura1Frente", OBJPROP_BACK, false);
         
         // *** Moldura 2 Traz
         if(ObjectFind(0, "Moldura2Traz")>=0) ObjectDelete(0, "Moldura2Traz");
         ObjectCreate(0, "Moldura2Traz", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Moldura2Traz", OBJPROP_XSIZE, 139);
         ObjectSetInteger(0, "Moldura2Traz", OBJPROP_YSIZE, 38);
         ObjectSetInteger(0,"Moldura2Traz", OBJPROP_XDISTANCE,1);
         ObjectSetInteger(0,"Moldura2Traz", OBJPROP_YDISTANCE,68);
         ObjectSetInteger(0, "Moldura2Traz", OBJPROP_BGCOLOR, clrMaroon);
         ObjectSetInteger(0, "Moldura2Traz",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Moldura2Traz", OBJPROP_BACK, false);        

         // *** Moldura 2 Frente
         if(ObjectFind(0, "Moldura2Frente")>=0) ObjectDelete(0, "Moldura2Frente");
         ObjectCreate(0, "Moldura2Frente", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Moldura2Frente", OBJPROP_XSIZE, 133);
         ObjectSetInteger(0, "Moldura2Frente", OBJPROP_YSIZE, 34);
         ObjectSetInteger(0,"Moldura2Frente",OBJPROP_XDISTANCE,4);
         ObjectSetInteger(0,"Moldura2Frente",OBJPROP_YDISTANCE,70);
         ObjectSetInteger(0, "Moldura2Frente", OBJPROP_BGCOLOR, clrDarkSlateGray);
         ObjectSetInteger(0, "Moldura2Frente",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Moldura2Frente",OBJPROP_BORDER_COLOR,clrOldLace);
         ObjectSetInteger(0, "Moldura2Frente", OBJPROP_BACK, false);  

         // *** Moldura 3 Traz
         if(ObjectFind(0, "Moldura3Traz")>=0) ObjectDelete(0, "Moldura3Traz");
         ObjectCreate(0, "Moldura3Traz", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Moldura3Traz", OBJPROP_XSIZE, 139);
         ObjectSetInteger(0, "Moldura3Traz", OBJPROP_YSIZE, 23);
         ObjectSetInteger(0,"Moldura3Traz",OBJPROP_XDISTANCE,1);
         ObjectSetInteger(0,"Moldura3Traz",OBJPROP_YDISTANCE,108);
         ObjectSetInteger(0, "Moldura3Traz", OBJPROP_BGCOLOR, clrMaroon);
         ObjectSetInteger(0, "Moldura3Traz",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Moldura3Traz", OBJPROP_BACK, false);        

         // *** Moldura 3 Frente
         if(ObjectFind(0, "Moldura3Frente")>=0) ObjectDelete(0, "Moldura3Frente");
         ObjectCreate(0, "Moldura3Frente", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Moldura3Frente", OBJPROP_XSIZE, 133);
         ObjectSetInteger(0, "Moldura3Frente", OBJPROP_YSIZE, 19);
         ObjectSetInteger(0,"Moldura3Frente",OBJPROP_XDISTANCE,4);
         ObjectSetInteger(0,"Moldura3Frente",OBJPROP_YDISTANCE,110);
         ObjectSetInteger(0, "Moldura3Frente", OBJPROP_BGCOLOR, clrDarkSlateGray);
         ObjectSetInteger(0, "Moldura3Frente",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Moldura3Frente",OBJPROP_BORDER_COLOR,clrOldLace);
         ObjectSetInteger(0, "Moldura3Frente", OBJPROP_BACK, false); 
 
         // *** Moldura 4 Traz
         if(ObjectFind(0, "Moldura4Traz")>=0) ObjectDelete(0, "Moldura4Traz");
         ObjectCreate(0, "Moldura4Traz", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Moldura4Traz", OBJPROP_XSIZE, 139);
         ObjectSetInteger(0, "Moldura4Traz", OBJPROP_YSIZE, 51);
         ObjectSetInteger(0,"Moldura4Traz",OBJPROP_XDISTANCE,1);
         ObjectSetInteger(0,"Moldura4Traz",OBJPROP_YDISTANCE,133);
         ObjectSetInteger(0, "Moldura4Traz", OBJPROP_BGCOLOR, clrMaroon);
         ObjectSetInteger(0, "Moldura4Traz",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Moldura4Traz", OBJPROP_BACK, false);        

         // *** Moldura 4 Frente
         if(ObjectFind(0, "Moldura4Frente")>=0) ObjectDelete(0, "Moldura4Frente");
         ObjectCreate(0, "Moldura4Frente", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "Moldura4Frente", OBJPROP_XSIZE, 133);
         ObjectSetInteger(0, "Moldura4Frente", OBJPROP_YSIZE, 47);
         ObjectSetInteger(0,"Moldura4Frente",OBJPROP_XDISTANCE,4);
         ObjectSetInteger(0,"Moldura4Frente",OBJPROP_YDISTANCE,135);
         ObjectSetInteger(0, "Moldura4Frente", OBJPROP_BGCOLOR, clrDarkSlateGray);
         ObjectSetInteger(0, "Moldura4Frente",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "Moldura4Frente",OBJPROP_BORDER_COLOR,clrOldLace);
         ObjectSetInteger(0, "Moldura4Frente", OBJPROP_BACK, false); 

         // *** Quadro Orientacao
         if(ObjectFind(0, "QuadroOrientacao")>=0) ObjectDelete(0, "QuadroOrientacao");
         ObjectCreate(0, "QuadroOrientacao", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "QuadroOrientacao", OBJPROP_XSIZE, 139);
         ObjectSetInteger(0, "QuadroOrientacao", OBJPROP_YSIZE, 25);
         ObjectSetInteger(0,"QuadroOrientacao",OBJPROP_XDISTANCE,2);
         ObjectSetInteger(0,"QuadroOrientacao",OBJPROP_YDISTANCE,187);
         ObjectSetInteger(0, "QuadroOrientacao",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0, "QuadroOrientacao",OBJPROP_BORDER_COLOR,clrOldLace);
         ObjectSetInteger(0, "QuadroOrientacao", OBJPROP_BACK, false);

         // Creditos
         if(ObjectFind(0, "Creditos1")>=0) ObjectDelete(0, "Creditos1");
         ObjectCreate(0,"Creditos1",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"Creditos1",OBJPROP_FONTSIZE,FonteBase1);
         ObjectSetString(0,"Creditos1",OBJPROP_TEXT,"4P_advisor v1.3 by Gustavo");
         ObjectSetInteger(0,"Creditos1",OBJPROP_XDISTANCE,2);
         ObjectSetInteger(0,"Creditos1",OBJPROP_YDISTANCE,15);
         ObjectSetInteger(0,"Creditos1",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"Creditos1",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "Creditos1", OBJPROP_BACK, false);

         // Lote em Uso
         if(ObjectFind(0, "LoteUso")>=0) ObjectDelete(0, "LoteUso");
         ObjectCreate(0,"LoteUso",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"LoteUso",OBJPROP_FONTSIZE,FonteBase1);
         ObjectSetString(0,"LoteUso",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"LoteUso",OBJPROP_TEXT,"Lote em Uso:");
         ObjectSetInteger(0,"LoteUso",OBJPROP_XDISTANCE,FontePaddingLeft);
         ObjectSetInteger(0,"LoteUso",OBJPROP_YDISTANCE,32);
         ObjectSetInteger(0,"LoteUso",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"LoteUso",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "LoteUso", OBJPROP_BACK, false);

         // Valor Lote em Uso
         if(ObjectFind(0, "ValorLoteUso")>=0) ObjectDelete(0, "ValorLoteUso");
         ObjectCreate(0,"ValorLoteUso",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorLoteUso",OBJPROP_FONTSIZE,FonteBase1);
         ObjectSetString(0,"ValorLoteUso",OBJPROP_FONT, "Arial");         
         ObjectSetInteger(0,"ValorLoteUso",OBJPROP_XDISTANCE,74);
         ObjectSetInteger(0,"ValorLoteUso",OBJPROP_YDISTANCE,32);
         ObjectSetInteger(0,"ValorLoteUso",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0, "ValorLoteUso", OBJPROP_BACK, false);

         // Lote Disponivel
         if(ObjectFind(0, "LoteDisponivel")>=0) ObjectDelete(0, "LoteDisponivel");
         ObjectCreate(0,"LoteDisponivel",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"LoteDisponivel",OBJPROP_FONTSIZE,FonteBase1);
         ObjectSetString(0,"LoteDisponivel",OBJPROP_FONT, "Arial");
         ObjectSetInteger(0,"LoteDisponivel",OBJPROP_XDISTANCE,FontePaddingLeft);
         ObjectSetInteger(0,"LoteDisponivel",OBJPROP_YDISTANCE,47);
         ObjectSetInteger(0,"LoteDisponivel",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"LoteDisponivel",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "LoteDisponivel", OBJPROP_BACK, false);

         // Valor Lote Disponivel         
         if(ObjectFind(0, "ValorLoteDisponivel")>=0) ObjectDelete(0, "ValorLoteDisponivel");
         ObjectCreate(0,"ValorLoteDisponivel",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_FONTSIZE,FonteBase1);
         ObjectSetString(0,"ValorLoteDisponivel",OBJPROP_FONT, "Arial");
         ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_XDISTANCE,87);
         ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_YDISTANCE,47);
         ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0, "ValorLoteDisponivel", OBJPROP_BACK, false);

         // Operações nesse Par
         if(ObjectFind(0, "PosicaoAberta")>=0) ObjectDelete(0, "PosicaoAberta");
         ObjectCreate(0,"PosicaoAberta",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"PosicaoAberta",OBJPROP_FONTSIZE,FonteBase1);
         ObjectSetString(0,"PosicaoAberta",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"PosicaoAberta",OBJPROP_TEXT,"Operações nesse Par:");
         ObjectSetInteger(0,"PosicaoAberta",OBJPROP_XDISTANCE,FontePaddingLeft);
         ObjectSetInteger(0,"PosicaoAberta",OBJPROP_YDISTANCE,72);
         ObjectSetInteger(0,"PosicaoAberta",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"PosicaoAberta",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "PosicaoAberta", OBJPROP_BACK, false);
         
         // Valor Operações nesse Par
         if(ObjectFind(0, "ValorPosicaoAberta")>=0) ObjectDelete(0, "ValorPosicaoAberta");
         ObjectCreate(0,"ValorPosicaoAberta",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorPosicaoAberta",OBJPROP_FONTSIZE,FonteBase1);
         ObjectSetString(0,"ValorPosicaoAberta",OBJPROP_FONT, "Arial");
         ObjectSetInteger(0,"ValorPosicaoAberta",OBJPROP_XDISTANCE,120);
         ObjectSetInteger(0,"ValorPosicaoAberta",OBJPROP_YDISTANCE,72);
         ObjectSetInteger(0,"ValorPosicaoAberta",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"ValorPosicaoAberta",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "ValorPosicaoAberta", OBJPROP_BACK, false);         
         
         // Lotes Operados nesse Par
         if(ObjectFind(0, "LotesOperadosNoPar")>=0) ObjectDelete(0, "LotesOperadosNoPar");
         ObjectCreate(0,"LotesOperadosNoPar",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"LotesOperadosNoPar",OBJPROP_FONTSIZE,FonteBase1);
         ObjectSetString(0,"LotesOperadosNoPar",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"LotesOperadosNoPar",OBJPROP_TEXT,"Lotes nesse Par:");
         ObjectSetInteger(0,"LotesOperadosNoPar",OBJPROP_XDISTANCE,FontePaddingLeft);
         ObjectSetInteger(0,"LotesOperadosNoPar",OBJPROP_YDISTANCE,88);
         ObjectSetInteger(0,"LotesOperadosNoPar",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"LotesOperadosNoPar",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "LotesOperadosNoPar", OBJPROP_BACK, false);
         
         // Valor Lotes Operados nesse Par
         if(ObjectFind(0, "ValorLotesOperadosNoPar")>=0) ObjectDelete(0, "ValorLotesOperadosNoPar");
         ObjectCreate(0,"ValorLotesOperadosNoPar",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorLotesOperadosNoPar",OBJPROP_FONTSIZE,FonteBase1);
         ObjectSetString(0,"ValorLotesOperadosNoPar",OBJPROP_FONT, "Arial");
         ObjectSetInteger(0,"ValorLotesOperadosNoPar",OBJPROP_XDISTANCE,94);
         ObjectSetInteger(0,"ValorLotesOperadosNoPar",OBJPROP_YDISTANCE,88);
         ObjectSetInteger(0,"ValorLotesOperadosNoPar",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"ValorLotesOperadosNoPar",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "ValorLotesOperadosNoPar", OBJPROP_BACK, false);         

         // Distancia da Mediana
         if(ObjectFind(0, "DistanciaMediana")>=0) ObjectDelete(0, "DistanciaMediana");
         ObjectCreate(0,"DistanciaMediana",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"DistanciaMediana",OBJPROP_FONTSIZE,FonteBase1);
         ObjectSetString(0,"DistanciaMediana",OBJPROP_FONT, "Arial");
         ObjectSetInteger(0,"DistanciaMediana",OBJPROP_XDISTANCE,FontePaddingLeft);
         ObjectSetInteger(0,"DistanciaMediana",OBJPROP_YDISTANCE,112);
         ObjectSetInteger(0,"DistanciaMediana",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"DistanciaMediana",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "DistanciaMediana", OBJPROP_BACK, false);

         // Valor Distancia Mediana
         if(ObjectFind(0, "ValorDistanciaMediana")>=0) ObjectDelete(0, "ValorDistanciaMediana");
         ObjectCreate(0,"ValorDistanciaMediana",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorDistanciaMediana",OBJPROP_FONTSIZE,FonteBase1);
         ObjectSetString(0,"ValorDistanciaMediana",OBJPROP_FONT, "Arial");
         ObjectSetInteger(0,"ValorDistanciaMediana",OBJPROP_XDISTANCE,PosicaoDistanciaMediana);
         ObjectSetInteger(0,"ValorDistanciaMediana",OBJPROP_YDISTANCE,112);
         ObjectSetInteger(0,"ValorDistanciaMediana",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"ValorDistanciaMediana",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "ValorDistanciaMediana", OBJPROP_BACK, false);                  

         // Swap Compra
         if(ObjectFind(0, "SwapCompra")>=0) ObjectDelete(0, "SwapCompra");
         ObjectCreate(0,"SwapCompra",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"SwapCompra",OBJPROP_FONTSIZE,FonteBase1);
         ObjectSetString(0,"SwapCompra",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"SwapCompra",OBJPROP_TEXT,"Swap Compra:");
         ObjectSetInteger(0,"SwapCompra",OBJPROP_XDISTANCE,FontePaddingLeft);
         ObjectSetInteger(0,"SwapCompra",OBJPROP_YDISTANCE,136);
         ObjectSetInteger(0,"SwapCompra",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"SwapCompra",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "SwapCompra", OBJPROP_BACK, false);

         // Valor Swap Compra
         if(ObjectFind(0, "ValorSwapCompra")>=0) ObjectDelete(0, "ValorSwapCompra");
         ObjectCreate(0,"ValorSwapCompra",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorSwapCompra",OBJPROP_FONTSIZE,FonteBase1);
         ObjectSetString(0,"ValorSwapCompra",OBJPROP_FONT, "Arial");
         ObjectSetInteger(0,"ValorSwapCompra",OBJPROP_XDISTANCE,83);
         ObjectSetInteger(0,"ValorSwapCompra",OBJPROP_YDISTANCE,136);
         ObjectSetInteger(0,"ValorSwapCompra",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0, "ValorSwapCompra", OBJPROP_BACK, false);

         // Swap Venda
         if(ObjectFind(0, "SwapVenda")>=0) ObjectDelete(0, "SwapVenda");
         ObjectCreate(0,"SwapVenda",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"SwapVenda",OBJPROP_FONTSIZE,FonteBase1);
         ObjectSetString(0,"SwapVenda",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"SwapVenda",OBJPROP_TEXT,"Swap Venda:");
         ObjectSetInteger(0,"SwapVenda",OBJPROP_XDISTANCE,FontePaddingLeft);
         ObjectSetInteger(0,"SwapVenda",OBJPROP_YDISTANCE,152);
         ObjectSetInteger(0,"SwapVenda",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"SwapVenda",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "SwapVenda", OBJPROP_BACK, false);

         // Valor Swap Venda
         if(ObjectFind(0, "ValorSwapVenda")>=0) ObjectDelete(0, "ValorSwapVenda");
         ObjectCreate(0,"ValorSwapVenda",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorSwapVenda",OBJPROP_FONTSIZE,FonteBase1);
         ObjectSetString(0,"ValorSwapVenda",OBJPROP_FONT, "Arial");
         ObjectSetInteger(0,"ValorSwapVenda",OBJPROP_XDISTANCE,78);
         ObjectSetInteger(0,"ValorSwapVenda",OBJPROP_YDISTANCE,152);
         ObjectSetInteger(0,"ValorSwapVenda",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0, "ValorSwapVenda", OBJPROP_BACK, false);

         // Spread
         if(ObjectFind(0, "Spread")>=0) ObjectDelete(0, "Spread");
         ObjectCreate(0,"Spread",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"Spread",OBJPROP_FONTSIZE,FonteBase1);
         ObjectSetString(0,"Spread",OBJPROP_FONT, "Arial");
         ObjectSetString(0,"Spread",OBJPROP_TEXT,"Spread:");
         ObjectSetInteger(0,"Spread",OBJPROP_XDISTANCE,FontePaddingLeft);
         ObjectSetInteger(0,"Spread",OBJPROP_YDISTANCE,167);
         ObjectSetInteger(0,"Spread",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"Spread",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "Spread", OBJPROP_BACK, false);

         // Valor Spread     
         if(ObjectFind(0, "ValorSpread")>=0) ObjectDelete(0, "ValorSpread");
         ObjectCreate(0,"ValorSpread",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"ValorSpread",OBJPROP_FONTSIZE,FonteBase1);
         ObjectSetString(0,"ValorSpread",OBJPROP_FONT, "Arial");
         ObjectSetInteger(0,"ValorSpread",OBJPROP_XDISTANCE,52);
         ObjectSetInteger(0,"ValorSpread",OBJPROP_YDISTANCE,167);
         ObjectSetInteger(0,"ValorSpread",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0, "ValorSpread", OBJPROP_BACK, false);

         // Topo ou Fundo
         if(ObjectFind(0, "OrientacaoTopoFundo")>=0) ObjectDelete(0, "OrientacaoTopoFundo");
         ObjectCreate(0,"OrientacaoTopoFundo",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"OrientacaoTopoFundo",OBJPROP_FONTSIZE,FonteBase1);
         ObjectSetString(0,"OrientacaoTopoFundo",OBJPROP_FONT, "Arial");
         ObjectSetInteger(0,"OrientacaoTopoFundo",OBJPROP_XDISTANCE,FontePaddingLeft);
         ObjectSetInteger(0,"OrientacaoTopoFundo",OBJPROP_YDISTANCE,192);
         ObjectSetInteger(0,"OrientacaoTopoFundo",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"OrientacaoTopoFundo",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "OrientacaoTopoFundo", OBJPROP_BACK, false);

         // Orientacao Compra, Vende ou Aguarda
         if(ObjectFind(0, "OrientacaoCompraVenda")>=0) ObjectDelete(0, "OrientacaoCompraVenda");  
         ObjectCreate(0,"OrientacaoCompraVenda",OBJ_LABEL,0,0,0,0,0,0,0);
         ObjectSetInteger(0,"OrientacaoCompraVenda",OBJPROP_FONTSIZE,FonteBase2);
         ObjectSetString(0,"OrientacaoCompraVenda",OBJPROP_FONT, "Arial Black");
         ObjectSetInteger(0,"OrientacaoCompraVenda",OBJPROP_YDISTANCE,191);
         ObjectSetInteger(0,"OrientacaoCompraVenda",OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,"OrientacaoCompraVenda",OBJPROP_COLOR,clrSnow);
         ObjectSetInteger(0, "OrientacaoCompraVenda", OBJPROP_BACK, false);


//+------------------------------------------------------------------+
//| Calculo Topo e Fundo                 |
//+------------------------------------------------------------------+ 
      PegaVariaveisDinamicas();
      
      // Array com os preços dos ultimos 5 anos
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
         MqlDateTime Time;
         TimeCurrent(Time);   
        
         //Topo Historico Label
         if(ObjectFind(0, "TopoLabel")>=0) ObjectDelete(0, "TopoLabel");
         ObjectCreate(0,"TopoLabel",OBJ_TEXT,0,IntegerToString(Time.year+1) + "." + IntegerToString(Time.mon) + "." + IntegerToString(Time.day),Topo);
         ObjectSetString(0, "TopoLabel", OBJPROP_TEXT, "Topo Histórico");
         ObjectSetString(0,"TopoLabel",OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,"TopoLabel",OBJPROP_FONTSIZE,11);
         ObjectSetInteger(0,"TopoLabel",OBJPROP_COLOR,clrDodgerBlue);
         //Mediana Label
         if(ObjectFind(0, "MedianaLabel")>=0) ObjectDelete(0, "MedianaLabel");
         ObjectCreate(0,"MedianaLabel",OBJ_TEXT,0,IntegerToString(Time.year+1) + "." + IntegerToString(Time.mon) + "." + IntegerToString(Time.day),Mediana);
         ObjectSetString(0, "MedianaLabel", OBJPROP_TEXT, "Mediana");
         ObjectSetString(0,"MedianaLabel",OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,"MedianaLabel",OBJPROP_FONTSIZE,11);
         ObjectSetInteger(0,"MedianaLabel",OBJPROP_COLOR,clrGold);
         //Fundo Historico Label
         if(ObjectFind(0, "FundoLabel")>=0) ObjectDelete(0, "FundoLabel");
         ObjectCreate(0,"FundoLabel",OBJ_TEXT,0,IntegerToString(Time.year+1) + "." + IntegerToString(Time.mon) + "." + IntegerToString(Time.day),Fundo);
         ObjectSetString(0, "FundoLabel", OBJPROP_TEXT, "Fundo Histórico");
         ObjectSetString(0,"FundoLabel",OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,"FundoLabel",OBJPROP_FONTSIZE,11);
         ObjectSetInteger(0,"FundoLabel",OBJPROP_COLOR,clrSalmon);
      
        
         if(!titulo_TopoMedianaFundo)
           {
            ObjectSetString(0,"TopoLabel",OBJPROP_TEXT," ");
            ObjectSetString(0,"MedianaLabel",OBJPROP_TEXT," ");
            ObjectSetString(0,"FundoLabel",OBJPROP_TEXT," ");
            ObjectSetString(0,"PrecoAtualLabel",OBJPROP_TEXT," ");
           }
         //Preco atual
         if(mostrarPrecoAtual)
           {
            if(ObjectFind(0, "PrecoAtualLabel")>=0) ObjectDelete(0, "PrecoAtualLabel");
            ObjectCreate(0,"PrecoAtualLabel",OBJ_TEXT,0,IntegerToString(Time.year+1) + "." + IntegerToString(Time.mon) + "." + IntegerToString(Time.day),PrecoBid);
            ObjectSetString(0, "PrecoAtualLabel", OBJPROP_TEXT, "Preço Atual");
            ObjectSetString(0,"PrecoAtualLabel",OBJPROP_FONT,"Arial");
            ObjectSetInteger(0,"PrecoAtualLabel",OBJPROP_FONTSIZE,8);
            ObjectSetInteger(0,"PrecoAtualLabel",OBJPROP_COLOR,clrGray);
            
           }
           else
            {
             ObjectSetString(0,"PrecoAtualLabel",OBJPROP_TEXT," ");
            } 

         if(TamanhoDisplay == 2)
           {
           int AumentoQuadroAltura = 20;
           int AumentoQuadroLargura = 35;
           int FonteAumento = 2;
           int FonteDistanciaXItem1 = 5;
           int FonteDistanciaXItem2 = 28;
           int FonteDistanciaY = 3;
           
           
            ObjectSetInteger(0,"Creditos1",OBJPROP_FONTSIZE,FonteBase1+FonteAumento);
            ObjectSetInteger(0,"Creditos1",OBJPROP_XDISTANCE,2+FonteDistanciaXItem1);
            ObjectSetInteger(0,"Creditos1",OBJPROP_YDISTANCE,13);
            
            ObjectSetInteger(0,"LoteUso",OBJPROP_FONTSIZE,FonteBase1+FonteAumento);
            ObjectSetInteger(0,"LoteUso",OBJPROP_XDISTANCE,FontePaddingLeft+FonteDistanciaXItem1);
            ObjectSetInteger(0,"LoteUso",OBJPROP_YDISTANCE,32+FonteDistanciaY);
            
            ObjectSetInteger(0,"ValorLoteUso",OBJPROP_FONTSIZE,FonteBase1+FonteAumento);
            ObjectSetInteger(0,"ValorLoteUso",OBJPROP_XDISTANCE,74+FonteDistanciaXItem2);
            ObjectSetInteger(0,"ValorLoteUso",OBJPROP_YDISTANCE,32+FonteDistanciaY);
            
            ObjectSetInteger(0,"LoteDisponivel",OBJPROP_FONTSIZE,FonteBase1+FonteAumento);
            ObjectSetInteger(0,"LoteDisponivel",OBJPROP_XDISTANCE,FontePaddingLeft+FonteDistanciaXItem1);
            ObjectSetInteger(0,"LoteDisponivel",OBJPROP_YDISTANCE,47+FonteDistanciaY); 
            
            ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_FONTSIZE,FonteBase1+FonteAumento);
            ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_XDISTANCE,PosicaoDistanciaMediana+FonteDistanciaXItem2);
            ObjectSetInteger(0,"ValorLoteDisponivel",OBJPROP_YDISTANCE,47+FonteDistanciaY); 
            
            ObjectSetInteger(0,"PosicaoAberta",OBJPROP_FONTSIZE,FonteBase1+FonteAumento);
            ObjectSetInteger(0,"PosicaoAberta",OBJPROP_XDISTANCE,FontePaddingLeft+FonteDistanciaXItem1);
            ObjectSetInteger(0,"PosicaoAberta",OBJPROP_YDISTANCE,72+FonteDistanciaY); 
            
            ObjectSetInteger(0,"ValorPosicaoAberta",OBJPROP_FONTSIZE,FonteBase1+FonteAumento);
            ObjectSetInteger(0,"ValorPosicaoAberta",OBJPROP_XDISTANCE,120+FonteDistanciaXItem2);
            ObjectSetInteger(0,"ValorPosicaoAberta",OBJPROP_YDISTANCE,72+FonteDistanciaY); 
            
            ObjectSetInteger(0,"LotesOperadosNoPar",OBJPROP_FONTSIZE,FonteBase1+FonteAumento);
            ObjectSetInteger(0,"LotesOperadosNoPar",OBJPROP_XDISTANCE,FontePaddingLeft+FonteDistanciaXItem1);
            ObjectSetInteger(0,"LotesOperadosNoPar",OBJPROP_YDISTANCE,88+FonteDistanciaY); 
            
            ObjectSetInteger(0,"ValorLotesOperadosNoPar",OBJPROP_FONTSIZE,FonteBase1+FonteAumento);
            ObjectSetInteger(0,"ValorLotesOperadosNoPar",OBJPROP_XDISTANCE,94+FonteDistanciaXItem2);
            ObjectSetInteger(0,"ValorLotesOperadosNoPar",OBJPROP_YDISTANCE,88+FonteDistanciaY);
            
            ObjectSetInteger(0,"DistanciaMediana",OBJPROP_FONTSIZE,FonteBase1+FonteAumento);
            ObjectSetInteger(0,"DistanciaMediana",OBJPROP_XDISTANCE,FontePaddingLeft+FonteDistanciaXItem1);
            ObjectSetInteger(0,"DistanciaMediana",OBJPROP_YDISTANCE,112+FonteDistanciaY);
            
            ObjectSetInteger(0,"ValorDistanciaMediana",OBJPROP_FONTSIZE,FonteBase1+FonteAumento);
            ObjectSetInteger(0,"ValorDistanciaMediana",OBJPROP_XDISTANCE,81+FonteDistanciaXItem2);
            ObjectSetInteger(0,"ValorDistanciaMediana",OBJPROP_YDISTANCE,112+FonteDistanciaY);
            
            ObjectSetInteger(0,"SwapCompra",OBJPROP_FONTSIZE,FonteBase1+FonteAumento);
            ObjectSetInteger(0,"SwapCompra",OBJPROP_XDISTANCE,FontePaddingLeft+FonteDistanciaXItem1);
            ObjectSetInteger(0,"SwapCompra",OBJPROP_YDISTANCE,136+FonteDistanciaY);
            
            ObjectSetInteger(0,"ValorSwapCompra",OBJPROP_FONTSIZE,FonteBase1+FonteAumento);
            ObjectSetInteger(0,"ValorSwapCompra",OBJPROP_XDISTANCE,83+FonteDistanciaXItem2);
            ObjectSetInteger(0,"ValorSwapCompra",OBJPROP_YDISTANCE,136+FonteDistanciaY);
            
            ObjectSetInteger(0,"SwapVenda",OBJPROP_FONTSIZE,FonteBase1+FonteAumento);
            ObjectSetInteger(0,"SwapVenda",OBJPROP_XDISTANCE,FontePaddingLeft+FonteDistanciaXItem1);
            ObjectSetInteger(0,"SwapVenda",OBJPROP_YDISTANCE,152+FonteDistanciaY);
            
            ObjectSetInteger(0,"ValorSwapVenda",OBJPROP_FONTSIZE,FonteBase1+FonteAumento);
            ObjectSetInteger(0,"ValorSwapVenda",OBJPROP_XDISTANCE,78+FonteDistanciaXItem2);
            ObjectSetInteger(0,"ValorSwapVenda",OBJPROP_YDISTANCE,152+FonteDistanciaY);
            
            ObjectSetInteger(0,"Spread",OBJPROP_FONTSIZE,FonteBase1+FonteAumento);
            ObjectSetInteger(0,"Spread",OBJPROP_XDISTANCE,FontePaddingLeft+FonteDistanciaXItem1);
            ObjectSetInteger(0,"Spread",OBJPROP_YDISTANCE,167+FonteDistanciaY);
            
            ObjectSetInteger(0,"ValorSpread",OBJPROP_FONTSIZE,FonteBase1+FonteAumento);
            ObjectSetInteger(0,"ValorSpread",OBJPROP_XDISTANCE,52+FonteDistanciaXItem2);
            ObjectSetInteger(0,"ValorSpread",OBJPROP_YDISTANCE,167+FonteDistanciaY);
            
            ObjectSetInteger(0,"OrientacaoTopoFundo",OBJPROP_FONTSIZE,FonteBase2+FonteAumento);
            ObjectSetInteger(0,"OrientacaoTopoFundo",OBJPROP_XDISTANCE,10+FontePaddingLeft+FonteDistanciaXItem1);
            ObjectSetInteger(0,"OrientacaoTopoFundo",OBJPROP_YDISTANCE,180+AumentoQuadroAltura+FonteDistanciaY);
            
            ObjectSetInteger(0,"OrientacaoCompraVenda",OBJPROP_FONTSIZE,FonteBase2+FonteAumento);
            ObjectSetInteger(0,"OrientacaoCompraVenda",OBJPROP_XDISTANCE,OrientacaoDistanciaEsquerda+FonteDistanciaXItem1);
            ObjectSetInteger(0,"OrientacaoCompraVenda",OBJPROP_YDISTANCE,178+AumentoQuadroAltura+FonteDistanciaY);                    

            ObjectSetInteger(0, "Rectangle", OBJPROP_XSIZE, 145+AumentoQuadroLargura);
            ObjectSetInteger(0, "Rectangle", OBJPROP_YSIZE, 197+AumentoQuadroAltura);           
            ObjectSetInteger(0, "Rectangle", OBJPROP_XDISTANCE, 0);
            ObjectSetInteger(0, "Rectangle", OBJPROP_YDISTANCE, 13);
                      
            ObjectSetInteger(0, "Moldura1Traz", OBJPROP_XSIZE, 139+AumentoQuadroLargura);
            ObjectSetInteger(0, "Moldura1Traz", OBJPROP_YSIZE, 38+AumentoQuadroAltura);
            ObjectSetInteger(0, "Moldura1Traz",OBJPROP_XDISTANCE,1);
            ObjectSetInteger(0, "Moldura1Traz",OBJPROP_YDISTANCE,28);           
            
            ObjectSetInteger(0, "Moldura1Frente", OBJPROP_XSIZE, 133+AumentoQuadroLargura);
            ObjectSetInteger(0, "Moldura1Frente", OBJPROP_YSIZE, 34+AumentoQuadroAltura);
            ObjectSetInteger(0, "Moldura1Frente",OBJPROP_XDISTANCE,4);
            ObjectSetInteger(0, "Moldura1Frente",OBJPROP_YDISTANCE,30);           
            
            ObjectSetInteger(0, "Moldura2Traz", OBJPROP_XSIZE, 139+AumentoQuadroLargura);
            ObjectSetInteger(0, "Moldura2Traz", OBJPROP_YSIZE, 38+AumentoQuadroAltura);
            ObjectSetInteger(0,"Moldura2Traz",OBJPROP_XDISTANCE,1);
            ObjectSetInteger(0,"Moldura2Traz",OBJPROP_YDISTANCE,68);
            
            ObjectSetInteger(0, "Moldura2Frente", OBJPROP_XSIZE, 133+AumentoQuadroLargura);
            ObjectSetInteger(0, "Moldura2Frente", OBJPROP_YSIZE, 34+AumentoQuadroAltura);
            ObjectSetInteger(0,"Moldura2Frente",OBJPROP_XDISTANCE,4);
            ObjectSetInteger(0,"Moldura2Frente",OBJPROP_YDISTANCE,70);           
            
            ObjectSetInteger(0, "Moldura3Traz", OBJPROP_XSIZE, 139+AumentoQuadroLargura);
            ObjectSetInteger(0, "Moldura3Traz", OBJPROP_YSIZE, 23+AumentoQuadroAltura);
            ObjectSetInteger(0,"Moldura3Traz",OBJPROP_XDISTANCE,1);
            ObjectSetInteger(0,"Moldura3Traz",OBJPROP_YDISTANCE,108);
              
            ObjectSetInteger(0, "Moldura3Frente", OBJPROP_XSIZE, 133+AumentoQuadroLargura);
            ObjectSetInteger(0, "Moldura3Frente", OBJPROP_YSIZE, 19+AumentoQuadroAltura);
            ObjectSetInteger(0,"Moldura3Frente",OBJPROP_XDISTANCE,4);
            ObjectSetInteger(0,"Moldura3Frente",OBJPROP_YDISTANCE,110);           
                        
            ObjectSetInteger(0, "Moldura4Traz", OBJPROP_XSIZE, 139+AumentoQuadroLargura);
            ObjectSetInteger(0, "Moldura4Traz", OBJPROP_YSIZE, 42+AumentoQuadroAltura);
            ObjectSetInteger(0,"Moldura4Traz",OBJPROP_XDISTANCE,1);
            ObjectSetInteger(0,"Moldura4Traz",OBJPROP_YDISTANCE,133);
            
            ObjectSetInteger(0, "Moldura4Frente", OBJPROP_XSIZE, 133+AumentoQuadroLargura);
            ObjectSetInteger(0, "Moldura4Frente", OBJPROP_YSIZE, 38+AumentoQuadroAltura);
            ObjectSetInteger(0,"Moldura4Frente",OBJPROP_XDISTANCE,4);
            ObjectSetInteger(0,"Moldura4Frente",OBJPROP_YDISTANCE,135);

            ObjectSetInteger(0, "QuadroOrientacao", OBJPROP_XSIZE, 139+AumentoQuadroLargura);
            ObjectSetInteger(0, "QuadroOrientacao", OBJPROP_YSIZE, 8+AumentoQuadroAltura);
            ObjectSetInteger(0,"QuadroOrientacao",OBJPROP_XDISTANCE,2);
            ObjectSetInteger(0,"QuadroOrientacao",OBJPROP_YDISTANCE,198);
            
           }
          else if(TamanhoDisplay == 3)
           {
            
           }
          else if(TamanhoDisplay == 4)
           {
            
           }
          
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
         ObjectSetString(0,"ValorPosicaoAberta",OBJPROP_TEXT,PosicoesAbertasNoPar);


         // Valor Lotes Operados nesse Par DINÂMICO
         ObjectSetString(0,"ValorLotesOperadosNoPar",OBJPROP_TEXT,DoubleToString(LotesUsados,2));

  
         // Valor Distancia Mediana DINÂMICO
         ObjectSetString(0,"ValorDistanciaMediana",OBJPROP_TEXT,DistanciaMediana + " Pts");
         ObjectSetString(0,"DistanciaMediana",OBJPROP_TEXT,TextoMediana);
         
         
         // Valor Swap Compra DINÂMICO
         ObjectSetString(0,"ValorSwapCompra",OBJPROP_TEXT,SwapCompra);

        
         // Valor Swap Venda DINÂMICO
         ObjectSetString(0,"ValorSwapVenda",OBJPROP_TEXT,SwapVenda);


         // Valor Spread DINÂMICO
         ObjectSetString(0,"ValorSpread",OBJPROP_TEXT,SpreadAtual);


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

