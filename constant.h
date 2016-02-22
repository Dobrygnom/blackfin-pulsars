
//#define TSCALE=                 0x3ffb;
//#define TCOUNT=                 0x3ffc;
//#define TPERIOD=                0x3ffd;
#define	System_Control_Reg=     0x3fff;

.extern   init_uart;          //{ UART initialize baudrate etc. }
.extern   out_char_ax1;       //{ UART output a character }
.extern   get_char_ax1;       //{ UART wait & get input character }
.extern   get_char_ax1_to;    //{ UART wait & get input char. with timeout } 
.extern   out_int_ar;         //{ UART wait & get input int with timeout }
.extern   get_int_ar_to;      //{ UART wait & get input int with timeout }
.extern   turn_rx_on;         //{ UART enable the rx section }
.extern   turn_rx_off;        //{ UART disable the rx section }
.extern   process_a_bit;      //{ UART timer interrupt routine for RX and TX } 

.extern   SEND_INT_ONLY;
.extern   SEND_WORD_ONLY;
.extern   GET_WORD;

.extern   Init_Buffers;
.extern   Prepare_To_Send;
.extern   Buf_Set_Index;
.extern   Buf_Save_Item;
.extern   Change_Buffers;
//{.extern   av_m;}

.extern   char_ready;         //{ UART input character ready }
.extern   flag_tx_ready;      //{ UART transmit is ready }
.extern   tx_c;
.extern   tx_2c;
.extern   Temp_Item;
.extern   CCD_LEN;
.extern   tMr1;
.extern   Nread;
.extern   tMr11;
.extern   Nread2;
.extern   tMr0;
.extern   Bsempl;
.extern   min_;
.extern   odd_shift;