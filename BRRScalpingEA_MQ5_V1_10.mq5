//+------------------------------------------------------------------+
//|                                                BRRScalpingEA.mq5 |
//|                                   Copyright 2023, Atikur Rahman. |
//|                                    https://www.validatortech.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Atikur Rahman."
#property link      "https://www.validatortech.com"

// Old version
//#property prev_version   "1.00"

// New version 
#define VERSION "1.10"
#property version VERSION


//+------------------------------------------------------------------+
//| Library Include                                                  |
//+------------------------------------------------------------------+

//#include <Trade/Trade.mqh>

// Trade
#include <ValidatorTech/Frameworks/Framework_1.0/Trade/Trade.mqh>


// Moving Average Indicators
//#include <ValidatorTech/MovingAverage/MAIndicator.mqh>
//#include <ValidatorTech/MovingAverage/MATouchSignal.mqh>
//#include <ValidatorTech/MovingAverage/MACrossoverSignal.mqh>
//#include <ValidatorTech/MovingAverage/MASniperSignal.mqh>

// Stochastic Indicator
//#include <ValidatorTech/Stochastic/StochasticIndicator.mqh>
//#include <ValidatorTech/Stochastic/StochasticSignal.mqh>


// Candlestick Pattern
#include <ValidatorTech/CandlestickPattern/CandlestickPattern.mqh>

// ADX Indicator
#include <ValidatorTech/ADX/ADXIndicator.mqh>
#include <ValidatorTech/ADX/ADXSignal.mqh>

// Volume 
//#include <ValidatorTech/Volume/VolumeIndicator.mqh>

// ATR Indicator
//#include <ValidatorTech/ATR/ATRIndicator.mqh>
//#include <ValidatorTech/ATR/ATRSignal.mqh>

// Indicators
//#include <ValidatorTech/MovingAverage/MAIndicator.mqh>

// Using TimeRange, For Trading Time Check
#include <ValidatorTech/TimeRange/TimeRange.mqh>

// Candles/Bars Info Update
#include <ValidatorTech/CandleInfoClasses/CandleInfo.mqh>

// Draw Trendline
//#include <ValidatorTech/TrendLinesClasses/TrendHighLow.mqh>

// Using ChartObjectTrendline, For Trendline breakout
#include <ValidatorTech/ChartObjectsClasses/ChartObjectTrendline.mqh>

// Using ChartObjectHorizontalLine, For Horizontalline Breakout
//#include <ValidatorTech/ChartObjectsClasses/ChartObjectHorizontalLine.mqh>

// Using ChartObjectRectangular, For Rectangular Support/Resistance Zone Breakout
#include <ValidatorTech/ChartObjectsClasses/ChartObjectRectangular.mqh>
#include <ValidatorTech/ChartObjectsClasses/MyRectangle.mqh>

// Commodity Channel Index (CCI)
//#include <ValidatorTech/CCI/CCIIndicator.mqh>


/****************************************************************************/
/* Program Defination                                                       */
/****************************************************************************/

#define PROJECT_NAME MQLInfoString(MQL_PROGRAM_NAME)
#define EA_CURRENT_DRAWDOWN "EA_CURRENT_DRAWDOWN"
#define INSTANT_TRADE "INSTANT_TRADE"
#define PREFIX "ChartObj"

//+------------------------------------------------------------------+
//| Inputs Section                                                   |
//+------------------------------------------------------------------+

enum MARKET_TREND {
   AUTO        = 0,
   UP_TREND    =  1,
   DOWN_TREND  =  2,
   RANGING     =  3
};


//input int                  TrendLineBarStart              =  1;
//input int                  TrendLineBarCount              =  30;

input group    "#----- Trade Permission  -----#"
input bool     IsExpertAllowedToTrade  =  true;             // Is Expert Allowed To Trade


input group    "#----- User Interface -----#"
input bool     ShowUserInterface = false;                   // Show user interface
input bool     UserInterfaceTransparent = false;            // Show user interface as transparent


input group    "#----- Trading Timeframe -----#"
input ENUM_TIMEFRAMES   Timeframe      =  PERIOD_H1;        // Trading Timeframe


input group    "#----- Trading Hours -----#"
input bool     TradingHoursActive = false;                  // Is trading hours active

input int      TradingStartHour = 01;                       // Trading start hour
input int      TradingStartMin = 00;                        // Trading start minute
input int      TradingEndHour = 23;                         // Trading end hour
input int      TradingEndMin = 59;                          // Trading end minute


input group    "#----- Risk Management -----#"
input double   InitialAccountBalance   =  200.0;            // Account Fixed Balance
input double   PerTradeRiskPercent     =  1.0;              // Per Trade Risk(%)
input double   PerDayRiskOfBalance     =  4.00;             // Per Day Max Risk(%)
input double   TotalRiskOfBalance      =  10.0;             // Per Month Average Risk(%)
input double   MaxRiskOfBalance        =  15.0;             // Maximum Risk(%) Of Balance


input group    "#----- Chart Scan -----#"
input int      NumberOfBarScan = 200;                       // Scan Number Of Bars
input int      LookBackBars = 5;                            // Look Back Bars For High/Low Peaks
input int      ExtraOffsetPoints = 30;                      // Add Extra Offset Points To Pending Trades 


input group    "#----- Trade Management -----#"
input bool     AllowPendingTrades      =  true;             // Allow Pending Orders
input bool     AllowTrendlineTrades    =  true;             // Allow Trendline Breakout Trades
input bool     ForclyCloseAllTrades    =  false;            // Forcly closes all trades
input bool     CloseAllProfitTrades    =  false;            // Closes all profit trades
input bool     CloseAllLossTrades      =  false;            // Closes all loss trades
input bool     CloseAllPendingTrades   =  false;            // Closes all pending trades
input bool     OpenBuyTrades           =  true;             // Open buy trades
input bool     OpenSellTrades          =  true;             // Open sell trades


input group    "#----- Trade Setting -----#"
input MARKET_TREND MarketTrend         =  AUTO;             // Market Trend, AUTO = Buy and Sell both
input bool     FixedLotsSize           =  false;            // Fixed Lots Size, true = Fixed, false = Dynamic Lots
input double   Lots = 0.1;                                  // Fixed Lots
input int      MaxRunningTrade = 3;                         // Maximum Running Trade

input int      OrderDistPoints = 200;                       // Maximum distance between two orders
input int      TLTpPoints = 1500;                           // Trendline TP
input int      TLSLPoints = 500;                            // Trendline Stoploss
input int      TLTslPoints = 500;                           // Trendline Trailing Stop
input int      BreakevenWhenProfit = 200;                   // Set Trendline Trade Breakeven When Profit 
input int      BreakevenStopLoss   = 10;                    // Set Trendline Breakeven Stoploss Points

input int      TpPoints = 500;                              // Take Profit Points, 0 = No TP
input int      SlPoints = 350;                              // Stoploss Points, 0 = No SL
input int      TslPoints = 10;                              // Trailing Stop Points
input int      TslTriggerPoints = 50;                       // Trailing Stop Trigger Points, 0 = No TSL



input int      ExpirationHours = 20;                        // Pending Trade Expire Time


/****************************************************************************/
/* Stochastic Indicator Inputs */
/****************************************************************************/
/*
input group    "#----- Stochastic Setting -----#"
input bool                 Stoch_Will_Attach              =  true;
input int                  Stoch_KPeriod                  =  14;
input int                  Stoch_DPeriod                  =  3; 
input int                  Stoch_Slowing                  =  3; 
input ENUM_MA_METHOD       Stoch_Method                   =  MODE_SMA;
input ENUM_STO_PRICE       Stoch_Price                    =  STO_LOWHIGH;
input double               Stoch_Overbought_Level         =  80.0;
input double               Stoch_Oversold_Level           =  20.0;
*/

/****************************************************************************/
/* Moving Average Inputs */
/****************************************************************************/
/* Uncomment if needed
input group    "#----- Moving Average Setting -----#"
input bool                 All_MA_Will_Attach              =  true;


input bool                 TwentyOne_EMA_Will_Attach       =  true;
input int                  TwentyOne_MA_Period             =  21;
input ENUM_MA_METHOD       EMA_Method                      =  MODE_EMA;


input bool                 Fifty_EMA_Will_Attach           =  true;
input int                  Fifty_MA_Period                 =  50;
    

input bool                 OneHundred_EMA_Will_Attach      =  true;
input int                  OneHundred_MA_Period            =  100;


input bool                 TwoHundred_EMA_Will_Attach      =  true;
input int                  TwoHundred_MA_Period            =  200;


input ENUM_APPLIED_PRICE   MA_AppliedPrice                 =  PRICE_CLOSE;  
*/

input group    "#----- Magic, Comments -----#"
input int      Magic = 111111;                              // Magic Number
input string   TradeComments = "";                          // Trade Comments

/****************************************************************************/
/* Consolidation Variables */
/****************************************************************************/
/*
input int      RangeSizePoints                =  100;
input int      RangeBars                      =  20;
input int      VolumeBars                     =  20;
*/


//+------------------------------------------------------------------+
//| Variable declaration                                             |
//+------------------------------------------------------------------+

//CTrade trade;
// Trade class
CTradeCustom trade;


// Moving Average Indicator Classes
//CMAIndicator   *twoHundredEMA, *oneHundredEMA,   
//               *fiftyEMA, *twentyOneEMA;


//CMAIndicator *trendMA;
CTimeRange *cTimeRange;

// ADX Indicator
CADXIndicator *adxIndicator;
CADXSignal *adxSignal;


// Volume Indicator
//CVolumeIndicator *volumeIndicator;

// ATR Indicator
//CATRIndicator *atrIndicator;
//CATRSignal *atrSignal;


// Candlestick Pattern
CCandlestickPattern  *candleStickPattern;

//
CCandleInfo                *cCandleInfo;
//CTrendHighLow            *cTrendHighLow;
CChartObjectTrendline      *cChartObjTline;
//CChartObjectHorizontalLine *cObjHLine;
CChartObjectRectangular    *cObjRectangle;

// Commodity Channel Index (CCI)
//CCCIIndicator           *cciIndicator1,   *cciIndicator2,   *cciIndicator3;


// Stochastic Variables
//CStochasticIndicator *stochIndicator;
//CStochasticSignal    *stochSignal;


MARKET_TREND selectedMarketTrend;


int totalBars;
ulong buyPos = -1, sellPos = -1;
string buyPosStr = "", sellPosStr = "";


// Moveing Average Variables
int    TwoHundredEMA_Flag;
double TwoHundredEMA_Handle;
double TwoHundredEMA_Buffer[];


bool newBar = false, dailyNewBar = false, weeklyNewBar = false, monthlyNewBar = false;
bool isDrawdown = false, isPerDayDrawdownHit = false;
bool isProgramReset = false;
bool visibleUserInterface = false;
bool is_trade_allow = true;

bool IsTLineBreaks           =  false;
bool IsTLineBreaksAndRetouch =  false;
bool TLinePriceMovementUncertain =  false;
bool TLinePriceQuickMovement = false;

bool IsHLineBreaks           =  false;
bool IsHLineBreaksAndRetouch =  false;

bool IsRObjectBreaks           =  false;
bool IsRObjectBreaksAndRetouch =  false;
bool RectObjPriceMovementUncertain =  false;
bool RectObjPriceQuickMovement = false;

int  TLBreaksBarCount  =  0;
int  TLBreaksTradeCount = 0;

int  HLBreaksBarCount  =  0;
int  HLBreaksTradeCount = 0;

int  RObjectBreaksBarCount  =  0;
int  RObjectBreaksTradeCount = 0;

string adxStatus = "";
string TLBreakOrderType="", TLObjName="", RectObjBreakOrderType="", RectObjName="";
string chartObjName;
string candlestickPatternName = "";

double lowPrice = 0, highPrice = 0;
static double prevLowPrice = 0, prevHighPrice = 0;

int lowPriceIndex = -1, highPriceIndex = -1;
static int prevLowPriceIndex = -1, prevHighPriceIndex = -1;

int positionTotal = 0;

string separator = "#"; 
ushort separatorChar;

string upperTLTouchArr[], lowerTLTouchArr[], resistanceZoneTouchArr[], supportZoneTouchArr[];

MyRectangle *myRectangle[];

string            mSymbol;                            // Current Chart Symbol
ENUM_TIMEFRAMES   mPeriod;                            // Current Chart Time Period


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit() {

   //Print("Input Time: " + PeriodSeconds(Timeframe) + ", Chart Time: " + PeriodSeconds(Period()));
   selectedMarketTrend = MarketTrend;
   //Print("MarketTrend: "+MarketTrend + ", selectedMarketTrend: "+selectedMarketTrend);
   
   if(PeriodSeconds(Timeframe) != PeriodSeconds(Period())) {
      PrintFormat("Chart timeframe is mismatched with input timeframe, Please make your chart timeframe to %s",
                  EnumToString(Timeframe));
      return(INIT_PARAMETERS_INCORRECT);
   }

   mSymbol  =  Symbol();
   mPeriod  =  Period();
   separatorChar = StringGetCharacter(separator, 0);
   

   trade.SetExpertMagicNumber(Magic);

   if(!trade.SetTypeFillingBySymbol(mSymbol)) {
      trade.SetTypeFilling(ORDER_FILLING_RETURN);
   }
   
   
   // Moving Average Indicator Setup
   //MovingAverageSetup();
   
   
   // EMA Setup
   //TwoHundredEMA_Handle = iMA(cSymbol, PERIOD_CURRENT, TwoHundred_MA_Period, 0, TwoHundred_EMA_Method, PRICE_CLOSE);
   
   
   // Stochastic Indicator
   //stochIndicator = new CStochasticIndicator(mSymbol, mPeriod, Stoch_KPeriod, Stoch_DPeriod, 
   //                                          Stoch_Slowing, Stoch_Method, Stoch_Price);
   //stochSignal    = new CStochasticSignal(Stoch_Oversold_Level, Stoch_Overbought_Level, stochIndicator);
      
   
   
   // ADX Indicator
   adxIndicator   =  new CADXIndicator(mSymbol, mPeriod, 14);
   adxSignal      =  new CADXSignal(adxIndicator); 


   // Volume Indicator
   //volumeIndicator = new CVolumeIndicator(mSymbol, mPeriod);
      
      
   // ATR Indicator
   //atrIndicator   =  new CATRIndicator(mSymbol, mPeriod, RangeBars);
   //atrSignal      =  new CATRSignal(atrIndicator); 

// Initialize CTimeRange Instance
   cTimeRange     =  new CTimeRange(mSymbol, mPeriod, TradingStartHour, TradingStartMin,
                                    TradingEndHour, TradingEndMin);

// Initialize CCandleInfo Class Instance
   cCandleInfo    =  new CCandleInfo(mSymbol, mPeriod);
   
   // Candlestick Pattern
   candleStickPattern =  new CCandlestickPattern(mSymbol, Timeframe);

// Initialize CChartObjectTrendline Class Instance
   cChartObjTline =  new CChartObjectTrendline(mSymbol, mPeriod, true);

// Initialize CChartObjectTrendline Class Instance
   //cObjHLine      =  new CChartObjectHorizontalLine(mSymbol, mPeriod, false);

   // Initialize CChartObjectTrendline Class Instance
   cObjRectangle  =  new CChartObjectRectangular(mSymbol, mPeriod, true);



   static bool isInit = false;
   if(!isInit) {

      isInit = true;
      //Print(__FUNCTION__," > EA (re)start...");
      //Print(__FUNCTION__," > EA version ",VERSION,"...");

      for(int i = PositionsTotal()-1; i >= 0; i--)
        {
         CPositionInfo pos;
         if(pos.SelectByIndex(i))
           {
            if(pos.Magic() != Magic)
               continue;
            if(pos.Symbol() != mSymbol)
               continue;

            Print(__FUNCTION__," > Found open position with ticket #",pos.Ticket(),"...");
            if(pos.PositionType() == POSITION_TYPE_BUY)
               buyPos = pos.Ticket();
            if(pos.PositionType() == POSITION_TYPE_SELL)
               sellPos = pos.Ticket();
           }
        }


      for(int i = OrdersTotal()-1; i >= 0; i--)
        {
         COrderInfo order;
         if(order.SelectByIndex(i))
           {
            if(order.Magic() != Magic)
               continue;
            if(order.Symbol() != mSymbol)
               continue;

            Print(__FUNCTION__," > Found pending order with ticket #",order.Ticket(),"...");
            if(order.OrderType() == ORDER_TYPE_BUY_STOP)
               buyPos = order.Ticket();
            if(order.OrderType() == ORDER_TYPE_SELL_STOP)
               sellPos = order.Ticket();
           }
        }
     }

//Print(__FUNCTION__ + ", Position: "+PositionsTotal() + ", Orders: " + OrdersTotal() + ", buyPos: "+buyPos+", sellPos: "+sellPos);

   // Set initialy true
   IsNewBar(true);
   IsDailyNewBar(true);
   IsWeeklyNewBar(true);
   IsMonthlyNewBar(true);
  
  
   // Create User Interface
   if(ShowUserInterface) createUserInterface();
   

   /*
   //--- Creating a 1.5 inch wide button on a screen
   int screen_dpi = TerminalInfoInteger(TERMINAL_SCREEN_DPI); // Find DPI of the user monitor
   int base_width = 144;                                      // The basic width in the screen points for standard monitors with DPI=96
   int width      = (base_width * screen_dpi) / 96;         // Calculate the button width for the user monitor (for the specific DPI)
   Print("111 screen_dpi: "+screen_dpi + ", base_width: "+ base_width +", width: " + width);
    
   //--- Calculating the scaling factor as a percentage
   int scale_factor=(screen_dpi * 100) / 96;
   //--- Use of the scaling factor
   width=(base_width * scale_factor) / 100;
   
   Print("222 scale_factor: "+scale_factor + ", base_width: "+ base_width +", width: " + width);
   
   int screen_width = TerminalInfoInteger(TERMINAL_SCREEN_WIDTH);
   int screen_height = TerminalInfoInteger(TERMINAL_SCREEN_HEIGHT);
   double screen_ratio = ((double)screen_height/(double)screen_width);
   Print("screen_width: "+screen_width + ", screen_height: "+screen_height + ", screen_ratio: "+DoubleToString(screen_ratio, 2));
   */
   
//---
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   //--- destroy timer
   EventKillTimer();

   // Delete MA
   //delete twoHundredEMA;
   //delete oneHundredEMA;
   //delete fiftyEMA;
   //delete twentyOneEMA;
   
   // Delete ADX
   delete adxIndicator;
   delete adxSignal;
   
   
   // Delete Volumn
   //delete volumeIndicator;
   
   
   // Delete ATR
   //delete atrIndicator;
   //delete atrSignal;
   
   
   // Delete Stochastic
   //delete stochIndicator;
   //delete stochSignal;
   
   
   // Delete CandlestickPattern
   delete candleStickPattern;

// Delete Objects
   delete cTimeRange;
   delete cCandleInfo;
   delete cChartObjTline;
   //delete cObjHLine;
   delete cObjRectangle;
   
   freeRectObjArray();
//delete cTrendHighLow;


   // Delete User Interface All Objects
   ObjectsDeleteAll(0, PREFIX, 0, -1);
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick() {

   // Check if expert allow to trade
   if(!IsExpertAllowedToTrade) return;
      
   // Quick check if trading is possible
   if(!IsTradeAllowed()) return;

   // Check if market is open
   if(!IsMarketOpen(mSymbol, TimeCurrent())) return;


   // Forcefully closes all trades
   if(ForclyCloseAllTrades) {
      closeAllPositions();
      return;
   }

   // Closes all profit trades
   if(CloseAllProfitTrades) {
      closeAllProfitPositions();
      return;
   }

   // Closes all loss trades
   if(CloseAllLossTrades) {
      closeAllLossPositions();
      return;
   }

   // Closes all pending trades
   if(CloseAllPendingTrades) {
      closeAllPendingPositions();
      return;
   }

   
   // Check if program is not allow any trades
   if(!is_trade_allow) return;


   // Return if trading time is not time range
   if(TradingHoursActive) {
      if(!cTimeRange.InsideRange()) {
         Print("Trading hours are over!");
         resetProgram();
         return;
      }
   }   

   /*if(isPerDayDrawdownHit) {
      Print("Per Day Max Drawdown Hits!");
      is_trade_allow = false;
      resetProgram();
      return;
   }*/


   // Check if PositionsTotal() <= MaxRunningTrade, if not then return


   // Reset isProgramReset flag
   if(isProgramReset) isProgramReset = false;
      

   // Returen true value, if new bar is generated, otherwise return false
   newBar         =  IsNewBar(true);
   dailyNewBar    =  IsNewBar(true);
   weeklyNewBar   =  IsNewBar(true);
   monthlyNewBar  =  IsNewBar(true);
   //Print("newBar: "+newBar + ", dailyNewBar: "+ dailyNewBar + ", weeklyNewBar: "+weeklyNewBar + ", monthlyNewBar: "+monthlyNewBar);
   

   // Get per day drawdown
   isPerDayDrawdownHit = getPerDayRiskFromEquity();
   
   
   // UserInterface: Update Account Overview
   if(ShowUserInterface) updateAccountOverview();
   

   //Print(__FUNCTION__ + ", Position: "+PositionsTotal() + ", Orders: " + OrdersTotal() + ", buyPos: "+buyPos+", sellPos: "+sellPos);

   if(buyPos > 0)  processPos(buyPos);
   if(sellPos > 0) processPos(sellPos);
   

   cCandleInfo.UpdateCandlePrice();
   
   //volumeIndicator.GetVolumeSignal(0, 1, VolumeBars);
   //atrSignal.GetATRSignal(cCandleInfo);

   positionTotal = PositionsTotal();
   if(positionTotal > 0) processTLBreakoutTrades();
   
   if(!(positionTotal <= MaxRunningTrade)) return;

   //int bars = iBars(mSymbol, Timeframe);
   //if(totalBars != bars) {
   if(newBar) {
      //Print("New bar created: "+newBar);
      // Set new total bars
      //totalBars = bars;
      
      
      // Resize KeyValue Array with total object size
      int totalRectObj = ObjectsTotal(0, 0, OBJ_RECTANGLE);
      Print("Total rect object: ", totalRectObj);
      if(totalRectObj > 0) ArrayResize(myRectangle, totalRectObj);
      else                 ArrayResize(myRectangle, 5);
      
      
      TLObjName = "";
      
      // Reset The Trendline Touched Array
      ArrayResize(upperTLTouchArr, 20);
      ArrayResize(lowerTLTouchArr, 20);
      
      // Reset The Rectangle Touched Array
      ArrayResize(resistanceZoneTouchArr, 20);
      ArrayResize(supportZoneTouchArr, 20);
      
            
      //drawMonthlyTrendline();
      //drawWeeklyTrendline();
      //drawDailyTrendline();
      
      
      
      // Reset Chart Objects Flag
      cChartObjTline.Reset();
      //cObjHLine.Reset();
      cObjRectangle.Reset();
      
      
      //
      // Get current candlestick pattern name
      //
      candlestickPatternName = candleStickPattern.CandleStickPatterSignal(cCandleInfo);
      //Print("candlestickPatternName: "+candlestickPatternName);
   
      
      //
      // Find Market Trend With Moving Average
      //
      //analysisTradeConditions()
      
      
      //
      // Stochastic Indicator Signal
      //
      /*----------------------------------------------------------------------------------*/
      
      
      //string message     =  stochSignal.UpdateStochasticSignal();
      //message = "Test Stoch signal"; 
      //message = ""; 
      //double stochLevel    =  stochSignal.GetStochLevel();
      
      
      /*----------------------------------------------------------------------------------*/
      
      /*string monthlyTrend     =  trendMA.GetMarketTrend(PERIOD_MN1),
             weeklyTrend      =  trendMA.GetMarketTrend(PERIOD_W1),
             dailyTrend       =  trendMA.GetMarketTrend(PERIOD_D1),
             fourHourTrend    =  trendMA.GetMarketTrend(PERIOD_H4);
             oneHourTrend     =  trendMA.GetMarketTrend(PERIOD_H1);
      if(TwoHundred_MA_Will_Attach) {
         message = twoHunSMATouchSignal.grabTouchSignal(candleInfo);
         if(StringLen(message) > 0) {
            // Adding signal to the array 
            addSignalToArray(count, "MovingAverage", message);
            count++;
         }
      }*/
      //Print("message: "+message);
      
      
      //adxIndicator.Get(0, 1);
      //bool IsMarketInRange       = adxSignal.IsMarketEnteredInRange(cCandleInfo, 10);
      //bool IsMarketExitFromRange = adxSignal.CheckIfMarketExitFromRange(cCandleInfo, 10);
      
      
      //
      // Get ADX signal
      //
      adxStatus = adxSignal.MarketRangeStatus(10);
      //Print("adxStatus: " + adxStatus + ", candlestickPatternName: "+candlestickPatternName);
      
      
      //
      // Find touch points from 
      // AscendingHigherTrendline, DescendingHigherTrendline, AscendingLowerTrendline, DescendingLowerTrendline
      //
      findTrendlineTouchPoints();
      
      
      //
      // Find touch points from Rectangle Objects
      //
      findRectangleObjectTouchPoints();
      
      
      //Print("buyPos: "+buyPos+ ", sellPos: "+sellPos);
      //totalBars = bars;
      // && StringFind(buyPosStr, "HighTrendline@"+highPriceIndex) < 0
      
      //
      // Set buystop & sellstop trade on high & low price
      //
      if(buyPos <= 0 && OpenBuyTrades && (selectedMarketTrend == AUTO || selectedMarketTrend == UP_TREND)) {
         
         double high = findHigh();
         if(high > 0 && positionTotal < MaxRunningTrade) {
            //executeBuy(high, 1, 0.0);
         }
         
         //
         // Draw Trendline At High And Low Peaks
         //
         /*if(StringFind(buyPosStr, "HighTrendline@"+prevHighPriceIndex) < 0) {
            Print("findHighPriceAndBarIndex");
            
            double high = findHighPriceAndBarIndex();
            if(high > 0 && positionTotal < MaxRunningTrade) {
               executeBuy(high, 1, 0.0);
            }
         }*/
      }
      //&& StringFind(sellPosStr, "LowTrendline@"+lowPriceIndex) < 0
      if(sellPos <= 0 && OpenSellTrades && (selectedMarketTrend == AUTO || selectedMarketTrend == DOWN_TREND)) {
         double low = findLow();
         if(low > 0 && positionTotal < MaxRunningTrade) {
            //executeSell(low, 1, 0.0);
         }
         
         //
         // Draw Trendline At High And Low Peaks
         //
         /*if(StringFind(sellPosStr, "LowTrendline@"+prevLowPriceIndex) < 0) {
            Print("findLowPriceAndBarIndex");
               
            double low = findLowPriceAndBarIndex();
            if(low > 0 && positionTotal < MaxRunningTrade) {
               executeSell(low, 1, 0.0);
            }
         }*/
      }
      
      
      //
      // Draw Trendline At High And Low Peaks
      //
      /*Print("buyPosStr: "+StringFind(buyPosStr, "HighTrendline") + ", LowTrendline: "+StringFind(sellPosStr, "LowTrendline"));
      if(StringFind(buyPosStr, "HighTrendline@"+prevHighPriceIndex) < 0 && OpenBuyTrades) {
         Print("findHighPriceAndBarIndex");
         
         double high = findHighPriceAndBarIndex();
         if(high > 0 && positionTotal < MaxRunningTrade) {
            executeBuy(high, 1, 0.0);
         }
      }
      if(StringFind(sellPosStr, "LowTrendline@"+prevLowPriceIndex) < 0 && OpenSellTrades) {
         Print("findLowPriceAndBarIndex");
            
         double low = findLowPriceAndBarIndex();
         if(low > 0 && positionTotal < MaxRunningTrade) {
            executeSell(low, 1, 0.0);
         }
      }*/
   }
                  
         
   /**************************************************************************************/
   /**************************** Trendline Breakout Buy/Sell Signal **********************/
   /**************************************************************************************/
   
   string tradeSignal = TradeSignalFromChartObjects();
   if(StringLen(tradeSignal) > 0) {
      //Print("tradeSignal: " + tradeSignal);
      if(tradeSignal == "BUY" && OpenBuyTrades && 
         (selectedMarketTrend == AUTO || selectedMarketTrend == UP_TREND)) {
         double entry = NormalizeDouble(SymbolInfoDouble(mSymbol, SYMBOL_ASK), _Digits);
         //Print("111 tradeSignal: "+tradeSignal+", entry: "+entry+", positionTotal: "+positionTotal + ", MaxRunningTrade: "+MaxRunningTrade);
         if(entry > 0 && positionTotal < MaxRunningTrade) {
            // Instant buy order
            executeBuy(entry, 0, 0.0);

            // Reset Trend Line Breakout Count
            if(TLBreaksTradeCount == 2) {
               TLBreaksTradeCount = 0;
               IsTLineBreaks = false;
               IsTLineBreaksAndRetouch = false;
            }
            if(RObjectBreaksTradeCount == 2) {
               RObjectBreaksTradeCount = 0;
               IsRObjectBreaks = false;
               IsRObjectBreaksAndRetouch = false;
            }
         }
      }
      else
      if(tradeSignal == "SELL" && OpenSellTrades && 
         (selectedMarketTrend == AUTO || selectedMarketTrend == DOWN_TREND)) {
         double entry = NormalizeDouble(SymbolInfoDouble(mSymbol, SYMBOL_BID), _Digits);
         //Print("222 tradeSignal: "+tradeSignal+", entry: "+entry+", positionTotal: "+positionTotal + ", MaxRunningTrade: "+MaxRunningTrade);
         if(entry > 0 && positionTotal < MaxRunningTrade) {
            // Instant sell order
            executeSell(entry, 0, 0.0);

            // Reset Trend Line Breakout Count
            if(TLBreaksTradeCount == 2) {
               TLBreaksTradeCount = 0;
               IsTLineBreaks = false;
               IsTLineBreaksAndRetouch = false;
            }
            if(RObjectBreaksTradeCount == 2) {
               RObjectBreaksTradeCount = 0;
               IsRObjectBreaks = false;
               IsRObjectBreaksAndRetouch = false;
            }
         }
      }
   }
  
}


void analysisTradeConditions() {

   /*
   //
   // Find Market Trend With Moving Average
   //
   string monthlyMarketTrend        =  twentyOneEMA.GetMarketTrend(PERIOD_MN1, "PERIOD_MN1"),
          weeklyMarketTrend         =  twentyOneEMA.GetMarketTrend(PERIOD_W1, "PERIOD_W1"),
          dailyMarketTrend          =  fiftyEMA.GetMarketTrend(PERIOD_D1, "PERIOD_D1"),
          fourHourMarketTrend       =  oneHundredEMA.GetMarketTrend(PERIOD_H4, "PERIOD_H4"),
          oneHourMarketTrend        =  oneHundredEMA.GetMarketTrend(PERIOD_H1, "PERIOD_H1"),
          fifteenMintueMarketTrend  =  oneHundredEMA.GetMarketTrend(PERIOD_M15, "PERIOD_M15");
      
   Comment("----- Market Trend & Last Candle Formation -----\n" + 
           "PERIOD_MN1: " + monthlyMarketTrend + "\n" + 
           " PERIOD_W1: " + weeklyMarketTrend + "\n" + 
           " PERIOD_D1: " + dailyMarketTrend + "\n" + 
           " PERIOD_H4: " + fourHourMarketTrend + "\n" + 
           " PERIOD_H1: " + oneHourMarketTrend + "\n" + 
           "PERIOD_M15: " + fifteenMintueMarketTrend + "\n");
           
   
   string entrySignal = "";        
   if(monthlyMarketTrend == "Uptrend" && monthlyMarketTrend == weeklyMarketTrend && 
      weeklyMarketTrend  == dailyMarketTrend && dailyMarketTrend == fourHourMarketTrend && 
      fourHourMarketTrend == oneHourMarketTrend) {    // Pure BUY Signal (All timeframes align one direction)
      entrySignal = "BUY";
   }
   else
   if(monthlyMarketTrend == "Downtrend" && monthlyMarketTrend == weeklyMarketTrend && 
      weeklyMarketTrend  == dailyMarketTrend && dailyMarketTrend == fourHourMarketTrend && 
      fourHourMarketTrend == oneHourMarketTrend) {    // Pure SELL Signal (All timeframes align one direction)
      entrySignal = "SELL";
   }   
   else
   if(monthlyMarketTrend == "Uptrend") {    // 
      if(monthlyMarketTrend == weeklyMarketTrend) {
         if(weeklyMarketTrend  == dailyMarketTrend) {
            if(dailyMarketTrend == fourHourMarketTrend) {
               if(fourHourMarketTrend == oneHourMarketTrend) {
               
               }
               else {
               
               }
            }
            else {
            
            }
         }
         else {
         
         }
      }
      else {
      
      }
      entrySignal = "BUY";
   }
   */
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void resetProgram() {

   if(!isProgramReset) {
      buyPos  =  -1;
      sellPos  =  -1;
      
      ObjectsDeleteAll(0, "HighTrendline", 0, OBJ_TREND);
      ObjectsDeleteAll(0, "LowTrendline", 0, OBJ_TREND);
      buyPosStr = "";
      sellPosStr = "";
      
      
      
      lowPrice = 0; highPrice = 0;
      prevLowPrice = 0; prevHighPrice = 0;
      
      lowPriceIndex = -1; highPriceIndex = -1;
      prevLowPriceIndex = -1; prevHighPriceIndex = -1;
      

      isDrawdown = false;
      isPerDayDrawdownHit = false;
      if(GlobalVariableCheck(EA_CURRENT_DRAWDOWN)) GlobalVariableDel(EA_CURRENT_DRAWDOWN);

      TLBreakOrderType = "";
      TLBreaksBarCount = 0;
      TLBreaksTradeCount = 0;
      IsTLineBreaks = false;
      IsTLineBreaksAndRetouch = false;

      // Close all trades
      closeAllPositions();


      isProgramReset = true;

      Print(__FUNCTION__," > Program resetting is done");
   }

}


//+------------------------------------------------------------------+
//|  Get trade signal from all kind of trendlines                                                                |
//+------------------------------------------------------------------+

string TradeSignalFromChartObjects() {
   
   //if((StringFind(adxStatus, "MarketIsAboveTheRange") >= 0) || 
   //   (StringFind(adxStatus, "MarketExitFromTheRange") >= 0)) {
   
   
   double bidPrice = NormalizeDouble(SymbolInfoDouble(mSymbol, SYMBOL_BID), _Digits);
   double askPrice = NormalizeDouble(SymbolInfoDouble(mSymbol, SYMBOL_ASK), _Digits);

   int totalObj   =  ObjectsTotal(0, 0, OBJ_TREND);
   /*for(int i=totalObj-1; i>=0; i--) {
      // Get object name
      string objName = ObjectName(0, i, 0, OBJ_TREND);
      //Print("111 objName="+objName+", bidPrice="+bidPrice);
      
      // Continue if 'Trendline', 'Horizontalline' & 'Rectangular' object not found
      //if(!(StringFind(objName, "Trendline") > 0)) continue;
      //if(!(StringFind(objName, "Horizontal") > 0)) continue;
      //if(!(StringFind(objName, "Rectangle") > 0)) continue;
      
      string message = "";
      
      //
      // Check Trendline breakout
      //
      if((StringFind(objName, "Trendline") >= 0)) {
         message = cChartObjTline.CheckPriceOnTrendline(newBar, objName, bidPrice, cCandleInfo);
         //Print("Trendline message: "+message);
         if(StringFind(message, "broken", 0) >= 0 && StringFind(message, "above", 0) >= 0) {
            bool hasLossPosition = checkLossPositions(POSITION_TYPE_BUY);
            //Print("111 objName: "+ objName + ", TLBreakOrderType: " + TLBreakOrderType + ", hasLossPosition: "+ hasLossPosition + ", TLinePriceMovementUncertain: "+TLinePriceMovementUncertain);
            if((TLBreakOrderType == "BUY" || TLBreakOrderType == "") && hasLossPosition) {   //!TLinePriceMovementUncertain || 
               TLinePriceMovementUncertain = true;
               
               closeAllBuyPositions();
               //return "";
            }
            if(TLBreaksTradeCount == 1) {
               ResetTLBreakoutFlags();
            }
            
            IsTLineBreaks = true;
            TLBreaksTradeCount++;
            TLObjName = objName;
            TLBreakOrderType = "SELL";
            return TLBreakOrderType;
         }
         else
         if(StringFind(message, "broken", 0) >= 0 && StringFind(message, "below", 0) >= 0) {
            bool hasLossPosition = checkLossPositions(POSITION_TYPE_SELL);
            //Print("222 objName: "+ objName + ", TLBreakOrderType: " + TLBreakOrderType + ", hasLossPosition: "+ hasLossPosition + ", TLinePriceMovementUncertain: "+TLinePriceMovementUncertain);
            if((TLBreakOrderType == "SELL" || TLBreakOrderType == "") && hasLossPosition) {  // !TLinePriceMovementUncertain || 
               TLinePriceMovementUncertain = true;
               
               closeAllSellPositions();
               //return "";
            }
               
            if(TLBreaksTradeCount == 1) {
               ResetTLBreakoutFlags();
            }

            IsTLineBreaks = true;
            TLBreaksTradeCount++;
            TLObjName = objName;
            TLBreakOrderType = "BUY";
            return TLBreakOrderType;
         }
         
         
         
         if(StringFind(message, "UP through", 0) >= 0 && 
            StringFind(message, "immediately back to DOWN side", 0) >= 0) {
            //Print("333 objName: "+ objName + ", TLBreakOrderType: " + TLBreakOrderType + ", TLinePriceQuickMovement: "+TLinePriceQuickMovement);
            bool hasLossPosition = checkLossPositions(POSITION_TYPE_SELL);
            if(hasLossPosition && 
               (StringFind(objName, "DailyHighTrendline", 0) >= 0 || 
               StringFind(objName, "WeeklyHighTrendline", 0) >= 0 || 
               StringFind(objName, "MonthlyHighTrendline", 0) >= 0)) Print("");
               //closeAllLossBuyPositions();
            else 
            if(hasLossPosition &&
               (StringFind(objName, "DailyLowTrendline", 0) >= 0 || 
               StringFind(objName, "WeeklyLowTrendline", 0) >= 0 || 
               StringFind(objName, "MonthlyLowTrendline", 0) >= 0))
               //closeAllLossSellPositions();
            TLObjName = "";
            return "";
         }
         else
         if(StringFind(message, "DOWN through", 0) >= 0 && 
            StringFind(message, "immediately back to UP side", 0) >= 0) {
            //Print("444 objName: "+ objName + ", TLBreakOrderType: " + TLBreakOrderType + ", TLinePriceQuickMovement: "+TLinePriceQuickMovement);
            
            /*if(StringFind(objName, "HighTrendline", 0) >= 0)
               closeAllLossSellPositions();
            else 
            if(StringFind(objName, "LowTrendline", 0) >= 0)
               closeAllLossBuyPositions();
            */
            
            // Uncomment from here
            /*if(StringFind(objName, "DailyHighTrendline", 0) >= 0 || 
               StringFind(objName, "WeeklyHighTrendline", 0) >= 0 || 
               StringFind(objName, "MonthlyHighTrendline", 0) >= 0)  Print("");
               //closeAllLossSellPositions();
            else 
            if(StringFind(objName, "DailyLowTrendline", 0) >= 0 || 
               StringFind(objName, "WeeklyLowTrendline", 0) >= 0 || 
               StringFind(objName, "MonthlyLowTrendline", 0) >= 0)
               //closeAllLossBuyPositions();
            TLObjName = "";
            return "";
         }
            
         
         
         
         if(StringFind(message, "retracing", 0) >= 0) {
            if(IsTLineBreaks) {
               chartObjName = objName;
               IsTLineBreaksAndRetouch = true;
            }
            else {
               
               string upperTLName = "", lowerTLName = "";
               int upperTLTouchCount = 0, lowerTLTouchCount = 0;
               
               // Upper Trendline Touched Points
               for(int j=0; j<ArraySize(upperTLTouchArr); j++) {
                  if(StringLen(upperTLTouchArr[j]) > 0) {
                     //Print("upperTLTouchArr["+j+"]:" + upperTLTouchArr[j]);
                     string tlTouchPointArr[];
                     int splitArrCount = StringSplit(upperTLTouchArr[j], separatorChar, tlTouchPointArr);
                     if(splitArrCount > 0) {
                        if(tlTouchPointArr[0] == objName) {
                           upperTLName = tlTouchPointArr[0];
                           upperTLTouchCount = (int)StringToInteger(tlTouchPointArr[1]);
                        }
                     }
                  }
                  
                  if(StringLen(upperTLName) > 0 && upperTLTouchCount >= 2) break;
               }
               
               // Lower Trendline Touched Points
               for(int j=0; j<ArraySize(lowerTLTouchArr); j++) {
                  if(StringLen(lowerTLTouchArr[j]) > 0) {
                     //Print("lowerTLTouchArr["+j+"]:" + lowerTLTouchArr[j]);
                     string tlTouchPointArr[];
                     int splitArrCount = StringSplit(lowerTLTouchArr[j], separatorChar, tlTouchPointArr);
                     if(splitArrCount > 0) {
                        if(tlTouchPointArr[0] == objName) {
                           lowerTLName = tlTouchPointArr[0];
                           lowerTLTouchCount = (int)StringToInteger(tlTouchPointArr[1]);
                        }
                     }
                  }
                  
                  if(StringLen(lowerTLName) > 0 && lowerTLTouchCount >= 2) break;
               }
            
               //Print("Retracing Market, upperTLName: "+ upperTLName + ", upperTLTouchCount: "+upperTLTouchCount + ", TLBreakOrderType: "+ TLBreakOrderType);
               //Print("Retracing Market, lowerTLName: "+ lowerTLName + ", lowerTLTouchCount: "+lowerTLTouchCount + ", TLBreakOrderType: "+ TLBreakOrderType);
               
               // StringLen(candleName) > 0 && 
               if(StringLen(upperTLName) > 0 && upperTLTouchCount >= 2) {
                  //if(TLBreakOrderType == "BUY") return "";
                  string orderType = whichOrderTypeWillExecuteNextTrade("retracing", "SELL");
                  //Print("111 whichOrderTypeWillExecuteNextTrade: " + orderType);
                  TLBreaksTradeCount++;
                  TLObjName = objName;
                  return "SELL"; //TLBreakOrderType
               }
               else 
               if(StringLen(lowerTLName) > 0 && lowerTLTouchCount >= 2) {
                  //if(TLBreakOrderType == "SELL") return "";
                  string orderType = whichOrderTypeWillExecuteNextTrade("retracing", "BUY");
                  //Print("222 whichOrderTypeWillExecuteNextTrade: " + orderType);
                  TLBreaksTradeCount++;
                  TLObjName = objName;
                  return "BUY";  //TLBreakOrderType
               }            
            }
         }
         
         if(IsTLineBreaksAndRetouch && StringFind(message, "above", 0) >= 0) {
            if(TLBreakOrderType == "SELL") return "";
            TLBreaksTradeCount++;
            TLObjName = objName;
            return "BUY";  //TLBreakOrderType
         }
         else
         if(IsTLineBreaksAndRetouch && StringFind(message, "below", 0) >= 0) {
            if(TLBreakOrderType == "BUY") return "";
            TLBreaksTradeCount++;
            TLObjName = objName;
            return "SELL"; //TLBreakOrderType
         }
         else
         if(IsTLineBreaks && StringFind(message, "hit", 0) >= 0 && StringFind(message, "above", 0) >= 0) {
            if(TLBreakOrderType == "SELL") return "";
            TLBreaksTradeCount++;
            TLObjName = objName;
            return "BUY";  //TLBreakOrderType
         }
         else
         if(IsTLineBreaks && StringFind(message, "hit", 0) >= 0 && StringFind(message, "below", 0) >= 0) {
            if(TLBreakOrderType == "BUY") return "";
            TLBreaksTradeCount++;
            TLObjName = objName;
            return "SELL"; //TLBreakOrderType
         }
         
         
      }
   }*/
   
   
   totalObj   =  ObjectsTotal(0, 0, OBJ_RECTANGLE);
   for(int i=totalObj-1; i>=0; i--) {
      // Get object name
      string objName = ObjectName(0, i, 0, OBJ_RECTANGLE);
      //Print("111 objName="+objName+", bidPrice="+bidPrice);
         
      string message = "";
      
      //
      // Check Rectangular breakout
      //
      if((StringFind(objName, "Rectangle") >= 0)) {
         message = cObjRectangle.CheckPriceOnRectangle(newBar, objName, bidPrice, cCandleInfo);
         
         if(StringFind(message, "broken", 0) >= 0 && StringFind(message, "above", 0) >= 0) {
            bool hasLossPosition = checkLossPositions(POSITION_TYPE_BUY);
            //Print("111 objName: "+ objName + ", TLBreakOrderType: " + TLBreakOrderType + ", hasLossPosition: "+ hasLossPosition + ", TLinePriceMovementUncertain: "+TLinePriceMovementUncertain);
            if((RectObjBreakOrderType == "BUY" || RectObjBreakOrderType == "") && hasLossPosition) {   //!TLinePriceMovementUncertain || 
               RectObjPriceMovementUncertain = true;
               
               closeAllBuyPositions();
               //return "";
            }
            if(RObjectBreaksBarCount == 1) {
               ResetTLBreakoutFlags();
            }
            
            IsRObjectBreaks = true;
            RObjectBreaksTradeCount++;
            RectObjName = objName;
            RectObjBreakOrderType = "SELL";
            return RectObjBreakOrderType;
         }
         else
         if(StringFind(message, "broken", 0) >= 0 && StringFind(message, "below", 0) >= 0) {
            bool hasLossPosition = checkLossPositions(POSITION_TYPE_SELL);
            //Print("222 objName: "+ objName + ", RectObjBreakOrderType: " + RectObjBreakOrderType + ", hasLossPosition: "+ hasLossPosition + ", TLinePriceMovementUncertain: "+TLinePriceMovementUncertain);
            if((RectObjBreakOrderType == "SELL" || RectObjBreakOrderType == "") && hasLossPosition) {  // !TLinePriceMovementUncertain || 
               RectObjPriceMovementUncertain = true;
               
               closeAllSellPositions();
               //return "";
            }
               
            if(TLBreaksTradeCount == 1) {
               ResetTLBreakoutFlags();
            }

            IsRObjectBreaks = true;
            RObjectBreaksTradeCount++;
            RectObjName = objName;
            RectObjBreakOrderType = "BUY";
            return RectObjBreakOrderType;
         }
         
         
         
         if(StringFind(message, "UP through", 0) >= 0 && 
            StringFind(message, "immediately back to DOWN side", 0) >= 0) {
            //Print("333 objName: "+ objName + ", RectObjBreakOrderType: " + RectObjBreakOrderType + ", TLinePriceQuickMovement: "+TLinePriceQuickMovement);
            bool hasLossPosition = checkLossPositions(POSITION_TYPE_SELL);
            if(hasLossPosition && 
               (StringFind(objName, "DailyResistanceRectangle", 0) >= 0 || 
               StringFind(objName, "WeeklyResistanceRectangle", 0) >= 0 || 
               StringFind(objName, "MonthlyResistanceRectangle", 0) >= 0)) Print("");
               //closeAllLossBuyPositions();
            else 
            if(hasLossPosition &&
               (StringFind(objName, "DailySupportRectangle", 0) >= 0 || 
               StringFind(objName, "WeeklySupportRectangle", 0) >= 0 || 
               StringFind(objName, "MonthlySupportRectangle", 0) >= 0))
               //closeAllLossSellPositions();
            RectObjName = "";
            return "";
         }
         else
         if(StringFind(message, "DOWN through", 0) >= 0 && 
            StringFind(message, "immediately back to UP side", 0) >= 0) {
            //Print("444 objName: "+ objName + ", RectObjBreakOrderType: " + RectObjBreakOrderType + ", TLinePriceQuickMovement: "+TLinePriceQuickMovement);
            
            if(StringFind(objName, "DailyResistanceRectangle", 0) >= 0 || 
               StringFind(objName, "WeeklyResistanceRectangle", 0) >= 0 || 
               StringFind(objName, "MonthlyResistanceRectangle", 0) >= 0)  Print("");
               //closeAllLossSellPositions();
            else 
            if(StringFind(objName, "DailySupportRectangle", 0) >= 0 || 
               StringFind(objName, "WeeklySupportRectangle", 0) >= 0 || 
               StringFind(objName, "MonthlySupportRectangle", 0) >= 0)
               //closeAllLossBuyPositions();
            RectObjName = "";
            return "";
         }
            
         
         
         
         if(StringFind(message, "retracing", 0) >= 0) {
            if(IsRObjectBreaks) {
               chartObjName = objName;
               IsRObjectBreaksAndRetouch = true;
            }
         }
         
         if(IsRObjectBreaksAndRetouch && StringFind(message, "above", 0) >= 0) {
            if(RectObjBreakOrderType == "SELL") return "";
            RObjectBreaksTradeCount++;
            RectObjName = objName;
            return "BUY";  //RectObjBreakOrderType
         }
         else
         if(IsRObjectBreaksAndRetouch && StringFind(message, "below", 0) >= 0) {
            if(RectObjBreakOrderType == "BUY") return "";
            RObjectBreaksTradeCount++;
            RectObjName = objName;
            return "SELL"; //RectObjBreakOrderType
         }
         else
         if(IsRObjectBreaks && StringFind(message, "hit", 0) >= 0 && StringFind(message, "above", 0) >= 0) {
            if(RectObjBreakOrderType == "SELL") return "";
            RObjectBreaksTradeCount++;
            RectObjName = objName;
            return "BUY";  //RectObjBreakOrderType
         }
         else
         if(IsTLineBreaks && StringFind(message, "hit", 0) >= 0 && StringFind(message, "below", 0) >= 0) {
            if(RectObjBreakOrderType == "BUY") return "";
            RObjectBreaksTradeCount++;
            RectObjName = objName;
            return "SELL"; //RectObjBreakOrderType
         }
         
         
      }
   }



   // Trendline Object
   if(newBar && IsTLineBreaks) {
      TLBreaksBarCount++;
      //Print("IsTrendlineBreaks: "+ IsTrendlineBreaks + ", TLBreaksBarCount: "+ TLBreaksBarCount);
   }
   if(newBar && IsTLineBreaksAndRetouch) {
      //Print("IsTrendlineBreaksAndRetouch: "+ IsTrendlineBreaks + ", TLBreaksBarCount: "+ TLBreaksBarCount);
   }


   if(TLBreaksBarCount >= 6) {
      ResetTLBreakoutFlags();
   }
   else 
   if(TLBreaksBarCount >= 3 && TLBreaksBarCount < 4 && TLinePriceMovementUncertain) {
      ResetTLBreakoutFlags();
   } 
   
   
   
   // Rectangle Object
   if(newBar && IsRObjectBreaks) {
      RObjectBreaksBarCount++;
   }

   if(RObjectBreaksBarCount >= 6) {
      ResetRObjectBreakoutFlags();
   }
   else 
   if(IsRObjectBreaks >= 3 && IsRObjectBreaks < 4 && RectObjPriceMovementUncertain) {
      ResetRObjectBreakoutFlags();
   } 
   

   TLObjName = "";
   RectObjName = "";
   return "";
   
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ResetTLBreakoutFlags() {
   TLBreakOrderType = "";
   TLBreaksBarCount = 0;
   TLBreaksTradeCount = 0;
   IsTLineBreaks = false;
   IsTLineBreaksAndRetouch = false;
   TLinePriceMovementUncertain = false;
   TLinePriceQuickMovement = false;

   //Print("Called ResetTLBreakoutFlags");
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ResetHLBreakoutFlags() {
   HLBreaksBarCount = 0;
   HLBreaksTradeCount = 0;
   IsHLineBreaks = false;
   IsHLineBreaksAndRetouch = false;

   //Print("Called ResetHLBreakoutFlags");
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ResetRObjectBreakoutFlags() {
   RectObjBreakOrderType = "";
   RObjectBreaksBarCount = 0;
   RObjectBreaksTradeCount = 0;
   IsRObjectBreaks = false;
   IsRObjectBreaksAndRetouch = false;

   //Print("Called ResetRObjectBreakoutFlags");
}


//+------------------------------------------------------------------+
//|         Moving Average Initialize                                                         |
//+------------------------------------------------------------------+

// Moving Average Indicator Setup
void MovingAverageSetup() {
   /*
   if(!All_MA_Will_Attach) {
      Print("All moving average are deattached from chart");
      return;
   }
   
   
   // Find Market Trend, Touch And Break With The Moving Average Strategy
   if(TwentyOne_EMA_Will_Attach) {
      twentyOneEMA   =  new CMAIndicator(mSymbol, PERIOD_CURRENT, TwentyOne_MA_Period, 0, EMA_Method, MA_AppliedPrice);
      //fiftyEMATouchSignal  =  new CMATouchSignal(1, 2, 3, fiftyEMA);
   }
   
   if(Fifty_EMA_Will_Attach) {
      fiftyEMA       =  new CMAIndicator(mSymbol, PERIOD_CURRENT, Fifty_MA_Period,      0, EMA_Method,   MA_AppliedPrice);
      //fiftyEMATouchSignal  =  new CMATouchSignal(1, 2, 3, fiftyEMA);
   }
   
   if(OneHundred_EMA_Will_Attach) {
      oneHundredEMA  =  new CMAIndicator(mSymbol, PERIOD_CURRENT, OneHundred_MA_Period, 0, EMA_Method,  MA_AppliedPrice);
      //oneHunEMATouchSignal =  new CMATouchSignal(1, 2, 3, oneHundredEMA);
   }
   
   if(TwoHundred_EMA_Will_Attach) {
      twoHundredEMA  =  new CMAIndicator(mSymbol, PERIOD_CURRENT, TwoHundred_MA_Period, 0, EMA_Method,  MA_AppliedPrice);
      //twoHunEMATouchSignal =  new CMATouchSignal(1, 2, 3, twoHundredEMA);
   }
   */
   
  
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void processPos(ulong &posTicket) {
   //Print(__FUNCTION__, ", posTicket: "+posTicket);
   if(posTicket <= 0)
      return;
   if(OrderSelect(posTicket))
      return;

   //Print(__FUNCTION__, ", Order is selected by ticket: "+posTicket);

   double offset = 0;
   CPositionInfo pos;
   if(!pos.SelectByTicket(posTicket)) {
      posTicket = 0;
      return;
   }
   else {
   if(pos.PositionType() == POSITION_TYPE_BUY) {
      //Print(__FUNCTION__+", POSITION_TYPE_BUY");
      double bid = SymbolInfoDouble(mSymbol,SYMBOL_BID);
      //if(bid > (pos.PriceOpen() + (TslTriggerPoints*_Point))){
      if(bid > (pos.PriceOpen() + PointsToDouble(TslTriggerPoints))) {

         //double sl = bid - TslPoints * _Point;
         double sl = bid - PointsToDouble(TslPoints);
         sl = NormalizeDouble(sl,_Digits);

         if(sl > pos.StopLoss())
           {
            trade.PositionModify(pos.Ticket(),sl,pos.TakeProfit());
           }
        }
      }
      else
      if(pos.PositionType() == POSITION_TYPE_SELL) {
         //Print(__FUNCTION__+", POSITION_TYPE_SELL");
         double ask = SymbolInfoDouble(mSymbol,SYMBOL_ASK);
         //if(ask < (pos.PriceOpen() - (TslTriggerPoints*_Point))){
         if(ask < (pos.PriceOpen() - PointsToDouble(TslTriggerPoints))) {
            //double sl = ask + TslPoints * _Point;
            double sl = ask + PointsToDouble(TslPoints);
            sl = NormalizeDouble(sl,_Digits);

            if(sl < pos.StopLoss() || pos.StopLoss() == 0) {
               trade.PositionModify(pos.Ticket(),sl,pos.TakeProfit());
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void processTLBreakoutTrades() {
// Update stoploss and Update Trailing Stoploss
   double breakevenStopLoss = SymbolInfoDouble(mSymbol, SYMBOL_POINT)*BreakevenStopLoss;
   double targetTakeProfit  = SymbolInfoDouble(mSymbol, SYMBOL_POINT)*BreakevenWhenProfit;
   //double traillingStop = PointsToDouble(TLTslPoints);
   //if(PositionGetDouble(POSITION_TP) > 500) traillingStop = PointsToDouble(TLTslPoints-250);
   trade.UpdateStoplossByOrderComment(mSymbol, Magic, targetTakeProfit, breakevenStopLoss, PointsToDouble(TLTslPoints), INSTANT_TRADE);

   //Print(__FUNCTION__);
}



void drawDailyTrendline() {
   
   string trendlineName = "DailyHighTrendline";
    
   double dailyHigh  = NormalizeDouble(iHigh(mSymbol, PERIOD_D1, 1), _Digits);
   double dailyLow   = NormalizeDouble(iLow(mSymbol, PERIOD_D1, 1), _Digits);
   
   // Draw trendline
   ObjectDelete(0, trendlineName);
   ObjectCreate(0, trendlineName, OBJ_TREND, 0,    
                  iTime(Symbol(), PERIOD_D1, 1), dailyHigh, 
                  iTime(Symbol(), PERIOD_D1, 0), dailyHigh);
   ObjectSetInteger(0, trendlineName, OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, trendlineName, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, trendlineName, OBJPROP_RAY_RIGHT, true);
   
   
   
   trendlineName = "DailyLowTrendline";
   // Draw trendline
   ObjectDelete(0, trendlineName);
   ObjectCreate(0, trendlineName, OBJ_TREND, 0,    
                  iTime(Symbol(), PERIOD_D1, 1), dailyLow, 
                  iTime(Symbol(), PERIOD_D1, 0), dailyLow);
   ObjectSetInteger(0, trendlineName, OBJPROP_COLOR, clrBlue);
   ObjectSetInteger(0, trendlineName, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, trendlineName, OBJPROP_RAY_RIGHT, true);
   
}


void drawWeeklyTrendline() {
   
   string trendlineName = "WeeklyHighTrendline";
   
   double hPrice  = NormalizeDouble(iHigh(mSymbol, PERIOD_W1, 1), _Digits);
   double lPrice   = NormalizeDouble(iLow(mSymbol, PERIOD_W1, 1), _Digits);
   
   // Draw trendline
   ObjectDelete(0, trendlineName);
   ObjectCreate(0, trendlineName, OBJ_TREND, 0,    
                  iTime(Symbol(), PERIOD_W1, 1), hPrice, 
                  iTime(Symbol(), PERIOD_W1, 0), hPrice);
   ObjectSetInteger(0, trendlineName, OBJPROP_COLOR, clrDarkTurquoise);
   ObjectSetInteger(0, trendlineName, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, trendlineName, OBJPROP_RAY_RIGHT, true);
   
   
   
   trendlineName = "WeeklyLowTrendline";
   // Draw trendline
   ObjectDelete(0, trendlineName);
   ObjectCreate(0, trendlineName, OBJ_TREND, 0,    
                  iTime(Symbol(), PERIOD_W1, 1), lPrice, 
                  iTime(Symbol(), PERIOD_W1, 0), lPrice);
   ObjectSetInteger(0, trendlineName, OBJPROP_COLOR, clrDarkTurquoise);
   ObjectSetInteger(0, trendlineName, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, trendlineName, OBJPROP_RAY_RIGHT, true);
   
}



void drawMonthlyTrendline() {
   
   string trendlineName = "MonthlyHighTrendline";
   
   double hPrice  = NormalizeDouble(iHigh(mSymbol, PERIOD_MN1, 1), _Digits);
   double lPrice   = NormalizeDouble(iLow(mSymbol, PERIOD_MN1, 1), _Digits);
   
   // Draw trendline
   ObjectDelete(0, trendlineName);
   ObjectCreate(0, trendlineName, OBJ_TREND, 0,    
                  iTime(Symbol(), PERIOD_MN1, 1), hPrice, 
                  iTime(Symbol(), PERIOD_MN1, 0), hPrice);
   ObjectSetInteger(0, trendlineName, OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, trendlineName, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, trendlineName, OBJPROP_RAY_RIGHT, true);
   
   
   
   trendlineName = "MonthlyLowTrendline";
   // Draw trendline
   ObjectDelete(0, trendlineName);
   ObjectCreate(0, trendlineName, OBJ_TREND, 0,    
                  iTime(Symbol(), PERIOD_MN1, 1), lPrice, 
                  iTime(Symbol(), PERIOD_MN1, 0), lPrice);
   ObjectSetInteger(0, trendlineName, OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0, trendlineName, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, trendlineName, OBJPROP_RAY_RIGHT, true);
   
}



void drawTLAtHighLowPeaks(double price, int priceIndex, int trendlineMode) {
   //Print("price: "+price+", priceIndex: "+priceIndex + ", trendlineMode: "+trendlineMode);
   string trendlineName = "";
   if(trendlineMode == 1) {
      trendlineName = "HighTrendline@"+IntegerToString(priceIndex);
      buyPosStr = trendlineName;
   }
   else  {
      trendlineName = "LowTrendline@"+IntegerToString(priceIndex);
      sellPosStr = trendlineName;
   }
   
   // Draw trendline
   ObjectDelete(0, trendlineName);
   ObjectCreate(0, trendlineName, OBJ_TREND, 0,    
                  iTime(Symbol(), PERIOD_CURRENT, priceIndex), price, 
                  iTime(Symbol(), PERIOD_CURRENT, priceIndex-3), price);
   ObjectSetInteger(0, trendlineName, OBJPROP_COLOR, clrChartreuse);
   ObjectSetInteger(0, trendlineName, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, trendlineName, OBJPROP_RAY_RIGHT, true);
}


/*

   if(orderExecutionType ||
         StringFind(TLObjName, "HighTrendline") >=0 || 
         StringFind(TLObjName, "HighTrendline") >=0 || 
         StringFind(TLObjName, "DailyHighTrendline") >=0 || 
         StringFind(TLObjName, "DailyLowTrendline") >=0
         StringFind(TLObjName, "WeeklyHighTrendline") >=0 || 
         StringFind(TLObjName, "WeeklyLowTrendline") >=0
         StringFind(TLObjName, "MonthlyHighTrendline") >=0 || 
         StringFind(TLObjName, "MonthlyLowTrendline") >=0)

*/

//+------------------------------------------------------------------+
//|  Trande Entry Manage                                             |
//+------------------------------------------------------------------+

void executeBuy(double entry, int orderExecutionType, double lots=0.0) {
   
   bool result = false;
   while(!result) {
      
      if(orderExecutionType == 0) entry = SymbolInfoDouble(mSymbol, SYMBOL_ASK);
      entry = NormalizeDouble(entry,_Digits);
   
      double ask = SymbolInfoDouble(mSymbol,SYMBOL_ASK);
   
      //if(orderExecutionType && (ask > entry - OrderDistPoints * _Point)) return;
      if(orderExecutionType && (ask > (entry - PointsToDouble(OrderDistPoints))))
         return;
   
      // Add extra offset price for avoding high peaks pending trades
      entry += PointsToDouble(ExtraOffsetPoints);
      
      
      //Print("ExecuteBuy### entry: " + entry + ", orderExecutionType: "+ orderExecutionType);
      //Print("entry: " + entry + ", ask: "+ ask + ", "+ask+" > "+(entry - PointsToDouble(OrderDistPoints))
      //+ ", " + (ask < (entry - PointsToDouble(OrderDistPoints))));
   
      //double tp = entry + TpPoints * _Point;
      double tp = (orderExecutionType) ? (entry + PointsToDouble(TpPoints)) :
                  (entry + PointsToDouble(TLTpPoints));
      tp = NormalizeDouble(tp,_Digits);
   
      //double sl = entry - SlPoints * _Point;
      //double sl = entry - (orderExecutionType) ? PointsToDouble(SlPoints) : PointsToDouble(TLSLPoints);
      double sl = (orderExecutionType) ? (entry - PointsToDouble(SlPoints)) : 
                                         (entry - PointsToDouble(TLSLPoints));
      sl = NormalizeDouble(sl,_Digits);
   
      //double lots = Lots;
      //if(PerTradeRiskPercent > 0) lots = calcLots(entry-sl);
      
      if(lots > 0.0) lots = lots;
      else if(FixedLotsSize) lots = Lots;
      else lots = calcLots(entry-sl);
      
      //Print("lots: " + lots);
      
      if(orderExecutionType == 0) {
         if(AllowTrendlineTrades)
            result = trade.Buy(lots, mSymbol, ask, sl, tp, INSTANT_TRADE);
         else result = true;
      }
      else {
         if(AllowPendingTrades) {
            //Print("AllowPendingTrades");
            // Uncomment if need
            datetime expiration = iTime(mSymbol,Timeframe,0) + ExpirationHours * PeriodSeconds(PERIOD_H1);  //PERIOD_H1
            result = trade.BuyStop(lots,entry,mSymbol,sl,tp,ORDER_TIME_SPECIFIED,expiration);
            buyPos = trade.ResultOrder();
            //result = true; // Delete this statement if above code is uncomment
         }
         else result = true;
         
         
         if(AllowTrendlineTrades) {
            return;
            if(highPrice != 0.0 && highPriceIndex != -1 && 
               highPrice != prevHighPrice && highPriceIndex != prevHighPriceIndex) {
               
               //Print("highPrice: "+highPrice+", highPriceIndex: "+highPriceIndex+", prevHighPrice: "+prevHighPrice+", prevHighPriceIndex: "+prevHighPriceIndex);
               
               if(result && StringFind(buyPosStr, "HighTrendline@"+IntegerToString(prevHighPriceIndex)) >= 0) {
                  ObjectDelete(0, buyPosStr);
                  buyPosStr = "";
               }
               
               buyPos = (ulong)rand();
               prevHighPrice = highPrice;
               prevHighPriceIndex = highPriceIndex;
               drawTLAtHighLowPeaks(highPrice, highPriceIndex, 1);
               result = true; // Delete this statement if above code is uncomment
               //Print("buyPos: "+buyPos);
            }
         }
      }
   }
   //Print(__FUNCTION__, " "+GetLastError() + ", result: "+result);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void executeSell(double entry, int orderExecutionType, double lots=0.0) {

   bool result = false;
   while(!result) {
      if(orderExecutionType == 0) entry = SymbolInfoDouble(mSymbol, SYMBOL_BID);
      entry = NormalizeDouble(entry,_Digits);
      
      double bid = SymbolInfoDouble(mSymbol,SYMBOL_BID);
   
      //if(orderExecutionType && (bid < entry + OrderDistPoints * _Point)) return;
      if(orderExecutionType && (bid < (entry + PointsToDouble(OrderDistPoints))))
         return;
         
      
      // Minus extra offset price for avoding low peaks pending trades
      entry -= PointsToDouble(ExtraOffsetPoints);
         
   
      //Print("ExecuteSell### entry: " + entry + ", orderExecutionType: "+ orderExecutionType);
      //Print("entry: " + entry + ", bid: "+ bid + ", "+bid+" < "+(entry + PointsToDouble(OrderDistPoints)) +
      //", "+ (bid < (entry + PointsToDouble(OrderDistPoints))));
   
      //double tp = entry - TpPoints * _Point;
      double tp = (orderExecutionType) ? (entry - PointsToDouble(TpPoints)) :
                                         (entry - PointsToDouble(TLTpPoints));
      tp = NormalizeDouble(tp,_Digits);
   
      //double sl = entry + SlPoints * _Point;
      double sl = (orderExecutionType) ? (entry + PointsToDouble(SlPoints)) : 
                                         (entry + PointsToDouble(TLSLPoints));
      sl = NormalizeDouble(sl,_Digits);
   
      //double lots = Lots;
      //if(PerTradeRiskPercent > 0) lots = calcLots(sl-entry);
      
      if(lots > 0.0) lots = lots;
      else if(FixedLotsSize) lots = Lots;
      else lots = calcLots(sl-entry);
      
      //Print("lots: " + lots);
      if(orderExecutionType == 0) {
         if(AllowTrendlineTrades)
            result = trade.Sell(lots, mSymbol, bid, sl, tp, INSTANT_TRADE);
         else result = true;
      }
      else {
         if(AllowPendingTrades) {
            //Print("Sell AllowPendingTrades");
            // Uncomment if need
            datetime expiration = iTime(mSymbol,Timeframe,0) + ExpirationHours * PeriodSeconds(PERIOD_H1);  //PERIOD_H1
            result = trade.SellStop(lots,entry,mSymbol,sl,tp,ORDER_TIME_SPECIFIED,expiration);
            sellPos = trade.ResultOrder();
            //result = true; // Delete this statement if above code is uncomment
         }
         else result = true;
         
         if(AllowTrendlineTrades) {
            return;
            if(lowPrice != 0.0 && lowPriceIndex != -1 && 
               lowPrice != prevLowPrice && lowPriceIndex != prevLowPriceIndex) {
               
               //Print("lowPrice: "+lowPrice+", lowPriceIndex: "+lowPriceIndex+", prevLowPrice: "+prevLowPrice+", prevLowPriceIndex: "+prevLowPriceIndex);
               
               if(result && StringFind(sellPosStr, "LowTrendline@"+IntegerToString(prevLowPriceIndex)) >= 0) {
                  ObjectDelete(0, sellPosStr);
                  sellPosStr = "";
               }
               
               sellPos = (ulong)rand();
               prevLowPrice = lowPrice;
               prevLowPriceIndex = lowPriceIndex;
               
               drawTLAtHighLowPeaks(lowPrice, lowPriceIndex, 2);
               result = true; // Delete this statement if above code is uncomment
               //Print("sellPos: ",sellPos);
               
            }   
         }      
      }
      
      
      //Print(__FUNCTION__, " "+GetLastError() + ", result: "+result);
   }      
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcLots(double slPoints) {

   double risk = 0.0;
   if(PerTradeRiskPercent > 0) {
      risk = AccountInfoDouble(ACCOUNT_BALANCE) * (PerTradeRiskPercent/100);
      //Print("PerTradeRiskPercent: "+DoubleToString(risk));
   }   
   else {
      int randRisk = 1+(MathRand()%50);
      risk = AccountInfoDouble(ACCOUNT_BALANCE) * (randRisk/100);
      //Print("Random Risk: "+DoubleToString(risk));
   }
   
   double ticksize = SymbolInfoDouble(mSymbol,SYMBOL_TRADE_TICK_SIZE);
   double tickvalue = SymbolInfoDouble(mSymbol,SYMBOL_TRADE_TICK_VALUE);
   double lotstep = SymbolInfoDouble(mSymbol,SYMBOL_VOLUME_STEP);

   double moneyPerLotstep = slPoints / ticksize * tickvalue * lotstep;
   double lots = MathFloor(risk / moneyPerLotstep) * lotstep;
   lots = MathMin(lots,SymbolInfoDouble(mSymbol,SYMBOL_VOLUME_MAX));
   lots = MathMax(lots,SymbolInfoDouble(mSymbol,SYMBOL_VOLUME_MIN));

   return lots;

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsHitPerDayDrawdown() {

   // Calculate how much can effort to lose per day
   double maxLossPerDay = AccountInfoDouble(ACCOUNT_BALANCE)*(PerDayRiskOfBalance/100);

   datetime now = TimeCurrent();
   string dateTime = TimeToString(now, TIME_DATE);
   datetime startTime = StringToTime(dateTime + " " + IntegerToString(TradingStartHour));
   datetime endTime = StringToTime(dateTime + " " + IntegerToString(TradingEndHour));
   //datetime startTime = StringToTime("2022.10.28" + " 02:00");
   //datetime endTime = StringToTime("2022.10.28" + " 21:00");

   HistorySelect(startTime, endTime);
   //--- create objects
   string   name;
   uint     total=HistoryDealsTotal();
   ulong    ticket=0;
   double   profit = 0.0, totalProfit = 0.0, swap, commission;
   datetime time;
   string   symbol;
   //long     type;
   long     entry;
   //--- for all deals
   for(uint i=0; i<total; i++) {
      ticket = HistoryDealGetTicket(i);
      //Print("i: "+i + ", ticket: "+ ticket);
      //--- try to get deals ticket
      if(ticket > 0)
        {
         //--- get deals properties
         //price =HistoryDealGetDouble(ticket,DEAL_PRICE);
         time = (datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
         //symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         //type  =HistoryDealGetInteger(ticket,DEAL_TYPE);
         entry = HistoryDealGetInteger(ticket,DEAL_ENTRY);
         profit = HistoryDealGetDouble(ticket,DEAL_PROFIT);
         swap = HistoryDealGetDouble(ticket,DEAL_SWAP);
         commission = HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         //--- only for current symbol
         //Print("profit: "+profit + ", time: "+ time + ", entry: "+ entry);
         if(profit != 0.0 && time && entry)
           {
            //--- calculation
            totalProfit += (profit + swap + commission);
           }
        }
     }

   //Print("maxLossPerDay: "+ DoubleToString(maxLossPerDay,2) + " totalProfit: "+DoubleToString(totalProfit, 2));
   if(totalProfit < 0.0) {
      //Print("totalProfit : " + DoubleToString(MathAbs(totalProfit), 2));
      if(MathAbs(totalProfit) >= maxLossPerDay) {
         //Print("Close all positions");
         // Close all positions
         closeAllPositions();
         return true;
      }
   }
   
   return false;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calTotalRiskOfBalance() {

   double risk = AccountInfoDouble(ACCOUNT_BALANCE) * (TotalRiskOfBalance/100);
   double profit = AccountInfoDouble(ACCOUNT_PROFIT);
   //Print("Risk per day: "+DoubleToString(risk*(-1)) + ", profit: "+DoubleToString(profit));
   //if(profit < risk*(-1)) {
   //   Print("Close all trades");
   //}

//datetime todayStartTime, todayEndTime;
//HistorySelect();

   return 0.0;
}


double getSymbolProfit(string symbol){ 

   /*
   double pft=0;
   for(int i=PositionsTotal()-1; i>=0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0) {
         if(PositionGetInteger(POSITION_MAGIC)==Magic && PositionGetString(POSITION_SYMBOL)==Symbol()) {
            pft += PositionGetDouble(POSITION_PROFIT);
         }
      }
   }
   
   return pft;
   */

   
   //--- create objects
   //string   name;
   uint     total=HistoryDealsTotal();
   ulong    ticket=0;
   double   profit = 0.0, totalProfit = 0.0, swap, commission;
   datetime time;
   //long     type;
   long     entry;
   //--- for all deals
   for(uint i=0; i<total; i++) {
      ticket = HistoryDealGetTicket(i);
      //Print("i: "+i + ", ticket: "+ ticket);
      //--- try to get deals ticket
      if(ticket > 0) {
         //--- get deals properties
         time = (datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
         entry = HistoryDealGetInteger(ticket,DEAL_ENTRY);
         profit = HistoryDealGetDouble(ticket,DEAL_PROFIT);
         swap = HistoryDealGetDouble(ticket,DEAL_SWAP);
         commission = HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         //--- only for current symbol
         //Print("profit: "+profit + ", time: "+ time + ", entry: "+ entry);
         if(profit != 0.0 && time && entry) {
            //--- calculation
            totalProfit += (profit + swap + commission);
         }
      }
   }
   
   return totalProfit;
   //return(BuyProfit+SellProfit);
   
}


double startingBalance = 0.0, equityMax = 0.0, drawdownPercent = 0.0, maxDrawdownPercent = 0.0;
bool getPerDayRiskFromEquity() {

   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(equity > equityMax)
      equityMax = equity;

   // Calculate drawdown for fixed Account Balance
   //double drawdownPercent = ((equityMax-equity)/InitialAccountBalance)*100;
   //Print("drawdownPercent: " + drawdownPercent);

   // Calculate drawdown for current Account Balance
   //drawdownPercent = ((equityMax-equity)/equityMax)*100;
   drawdownPercent = ((startingBalance-equity)/startingBalance)*100;
   //Print("equityMax: "+equityMax+", equity: "+equity+", drawdownPercent: "+drawdownPercent);
   if(drawdownPercent > maxDrawdownPercent) 
      maxDrawdownPercent = drawdownPercent;

   if(GlobalVariableCheck(EA_CURRENT_DRAWDOWN)) {
      isDrawdown = true;
      double gv_drawdown = GlobalVariableGet(EA_CURRENT_DRAWDOWN);
      if(gv_drawdown > equityMax)
         equityMax = gv_drawdown;
   }

   int bars = iBars(mSymbol, PERIOD_D1);
   static int barsTotal = bars;
   if(barsTotal != bars) {
      // Reset drawdown
      equityMax = equity;
      isDrawdown = false;
      if(GlobalVariableCheck(EA_CURRENT_DRAWDOWN))
         GlobalVariableDel(EA_CURRENT_DRAWDOWN);
   }

   if(isDrawdown || drawdownPercent >= PerDayRiskOfBalance) {

      isDrawdown = true;
      GlobalVariableSet(EA_CURRENT_DRAWDOWN, equityMax);
      
      // Close all positions
      closeExpertAdvisorAllPositions();
      
      //Print("Closed all trades.");
      
      return true;
   }


   /* Put at the start of OnTick function for other EAs */
   /*if(GlobalVariableCheck(EA_CURRENT_DRAWDOWN)) {
      // Do not open trade
      return;
   }*/

   return false;
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string whichOrderTypeWillExecuteNextTrade(string tlSignal, string futureOrderSignal) {
   
   //Print("tlSignal: "+tlSignal + ", futureOrderSignal: "+futureOrderSignal);
   // By default nextOrderType = futureOrderSignal
   string nextOrderType = futureOrderSignal;
   
   // Close all profit trades, if futureOrderSignal is not same with the current positions type
   //bool result = closeAllProfitTrades(futureOrderSignal);
   //if(!result) {
      nextOrderType = (futureOrderSignal == "BUY") ? "BUY" : "SELL";
   //}
   
   return nextOrderType;
}


bool closeAllProfitTrades(string orderType) {
   
   // If closePostion = true, that means profit positions are closed,
   // where positions type are not equal to orderType
   bool closePostion = false;
   
   // close running positions
   for(int i=PositionsTotal()-1; i>=0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionSelectByTicket(ticket)) {
         if(PositionGetDouble(POSITION_PROFIT) > 0 && PositionGetInteger(POSITION_TYPE) != POSITION_TYPE_BUY && 
            PositionGetString(POSITION_SYMBOL) == mSymbol && PositionGetInteger(POSITION_MAGIC) == Magic) {
            //Print("ticket: "+ticket + ", profit: "+PositionGetDouble(POSITION_PROFIT) + ", position type: "+PositionGetInteger(POSITION_TYPE));
            bool result = false;
            while(!result) {
               result = trade.PositionClose(ticket);
               closePostion = result;
            }
         }     
      }
   }
   return closePostion;
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAllPositions() {

   // close all positions
   for(int i=PositionsTotal()-1; i>=0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionSelectByTicket(ticket)) {
         if(PositionGetInteger(POSITION_MAGIC) == Magic) {
            bool result = false;
            while(!result) result = trade.PositionClose(ticket);
         }   
      }
   }

   // delete all positions
   for(int i=OrdersTotal()-1; i>=0; i--) {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0 && OrderSelect(ticket)) {
         if(OrderGetInteger(ORDER_MAGIC) == Magic) {
            bool result = false;
            while(!result) result = trade.OrderDelete(ticket);
         }      
      }
   }
}


void closeExpertAdvisorAllPositions() {

   // close all positions
   for(int i=PositionsTotal()-1; i>=0; i--) {
      ulong ticket = PositionGetTicket(i);
      
      //Print("111 ticket: "+ticket + ", symbol: "+PositionGetString(POSITION_SYMBOL) + ", magic: "+ PositionGetInteger(POSITION_MAGIC));
      
      if(ticket > 0 && PositionSelectByTicket(ticket)) {
         if(PositionGetInteger(POSITION_MAGIC) == Magic) {
            bool result = false;
            while(!result) result = trade.PositionClose(ticket);
         }   
      }
   }

   // delete all positions
   for(int i=OrdersTotal()-1; i>=0; i--) {
      ulong ticket = OrderGetTicket(i);
      
      //Print("222 ticket: "+ticket + ", symbol: "+OrderGetString(ORDER_SYMBOL) + ", magic: "+ OrderGetInteger(ORDER_MAGIC));
      
      if(ticket > 0 && OrderSelect(ticket)) {
         if(OrderGetInteger(ORDER_MAGIC) == Magic) {
            bool result = false;
            while(!result) result = trade.OrderDelete(ticket);
         }      
      }
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAllBuyPositions() {
   //Print("Called closeAllBuyPositions");
   // close all positions
   for(int i=PositionsTotal()-1; i>=0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionSelectByTicket(ticket)) {
         if(PositionGetString(POSITION_SYMBOL)==mSymbol && PositionGetInteger(POSITION_MAGIC) == Magic && 
            PositionGetInteger(POSITION_TYPE)==ORDER_TYPE_BUY) {
            bool result = false;
            while(!result) {
               result = trade.PositionClose(ticket);
            }
         }   
      }
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkLossPositions(ENUM_POSITION_TYPE positionType) {
   bool result = false;
   // close all positions
   for(int i=PositionsTotal()-1; i>=0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionSelectByTicket(ticket)) {
         if(PositionGetString(POSITION_SYMBOL)==mSymbol && PositionGetInteger(POSITION_MAGIC) == Magic && 
            PositionGetInteger(POSITION_TYPE)==positionType && PositionGetDouble(POSITION_PROFIT) < 0) {
            result = true;
            break;
         }   
      }
   }
   return result;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAllLossBuyPositions() {
   //Print("Called closeAllLossBuyPositions");
   // close all positions
   for(int i=PositionsTotal()-1; i>=0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionSelectByTicket(ticket)) {
         if(PositionGetString(POSITION_SYMBOL)==mSymbol && PositionGetInteger(POSITION_MAGIC) == Magic && 
            PositionGetInteger(POSITION_TYPE)==ORDER_TYPE_BUY && PositionGetDouble(POSITION_PROFIT) < 0) {
            bool result = false;
            while(!result) {
               result = trade.PositionClose(ticket);
            }
         }   
      }
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAllSellPositions() {
   //Print("Called closeAllSellPositions");
   // close all positions
   for(int i=PositionsTotal()-1; i>=0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionSelectByTicket(ticket)) {
         if(PositionGetString(POSITION_SYMBOL)==mSymbol && PositionGetInteger(POSITION_MAGIC) == Magic && 
            PositionGetInteger(POSITION_TYPE)==ORDER_TYPE_SELL) {
            bool result = false;
            while(!result) {
               result = trade.PositionClose(ticket);
            }
         }   
      }
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAllLossSellPositions() {
   //Print("Called closeAllLossSellPositions");
   // close all positions
   for(int i=PositionsTotal()-1; i>=0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionSelectByTicket(ticket)) {
         if(PositionGetString(POSITION_SYMBOL)==mSymbol && PositionGetInteger(POSITION_MAGIC) == Magic && 
            PositionGetInteger(POSITION_TYPE)==ORDER_TYPE_SELL && PositionGetDouble(POSITION_PROFIT) < 0) {
            bool result = false;
            while(!result) {
               result = trade.PositionClose(ticket);
            }
         }   
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAllProfitPositions() {
   // close all positions
   for(int i=PositionsTotal()-1; i>=0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionSelectByTicket(ticket)) {
         //if(PositionGetString(POSITION_SYMBOL)==symbol && PositionGetInteger(POSITION_MAGIC) == Magic)
         if(PositionGetDouble(POSITION_PROFIT) > 0 && 
            PositionGetString(POSITION_SYMBOL) == mSymbol && PositionGetInteger(POSITION_MAGIC) == Magic) {
            bool result = false;
            while(!result) {
               result = trade.PositionClose(ticket);
            }
         }   
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAllLossPositions() {
   // close all positions
   for(int i=PositionsTotal()-1; i>=0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionSelectByTicket(ticket)) {
         //if(PositionGetString(POSITION_SYMBOL)==symbol && PositionGetInteger(POSITION_MAGIC) == Magic)
         if(PositionGetDouble(POSITION_PROFIT) < 0 && 
            PositionGetString(POSITION_SYMBOL) == mSymbol && PositionGetInteger(POSITION_MAGIC) == Magic) {
            bool result = false;
            while(!result) result = trade.PositionClose(ticket);
         }   
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAllPendingPositions() {
   // delete all positions
   for(int i=OrdersTotal()-1; i>=0; i--) {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0 && OrderSelect(ticket)) {
         if(OrderGetString(ORDER_SYMBOL)==mSymbol && OrderGetInteger(ORDER_MAGIC) == Magic) {
            bool result = false;
            while(!result) result = trade.OrderDelete(ticket);
         }      
      }
   }
}


//+------------------------------------------------------------------+
//|  Find market High & Low prices                                                                |
//+------------------------------------------------------------------+
double findHigh() {

   highPrice = 0;
   highPriceIndex = -1;
   
   double highestHigh = 0;
   for(int i = 0; i < NumberOfBarScan; i++) {
      double high = iHigh(mSymbol, Timeframe, i);
      //if(i > LookBackBars && iHighest(mSymbol,Timeframe,MODE_HIGH,LookBackBars*2+1,i-LookBackBars) == i) {
      if(i > LookBackBars && iHighest(mSymbol,Timeframe,MODE_HIGH, (LookBackBars*2)+1, (i-LookBackBars)) == i) {
      //if(i > LookBackBars && iHighest(mSymbol,Timeframe,MODE_HIGH,LookBackBars*+1,i-LookBackBars) == i) {
         if(high > highestHigh) {
            highPrice = high;
            highPriceIndex = i;
            //Print("findHigh() ## high: "+high+", i: "+i);
            return high;
         }
      }
      highestHigh = MathMax(high,highestHigh);
   }
   return -1;
}


//+------------------------------------------------------------------------------+
//|  Find touch points on AscendingHigherTrendline, DescendingHigherTrendline    |
//|  AscendingLowerTrendline, DescendingLowerTrendline                           |
//+------------------------------------------------------------------------------+

void findTrendlineTouchPoints() {

   int arrayIndex = 0, tlCount = 0, lowerTLCount = 0;
   double highestHigh = 0;
   //string upperArr[], lowerArr[];
   //ArrayResize(upperArr, 100);
   //ArrayResize(lowerArr, 100);

   
   for(int tl=0; tl<ObjectsTotal(0, 0, OBJ_TREND); tl++) {
      string objName = ObjectName(0, tl, 0, OBJ_TREND);
      if(ObjectGetInteger(0, objName, OBJPROP_TYPE) == OBJ_TREND) {
         if(!(StringFind(objName, "HighTrendline") > -1) && 
            !(StringFind(objName, "LowTrendline") > -1) && 
            (StringFind(objName, "Trendline") > -1)) {
            
            
            // Scan Number Of Bars
            int tlTouchCount = 0, lowerTLTouchCount = 0;
            for(int i = 0; i < NumberOfBarScan*3; i++) {
               
               datetime time = 0;
               
               if(StringFind(objName, "AscendingHigherTrendline") > -1 || 
                  StringFind(objName, "DescendingHigherTrendline") > -1) {
                  
                  // Get higher trendline touched price
                  double high = iHigh(mSymbol, Timeframe, i);
                  time = iTime(mSymbol, mPeriod, i);
               
                  double price = NormalizeDouble(ObjectGetValueByTime(0, objName, time), _Digits);
                  double priceDif = (high-price);
                  double absPriceDif = MathAbs(priceDif);
                  int pricePoints = DoubleToPoints(absPriceDif);
                  if(price > 0 && priceDif < 0 && high >= price) {
                     tlTouchCount++;
                     //Print("111 objName: "+ objName + ", tlTouchCount: "+ tlTouchCount +", high: "+high + ", price: "+price+", priceDif: "+priceDif + ", absPriceDif: "+absPriceDif + ", pricePoints: "+pricePoints);
                  }
                  else if(price > 0 && (priceDif == 0.0 || (pricePoints >= 0 &&  pricePoints <= 10))) {
                     tlTouchCount++;
                     //Print("222 objName: "+ objName + ", tlTouchCount: " + tlTouchCount +", high: "+high + ", price: "+price+", priceDif: "+priceDif + ", absPriceDif: "+absPriceDif + ", pricePoints: "+pricePoints);
                  }
               }
               
               
               if(StringFind(objName, "AscendingLowerTrendline") > -1 || 
                  StringFind(objName, "DescendingLowerTrendline") > -1) {
                  
                  // Get lower trendline touched price
                  double low = iLow(mSymbol, Timeframe, i);
                  time = iTime(mSymbol, mPeriod, i);
                  
                  double price = NormalizeDouble(ObjectGetValueByTime(0, objName, time), _Digits);
                  double priceDif = (low-price);
                  double absPriceDif = MathAbs(priceDif);
                  int pricePoints = DoubleToPoints(absPriceDif);
                  if(price > 0 && priceDif > 0 && low <= price) {
                     lowerTLTouchCount++;
                     //Print("333 objName: "+ objName + ", tlTouchCount: " + tlTouchCount +", low: "+low + ", price: "+price+", priceDif: "+priceDif + ", absPriceDif: "+absPriceDif + ", pricePoints: "+pricePoints);
                  }
                  else if(price > 0 && (priceDif == 0.0 || (pricePoints >= 0 &&  pricePoints <= 10))) {
                     lowerTLTouchCount++;
                     //Print("444 objName: "+ objName + ", tlTouchCount: " + tlTouchCount +", low: "+low + ", price: "+price+", priceDif: "+priceDif + ", absPriceDif: "+absPriceDif + ", pricePoints: "+pricePoints);
                  }
               }      
            }
            
            if(tlTouchCount > 0) {
               string tmpStr = objName + "#" + IntegerToString(tlTouchCount);
               upperTLTouchArr[tlCount] = tmpStr;
               tlCount++;
            }
            
            if(lowerTLTouchCount > 0) {
               string tmpStr = objName + "#" + IntegerToString(lowerTLTouchCount);
               lowerTLTouchArr[lowerTLCount] = tmpStr;
               lowerTLCount++;
            }
         }
      }
   }
   
   /*
   // Print Upper Trendline Touched Points
   for(int i=0; i<upperTLTouchArr.Size(); i++) {
      if(StringLen(upperTLTouchArr[i]) > 0) {
         Print("upperTLTouchArr["+i+"]:" + upperTLTouchArr[i]);
      }
   }
   
   // Print Lower Trendline Touched Points
   for(int i=0; i<lowerTLTouchArr.Size(); i++) {
      if(StringLen(lowerTLTouchArr[i]) > 0) {
         Print("lowerTLTouchArr["+i+"]:" + lowerTLTouchArr[i]);
      }
   }
   */
   
   
   /*
   // Search Upper All High Price
   for(int i = 0; i < NumberOfBarScan*3; i++) {
      double high = iHigh(mSymbol, Timeframe, i);
      datetime time = iTime(mSymbol, mPeriod, i);
      if(i > LookBackBars && iHighest(mSymbol,Timeframe,MODE_HIGH, ((LookBackBars-2)*2)+1,(i-LookBackBars)) == i) {
         //Print("Higher TL, time: "+time + ", high: "+ high + ", LookBackBar: " + (LookBackBars*2+1) + ", Start: " + (i-LookBackBars) + ", iHighest: "+iHighest(mSymbol,Timeframe,MODE_HIGH, LookBackBars*2+1,i-LookBackBars) + ", i: "+i);
         double close = iClose(mSymbol, Timeframe, i);
         upperArr[arrayIndex] = DoubleToString(high)+"#"+DoubleToString(close)+"#"+IntegerToString(i)+"#"+TimeToString(time, TIME_DATE|TIME_MINUTES);
         //Print("111 Higher upperArr["+arrayIndex+"]:" + upperArr[arrayIndex]);
         arrayIndex++;
      }
   }
   
   
   // Search Lower All Low Price
   arrayIndex = 0;
   for(int i = 0; i < NumberOfBarScan*3; i++) {
      double low = iLow(mSymbol, Timeframe, i);
      datetime time = iTime(mSymbol, mPeriod, i);
      if(i > LookBackBars && iLowest(mSymbol,Timeframe,MODE_LOW, ((LookBackBars-2)*2)+1, (i-LookBackBars)) == i) {
         //Print("Lower TL, time: "+time + ", low: "+ low +", LookBackBar: " + (LookBackBars*2+1) + ", Start: " + (i-LookBackBars) + ", iLowest: "+iLowest(mSymbol,Timeframe,MODE_LOW, LookBackBars*2+1, i-LookBackBars) + ", i: "+i);
         double close = iClose(mSymbol, Timeframe, i);
         lowerArr[arrayIndex] = DoubleToString(low)+"#"+DoubleToString(close)+"#"+IntegerToString(i)+"#"+TimeToString(time, TIME_DATE|TIME_MINUTES);
         //Print("111 Lower lowerArr["+arrayIndex+"]:" + lowerArr[arrayIndex]);
         arrayIndex++;
      }
   }
   
   
   
   for(int tl=0; tl<ObjectsTotal(0, 0, OBJ_TREND); tl++) {
      string objName = ObjectName(0, tl, 0, OBJ_TREND);
      if(ObjectGetInteger(0, objName, OBJPROP_TYPE) == OBJ_TREND) {
         if(!(StringFind(objName, "HighTrendline") > -1) && !(StringFind(objName, "LowTrendline") > -1) && 
            (StringFind(objName, "Trendline") > -1)) {
         
            // Get Higher Trendline All Touch Points
            int tlTouchCount = 0;
            for(int i=0; i<upperArr.Size(); i++) {
               //Print("upperArr["+i+"]:" + upperArr[i]);
               
               string priceArr[];
               int splitArrCount = StringSplit(upperArr[i], separatorChar, priceArr);
               if(splitArrCount > 0) {
                  
                  double tlPrice = NormalizeDouble(ObjectGetValueByTime(0, objName, StringToTime(priceArr[3])), _Digits);
                  double hlPrice = NormalizeDouble(priceArr[0], _Digits);
                  double hClosePrice = NormalizeDouble(priceArr[1], _Digits);
                  double priceDif = (tlPrice-hlPrice);
                  double absPriceDif = MathAbs(priceDif);
                  int pricePoints = DoubleToPoints(absPriceDif);
                  //Print("Upper, objName: " + objName + ", tlPrice: "+tlPrice + ", hlPrice: "+hlPrice + ", hClosePrice: "+ hClosePrice +", priceDif: "+priceDif + ", pricePoints: "+pricePoints);
                  if(tlPrice > 0 && priceDif < 0 && hClosePrice <= tlPrice && hlPrice >= tlPrice) {
                     tlTouchCount++;
                     //Print("Upper, 111 objName: " + objName + ", pricePoints: " + pricePoints + ", tlTouchCount: "+tlTouchCount);
                  }
                  else if(tlPrice > 0 && priceDif == 0.0 || (pricePoints >= 0 &&  pricePoints <= 20)) {
                     tlTouchCount++;
                     //Print("Upper, 222 objName: " + objName + ", pricePoints: " + pricePoints + ", tlTouchCount: "+tlTouchCount);
                  }
               }
            }
            if(tlTouchCount > 0) {
               string tmpStr = objName + "#" + IntegerToString(tlTouchCount);
               upperTLTouchArr[tlCount] = tmpStr;
               
               tlCount++;
            }
            
            
            
            // Get Lower Trendline All Touch Points
            int lowerTLTouchCount = 0;
            for(int i=0; i<lowerArr.Size(); i++) {
               //Print("lowerArr["+i+"]:" + lowerArr[i]);
               
               string priceArr[];
               int splitArrCount = StringSplit(lowerArr[i], separatorChar, priceArr);
               if(splitArrCount > 0) {
                  
                  double tlPrice = NormalizeDouble(ObjectGetValueByTime(0, objName, StringToTime(priceArr[3])), _Digits);
                  double lowPrice = NormalizeDouble(priceArr[0], _Digits);
                  double lClosePrice = NormalizeDouble(priceArr[1], _Digits);
                  double priceDif = (tlPrice-lowPrice);
                  double absPriceDif = MathAbs(priceDif);
                  int pricePoints = DoubleToPoints(absPriceDif);
                  //Print("Lower, objName: " + objName + ", tlPrice: "+tlPrice + ", lowPrice: "+lowPrice + ", lClosePrice: "+ lClosePrice +", priceDif: "+priceDif + ", pricePoints: "+pricePoints);
                  if(tlPrice > 0 && priceDif > 0 && lClosePrice >= tlPrice && lowPrice <= tlPrice) {
                     lowerTLTouchCount++;
                     //Print("Lower, 111 objName: " + objName + ", pricePoints: " + pricePoints + ", lowerTLTouchCount: "+lowerTLTouchCount);
                  }
                  else if(tlPrice > 0 && priceDif == 0.0 || (pricePoints >= 0 &&  pricePoints <= 20)) {
                     lowerTLTouchCount++;
                     //Print("Lower, 222 objName: " + objName + ", pricePoints: " + pricePoints + ", lowerTLTouchCount: "+lowerTLTouchCount);
                  }
               }
            }
            if(lowerTLTouchCount > 0) {
               string tmpStr = objName + "#" + IntegerToString(lowerTLTouchCount);
               lowerTLTouchArr[lowerTLCount] = tmpStr;
               
               lowerTLCount++;
            }
         }
      }
   }
   
   
   // Print Upper Trendline Touched Points
   for(int i=0; i<upperTLTouchArr.Size(); i++) {
      if(StringLen(upperTLTouchArr[i]) > 0) {
         Print("upperTLTouchArr["+i+"]:" + upperTLTouchArr[i]);
      }
   }
   
   // Print Lower Trendline Touched Points
   for(int i=0; i<lowerTLTouchArr.Size(); i++) {
      if(StringLen(lowerTLTouchArr[i]) > 0) {
         Print("lowerTLTouchArr["+i+"]:" + lowerTLTouchArr[i]);
      }
   }*/
}


void findRectangleObjectTouchPoints() {

   for(int i=0; i<ObjectsTotal(0, 0, OBJ_RECTANGLE); i++) {   
      
      string objName = ObjectName(0, i, 0, OBJ_RECTANGLE);
      
      if(StringFind(objName, "Support", 0) >= 0 || 
         StringFind(objName, "Resistance", 0) >= 0 || 
         StringFind(objName, "Rectangle", 0) >= 0) {
         
         // Check if objName is exist in myRectangle[] array
         if(!checkRectNameExist(objName)) {
            datetime rectObjTimeStart  =  ObjectGetInteger(0, objName, OBJPROP_TIME, 1);
            datetime rectObjTimeEnd    =  ObjectGetInteger(0, objName, OBJPROP_TIME, 0);
            
            double rectObjPrice0       =  ObjectGetDouble(0, objName, OBJPROP_PRICE, 0);
            double rectObjPrice1       =  ObjectGetDouble(0, objName, OBJPROP_PRICE, 1);
            
            MyRectangle *mr = new MyRectangle(objName, rectObjPrice0, rectObjPrice1, 
                                 TimeToString(rectObjTimeStart), TimeToString(rectObjTimeEnd), 0);
            myRectangle[i] = mr; 
         }
         
      }
   }      



   int resistanceZoneTouchCount = 0, supportZoneTouchCount = 0;
   for(int i=0; i<myRectangle.Size(); i++) { 
      if(CheckPointer(myRectangle[i]) != POINTER_INVALID) {
         MyRectangle *mr = (MyRectangle *)myRectangle[i];  
         
         datetime rectObjTimeStart =  mr.GetObjStartTime();
         datetime rectObjTimeEnd   =  mr.GetObjEndTime();
         
         double   rectObjPrice0    =  mr.GetPriceLevel0();
         double   rectObjPrice1    =  mr.GetPriceLevel1();
         
         
         // Check if current time has in a valid rect zone
         datetime currentTime = iTime(mSymbol, mPeriod, 0);
         
         Print("currentTime: ", currentTime, ", rectObjTimeStart: ", rectObjTimeStart, ", rectObjTimeEnd: ", rectObjTimeEnd);
         
         if(!(currentTime >= rectObjTimeStart && currentTime <= rectObjTimeEnd) || 
                  rectObjPrice0 <= 0.0 || rectObjPrice1 <= 0.0) continue;
         
                        
         double cLowPrice     =  iLow(mSymbol, Timeframe, 0); 
         double cHighPrice    =  iHigh(mSymbol, Timeframe, 0);
         double cOpenPrice    =  iOpen(mSymbol, Timeframe, 0);  
         double cClosePrice   =  iClose(mSymbol, Timeframe, 0);
         
         
         Print("cLowPrice: ", cLowPrice, ", cHighPrice: ", cHighPrice, ", cOpenPrice: ", cOpenPrice, ", cClosePrice: ", cClosePrice);
         
         
         if(cClosePrice <= rectObjPrice1 && cHighPrice >= rectObjPrice0) {
            resistanceZoneTouchCount++;
            Print("resistanceZoneTouchCount: "+resistanceZoneTouchCount);
            mr.SetTouchCount(resistanceZoneTouchCount);
         }
         else if(cClosePrice >= rectObjPrice0 && cLowPrice <= rectObjPrice1) {
            supportZoneTouchCount++;
            Print("supportZoneTouchCount: "+supportZoneTouchCount);
            mr.SetTouchCount(supportZoneTouchCount);
         } 
         
      }         
   }

   Print("myRectangle size: ", myRectangle.Size());
   for(int i=0; i<myRectangle.Size(); i++) { 
      if(CheckPointer(myRectangle[i]) != POINTER_INVALID) {
         MyRectangle *mr = (MyRectangle *)myRectangle[i];  
         Print("myRectangle["+i+"]:" + ", Name: "+mr.GetObjName() + 
            ", Price0: "+mr.GetPriceLevel0() + 
            ", Price1: "+mr.GetPriceLevel1() + 
            ", StartTime: "+mr.GetObjStartTime() + 
            ", EndTime: "+mr.GetObjEndTime() + 
            ", TouchCount: "+mr.GetTouchCount());
      }         
   }

   return;
  
   int resistanceCount = 0, supportCount = 0;   
   for(int tl=0; tl<ObjectsTotal(0, 0, OBJ_RECTANGLE); tl++) {
      
      string objName = ObjectName(0, tl, 0, OBJ_RECTANGLE);
      
      if(StringFind(objName, "Support", 0) >= 0 || 
         StringFind(objName, "Resistance", 0) >= 0 || 
         StringFind(objName, "Rectangle", 0) >= 0) {
          
         
         datetime rectObjTimeStart  =  ObjectGetInteger(0, objName, OBJPROP_TIME, 1);
         datetime rectObjTimeEnd    =  ObjectGetInteger(0, objName, OBJPROP_TIME, 0);
         
         double rectObjPrice0       =  ObjectGetDouble(0, objName, OBJPROP_PRICE, 0);
         double rectObjPrice1       =  ObjectGetDouble(0, objName, OBJPROP_PRICE, 1);
         
         // Scan Number Of Bars
         datetime resistanceLastTouchTime = 0, supportLastTouchTime = 0;
         int resistanceZoneTouchCount = 0, supportZoneTouchCount = 0;
         for(int i = 0; i < NumberOfBarScan*3; i++) {
            
            datetime candleTime  =  iTime(Symbol(), PERIOD_CURRENT, i);
            if(!(candleTime >= rectObjTimeStart && candleTime <= rectObjTimeEnd) || 
               rectObjPrice0 <= 0.0 || rectObjPrice1 <= 0.0) continue;
               
            double cLowPrice     =  iLow(mSymbol, Timeframe, i); 
            double cHighPrice    =  iHigh(mSymbol, Timeframe, i);
            double cOpenPrice    =  iOpen(mSymbol, Timeframe, i);  
            double cClosePrice   =  iClose(mSymbol, Timeframe, i);
            
            
            //Print("111 objName: "+ objName + ", candleTime = "+ candleTime + ", rectObjTimeStart: "+rectObjTimeStart + ", rectObjTimeEnd: "+rectObjTimeEnd);
            //Print("rectObjPrice0: "+rectObjPrice0 + ", rectObjPrice1: "+rectObjPrice1 + ", cOpenPrice: "+ cOpenPrice + ", cClosePrice = "+ cClosePrice + ", cHighPrice: "+cHighPrice + ", cLowPrice: "+cLowPrice);
            
            if(cClosePrice <= rectObjPrice1 && cHighPrice >= rectObjPrice0) {
               
               datetime tmpBarTime = 0;
               int bIndex = i+1;
               bool flag = false, IsSameTouchZone = false;
               while(!flag) {
                  //Print("lastTouchIndex: " + lastTouchIndex + ", bIndex: "+bIndex);
                  //if(lastTouchIndex == bIndex) break;
                  double highPrice = iHigh(mSymbol, mPeriod, bIndex);
                  if(highPrice < rectObjPrice0) {     // Check previous candle is below the rect zone
                     if(resistanceLastTouchTime == iTime(Symbol(), PERIOD_CURRENT, bIndex-1)) {
                        flag = true;
                        IsSameTouchZone = false;
                     }
                     else {
                        flag = true;
                        IsSameTouchZone = true;
                     }
                     break;
                  }
                  bIndex++;
               }
               
               // Get a touch point in resistance zone
               if(flag && IsSameTouchZone) {
                  resistanceLastTouchTime = iTime(mSymbol, mPeriod, i);
                  resistanceZoneTouchCount++;
                  Print("resistanceZoneTouchCount: "+resistanceZoneTouchCount);
               }
            }
            else if(cClosePrice >= rectObjPrice0 && cLowPrice <= rectObjPrice1) {
               int bIndex = i+1;
               bool flag = true;
               while(flag) {
                  double highPrice =  iHigh(mSymbol, Timeframe, bIndex);
                  if(highPrice < rectObjPrice0) {
                     flag = false;
                  }
                  bIndex++;
               }
               if(flag == false) {
                  supportLastTouchTime = iTime(mSymbol, mPeriod, i);
                  supportZoneTouchCount++;
                  Print("supportZoneTouchCount: "+supportZoneTouchCount);
               }
               //supportZoneTouchCount++;
            }   
         }
         
         if(resistanceZoneTouchCount > 0) {
            string tmpStr = objName + "#" + IntegerToString(resistanceZoneTouchCount);
            resistanceZoneTouchArr[resistanceCount] = tmpStr;
            resistanceCount++;
         }
         
         if(supportZoneTouchCount > 0) {
            string tmpStr = objName + "#" + IntegerToString(supportZoneTouchCount);
            supportZoneTouchArr[supportCount] = tmpStr;
            supportCount++;
         }
      }
   }
   
   
   // Print Resistance Zone Touched Points
   for(int i=0; i<resistanceZoneTouchArr.Size(); i++) {
      if(StringLen(resistanceZoneTouchArr[i]) > 0) {
         Print("resistanceZoneTouchArr["+i+"]:" + resistanceZoneTouchArr[i]);
      }
   }
   
   // Print Support Zone Touched Points
   for(int i=0; i<supportZoneTouchArr.Size(); i++) {
      if(StringLen(supportZoneTouchArr[i]) > 0) {
         Print("supportZoneTouchArr["+i+"]:" + supportZoneTouchArr[i]);
      }
   }
   
}


// Check if reference object name has in myRectangle[] array
bool checkRectNameExist(string objName) {
   for(int i=0; i<myRectangle.Size(); i++) { 
      if(CheckPointer(myRectangle[i]) != POINTER_INVALID) {
         if(myRectangle[i].GetObjName() == objName) 
            return true;
      }         
   }
   return false;
}

// Delete all objects from array
void freeRectObjArray() {
   for(int i=myRectangle.Size()-1; i>=0; i--) {
      if(CheckPointer(myRectangle[i]) != POINTER_INVALID) {
         MyRectangle *mr = (MyRectangle *)myRectangle[i];
         delete mr;
      }
   }
}


double findHighPriceAndBarIndex() {
   
   highPrice = 0;
   highPriceIndex = -1;
            
   double highestHigh = 0;
   for(int i = 0; i < NumberOfBarScan; i++) {
      double high = iHigh(mSymbol, Timeframe, i);
      if(i > LookBackBars && iHighest(mSymbol,Timeframe,MODE_HIGH,LookBackBars*2+1,i-LookBackBars) == i) {
      //if(i > LookBackBars && iHighest(mSymbol,Timeframe,MODE_HIGH,LookBackBars,i-LookBackBars) == i) {
         if(high > highestHigh) {
            highPrice = high;
            highPriceIndex = i;
            //Print("findHighPriceAndBarIndex() ## high: "+high+", i: "+i);
            return high;
         }
      }
      highestHigh = MathMax(high,highestHigh);
   }
   return -1;
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double findLow() {

   lowPrice = 0;
   lowPriceIndex = -1;
   
   double lowestLow = DBL_MAX;
   for(int i = 0; i < NumberOfBarScan; i++) {
      double low = iLow(mSymbol, Timeframe, i);
      //if(i > LookBackBars && iLowest(mSymbol,Timeframe,MODE_LOW,LookBackBars*2+1,i-LookBackBars) == i) {
      if(i > LookBackBars && iLowest(mSymbol,Timeframe,MODE_LOW, (LookBackBars*2)+1, (i-LookBackBars)) == i) {
      //if(i > LookBackBars && iLowest(mSymbol,Timeframe,MODE_LOW,LookBackBars,i-LookBackBars) == i) {
         if(low < lowestLow) {
            lowPrice = low;
            lowPriceIndex = i;
            //Print("findLow() ## low: "+low+", i: "+i);
            return low;
         }
      }
      lowestLow = MathMin(low,lowestLow);
   }
   return -1;
}


double findLowPriceAndBarIndex() {

   lowPrice = 0;
   lowPriceIndex = -1;

   double lowestLow = DBL_MAX;
   for(int i = 0; i < NumberOfBarScan; i++) {
      double low = iLow(mSymbol, Timeframe, i);
      if(i > LookBackBars && iLowest(mSymbol,Timeframe,MODE_LOW,LookBackBars*2+1,i-LookBackBars) == i) {
      //if(i > LookBackBars && iLowest(mSymbol,Timeframe,MODE_LOW,LookBackBars,i-LookBackBars) == i) {
         if(low < lowestLow) {
            lowPrice = low;
            lowPriceIndex = i;
            //Print("findLowPriceAndBarIndex() ## low: "+low+", i: "+i);
            return low;
         }
      }
      lowestLow = MathMin(low,lowestLow);
   }
   return -1;
}

/*
void CheckTrendLine() {

   if(!NewTrendLineFound) return;
   NewTrendLineFound = false;

   cTrendHighLow.Update();

   static int bar_count = 0;
   int count = (TrendLineBarStart+TrendLineBarCount+bar_count);
   bar_count++;

   //Print("bar_count: "+bar_count);

   static double prevUpperValue = 0, prevLowerValue = 0;

   double upperValue = cTrendHighLow.UpperValueAt(count);
   double lowerValue = cTrendHighLow.LowerValueAt(count);

   if(prevUpperValue != upperValue) {
      prevUpperValue = upperValue;

      ObjectDelete(0, "UpperTrend");
      ObjectCreate(0, "UpperTrend", OBJ_TREND, 0,    iTime(Symbol(), PERIOD_CURRENT, count),
                  cTrendHighLow.UpperValueAt(count), iTime(Symbol(), PERIOD_CURRENT, 0),
                  cTrendHighLow.UpperValueAt(0));
      ObjectSetInteger(0, "UpperTrend", OBJPROP_COLOR, clrChartreuse);
      ObjectSetInteger(0, "UpperTrend", OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, "UpperTrend", OBJPROP_RAY_RIGHT, true);
   }


   if(prevLowerValue != lowerValue) {
      prevLowerValue = lowerValue;

      ObjectDelete(0, "LowerTrend");
      ObjectCreate(0, "LowerTrend", OBJ_TREND, 0,    iTime(Symbol(), PERIOD_CURRENT, count),
                  cTrendHighLow.LowerValueAt(count), iTime(Symbol(), PERIOD_CURRENT, 0),
                  cTrendHighLow.LowerValueAt(0));
      ObjectSetInteger(0, "LowerTrend", OBJPROP_COLOR, clrChartreuse);
      ObjectSetInteger(0, "LowerTrend", OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, "LowerTrend", OBJPROP_RAY_RIGHT, true);
   }

}
*/


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTradeAllowed() {

   return((bool)MQLInfoInteger(MQL_TRADE_ALLOWED) &&              // Trading allowed in input dialog
          (bool)TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) &&   // Trading allowed in terminal
          (bool)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED) &&     // Is account able to trade, not
          (bool)AccountInfoInteger(ACCOUNT_TRADE_EXPERT)         // Is account able to auto trade
         );
}

// Check if there is a new bar has created
bool IsNewBar(bool first_call = false) {

   static bool result = false;
   if(!first_call)
      return result;

   //Print("first_call = "+first_call);
   static datetime previousBarTime = 0;
   datetime currentBarTime = iTime(mSymbol, Timeframe, 0);
   result = false;

   if(currentBarTime != previousBarTime) {
      previousBarTime = currentBarTime;
      result = true;
   }

   return result;
}


// Check if there is a new daily bar has created
bool IsDailyNewBar(bool first_call = false) {

   static bool result = false;
   if(!first_call)
      return result;

   //Print("first_call = "+first_call);
   static datetime previousBarTime = 0;
   datetime currentBarTime = iTime(mSymbol, PERIOD_D1, 0);
   result = false;

   if(currentBarTime != previousBarTime) {
      previousBarTime = currentBarTime;
      is_trade_allow = true;
      result = true;
   }

   return result;
}


// Check if there is a new weely bar has created
bool IsWeeklyNewBar(bool first_call = false) {

   static bool result = false;
   if(!first_call)
      return result;

   //Print("first_call = "+first_call);
   static datetime previousBarTime = 0;
   datetime currentBarTime = iTime(mSymbol, PERIOD_W1, 0);
   result = false;

   if(currentBarTime != previousBarTime) {
      previousBarTime = currentBarTime;
      is_trade_allow = true;
      result = true;
   }

   return result;
}


// Check if there is a new monthly bar has created
bool IsMonthlyNewBar(bool first_call = false) {

   static bool result = false;
   if(!first_call)
      return result;

   //Print("first_call = "+first_call);
   static datetime previousBarTime = 0;
   datetime currentBarTime = iTime(mSymbol, PERIOD_MN1, 0);
   result = false;

   if(currentBarTime != previousBarTime) {
      startingBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      //Print("Monthly Account Balance: "+startingBalance);
      previousBarTime = currentBarTime;
      is_trade_allow = true;
      result = true;
   }

   return result;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsMarketOpen(string symbol, datetime time) {

   static string lastSymbol = "";
   static bool isOpen = false;
   static datetime sessionStart = 0, sessionEnd = 0;

   if(lastSymbol == symbol && sessionEnd > sessionStart) {
      if((isOpen && time >= sessionStart && time <= sessionEnd) ||
         (!isOpen && time > sessionStart && time < sessionEnd))
         return isOpen;
      }

   lastSymbol = symbol;

   MqlDateTime mTime;
   TimeToStruct(time, mTime);
   datetime seconds = mTime.hour*3600+mTime.min*60+mTime.sec;

   MqlDateTime mTime2 = mTime;
   mTime2.hour = 0;
   mTime2.min = 0;
   mTime2.sec = 0;

   datetime dayStart = StructToTime(mTime2);
   datetime dayEnd = dayStart + 86400;

   datetime fromTime, toTime;
   sessionStart = dayStart;
   sessionEnd = dayEnd;

   for(int session=0; ; session++) {
      if(!SymbolInfoSessionTrade(symbol, (ENUM_DAY_OF_WEEK)mTime.day_of_week, session, fromTime, toTime)) {
         sessionEnd = dayEnd;
         isOpen = false;
         return isOpen;
      }

      if(seconds < fromTime) {    // Not inside a session
         sessionEnd = dayStart + fromTime;
         isOpen = false;
         return isOpen;
      }

      if(seconds > toTime) {      // maybe a later session
         sessionStart = dayStart + toTime;
         continue;
      }


      // At this point must be inside a session
      sessionStart = dayStart + fromTime;
      sessionEnd = dayStart + toTime;
      isOpen = true;
      return isOpen;
   }

   return false;
}


// Points To Double Conversion
//double PointsToDouble(int points)                   {  return(points*Point());  }
//double PointsToDouble(int points, string symbol)    {  return(points*SymbolInfoDouble(symbol, SYMBOL_POINT));  }

//int DoubleToPoints(double value)                   {  return((int)(value/Point()));  }


//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---

  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void  OnTradeTransaction(const MqlTradeTransaction&    trans,
                         const MqlTradeRequest&        request,
                         const MqlTradeResult&         result) {

   if(trans.type == TRADE_TRANSACTION_ORDER_ADD) {
      COrderInfo order;
      if(order.Select(trans.order)) {
         if(order.Magic() == Magic) {
            if(order.OrderType() == ORDER_TYPE_BUY_STOP && AllowPendingTrades) {
               buyPos = order.Ticket();
            }
            else
            if(order.OrderType() == ORDER_TYPE_SELL_STOP && AllowPendingTrades) {
               sellPos = order.Ticket();
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
//---

  }
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
  {
//---

  }
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
  {
//---

  }


//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---

  }
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
bool is_button_hovered=false;
string prev_button_name = "";
void  OnChartEvent(
   const int       id,       // event ID 
   const long&     lparam,   // long type event parameter
   const double&   dparam,   // double type event parameter
   const string&   sparam    // string type event parameter
   ) {
   //updateAccountOverview();
   if(id == CHARTEVENT_OBJECT_CLICK && StringLen(sparam) > 0) {
      //Print("Clicked on object: " + sparam);
      //return;
      if(sparam == PREFIX+"ButtonMenu") {
         if(visibleUserInterface) {
            visibleUserInterface = false;
            ButtonTextChange(0, PREFIX+"ButtonMenu", "▼");
            toggleUserInterface(false);
         }   
         else { 
            visibleUserInterface = true;
            ButtonTextChange(0, PREFIX+"ButtonMenu", "▲");
            toggleUserInterface(true);
         } 
         ObjectSetInteger(0, PREFIX+"ButtonMenu", OBJPROP_STATE, false);
      }
      else 
      if(sparam == PREFIX+"Button16") {
         // math_flag = 0, means subtraction
         // math_flag = 1, means addition
         ChangeLotSize(0);
      }
      else 
      if(sparam == PREFIX+"Button18") {
         // math_flag = 0, means subtraction
         // math_flag = 1, means addition
         ChangeLotSize(1);
      }
      else 
      if(sparam == PREFIX+"Button19") {
         // Open BUY Order
         //Print("Open Buy Order");
         
         string text = ObjectGetString(0, PREFIX+"EditTextBox", OBJPROP_TEXT, 0);
         double lots  = StringToDouble(text);
         if(lots <= 0.0) {
            Print("Please increase lots size");
            return;
         }
         
         double entry = NormalizeDouble(SymbolInfoDouble(mSymbol, SYMBOL_ASK), _Digits);
         if(entry > 0 && positionTotal < MaxRunningTrade)
            executeBuy(entry, 0, 0.0);
      }
      else 
      if(sparam == PREFIX+"Button20") {
         // Open SELL Order
         //Print("Open Sell Order");
         
         string text = ObjectGetString(0, PREFIX+"EditTextBox", OBJPROP_TEXT, 0);
         double lots  = StringToDouble(text);
         if(lots <= 0.0) {
            Print("Please increase lots size");
            return;
         }
         
         double entry = NormalizeDouble(SymbolInfoDouble(mSymbol, SYMBOL_BID), _Digits);
         if(entry > 0 && positionTotal < MaxRunningTrade)
            executeSell(entry, 0, 0.0);
      }
      else 
      if(sparam == PREFIX+"Button21") {
         // Close All Profit Orders
         //Print("Close All Profit");
         closeAllProfitPositions();
      }
      else 
      if(sparam == PREFIX+"Button22") {
         // Close All Loss Orders
         //Print("Close All Loss");
         closeAllLossPositions();
      }
      else 
      if(sparam == PREFIX+"Button23") {
         // Close All Pending Orders
         //Print("Close All Pending");
         closeAllPendingPositions();
      }
      else 
      if(sparam == PREFIX+"Button24") {
         // Close This EAs All Orders
         //Print("Close All Orders");
         //closeAllPositions();
         closeExpertAdvisorAllPositions();
      }
      else 
      if(sparam == PREFIX+"Button28") {
         // User selected market trend:
         userSelectedMarketTrend("Auto");
      }
      else 
      if(sparam == PREFIX+"Button29") {
         // User selected market trend:
         userSelectedMarketTrend("Up");
      }
      else 
      if(sparam == PREFIX+"Button30") {
         // User selected market trend:
         userSelectedMarketTrend("Down");
      }
      else 
      if(sparam == PREFIX+"Button31") {
         // User selected market trend:
         userSelectedMarketTrend("Ranging");
      }
      else {
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      }
   }
   if(id == CHARTEVENT_MOUSE_MOVE) {
      string objectName = ButtonZone(lparam, dparam);
      //Print("Mouse over on object: " + objectName);
      if(StringLen(objectName) <= 0) return;
      
      if(!is_button_hovered) {
         ObjectSetInteger(0, objectName, OBJPROP_STATE, true);
         //Print("Mouse over on object: " + objectName);
         is_button_hovered = true;
      }
      if(StringLen(prev_button_name) > 0 && prev_button_name != objectName && is_button_hovered) {
         ObjectSetInteger(0, prev_button_name, OBJPROP_STATE, false);
         //Print("Mouse out from object: " + prev_button_name);
         is_button_hovered = false;
      }
      prev_button_name = objectName;
   }
   //Print(id, " ", lparam, " ", dparam, " ", sparam);   
   ChartRedraw();
}


void updateAccountOverview() {
   /*
   printf("ACCOUNT_BALANCE = %G", AccountInfoDouble(ACCOUNT_BALANCE));
   printf("ACCOUNT_CREDIT = %G",AccountInfoDouble(ACCOUNT_CREDIT));
   printf("ACCOUNT_PROFIT = %G",AccountInfoDouble(ACCOUNT_PROFIT));
   printf("ACCOUNT_EQUITY = %G",AccountInfoDouble(ACCOUNT_EQUITY));
   printf("ACCOUNT_MARGIN = %G",AccountInfoDouble(ACCOUNT_MARGIN));
   printf("ACCOUNT_MARGIN_FREE = %G",AccountInfoDouble(ACCOUNT_MARGIN_FREE));
   printf("ACCOUNT_MARGIN_LEVEL = %G",AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
   printf("ACCOUNT_MARGIN_SO_CALL = %G",AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL));
   printf("ACCOUNT_MARGIN_SO_SO = %G",AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));
   Print("The name of the broker = ",AccountInfoString(ACCOUNT_COMPANY));
   Print("Deposit currency = ",AccountInfoString(ACCOUNT_CURRENCY));
   Print("Client name = ",AccountInfoString(ACCOUNT_NAME));
   Print("The name of the trade server = ",AccountInfoString(ACCOUNT_SERVER));

   string growth        =  ObjectGetString(0, PREFIX+"Label2", OBJPROP_TEXT, 0);
   string profit        =  ObjectGetString(0, PREFIX+"Label4", OBJPROP_TEXT, 0);
   string equity        =  ObjectGetString(0, PREFIX+"Label6", OBJPROP_TEXT, 0);
   string balance       =  ObjectGetString(0, PREFIX+"Label8", OBJPROP_TEXT, 0);
   string maxDrawdown   =  ObjectGetString(0, PREFIX+"Label10", OBJPROP_TEXT, 0);
   string dailyDrawdown =  ObjectGetString(0, PREFIX+"Label12", OBJPROP_TEXT, 0);
   */
   
   //Print("ACCOUNT_PROFIT: " + AccountInfoDouble(ACCOUNT_PROFIT));
   
   // Growth
   if(ObjectFind(0, PREFIX+"Label3") >= 0) {
      //printf("ACCOUNT_BALANCE = %G", AccountInfoDouble(ACCOUNT_BALANCE));
      //ObjectSetString(0, PREFIX+"Label3", OBJPROP_TEXT, AccountInfoDouble(ACCOUNT_BALANCE) 
      //                + " " + AccountInfoString(ACCOUNT_CURRENCY));
      //Print("Account profit: "+getSymbolProfit(mSymbol));
   }
   
   // Profit
   if(ObjectFind(0, PREFIX+"Label5") >= 0) {
      ObjectSetString(0, PREFIX+"Label5", OBJPROP_TEXT, DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT), 2) 
                      + " " + AccountInfoString(ACCOUNT_CURRENCY));
   }
   
   // Equity
   if(ObjectFind(0, PREFIX+"Label7") >= 0) {
      ObjectSetString(0, PREFIX+"Label7", OBJPROP_TEXT, DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2) 
                      + " " + AccountInfoString(ACCOUNT_CURRENCY));
   }
   
   // Balance
   if(ObjectFind(0, PREFIX+"Label9") >= 0) {
      ObjectSetString(0, PREFIX+"Label9", OBJPROP_TEXT, DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) 
                      + " " + AccountInfoString(ACCOUNT_CURRENCY));
   }
   
   // Max Drawdown
   if(ObjectFind(0, PREFIX+"Label11") >= 0) {
      if(maxDrawdownPercent <= 0)
         ObjectSetString(0, PREFIX+"Label13", OBJPROP_TEXT, DoubleToString(0.00, 2) + "%");
      else 
         ObjectSetString(0, PREFIX+"Label13", OBJPROP_TEXT, DoubleToString(maxDrawdownPercent, 2) + "%");   
   }
   
   // Daily Drawdown
   if(ObjectFind(0, PREFIX+"Label13") >= 0) {
      if(drawdownPercent <= 0)
         ObjectSetString(0, PREFIX+"Label13", OBJPROP_TEXT, DoubleToString(0.00, 2) + "%");
      else 
         ObjectSetString(0, PREFIX+"Label13", OBJPROP_TEXT, DoubleToString(drawdownPercent, 2) + "%");   
   }   
   //Print("growth: "+growth+", profit: "+profit+", equity: "+equity+", balance: "+balance+", Max DD:"+maxDrawdown+", Daily DD: "+dailyDrawdown);
}


void userSelectedMarketTrend(string marketTrend) {
   
   if(marketTrend == "Auto") selectedMarketTrend = 0;
   else if(marketTrend == "Up")  selectedMarketTrend = 1;
   else if(marketTrend == "Down")   selectedMarketTrend = 2;
   else if(marketTrend == "Ranging")   selectedMarketTrend = 3;
   
   ObjectSetString(0, PREFIX+"Label27", OBJPROP_TEXT, marketTrend);
   
}

string prevObjName = "";
long Prev_X_Start=0, Prev_X_End=0, Prev_Y_Start=0, Prev_Y_End=0;
string ButtonZone(long lparam, double dparam) {

   if( lparam >= Prev_X_Start && lparam <= Prev_X_End && dparam >= Prev_Y_Start && dparam <= Prev_Y_End ) return(prevObjName);

   long ChartX = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   long ChartY = ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   for( int i=ObjectsTotal(0, 0, OBJ_BUTTON); i>=0; i-- ) {
      string name = ObjectName(0, i);
      long X_Start=0, X_Size=0, X_End=0, Y_Start=0, Y_Size=0, Y_End=0;
      if(StringFind(name, PREFIX+"Button") < 0) continue;
      X_Size = (int)ObjectGetInteger(0,name,OBJPROP_XSIZE);
      Y_Size = (int)ObjectGetInteger(0,name,OBJPROP_YSIZE);
      switch((int)ObjectGetInteger(0,name,OBJPROP_CORNER)) {
         case CORNER_LEFT_UPPER : { 
            X_Start = (long)ObjectGetInteger(0,name,OBJPROP_XDISTANCE);
            Y_Start = (long)ObjectGetInteger(0,name,OBJPROP_YDISTANCE);
            break;
         }
         case CORNER_RIGHT_UPPER : { 
            X_Start = ChartX-(long)ObjectGetInteger(0,name,OBJPROP_XDISTANCE);
            Y_Start = (long)ObjectGetInteger(0,name,OBJPROP_YDISTANCE);
            break;
         }
         case CORNER_LEFT_LOWER : { 
            X_Start = (long)ObjectGetInteger(0,name,OBJPROP_XDISTANCE);
            Y_Start = ChartY-(long)ObjectGetInteger(0,name,OBJPROP_YDISTANCE);
            break;
         }
         case CORNER_RIGHT_LOWER : { 
            X_Start = ChartX-(long)ObjectGetInteger(0,name,OBJPROP_XDISTANCE);
            Y_Start = ChartY-(long)ObjectGetInteger(0,name,OBJPROP_YDISTANCE);
            break;
         }
      }
      X_End   = X_Start + X_Size;
      Y_End   = Y_Start + Y_Size;
      if( lparam >= X_Start && lparam <= X_End && dparam >= Y_Start && dparam <= Y_End ) {
         Prev_X_Start=X_Start; Prev_X_End=X_End; Prev_Y_Start=Y_Start; Prev_Y_End=Y_End;
         prevObjName = name;
         return(name);
      }   
   }
   return("");
}


void ChangeLotSize(int math_flag) {
   string text = ObjectGetString(0, PREFIX+"EditTextBox", OBJPROP_TEXT, 0);
   double lot  = StringToDouble(text);
   if(lot >= 0.00) {
      if(math_flag) lot += 0.01;
      else          lot -= 0.01; 
      if(lot < 0.0) return;
      text = DoubleToString(lot, 2);
      EditTextChange(0, PREFIX+"EditTextBox", text);
   }
}


bool EditTextChange(const long   chart_ID=0,    // chart's ID
                      const string name="EditTextBox", // button name
                      const string text="Text")   // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetString(chart_ID, name, OBJPROP_TEXT, text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
}


bool ButtonTextChange(const long   chart_ID=0,    // chart's ID
                      const string name="Button", // button name
                      const string text="Text")   // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetString(chart_ID, name, OBJPROP_TEXT, text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
}


void toggleUserInterface(bool flag) {
   for(int i=ObjectsTotal(0, 0, -1)-1; i>=0; i--) {
      string objName = ObjectName(0, i, 0, -1); 
      //Print(__FUNCTION__, ", objName: "+ objName + ", find: " + StringFind(objName, PREFIX)); 
      //if(StringFind(objName, PREFIX) < 0 || objName == PREFIX+"ButtonMenu") continue;
      if(StringFind(objName, PREFIX) < 0) continue;
      if(flag) {
         ObjectSetInteger(0, objName, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
      }   
      else {
         if(objName == PREFIX+"ButtonMenu") continue;
         ObjectSetInteger(0, objName, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
      }
   }
   //ObjectSetInteger(0, PREFIX+"ButtonMenu", OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   
}

//+------------------------------------------------------------------+
//| Create User Interface On Chart                                   |
//+------------------------------------------------------------------+
long z_index = 1000;
void createUserInterface() {
   
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   
   string font1 = "Arial",
          font2 = "Arial Bold";
   int x = 0, y = 20, i = 0;
   
   // Create Rectangle Background 
   createRectangle(PREFIX+"Rect", x, y, 290, 670, clrWhiteSmoke, 2, CORNER_LEFT_UPPER, z_index+i);
   
   
   // Create Labels
   // --------- Account Overview ---------
   x = 10; y += 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "------------  Account Overview  -----------", font2, 12, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   
   
   x = 10; y += 20 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "Growth:", font2, 11, clrBlack, CORNER_LEFT_UPPER, z_index+i); 
   x += 120 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y+2, "0.0%", font2, 11, clrMediumBlue, CORNER_LEFT_UPPER, z_index+i);
   
   
   x = 10; y += 15 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "Profit:", font2, 11, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   x += 120 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y+2, "0.0 USD", font2, 11, clrMediumBlue, CORNER_LEFT_UPPER, z_index+i);
   
   
   x = 10; y += 15 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "Equity:", font2, 11, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   x += 120 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y+2, "0.0 USD", font2, 11, clrMediumBlue, CORNER_LEFT_UPPER, z_index+i);
   
   
   x = 10; y += 15 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "Balance:", font2, 11, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   x += 120 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y+2, "0.0 USD", font2, 11, clrMediumBlue, CORNER_LEFT_UPPER, z_index+i);
   
   
   x = 10; y += 15 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "Max DD:", font2, 11, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   x += 120 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "0.0%", font2, 11, clrRed, CORNER_LEFT_UPPER, z_index+i);
   
   
   x = 10; y += 15 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "Daily DD:", font2, 11, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   x += 120 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "0.0%", font2, 11, clrRed, CORNER_LEFT_UPPER, z_index+i);
   
   
   
   
   // --------- Trade Management ---------
   x = 10; y += 25 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "-----------  Trade Management  -----------", font2, 12, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   
   x = 10; y += 20 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y+3, "Enter Lot Size:", font1, 11, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   x += 105; i++;
   createButton(PREFIX+"Button"+IntegerToString(i), x, y, 30, 28, "-", font1, 18, clrWhite, clrGreen, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   x += 30; i++;
   createEditTextBox(PREFIX+"EditTextBox", x, y, 100, 28, "0.01", font2, 11, clrBlack, clrWhite, CORNER_LEFT_UPPER, z_index+i);
   x += 100; i++;
   createButton(PREFIX+"Button"+IntegerToString(i), x, y, 30, 28, "+", font1, 18, clrWhite, clrGreen, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   
   
   // Create Buttons
   // clrBlack, clrYellowGreen
   x = 10; y += 35 + 10; i++;
   createButton(PREFIX+"Button"+IntegerToString(i), x, y, 135, 30, "Open Buy", font1, 11, clrWhite, clrRoyalBlue, clrWhite, CORNER_LEFT_UPPER, z_index+i);
   x += 130 + 10; i++;
   createButton(PREFIX+"Button"+IntegerToString(i), x, y, 130, 30, "Open Sell", font1, 11, clrWhite, clrOrangeRed, clrWhite, CORNER_LEFT_UPPER, z_index+i);
   
   x = 10; y += 28 + 5; i++;
   createButton(PREFIX+"Button"+IntegerToString(i), x, y, 135, 30, "Close All Profit", font1, 11, clrWhite, clrRoyalBlue, clrWhite, CORNER_LEFT_UPPER, z_index+i);
   x += 130 + 10; i++;
   createButton(PREFIX+"Button"+IntegerToString(i), x, y, 130, 30, "Close All Loss", font1, 11, clrWhite, clrOrangeRed, clrWhite, CORNER_LEFT_UPPER, z_index+i);
   
   
   x = 10; y += 28 + 5; i++;
   createButton(PREFIX+"Button"+IntegerToString(i), x, y, 135, 30, "Close All Pending", font1, 11, clrWhite, clrRoyalBlue, clrWhite, CORNER_LEFT_UPPER, z_index+i);
   x += 130 + 10; i++;
   createButton(PREFIX+"Button"+IntegerToString(i), x, y, 130, 30, "Close All", font1, 11, clrWhite, clrOrangeRed, clrWhite, CORNER_LEFT_UPPER, z_index+i);
 
   
   
   
   // Create Labels
   // --- Market Technical Overview ---
   x = 10; y += 40 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "-----  Market Technical Overview  -----", font2, 12, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   
   
   x = 10; y += 20 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "User selected market trend:", font1, 11, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   x = 195; i++;
   
   string marketTrend = "";
   if(selectedMarketTrend == AUTO) marketTrend = "Auto";
   else if(selectedMarketTrend == UP_TREND) marketTrend = "Up";
   else if(selectedMarketTrend == DOWN_TREND) marketTrend = "Down";
   else if(selectedMarketTrend == RANGING) marketTrend = "Ranging";
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, marketTrend, font2, 11, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   
   x = 10; y += 15 + 10; i++;
   createButton(PREFIX+"Button"+IntegerToString(i), x, y, 60, 25, "Auto", font1, 11, clrWhite, clrRoyalBlue, clrWhite, CORNER_LEFT_UPPER, z_index+i);
   x += 60 + 5; i++;
   createButton(PREFIX+"Button"+IntegerToString(i), x, y, 60, 25, "Up", font1, 11, clrWhite, clrRoyalBlue, clrWhite, CORNER_LEFT_UPPER, z_index+i);
   x += 60 + 5; i++;
   createButton(PREFIX+"Button"+IntegerToString(i), x, y, 60, 25, "Down", font1, 11, clrWhite, clrRoyalBlue, clrWhite, CORNER_LEFT_UPPER, z_index+i);
   x += 60 + 5; i++;
   createButton(PREFIX+"Button"+IntegerToString(i), x, y, 70, 25, "Ranging", font1, 11, clrWhite, clrRoyalBlue, clrWhite, CORNER_LEFT_UPPER, z_index+i);
   
   
   
   x = 10; y += 30 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "Market Trend, Candle Formation:", font1, 11, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   
   x = 10; y += 15 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "• PERIOD_MN1:", font1, 9, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   x += 85 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "Uptrend", font1, 9, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   
   
   x = 10; y += 10 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "• PERIOD_W1:", font1, 9, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   x += 85 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "Uptrend", font1, 9, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   
   
   x = 10; y += 10 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "• PERIOD_D1:", font1, 9, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   x += 85 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "Uptrend", font1, 9, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   
   
   x = 10; y += 10 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "• PERIOD_H4:", font1, 9, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   x += 85 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "Uptrend", font1, 9, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   
   
   
   x = 10; y += 10 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "• PERIOD_H1:", font1, 9, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   x += 85 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "Uptrend", font1, 9, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   
   
   
   x = 10; y += 10 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "• PERIOD_M15:", font1, 9, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   x += 85 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "Uptrend", font1, 9, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   
   
   x = 10; y += 15 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "Current Trade Signal:", font2, 10, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   x += 135 + 10; i++;
   createLabel(PREFIX+"Label"+IntegerToString(i), x, y, "Buy", font2, 10, clrBlack, CORNER_LEFT_UPPER, z_index+i);
   
   
   x = 5; y = 35 + 5; i++;
   createButton(PREFIX+"ButtonMenu", x, y, 40, 35, "▲", font1, 14, clrWhite, clrForestGreen, clrBlack, CORNER_LEFT_LOWER, z_index+i);
   
   /*BitmapLabelCreate(const long              chart_ID=0,               // chart's ID
                       const string            name="BmpLabel",          // label name
                       const int               sub_window=0,             // subwindow index
                       const int               x=0,                      // X coordinate
                       const int               y=0,                      // Y coordinate
                       const string            file_on="",               // image in On mode
                       const string            file_off="",              // image in Off mode
                       const int               width=0,                  // visibility scope X coordinate
                       const int               height=0,                 // visibility scope Y coordinate
                       const int               x_offset=10,              // visibility scope shift by X axis
                       const int               y_offset=10,              // visibility scope shift by Y axis
                       const bool              state=false,              // pressed/released
                       const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                       const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type 
                       const color             clr=clrRed,               // border color when highlighted
                       const ENUM_LINE_STYLE   style=STYLE_SOLID,        // line style when highlighted
                       const int               point_width=1,            // move point size
                       const bool              back=false,               // in the background
                       const bool              selection=false,          // highlight to move
                       const bool              hidden=true,              // hidden in the object list
                       const long              z_order=0)
   
   
   BitmapLabelCreate(0, "BmpLabel", 0, 800, 300, "\\Images\\dollar.bmp", "\\Images\\dollar.bmp", 100, 50, 10, 10, 
                     false, CORNER_LEFT_UPPER, ANCHOR_LEFT_UPPER, clrRed, STYLE_SOLID, 1, false, false, false, 0);
   */
                      
   visibleUserInterface = true;
   
   
   ChartRedraw();
   
}

bool createRectangle(string objName, int x, int y, int width, int height, 
                     color clrBk, int line_width, ENUM_BASE_CORNER corner, long z_order=0) {

   //--- reset the error value
   ResetLastError();
   //--- create a rectangle label
   if(!ObjectCreate(0, objName, OBJ_RECTANGLE_LABEL, 0, 0, 0)) {
      Print(__FUNCTION__, ": failed to create a rectangle label! Error code = ",GetLastError());
      return(false);
   }
   
   
   //--- set label coordinates
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
   //--- set label size
   ObjectSetInteger(0, objName, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, objName, OBJPROP_YSIZE, height);
   //--- set background color
   ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, clrBk);
   //--- set border type
   ObjectSetInteger(0, objName, OBJPROP_BORDER_TYPE, BORDER_SUNKEN);
   //--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   //--- set flat border color (in Flat mode)
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clrBlack);
   //--- set flat border line style
   ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
   //--- set flat border width
   ObjectSetInteger(0, objName, OBJPROP_WIDTH, line_width);
   //--- display in the foreground (false) or background (true)
   ObjectSetInteger(0, objName, OBJPROP_BACK, UserInterfaceTransparent);
   //--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTED, false);
   //--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(0, objName, OBJPROP_HIDDEN, false);
   //--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, z_order);
  
   
   return true;
}


bool createButton(string objName, int x, int y, int width, int height, string text, 
                  string font, int font_size, color clrTxt, color clrBk, color clrBorder, 
                  ENUM_BASE_CORNER corner, const long z_order=0) {

   ResetLastError();
   if(!ObjectCreate(0, objName, OBJ_BUTTON, 0, 0, 0)) {
      Print(__FUNCTION__, ": failed to create the button! Error code = ",GetLastError());
      return(false);
   }

   //--- set button coordinates
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
   //--- set button size
   ObjectSetInteger(0, objName, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, objName, OBJPROP_YSIZE, height);
   //--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   //--- set the text
   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   //--- set text font
   ObjectSetString(0, objName, OBJPROP_FONT, font);
   //--- set font size
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, font_size);
   //--- set text color
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clrTxt);
   //--- set background color
   ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, clrBk);
   //--- set border color
   ObjectSetInteger(0, objName, OBJPROP_BORDER_COLOR, clrBorder);
   //--- display in the foreground (false) or background (true)
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
   //--- set button state
   ObjectSetInteger(0, objName, OBJPROP_STATE, false);
   //--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTED, false);
   //--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(0, objName, OBJPROP_HIDDEN, true);
   //--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, z_order);
   
   return true;
}



bool createLabel(string objName, int x, int y, string text, 
                 string font, int font_size, color clrTxt, 
                 ENUM_BASE_CORNER corner, long z_order=0) {

   ResetLastError();
   if(!ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0)) {
      Print(__FUNCTION__, ": failed to create text label! Error code = ",GetLastError());
      return(false);
   }

   //--- set button coordinates
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
   //--- set button size
   //ObjectSetInteger(0, objName, OBJPROP_XSIZE, width);
   //ObjectSetInteger(0, objName, OBJPROP_YSIZE, height);
   //--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   //--- set the text
   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   //--- set text font
   ObjectSetString(0, objName, OBJPROP_FONT, font);
   //--- set font size
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, font_size);
   //--- set the slope angle of the text
   ObjectSetDouble(0, objName, OBJPROP_ANGLE, 0);
   //--- set anchor type
   ObjectSetInteger(0, objName, OBJPROP_ANCHOR, 0);
   //--- set text color
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clrTxt);
   //--- set background color
   //ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, clrBk);
   //--- set border color
   //ObjectSetInteger(0, objName, OBJPROP_BORDER_COLOR, clrBk);
   //--- display in the foreground (false) or background (true)
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
   //--- set button state
   ObjectSetInteger(0, objName, OBJPROP_STATE, false);
   //--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTED, false);
   //--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(0, objName, OBJPROP_HIDDEN, false);
   //--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, z_order);
   
   return true;
}



bool createEditTextBox(string objName, int x, int y, int width, int height, string text, 
                       string font, int font_size, color clrTxt, color clrBk, 
                       ENUM_BASE_CORNER corner, long z_order=0) {

   ResetLastError();
   if(!ObjectCreate(0, objName, OBJ_EDIT, 0, 0, 0)) {
      Print(__FUNCTION__, ": failed to create \"Edit\" object! Error code = ",GetLastError());
      return(false);
   }

   //--- set button coordinates
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
   //--- set button size
   ObjectSetInteger(0, objName, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, objName, OBJPROP_YSIZE, height);
   //--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   //--- set the text
   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   //--- set text font
   ObjectSetString(0, objName, OBJPROP_FONT, font);
   //--- set font size
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, font_size);
   //--- set the type of text alignment in the object
   ObjectSetInteger(0, objName, OBJPROP_ALIGN, ALIGN_CENTER);
   //--- enable (true) or cancel (false) read-only mode
   ObjectSetInteger(0, objName, OBJPROP_READONLY, false);
   //--- set text color
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clrTxt);
   //--- set background color
   ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, clrBk);
   //--- set border color
   ObjectSetInteger(0, objName, OBJPROP_BORDER_COLOR, clrBlack);
   //--- display in the foreground (false) or background (true)
   ObjectSetInteger(0, objName, OBJPROP_BACK, false);
   //--- set button state
   //ObjectSetInteger(0, objName, OBJPROP_STATE, false);
   //--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_SELECTED, false);
   //--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(0, objName, OBJPROP_HIDDEN, false);
   //--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(0, objName, OBJPROP_ZORDER, z_order);
   
   return true;
}



bool BitmapLabelCreate(const long              chart_ID=0,               // chart's ID
                       const string            name="BmpLabel",          // label name
                       const int               sub_window=0,             // subwindow index
                       const int               x=0,                      // X coordinate
                       const int               y=0,                      // Y coordinate
                       const string            file_on="",               // image in On mode
                       const string            file_off="",              // image in Off mode
                       const int               width=0,                  // visibility scope X coordinate
                       const int               height=0,                 // visibility scope Y coordinate
                       const int               x_offset=10,              // visibility scope shift by X axis
                       const int               y_offset=10,              // visibility scope shift by Y axis
                       const bool              state=false,              // pressed/released
                       const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                       const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type 
                       const color             clr=clrRed,               // border color when highlighted
                       const ENUM_LINE_STYLE   style=STYLE_SOLID,        // line style when highlighted
                       const int               point_width=1,            // move point size
                       const bool              back=false,               // in the background
                       const bool              selection=false,          // highlight to move
                       const bool              hidden=true,              // hidden in the object list
                       const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create a bitmap label
   if(!ObjectCreate(chart_ID,name,OBJ_BITMAP_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create \"Bitmap Label\" object! Error code = ",GetLastError());
      return(false);
     }
//--- set the images for On and Off modes
   if(!ObjectSetString(chart_ID,name,OBJPROP_BMPFILE,0,file_on))
     {
      Print(__FUNCTION__,
            ": failed to load the image for On mode! Error code = ",GetLastError());
      return(false);
     }
   if(!ObjectSetString(chart_ID,name,OBJPROP_BMPFILE,1,file_off))
     {
      Print(__FUNCTION__,
            ": failed to load the image for Off mode! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set visibility scope for the image; if width or height values
//--- exceed the width and height (respectively) of a source image,
//--- it is not drawn; in the opposite case,
//--- only the part corresponding to these values is drawn
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the part of an image that is to be displayed in the visibility scope
//--- the default part is the upper left area of an image; the values allow
//--- performing a shift from this area displaying another part of the image
   ObjectSetInteger(chart_ID,name,OBJPROP_XOFFSET,x_offset);
   ObjectSetInteger(chart_ID,name,OBJPROP_YOFFSET,y_offset);
//--- define the label's status (pressed or released)
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set the border color when object highlighting mode is enabled
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the border line style when object highlighting mode is enabled
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set a size of the anchor point for moving an object
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,point_width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
