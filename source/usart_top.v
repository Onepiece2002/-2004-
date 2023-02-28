module usart_top(
   input 			sys_clk,			//50M系统时钟
	input 			sys_rst_n,			//系统复位
	input 			uart_rxd,			//接收数据线
   output wire 		uart_txd	//串口发送数据线
   );
parameter	UART_BPS=9600;			//波特率
parameter	CLK_FREQ=50_000_000;	//系统频率50M	
 
wire uart_en_w;
wire [7:0] uart_data_w; 
 
//例化发送模块
usart_tx#(
	.BPS		    (UART_BPS),
	.SYS_CLK_FRE	(CLK_FREQ))
u_uart_tx(
	.sys_clk		(sys_clk),
	.sys_rst_n	    (sys_rst_n),
	.uart_tx_en		(uart_en_w),
	.uart_data	    (uart_data_w),	
	.uart_txd	    (uart_txd)
);
//例化接收模块
usart_rx #(
	.BPS				(UART_BPS),
	.SYS_CLK_FRE		(CLK_FREQ))
u_uart_rx(
	.sys_clk			(sys_clk),
	.sys_rst_n		    (sys_rst_n),
	
	.uart_rxd		    (uart_rxd),	
	.uart_rx_done	    (uart_en_w),
	.uart_rx_data	    (uart_data_w)
);
endmodule