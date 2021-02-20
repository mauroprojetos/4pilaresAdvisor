bool CriarDisplayPares()
{
   int numLinhas = 11;
   int numColunas = 6;
   int altura = 21;
   int largura = 58;
   
   // CRIAR COLUNAS E LINHAS
   int label1Espacamento = 0;
   int label2Espacamento = (numColunas*largura)+label1Espacamento;
   int label3espacamento = label2Espacamento+(numColunas*largura);
   string objName;
   int x,y;
   int xPadding = 0;
   int yPadding = 27;
   color corFundo = clrSnow;
   color corTexto = clrDarkSlateGray;
   
   // localizacao canto direito superior
   if(LocalizacaoDisplay == 4)
   {
      xPadding = -45;
   }
   // tamanho maior do display
   if(TamanhoDisplay == 2)
   {
      xPadding = 30;
      if(LocalizacaoDisplay == 4)
      {
         xPadding = -75;
      } 
   }
   
   for(int i=0;i<numLinhas;i++)
   {  
      //PRIMEIRO BLOCO
      for(int j=0;j<numColunas;j++)
      {
         objName = "label1_c"+IntegerToString(j)+"_l"+IntegerToString(i);
         x = xPadding + j*largura;
         y = yPadding + i*altura;
         CreateLabel(objName,x,y,largura,altura,label1Espacamento,corFundo,corTexto);       
      }
      //SEGUNDO BLOCO
      for(int k=0;k<numColunas;k++)
      {
         objName = "label2_c"+IntegerToString(k)+"_l"+IntegerToString(i);
         x = xPadding + 3 + k*largura;
         y = yPadding + i*altura;
         CreateLabel(objName,x,y,largura,altura,label2Espacamento,corFundo,corTexto);        
      }
      //TERCEIRO BLOCO
      for(int l=0;l<numColunas;l++)
      {
         if(i<9)
         {
            objName = "label3_c"+IntegerToString(l)+"_l"+IntegerToString(i);
            x = xPadding + 6 + l*largura;
            y = yPadding + i*altura;
            CreateLabel(objName,x,y,largura,altura,label3espacamento,corFundo,corTexto);        
         }
      }
   }

   
   // INSERINDO TITULO
   string labelTitulo;
   string tituloPares[6] = {"ATIVO","PREÇO","AÇÃO","P.MEDIANA","P.DIA","P.HOJE"};
   corFundo = clrDarkSlateGray;
   corTexto = clrSnow;
   for(int i=1;i<numColunas;i++)
     {
      for(int j=0;j<numColunas;j++)
        {
         labelTitulo = "label"+IntegerToString(i)+"_c"+IntegerToString(j)+"_l0";
         MudarTituloDisplayPares(labelTitulo,tituloPares[j],corFundo,corTexto);
        }
     }

   InserePares();
   
   ChartRedraw();
   return(true);
}

bool InserePares()
{
   string ParesPrincipais1[10] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF",
"CADJPY","CHFJPY","EURAUD","EURCAD"};

   string ParesPrincipais2[10] = {"EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD",
"GBPCAD","GBPCHF","GBPJPY","GBPNZD"};

   string ParesPrincipais3[8] = {"GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD",
"USDCHF","USDJPY"};
   
   // INSERINDO PARES NAS COLUNAS
   DadosAtivo ativo;
   string labelPares;
   color corFundoNegativoPares = clrCrimson;
   color corFundoPositivoPares = clrGreen;
   color corTextoPares = clrSnow;
   color corFundo = clrSnow;
   color corTexto = clrDarkSlateGray;   
   int CasasDecimais;
   //PRIMEIRO BLOCO
   for(int i=0;i<10;i++)
   {
      for(int j=0;j<6;j++)
      {
         //coluna1
         if(j<1)
         {
            labelPares = "label1_c"+IntegerToString(j)+"_l"+IntegerToString(i+1);
            MudarItensDisplayPares(labelPares,ParesPrincipais1[i],10,corFundo,corTexto);         
         }
         //coluna2
         else if(j<2)
         {
            PegarDadosPares(ativo, ParesPrincipais1[i], MesesHistoricos);
            labelPares = "label1_c"+IntegerToString(j)+"_l"+IntegerToString(i+1);
            CasasDecimais = int(SymbolInfoInteger(ParesPrincipais1[i]+LetrasFinalPares,SYMBOL_DIGITS));
            MudarItensDisplayDados(labelPares,DoubleToString(ativo.PrecoBidPar,CasasDecimais),8);
         }
         //coluna3
         else if(j<3)
         {
            PegarDadosPares(ativo, ParesPrincipais1[i], MesesHistoricos);
            labelPares = "label1_c"+IntegerToString(j)+"_l"+IntegerToString(i+1);
            MudarCorFundo(labelPares,ativo.OrientacaoColor,corTextoPares);
            MudarItensDisplayDados(labelPares,ativo.Orientacao,9); 
         }
         //coluna4
         else if(j<4)
         {
            PegarDadosPares(ativo, ParesPrincipais1[i], MesesHistoricos);
            labelPares = "label1_c"+IntegerToString(j)+"_l"+IntegerToString(i+1);
            MudarItensDisplayDados(labelPares,DoubleToString(ativo.DistMediana,0),9); 
         }
         //coluna5
         else if(j<5)
         {
            PegarDadosPares(ativo, ParesPrincipais1[i], MesesHistoricos);
            labelPares = "label1_c"+IntegerToString(j)+"_l"+IntegerToString(i+1);
            MudarItensDisplayDados(labelPares,DoubleToString(ativo.MovDiaria,0),9); 
         }  
         //coluna6
         else if(j<6)
         {
            PegarDadosPares(ativo, ParesPrincipais1[i], MesesHistoricos);
            labelPares = "label1_c"+IntegerToString(j)+"_l"+IntegerToString(i+1);
            
            if(ativo.MovHoje<0)
               {
                  MudarCorFundo(labelPares,corFundoNegativoPares,corTextoPares);
                  ativo.MovHoje = ativo.MovHoje*-1;
                  ativo.PorcentMov = ativo.PorcentMov*-1;
               }
               else if(ativo.MovHoje>0)
               {
                  MudarCorFundo(labelPares,corFundoPositivoPares,corTextoPares);
               }
            MudarItensDisplayDados(labelPares,DoubleToString(ativo.MovHoje,0)+"("+DoubleToString(ativo.PorcentMov,0)+")%",8);
         }       
      }
      //SEGUNDO BLOCO
      for(int k=0;k<6;k++)
      {
         //coluna1
         if(k<1)
         {
            labelPares = "label2_c"+IntegerToString(k)+"_l"+IntegerToString(i+1);
            MudarItensDisplayPares(labelPares,ParesPrincipais2[i],10,corFundo,corTexto);      
         }
         //coluna2
         else if(k<2)
         {
            PegarDadosPares(ativo, ParesPrincipais2[i], MesesHistoricos);
            labelPares = "label2_c"+IntegerToString(k)+"_l"+IntegerToString(i+1);
            CasasDecimais = int(SymbolInfoInteger(ParesPrincipais2[i]+LetrasFinalPares,SYMBOL_DIGITS));
            MudarItensDisplayDados(labelPares,DoubleToString(ativo.PrecoBidPar,CasasDecimais),8);
         }         
         //coluna3
         else if(k<3)
         {
            PegarDadosPares(ativo, ParesPrincipais2[i], MesesHistoricos);
            labelPares = "label2_c"+IntegerToString(k)+"_l"+IntegerToString(i+1);
            MudarCorFundo(labelPares,ativo.OrientacaoColor,corTextoPares);
            MudarItensDisplayDados(labelPares,ativo.Orientacao,9); 
         }
         //coluna4
         else if(k<4)
         {
            PegarDadosPares(ativo, ParesPrincipais2[i], MesesHistoricos);
            labelPares = "label2_c"+IntegerToString(k)+"_l"+IntegerToString(i+1);
            MudarItensDisplayDados(labelPares,DoubleToString(ativo.DistMediana,0),9); 
         }
         //coluna5
         else if(k<5)
         {
            PegarDadosPares(ativo, ParesPrincipais2[i], MesesHistoricos);
            labelPares = "label2_c"+IntegerToString(k)+"_l"+IntegerToString(i+1);
            MudarItensDisplayDados(labelPares,DoubleToString(ativo.MovDiaria,0),9); 
         }
         //coluna6
         else if(k<6)
         {
            PegarDadosPares(ativo, ParesPrincipais2[i], MesesHistoricos);
            labelPares = "label2_c"+IntegerToString(k)+"_l"+IntegerToString(i+1);
             
            if(ativo.MovHoje<0)
               {
                  MudarCorFundo(labelPares,corFundoNegativoPares,corTextoPares);
                  ativo.MovHoje = ativo.MovHoje*-1;
                  ativo.PorcentMov = ativo.PorcentMov*-1;
               }
               else if(ativo.MovHoje>0)
               {
                  MudarCorFundo(labelPares,corFundoPositivoPares,corTextoPares);
               }
            MudarItensDisplayDados(labelPares,DoubleToString(ativo.MovHoje,0)+"("+DoubleToString(ativo.PorcentMov,0)+")%",8);
         }
      }
      //TERCEIRO BLOCO
      for(int l=0;l<6;l++)
      {
         //desconsidera os 2 ultimas linhas vazias
         if(i<8)
         {
            //coluna1
            if(l<1)
            {
               labelPares = "label3_c"+IntegerToString(l)+"_l"+IntegerToString(i+1);
               MudarItensDisplayPares(labelPares,ParesPrincipais3[i],10,corFundo,corTexto); 
            }
            //coluna2
            else if(l<2)
            {
               PegarDadosPares(ativo, ParesPrincipais3[i], MesesHistoricos);
               labelPares = "label3_c"+IntegerToString(l)+"_l"+IntegerToString(i+1);
               CasasDecimais = int(SymbolInfoInteger(ParesPrincipais3[i]+LetrasFinalPares,SYMBOL_DIGITS));
               MudarItensDisplayDados(labelPares,DoubleToString(ativo.PrecoBidPar,CasasDecimais),8);  
            }
            //coluna3
            else if(l<3)
            {
               PegarDadosPares(ativo, ParesPrincipais3[i], MesesHistoricos);
               labelPares = "label3_c"+IntegerToString(l)+"_l"+IntegerToString(i+1);
               MudarCorFundo(labelPares,ativo.OrientacaoColor,corTextoPares);
               MudarItensDisplayDados(labelPares,ativo.Orientacao,9);  
            }
            //coluna4
            else if(l<4)
            {
               PegarDadosPares(ativo, ParesPrincipais3[i], MesesHistoricos);
               labelPares = "label3_c"+IntegerToString(l)+"_l"+IntegerToString(i+1);
               MudarItensDisplayDados(labelPares,DoubleToString(ativo.DistMediana,0),9); 
            }
            //coluna5
            else if(l<5)
            {
               PegarDadosPares(ativo, ParesPrincipais3[i], MesesHistoricos);
               labelPares = "label3_c"+IntegerToString(l)+"_l"+IntegerToString(i+1);
               MudarItensDisplayDados(labelPares,DoubleToString(ativo.MovDiaria,0),9); 
            }
            //coluna6
            else if(l<6)
            {
               PegarDadosPares(ativo, ParesPrincipais3[i], MesesHistoricos);
               labelPares = "label3_c"+IntegerToString(l)+"_l"+IntegerToString(i+1);

            if(ativo.MovHoje<0)
               {
                  MudarCorFundo(labelPares,corFundoNegativoPares,corTextoPares);
                  ativo.MovHoje = ativo.MovHoje*-1;
                  ativo.PorcentMov = ativo.PorcentMov*-1;
               }
               else if(ativo.MovHoje>0)
               {
                  MudarCorFundo(labelPares,corFundoPositivoPares,corTextoPares);
               }
            MudarItensDisplayDados(labelPares,DoubleToString(ativo.MovHoje,0)+"("+DoubleToString(ativo.PorcentMov,0)+")%",8);
            }  
         }
      }

   }

   ChartRedraw();
   return(true);
}

struct DadosAtivo {
   double Mediana;
   double DistMediana;
   double PrecoBidPar;
   double MovHoje;
   double MovDiaria;
   double PorcentMov;
   string Orientacao;
   color OrientacaoColor;
};


DadosAtivo PegarDadosPares(DadosAtivo &ativo, string Par, int Meses)
{           
   double MedianaPares;
   double ArrayPrecosPares[];
   string ParName = Par+LetrasFinalPares;
   ArrayResize(ArrayPrecosPares,Meses);
  
   // Considerar Pandemia para calcular Array com os preços dos ultimos anos
   if(PularPandemiaTopoFundo==true)
   {
      int MesPular1=iBarShift(ParName,PERIOD_MN1,D'2020.03.01 00:00');
      int MesPular2=iBarShift(ParName,PERIOD_MN1,D'2020.04.01 00:00');
      
      for(int i=0;i<Meses;i++)
      {
      if(i == MesPular1)
        {
         ArrayPrecosPares[i] = iClose(ParName,PERIOD_MN1,i+1);
        }
      else if(i == MesPular2)
        {
         ArrayPrecosPares[i] = iClose(ParName,PERIOD_MN1,i-1);
        }
      else
        {
         ArrayPrecosPares[i] = iClose(ParName,PERIOD_MN1,i);
        }  
      }
   }
   else
     {
     // Array com os preços dos ultimos anos
     for(int i=0;i<Meses;i++)
       {
        ArrayPrecosPares[i] = iClose(ParName,PERIOD_MN1,i);
       }   
     }

   int MenorCandlePares = ArrayMinimum(ArrayPrecosPares,0,Meses);
   int MaiorCandlePares = ArrayMaximum(ArrayPrecosPares,0,Meses);
     
   MedianaPares = (ArrayPrecosPares[MaiorCandlePares] + ArrayPrecosPares[MenorCandlePares]) / 2;
   
   ativo.PrecoBidPar = SymbolInfoDouble(ParName,SYMBOL_BID);
   ativo.DistMediana = ativo.PrecoBidPar - MedianaPares;
   ativo.MovHoje = ativo.PrecoBidPar - iClose(ParName,PERIOD_D1,1); // Fechamento Dia Anterior
   
   double pontosPar = 0.0;
   for(int i=0;i<DiasMovMedia;i++)
     {
      pontosPar += iHigh(ParName,PERIOD_D1,i)-iLow(ParName,PERIOD_D1,i);
     }
   
   ativo.MovDiaria = pontosPar/DiasMovMedia;
   
   // se nao for carregado e ficar com valor zero
   if(!ativo.MovDiaria==0)
     {
      ativo.PorcentMov = (ativo.MovHoje/ativo.MovDiaria)*100;
     }
   else
     {
      ativo.PorcentMov =0.0;
     }

   //Se a moeda operada for JPY 
   int MultiplicadorPontos;      
   // se for JPY
   double OrientacaoPontos;
   if(StringFind(ParName, "JPY") >= 0)
     {
      MultiplicadorPontos = 1000;
      OrientacaoPontos = 100;
     }
   else if(StringFind(ParName, "XAU")>=0 || StringFind(ParName, "XAG")>=0)
     {
      MultiplicadorPontos = 1000;
      OrientacaoPontos = 100;
     }
    else
      {
       MultiplicadorPontos = 100000;
       OrientacaoPontos = 1;
      }
         
   // ORIENTACAO      
   double PontosDistanciaMediana = PontosAteMediana*0.00001;
   double MargemAteOndeOperarPares;
   if(ativo.PrecoBidPar>MedianaPares)  
     {
      MargemAteOndeOperarPares = MedianaPares + PontosDistanciaMediana*OrientacaoPontos;
         if(ativo.PrecoBidPar>MargemAteOndeOperarPares)
         {
            ativo.Orientacao="VENDA";          
            ativo.OrientacaoColor = clrCrimson;
         }
         else if(ativo.PrecoBidPar<MargemAteOndeOperarPares)
         {   
            ativo.Orientacao="NEUTRO";
            ativo.OrientacaoColor = clrBlack;
         } 
     }
   else if(ativo.PrecoBidPar<MedianaPares)
     {
      MargemAteOndeOperarPares = MedianaPares - PontosDistanciaMediana*OrientacaoPontos;
      if(ativo.PrecoBidPar<MargemAteOndeOperarPares)
      {
         ativo.Orientacao="COMPRA";        
         ativo.OrientacaoColor = clrMediumBlue;
      }
      else if(ativo.PrecoBidPar>MargemAteOndeOperarPares)
      {   
         ativo.Orientacao="NEUTRO";
         ativo.OrientacaoColor = clrBlack;
      }     
     }
   ativo.Mediana = MedianaPares;
   ativo.DistMediana = ativo.DistMediana*MultiplicadorPontos;
   ativo.MovHoje = ativo.MovHoje*MultiplicadorPontos;
   ativo.MovDiaria = ativo.MovDiaria*MultiplicadorPontos;
      
   return(ativo);
}


bool CriarDisplayCustom()
{
   int numLinhas = 11;
   int numColunas = 6;
   int altura = 21;
   int largura = 80;
   
   // CRIAR COLUNAS E LINHAS
   int label1Espacamento = 0;
   string objName;
   int x,y;
   int xPadding = LarguraBackgroud;
   int yPadding = 27;
   color corFundo = clrSnow;
   color corTexto = clrDarkSlateGray;
   
   for(int i=0;i<numLinhas;i++)
   {  
      
      for(int j=0;j<numColunas;j++)
      {
         objName = "labelCustom_c"+IntegerToString(j)+"_l"+IntegerToString(i);
         x = xPadding + j*largura;
         y = yPadding + i*altura;
         
         if(j==0 && i!=0)
           {
            CreateLabelEdit(objName,x,y,largura,altura,label1Espacamento);
           }
         else
           {
            CreateLabel(objName,x,y,largura,altura,label1Espacamento,corFundo,corTexto);
           }                
      }

   }
   
   // INSERINDO TITULO
   string labelTitulo;
   string tituloPares[6] = {"ATIVO","PREÇO","AÇÃO","P.MEDIANA","P.DIA","P.HOJE"};
   corFundo = clrDarkSlateGray;
   corTexto = clrSnow;
   for(int i=1;i<numColunas;i++)
     {
      for(int j=0;j<numColunas;j++)
        {
         labelTitulo = "labelCustom_c"+IntegerToString(j)+"_l0";
         MudarTituloDisplayPares(labelTitulo,tituloPares[j],corFundo,corTexto);
        }
     }
     
      // busca os ativos selecionados
      if(CustomParesNames!="")
        {
         string to_split=CustomParesNames;
         string sep=",";                // A separator as a character 
         ushort u_sep;                  // The code of the separator character 
         string NomeParesCustom[];               // An array to get strings 
         //--- Get the separator code 

         u_sep=StringGetCharacter(sep,0); 
         //--- Split the string to substrings 
         int k=StringSplit(to_split,u_sep,NomeParesCustom); 
         
         if(k>0) 
           { 
            for(int i=0;i<k;i++) 
              {
               labelTitulo = "labelCustom_c0_l"+IntegerToString(i+1);
               StringToUpper(NomeParesCustom[i]);
               MudarItensDisplayDados(labelTitulo,NomeParesCustom[i],10);
              } 
           }
        }
     
   CriaMenuSecundarioPainel();
       
   ChartRedraw();
   return(true);
}   
   
bool InsereParesCustom()
{
   DadosAtivo ativo;
   string labelPares;
   color corFundoNegativoPares = clrCrimson;
   color corFundoPositivoPares = clrGreen;
   color corTextoPares = clrSnow;
   int CasasDecimais;
   
   for (int i = 0; i < 10; i++)
   {
      string objectName = "labelCustom_c0_l"+IntegerToString(i+1);
      string nomeAtivo =ObjectGetString(0,objectName,OBJPROP_TEXT);
      StringToUpper(nomeAtivo);        
  
      if(nomeAtivo !="DIGITE")
      {      
         for(int j=1;j<6;j++)
         {
            //coluna2
            if(j<2)
            {
               PegarDadosPares(ativo, nomeAtivo, MesesHistoricos);
               labelPares = "labelCustom_c"+IntegerToString(j)+"_l"+IntegerToString(i+1);
               CasasDecimais = int(SymbolInfoInteger(nomeAtivo+LetrasFinalPares,SYMBOL_DIGITS));
               MudarItensDisplayDados(labelPares,DoubleToString(ativo.PrecoBidPar,CasasDecimais),8);
            }
            //coluna3
            else if(j<3)
            {
               PegarDadosPares(ativo, nomeAtivo, MesesHistoricos);
               labelPares = "labelCustom_c"+IntegerToString(j)+"_l"+IntegerToString(i+1);
               MudarCorFundo(labelPares,ativo.OrientacaoColor,corTextoPares);
               MudarItensDisplayDados(labelPares,ativo.Orientacao,9); 
            }
            //coluna4
            else if(j<4)
            {
               PegarDadosPares(ativo, nomeAtivo, MesesHistoricos);
               labelPares = "labelCustom_c"+IntegerToString(j)+"_l"+IntegerToString(i+1);
               MudarItensDisplayDados(labelPares,DoubleToString(ativo.DistMediana,0),9); 
            }
            //coluna5
            else if(j<5)
            {
               PegarDadosPares(ativo, nomeAtivo, MesesHistoricos);
               labelPares = "labelCustom_c"+IntegerToString(j)+"_l"+IntegerToString(i+1);
               MudarItensDisplayDados(labelPares,DoubleToString(ativo.MovDiaria,0),9); 
            }  
            //coluna6
            else if(j<6)
            {
               PegarDadosPares(ativo, nomeAtivo, MesesHistoricos);
               labelPares = "labelCustom_c"+IntegerToString(j)+"_l"+IntegerToString(i+1);
               
               if(ativo.MovHoje<0)
                  {
                     MudarCorFundo(labelPares,corFundoNegativoPares,corTextoPares);
                     ativo.MovHoje = ativo.MovHoje*-1;
                     ativo.PorcentMov = ativo.PorcentMov*-1;
                  }
                  else if(ativo.MovHoje>0)
                  {
                     MudarCorFundo(labelPares,corFundoPositivoPares,corTextoPares);
                  }
               MudarItensDisplayDados(labelPares,DoubleToString(ativo.MovHoje,0)+"("+DoubleToString(ativo.PorcentMov,0)+")%",8);
            }       
         }
      }
   }   

   ChartRedraw();
   return(true);
}   


bool CriarDisplayPrecos()
{
   int numLinhas = 11;
   int numColunas = 7;
   int altura = 21;
   int largura = 49;
   
   // CRIAR COLUNAS E LINHAS
   int label1Espacamento = 0;
   int label2Espacamento = (numColunas*largura)+label1Espacamento;
   int label3espacamento = label2Espacamento+(numColunas*largura);
   string objName;
   int x,y;
   int xPadding = 0;
   int yPadding = 27;
   color corFundo = C'36,46,65';
   color corTexto = clrSnow;
   color corBorda = clrDarkSlateGray;
   
   // localizacao canto direito superior
   if(LocalizacaoDisplay == 4)
   {
      xPadding = -45;
   }
   // tamanho maior do display
   if(TamanhoDisplay == 2)
   {
      xPadding = 30;
      if(LocalizacaoDisplay == 4)
      {
         xPadding = -75;
      } 
   }
   
   for(int i=0;i<numLinhas;i++)
   {  
      //PRIMEIRO BLOCO
      for(int j=0;j<numColunas;j++)
      {
         objName = "labelPrecos1_c"+IntegerToString(j)+"_l"+IntegerToString(i);
         x = xPadding + j*largura;
         y = yPadding + i*altura;
         CreateLabelPreco(objName,x,y,largura,altura,label1Espacamento,corFundo,corTexto,corBorda);       
      }
      //SEGUNDO BLOCO
      for(int k=0;k<numColunas;k++)
      {
         objName = "labelPrecos2_c"+IntegerToString(k)+"_l"+IntegerToString(i);
         x = xPadding + 3 + k*largura;
         y = yPadding + i*altura;
         CreateLabelPreco(objName,x,y,largura,altura,label2Espacamento,corFundo,corTexto,corBorda);        
      }
      //TERCEIRO BLOCO
      for(int l=0;l<numColunas;l++)
      {
         if(i<9)
         {
            objName = "labelPrecos3_c"+IntegerToString(l)+"_l"+IntegerToString(i);
            x = xPadding + 6 + l*largura;
            y = yPadding + i*altura;
            CreateLabelPreco(objName,x,y,largura,altura,label3espacamento,corFundo,corTexto,corBorda);        
         }
      }
   }
   
   // INSERINDO TITULO
   string labelTitulo;
   string tituloPares[7] = {"ATIVO","PREÇO","AÇÃO","ONTEM","1 SEMANA","1 MÊS"};
   string UltimosAnos = IntegerToString(MesesHistoricos/12)+" ANOS";
   tituloPares[6] = UltimosAnos;
   for(int i=1;i<numColunas;i++)
     {
      for(int j=0;j<numColunas;j++)
        {
         labelTitulo = "labelPrecos"+IntegerToString(i)+"_c"+IntegerToString(j)+"_l0";
         MudarTituloDisplayPares(labelTitulo,tituloPares[j],corFundo,corTexto);
         MudarCorTexto(labelTitulo,corTexto,clrSnow);
        }
     } 

   InsereParesPrecos();            
   ChartRedraw();
   return(true);
}


bool InsereParesPrecos()
{
   string ParesPrincipais1[10] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF",
"CADJPY","CHFJPY","EURAUD","EURCAD"};

   string ParesPrincipais2[10] = {"EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD",
"GBPCAD","GBPCHF","GBPJPY","GBPNZD"};

   string ParesPrincipais3[8] = {"GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD",
"USDCHF","USDJPY"};
   
   // INSERINDO PARES NAS COLUNAS
   DadosAtivo ativo;
   string labelPares;
   color corFundoNegativoPares = C'210, 0, 0';
   color corFundoPositivoPares = C'0, 210, 0';
   color corFundo = clrSnow;
   color corTexto = clrDarkSlateGray;
   color corTextoResultado;
   color corTextoOrientacao = clrSnow;
   int CasasDecimais;
   double PrecoHoje;
   double PrecoOntem;
   double PrecoMedio;
   double PorcentagemPreco;   

   //PRIMEIRO BLOCO
   for(int i=0;i<10;i++)
   {
      for(int j=0;j<7;j++)
      {
         //coluna1
         if(j<1)
         {
            labelPares = "labelPrecos1_c"+IntegerToString(j)+"_l"+IntegerToString(i+1);
            MudarItensDisplayPares(labelPares,ParesPrincipais1[i],10,corFundo,corTexto);    
         }
         //coluna2
         else if(j<2)
         {
            PrecoHoje = SymbolInfoDouble(ParesPrincipais1[i]+LetrasFinalPares,SYMBOL_BID);
            labelPares = "labelPrecos1_c"+IntegerToString(j)+"_l"+IntegerToString(i+1);
            CasasDecimais = int(SymbolInfoInteger(ParesPrincipais1[i]+LetrasFinalPares,SYMBOL_DIGITS));
            MudarItensDisplayDados(labelPares,DoubleToString(PrecoHoje,CasasDecimais),8);
         }
         //coluna3
         else if(j<3)
         {
            PegarDadosPares(ativo, ParesPrincipais1[i], MesesHistoricos);
            labelPares = "labelPrecos1_c"+IntegerToString(j)+"_l"+IntegerToString(i+1);
            MudarCorFundo(labelPares,ativo.OrientacaoColor,corTextoOrientacao);
            MudarItensDisplayDados(labelPares,ativo.Orientacao,9);
         }
         //coluna4
         else if(j<4)
         {
            PrecoOntem = iClose(ParesPrincipais1[i]+LetrasFinalPares,PERIOD_D1,1);
            labelPares = "labelPrecos1_c"+IntegerToString(j)+"_l"+IntegerToString(i+1);
            PorcentagemPreco = ((PrecoHoje-PrecoOntem)/PrecoHoje)*100;
            MudarItensDisplayDados(labelPares,DoubleToString(PorcentagemPreco,2)+"%",8);
            corTextoResultado = PorcentagemPreco > 0 ? corFundoPositivoPares : corFundoNegativoPares;
            MudarCorTexto(labelPares,corTextoResultado,corTexto);
         }
         //coluna5
         else if(j<5)
         {
            // Media de Preco ultima semana
            PrecoMedio = CalculaPrecoMedio(ParesPrincipais1[i]+LetrasFinalPares, "dias", 7);
            labelPares = "labelPrecos1_c"+IntegerToString(j)+"_l"+IntegerToString(i+1);
            PorcentagemPreco = ((PrecoHoje-PrecoMedio)/PrecoHoje)*100;
            MudarItensDisplayDados(labelPares,DoubleToString(PorcentagemPreco,2)+"%",8);
            corTextoResultado = PorcentagemPreco > 0 ? corFundoPositivoPares : corFundoNegativoPares;
            MudarCorTexto(labelPares,corTextoResultado,corTexto);
         }
         //coluna6
         else if(j<6)
         {
            // Media de Preco ultimo mes
            PrecoMedio = CalculaPrecoMedio(ParesPrincipais1[i]+LetrasFinalPares, "dias", 30);
            labelPares = "labelPrecos1_c"+IntegerToString(j)+"_l"+IntegerToString(i+1);
            PorcentagemPreco = ((PrecoHoje-PrecoMedio)/PrecoHoje)*100;
            MudarItensDisplayDados(labelPares,DoubleToString(PorcentagemPreco,2)+"%",8);
            corTextoResultado = PorcentagemPreco > 0 ? corFundoPositivoPares : corFundoNegativoPares;
            MudarCorTexto(labelPares,corTextoResultado,corTexto);
         }  
         //coluna7
         else if(j<7)
         {
            // Media de Preco dos ultimos Anos
            PrecoMedio = CalculaPrecoMedio(ParesPrincipais1[i]+LetrasFinalPares, "meses", MesesHistoricos);
            labelPares = "labelPrecos1_c"+IntegerToString(j)+"_l"+IntegerToString(i+1);
            PorcentagemPreco = ((PrecoHoje-PrecoMedio)/PrecoHoje)*100;
            MudarItensDisplayDados(labelPares,DoubleToString(PorcentagemPreco,2)+"%",8);
            corTextoResultado = PorcentagemPreco > 0 ? corFundoPositivoPares : corFundoNegativoPares;
            MudarCorTexto(labelPares,corTextoResultado,corTexto);
         }
      }
      //SEGUNDO BLOCO
      for(int k=0;k<6;k++)
      {
         //coluna1
         if(k<1)
         {
            labelPares = "labelPrecos2_c"+IntegerToString(k)+"_l"+IntegerToString(i+1);
            MudarItensDisplayPares(labelPares,ParesPrincipais2[i],10,corFundo,corTexto);
         }
         //coluna2
         else if(k<2)
         {
            PrecoHoje = SymbolInfoDouble(ParesPrincipais2[i]+LetrasFinalPares,SYMBOL_BID);
            labelPares = "labelPrecos2_c"+IntegerToString(k)+"_l"+IntegerToString(i+1);
            CasasDecimais = int(SymbolInfoInteger(ParesPrincipais2[i]+LetrasFinalPares,SYMBOL_DIGITS));
            MudarItensDisplayDados(labelPares,DoubleToString(PrecoHoje,CasasDecimais),8);
         }
         //coluna3
         else if(k<3)
         {
            PegarDadosPares(ativo, ParesPrincipais2[i], MesesHistoricos);
            labelPares = "labelPrecos2_c"+IntegerToString(k)+"_l"+IntegerToString(i+1);
            MudarCorFundo(labelPares,ativo.OrientacaoColor,corTextoOrientacao);
            MudarItensDisplayDados(labelPares,ativo.Orientacao,9); 
         }     
         //coluna4
         else if(k<4)
         {
            PrecoOntem = iClose(ParesPrincipais2[i]+LetrasFinalPares,PERIOD_D1,1);
            labelPares = "labelPrecos2_c"+IntegerToString(k)+"_l"+IntegerToString(i+1);
            PorcentagemPreco = ((PrecoHoje-PrecoOntem)/PrecoHoje)*100;
            MudarItensDisplayDados(labelPares,DoubleToString(PorcentagemPreco,2)+"%",8);
            corTextoResultado = PorcentagemPreco > 0 ? corFundoPositivoPares : corFundoNegativoPares;
            MudarCorTexto(labelPares,corTextoResultado,corTexto);
         }
         //coluna5
         else if(k<5)
         {
            // Media de Preco ultima semana
            PrecoMedio = CalculaPrecoMedio(ParesPrincipais2[i]+LetrasFinalPares, "dias", 7);
            labelPares = "labelPrecos2_c"+IntegerToString(k)+"_l"+IntegerToString(i+1);
            PorcentagemPreco = ((PrecoHoje-PrecoMedio)/PrecoHoje)*100;
            MudarItensDisplayDados(labelPares,DoubleToString(PorcentagemPreco,2)+"%",8);
            corTextoResultado = PorcentagemPreco > 0 ? corFundoPositivoPares : corFundoNegativoPares;
            MudarCorTexto(labelPares,corTextoResultado,corTexto);
         }
         //coluna6
         else if(k<6)
         {
            // Media de Preco ultimo mes
            PrecoMedio = CalculaPrecoMedio(ParesPrincipais2[i]+LetrasFinalPares, "dias", 30);
            labelPares = "labelPrecos2_c"+IntegerToString(k)+"_l"+IntegerToString(i+1);
            PorcentagemPreco = ((PrecoHoje-PrecoMedio)/PrecoHoje)*100;
            MudarItensDisplayDados(labelPares,DoubleToString(PorcentagemPreco,2)+"%",8);
            corTextoResultado = PorcentagemPreco > 0 ? corFundoPositivoPares : corFundoNegativoPares;
            MudarCorTexto(labelPares,corTextoResultado,corTexto);
         }
         //coluna7
         else if(k<7)
         {
            // Media de Preco dos ultimos Anos
            PrecoMedio = CalculaPrecoMedio(ParesPrincipais2[i]+LetrasFinalPares, "meses", MesesHistoricos);
            labelPares = "labelPrecos2_c"+IntegerToString(k)+"_l"+IntegerToString(i+1);
            PorcentagemPreco = ((PrecoHoje-PrecoMedio)/PrecoHoje)*100;
            MudarItensDisplayDados(labelPares,DoubleToString(PorcentagemPreco,2)+"%",8);
            corTextoResultado = PorcentagemPreco > 0 ? corFundoPositivoPares : corFundoNegativoPares;
            MudarCorTexto(labelPares,corTextoResultado,corTexto);
         }
      }
      //TERCEIRO BLOCO
      for(int l=0;l<6;l++)
      {
         //desconsidera os 2 ultimas linhas vazias
         if(i<8)
         {
            //coluna1
            if(l<1)
            {
               labelPares = "labelPrecos3_c"+IntegerToString(l)+"_l"+IntegerToString(i+1);
               MudarItensDisplayPares(labelPares,ParesPrincipais3[i],10,corFundo,corTexto);
            }
            //coluna2
            else if(l<2)
            {
               PrecoHoje = SymbolInfoDouble(ParesPrincipais3[i]+LetrasFinalPares,SYMBOL_BID);
               labelPares = "labelPrecos3_c"+IntegerToString(l)+"_l"+IntegerToString(i+1);
               CasasDecimais = int(SymbolInfoInteger(ParesPrincipais3[i]+LetrasFinalPares,SYMBOL_DIGITS));
               MudarItensDisplayDados(labelPares,DoubleToString(PrecoHoje,CasasDecimais),8);
            }
            //coluna3
            else if(l<3)
            {
               PegarDadosPares(ativo, ParesPrincipais3[i], MesesHistoricos);
               labelPares = "labelPrecos3_c"+IntegerToString(l)+"_l"+IntegerToString(i+1);
               MudarCorFundo(labelPares,ativo.OrientacaoColor,corTextoOrientacao);
               MudarItensDisplayDados(labelPares,ativo.Orientacao,9); 
            } 
            //coluna4
            else if(l<4)
            {
               PrecoOntem = iClose(ParesPrincipais3[i]+LetrasFinalPares,PERIOD_D1,1);
               labelPares = "labelPrecos3_c"+IntegerToString(l)+"_l"+IntegerToString(i+1);
               PorcentagemPreco = ((PrecoHoje-PrecoOntem)/PrecoHoje)*100;
               MudarItensDisplayDados(labelPares,DoubleToString(PorcentagemPreco,2)+"%",8);
               corTextoResultado = PorcentagemPreco > 0 ? corFundoPositivoPares : corFundoNegativoPares;
               MudarCorTexto(labelPares,corTextoResultado,corTexto);
            }
            //coluna5
            else if(l<5)
            {
               // Media de Preco ultima semana
               PrecoMedio = CalculaPrecoMedio(ParesPrincipais3[i]+LetrasFinalPares, "dias", 7);
               labelPares = "labelPrecos3_c"+IntegerToString(l)+"_l"+IntegerToString(i+1);
               PorcentagemPreco = ((PrecoHoje-PrecoMedio)/PrecoHoje)*100;
               MudarItensDisplayDados(labelPares,DoubleToString(PorcentagemPreco,2)+"%",8);
               corTextoResultado = PorcentagemPreco > 0 ? corFundoPositivoPares : corFundoNegativoPares;
               MudarCorTexto(labelPares,corTextoResultado,corTexto);
            }
            //coluna6
            else if(l<6)
            {
               // Media de Preco ultimo mes
               PrecoMedio = CalculaPrecoMedio(ParesPrincipais3[i]+LetrasFinalPares, "dias", 30);
               labelPares = "labelPrecos3_c"+IntegerToString(l)+"_l"+IntegerToString(i+1);
               PorcentagemPreco = ((PrecoHoje-PrecoMedio)/PrecoHoje)*100;
               MudarItensDisplayDados(labelPares,DoubleToString(PorcentagemPreco,2)+"%",8);
               corTextoResultado = PorcentagemPreco > 0 ? corFundoPositivoPares : corFundoNegativoPares;
               MudarCorTexto(labelPares,corTextoResultado,corTexto);
            }
            //coluna7
            else if(l<7)
            {
               // Media de Preco dos ultimos Anos
               PrecoMedio = CalculaPrecoMedio(ParesPrincipais3[i]+LetrasFinalPares, "meses", MesesHistoricos);
               labelPares = "labelPrecos3_c"+IntegerToString(l)+"_l"+IntegerToString(i+1);
               PorcentagemPreco = ((PrecoHoje-PrecoMedio)/PrecoHoje)*100;
               MudarItensDisplayDados(labelPares,DoubleToString(PorcentagemPreco,2)+"%",8);
               corTextoResultado = PorcentagemPreco > 0 ? corFundoPositivoPares : corFundoNegativoPares;
               MudarCorTexto(labelPares,corTextoResultado,corTexto);
            }  
         }
      }

   }

   ChartRedraw();
   return(true);
}


bool CreateLabel(string objName,int x_dist, int y_dist, int largura, int altura, int DistanciaEspacamento, color corFundo, color corTexto)
{
   if( ObjectFind(0,objName)>=0 ) ObjectDelete(0,objName);
   ObjectCreate(0,objName,OBJ_EDIT,0,0,0);
   ObjectSetInteger(0,objName,OBJPROP_XDISTANCE,DistanciaEspacamento+x_dist);
   ObjectSetInteger(0,objName,OBJPROP_YDISTANCE,y_dist);
   ObjectSetInteger(0,objName,OBJPROP_XSIZE,largura);
   ObjectSetInteger(0,objName,OBJPROP_YSIZE,altura);
   ObjectSetString(0,objName,OBJPROP_TEXT,"-");
   ObjectSetString(0,objName,OBJPROP_FONT,"Consolas Bold");
   ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,objName,OBJPROP_COLOR,corTexto);
   ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,corFundo);
   //ObjectSetInteger(0,objName,OBJPROP_BORDER_COLOR,clrDarkSlateGray);
   ObjectSetInteger(0,objName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,objName,OBJPROP_READONLY,true);
   ObjectSetInteger(0,objName,OBJPROP_ALIGN,ALIGN_CENTER);  
   ObjectSetInteger(0,objName,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   
   return(true);
}

bool CreateLabelPreco(string objName,int x_dist, int y_dist, int largura, int altura, int DistanciaEspacamento, color corFundo, color corTexto, color corBorda)
{
   if( ObjectFind(0,objName)>=0 ) ObjectDelete(0,objName);
   ObjectCreate(0,objName,OBJ_EDIT,0,0,0);
   ObjectSetInteger(0,objName,OBJPROP_XDISTANCE,DistanciaEspacamento+x_dist);
   ObjectSetInteger(0,objName,OBJPROP_YDISTANCE,y_dist);
   ObjectSetInteger(0,objName,OBJPROP_XSIZE,largura);
   ObjectSetInteger(0,objName,OBJPROP_YSIZE,altura);
   ObjectSetString(0,objName,OBJPROP_TEXT,"-");
   ObjectSetString(0,objName,OBJPROP_FONT,"Consolas Bold");
   ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,objName,OBJPROP_COLOR,corTexto);
   ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,corFundo);
   ObjectSetInteger(0,objName,OBJPROP_BORDER_COLOR,corBorda);
   ObjectSetInteger(0,objName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,objName,OBJPROP_READONLY,true);
   ObjectSetInteger(0,objName,OBJPROP_ALIGN,ALIGN_CENTER);  
   ObjectSetInteger(0,objName,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   
   return(true);
}

bool CreateLabelEdit(string objName,int x_dist, int y_dist, int largura, int altura, int DistanciaEspacamento)
{
   if( ObjectFind(0,objName)>=0 ) ObjectDelete(0,objName);
   ObjectCreate(0,objName,OBJ_EDIT,0,0,0);
   ObjectSetInteger(0,objName,OBJPROP_XDISTANCE,DistanciaEspacamento+x_dist);
   ObjectSetInteger(0,objName,OBJPROP_YDISTANCE,y_dist);
   ObjectSetInteger(0,objName,OBJPROP_XSIZE,largura);
   ObjectSetInteger(0,objName,OBJPROP_YSIZE,altura);
   ObjectSetString(0,objName,OBJPROP_TEXT,"DIGITE");
   ObjectSetString(0,objName,OBJPROP_FONT,"Consolas Bold");
   ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,objName,OBJPROP_COLOR,clrDarkSlateGray);
   ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrSnow);
   ObjectSetInteger(0,objName,OBJPROP_ALIGN,ALIGN_CENTER);  
   ObjectSetInteger(0,objName,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   
   return(true);
}


bool MudarItensDisplayPares(string labelPares,string tituloPares,int fonte,color corFundo,color corTexto)
{
   ObjectSetString(0,labelPares,OBJPROP_TEXT,tituloPares);
   ObjectSetInteger(0,labelPares,OBJPROP_FONTSIZE,fonte);
   ObjectSetInteger(0,labelPares,OBJPROP_COLOR,corTexto);
   ObjectSetInteger(0,labelPares,OBJPROP_BGCOLOR,corFundo);
   //ObjectSetInteger(0,labelPares,OBJPROP_BORDER_COLOR,clrDarkSlateGray);

return(true);
}

bool MudarItensDisplayDados(string labelTitulo,string tituloPares,int fonte)
{
   ObjectSetString(0,labelTitulo,OBJPROP_TEXT,tituloPares);
   ObjectSetInteger(0,labelTitulo,OBJPROP_FONTSIZE,fonte);

return(true);}



bool MudarTituloDisplayPares(string labelPares,string tituloPares,color corFundo,color corTexto)
{
   ObjectSetString(0,labelPares,OBJPROP_TEXT,tituloPares);
   ObjectSetInteger(0,labelPares,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,labelPares,OBJPROP_COLOR,corTexto);
   ObjectSetInteger(0,labelPares,OBJPROP_BGCOLOR,corFundo);

return(true);
}


bool MudarCorFundo(string labelPares,color corFundo,color corTexto)
{
   ObjectSetInteger(0,labelPares,OBJPROP_COLOR,corTexto);
   ObjectSetInteger(0,labelPares,OBJPROP_BGCOLOR,corFundo);

return(true);
}


bool MudarCorTexto(string labelPares,color corTexto,color corBorda)
{
   ObjectSetInteger(0,labelPares,OBJPROP_COLOR,corTexto);
   ObjectSetInteger(0,labelPares,OBJPROP_BORDER_COLOR,corBorda);

return(true);
}