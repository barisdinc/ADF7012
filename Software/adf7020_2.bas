'Device 18F24K20
Device 18F24K22
'Device 18F2550
Xtal 20

Config_Start
FOSC = HSHP ' Oscillator Selection HS
'OSCS = Off ' Osc. Switch Enable Disabled
PLLCFG = OFF
PRICLKEN = On

FCMEN = Off
IESO = OFF

PWRTEN = On ' Power-up Timer Enabled
'BOR = Off ' Brown-out Reset Disabled
BOREN = SBORDIS
BORV = 190 ' Brown-out Voltage 2.5V
WDTEN = Off ' Watchdog Timer Disabled
WDTPS = 128 ' Watchdog Postscaler 1:128
CCP2MX = PORTC1 ' CCP2 MUX Enable (RC1)
STVREN = OFF ' Stack Overflow Reset Disabled
LVP = Off ' Low Voltage ICSP Disabled
'DEBUG = Off ' Background Debugger Enable Disabled
MCLRE = INTMCLR

CP0 = Off ' Code Protection Block 0 Disabled
CP1 = Off ' Code Protection Block 1 Disabled
CPB = Off ' Boot Block Code Protection Disabled
CPD = Off ' Data EEPROM Code Protection Disabled
WRT0 = Off ' Write Protection Block 0 Disabled
WRT1 = Off ' Write Protection Block 1Disabled
WRTB = Off ' Boot Block Write Protection Disabled
WRTC = Off ' Configuration Register Write Protection Disabled
WRTD = Off ' Data EEPROM Write Protection Disabled
EBTR0 = Off ' Table Read Protection Block 0 Disabled
EBTR1 = Off ' Table Read Protection Block 1 Disabled
EBTRB = Off ' Boot Block Table Read Protection Disabled
Config_End
 
'MCLRE = EXTMCLR

All_Digital   = true
'portb_pullups = true

TRISA.0 = 1 'ADC_VIN
TRISA.5 = 1 'MUX
TRISB = 0 
TRISC = 0

Symbol GIE = INTCON.7           ' Global Interrupt Enable Bit 
Symbol TMR1_Val = 64536         ' Set the initial value of TMR1 
Symbol TMR1_mS = 1              ' Time period of TMR1 
Symbol Timer1 = TMR1L.Word      ' A special way of addressing both TMR1L and TMR1H with one register
Symbol TMR1_Enable = PIE1.0     ' TMR1 interrupt enable
Symbol TMR1_Overflow = PIR1.0   ' TMR1 overflow flag
Symbol TMR1_On = T1CON.0        ' Enables TMR1 to start incrementing 
Symbol PEIE = INTCON.6                  'Peripheral Interrupt Enable same as GIEL


Symbol LE   = PORTB.0
Symbol DAT  = PORTB.1
Symbol CLK  = PORTB.2
Symbol LED1 = PORTB.4
Symbol LED2 = PORTB.5

DelayMS 500
 
PEIE = 0 ' Peripheral Interrupts
T1CON.1 = 0 ' 1 = External clock from pin RC0/T1OSO/T1CKI (on the rising edge)  ' 0 = Internal clock (FOSC/4)  'TRISC.0 = 1 ' If External clock, then set clock as an input  'HPWM 1,128,32000 ' Set TMR1's External Source   T1CON.2 = 1 ' 1 = Do not synchronize external clock input  ' 0 = Synchronize external clock input  ' When T1CON.1 = 0;  ' this bit is ignored. Timer1 uses the internal clock when TMR1CS = 0. 
T1CON.4 = 0 ' 11 = 1:8 prescale value  T1CON.5 = 0 ' 10 = 1:4 prescale value  ' 01 = 1:2 prescale value  ' 00 = 1:1 prescale value  Timer1 = TMR1_Val
GIE = 0
 
 
GoTo PreMain
On_Interrupt GoTo InterruptSection


InterruptSection:
Context Save

 GIE = 0
 
 If TMR1_Overflow = 1 And TMR1_Enable = 1 Then
     TMR1_Enable = 0
     Timer1 = Timer1 + TMR1_Val
     TMR1_Enable = 1
     TMR1_Overflow = 0
'     mS = mS + TMR1_mS
 EndIf
 
GIE = 1

Context Restore

Dim Dataout As Word
Dim sayac As Byte

Dim frekans As Word

frekans = 563
Symbol N = frekans / 4
Symbol NFrac = (frekans // 4) * 496

Symbol Reg1H = 0*256+1*128+(N/4)
Symbol Reg1L = (N-4*(N/4))*64+(Nfrac*4)+1

PreMain:
Low PORTB


Main:
    DelayUS 10
    Low LE
	DelayUS 10
	Dataout = $0016  '$0415
	GoSub sendSPI
	Dataout = $2000   '$E000 'R0 register
	GoSub sendSPI
    DelayUS 10
    High LE


    DelayUS 10
    Low LE
	DelayUS 10
	Dataout = $0023 'Reg1H '$0024 '$005B
	GoSub sendSPI
	Dataout = $A001 'Reg1L '$4001 '$6001 'R1 register
	GoSub sendSPI
	GoSub sendSPI
    DelayUS 10
    High LE


    DelayUS 10
    Low LE
	DelayUS 10
	Dataout = $0000 '$0000
	GoSub sendSPI
	Dataout = $87E2 '$821A 'R2 register
	GoSub sendSPI
    DelayUS 10
    High LE
	
    DelayUS 10
    Low LE
	DelayUS 10
	Dataout = $0040 '$0045
	GoSub sendSPI	
	Dataout = $286f '$38FF 'R3 register
	GoSub sendSPI
    DelayUS 10
    High LE
    DelayUS 10
    Low LE

 

	'0x0045,0x40DF	//R3 Set (R-divider)
	'0x0045,0x30DF	//R3 Set (R-divider/2)
	'0x0045,0x38F7	//R3 Set (N-divider/2)
	'0x0045,0x28DF	//R3 Set (Analog Lock Det.)
	'0x0045,0x20DF	//R3 Set (Digital Lock Det.)

    '0x0045,0x38FF	//PA On
    '0x0045,0x38F7	//PA Off
   ' delayms 1000
'    DelayMS 1000
 '   DelayMS 1000
 '   DelayMS 1000

main2:

    Dim buyuk As Word '= $12       birer birer artacak
    Dim kucuk As Word '= $0001     dorder artacak

    For buyuk = $12 To $32
        DelayUS 10
        Low LE
    	DelayUS 10
    	Dataout = buyuk 'Reg1H '$0024 '$005B
    	GoSub sendSPI
    	Dataout = $A001 'Reg1L '$4001 '$6001 'R1 register
    	GoSub sendSPI
    	GoSub sendSPI
        DelayUS 10
        High LE
        
        DelayMS 500
    Next buyuk 
        Toggle LED2

    GoTo main2
    For frekans = 1 To  530 
        DelayUS 10
        Low LE
    	DelayUS 10
    	Dataout = Reg1H '$0020 '$005B
    	GoSub sendSPI
    	Dataout = Reg1L '$3001 '$6001 'R1 register
    	GoSub sendSPI
    	GoSub sendSPI
        DelayUS 10
        High LE
        DelayMS 1000
    Next frekans
     
    GoTo main2
    
    DelayMS 1
    GoTo main2
    DelayMS 1000
    DelayMS 1000
    DelayMS 1000
    Low LE
	DelayUS 10
	Dataout = $0045
	GoSub sendSPI	
	Dataout = $20F7 'R3 register
	GoSub sendSPI
    DelayUS 10
    High LE
    DelayUS 10
    Low LE
    
    DelayMS 1000
    DelayMS 1000
    DelayMS 1000
    Low LE
	DelayUS 10
	Dataout = $0045
	GoSub sendSPI	
	Dataout = $20FF 'R3 register
	GoSub sendSPI
    DelayUS 10
    High LE
    DelayUS 10
    Low LE
    
    
   
GoTo main2


sendSPI:

    For sayac = 1 To 16
        Low DAT
        Low CLK
'        If (Dataout.15 & %1000000000000000) = 1 Then High DAT
        If Dataout.15  = 1 Then High DAT
        Dataout = Dataout << 1
        DelayUS 10
        High CLK
        DelayUS 10
        Low CLK
        DelayUS 10
        Toggle LED1
    Next sayac


    Return
