
module top(
    input                       sys_clk,
    input                       rst_n,
    input                       hs,
    input                       vs,
    input                       de,
    input                       [7:0]in_rgb_r,
    input                       [7:0]in_rgb_g,
    input                       [7:0]in_rgb_b,
	input 						uart_rxd,			//接收数据线
    output wire 				uart_txd,	//串口发送数据线
	//hdmi output        
    output                      tmds_clk_p,
    output                      tmds_clk_n,
    output[2:0]                 tmds_data_p,       
    output[2:0]                 tmds_data_n        
);
//串口变量
parameter	UART_BPS=9600;			//波特率
parameter	CLK_FREQ=50_000_000;	//系统频率50M
wire [7:0]	rev_data;


//hdmi变量
wire                            video_clk;
wire                            video_clk5x;
/*
wire[7:0]                       video_r;
wire[7:0]                       video_g;
wire[7:0]                       video_b;
wire                            hs;
wire                            vs;
wire                            de;
*/
wire                            hdmi_hs;
wire                            hdmi_vs;
wire                            hdmi_de;
wire[7:0]                       hdmi_r;
wire[7:0]                       hdmi_g;
wire[7:0]                       hdmi_b;

//时钟约束
wire                             sys_clk_g;
wire                             video_clk_w;       
wire                             video_clk5x_w;
GTP_CLKBUFG sys_clkbufg
(
  .CLKOUT                    (sys_clk_g                ),
  .CLKIN                     (sys_clk                  )
);
GTP_CLKBUFG video_clk5xbufg
(
  .CLKOUT                    (video_clk5x               ),
  .CLKIN                     (video_clk5x_w             )
);
GTP_CLKBUFG video_clkbufg
(
  .CLKOUT                    (                     ),
  .CLKIN                     (video_clk_w               )
);

//中间变量
assign  hdmi_hs    = ~hs;
assign  hdmi_vs    = vs;
assign  hdmi_de    = ~de;

//assign  hdmi_r      = rgb_r;
//assign  hdmi_g      = rgb_g;
//assign  hdmi_b      = rgb_b;

color_bar hdmi_color_bar(
	.vpg_pclk(video_clk_w),
	.rst(1'b0     ),
	.vpg_de(hdmi_de    ),
	.vs(hdmi_vs),
	.in_rgb_r(in_rgb_r),
	.in_rgb_g(in_rgb_g),
	.in_rgb_b(in_rgb_b),
	/*
	.x(),
	.y(),
	.w(),
	.h(),
	*/
	.out_rgb_r(hdmi_r),
	.out_rgb_g(hdmi_g),
	.out_rgb_b(hdmi_b)
);

video_pll video_pll_m0
 (
    .pll_rst(1'b0),
    .clkin1(sys_clk_g),
    .pll_lock(),
    .clkout0(video_clk5x_w),
    .clkout1(video_clk_w));


dvi_encoder dvi_encoder_m0
 (
     .pixelclk      (video_clk_w          ),// system clock
     .pixelclk5x    (video_clk5x        ),// system clock x5
     .rstin         (~rst_n             ),// reset
     .blue_din      (hdmi_b            ),// Blue data in
     .green_din     (hdmi_g            ),// Green data in
     .red_din       (hdmi_r            ),// Red data in
     .hsync         (hdmi_hs           ),// hsync data
     .vsync         (hdmi_vs           ),// vsync data
     .de            (hdmi_de         ),// data enable
     .tmds_clk_p    (tmds_clk_p         ),
     .tmds_clk_n    (tmds_clk_n         ),
     .tmds_data_p   (tmds_data_p        ),//rgb
     .tmds_data_n   (tmds_data_n        ) //rgb
 );

assign rev_data = uart_rxd;
usart_top  #(
	.UART_BPS  (UART_BPS),
	.CLK_FREQ  (CLK_FREQ)
)
u_usart_top(
	.sys_clk		(sys_clk),
	.sys_rst_n		(sys_rst_n),
	.uart_rxd		(uart_rxd),
	.uart_txd		(uart_txd)
);
endmodule