
module color_bar(
input				  vpg_pclk     	,
input				  rst,
input				  vpg_de      	,
input				  vs,
input				  [7:0]in_rgb_r,
input  				  [7:0]in_rgb_g,
input 			   	  [7:0]in_rgb_b,
/*
input				  [1:0]x,
input  				  [1:0]y,
input  				  [1:0]w,
input  				  [1:0]h,
*/
output	wire      [7:0]	  out_rgb_r        	,//输出图像值
output	wire      [7:0]	  out_rgb_g        	,//输出图像值
output	wire      [7:0]	  out_rgb_b        	 //输出图像值
);
						
parameter       H_TOTAL = 2200 - 1  ;//一行总共需要计数的值
parameter       H_SYNC = 44 - 1     ;//行同步计数值
parameter       H_START = 190 - 1   ;//行图像数据有效开始计数值
parameter       H_END = 2110 - 1    ;//行图像数据有效结束计数值
parameter       V_TOTAL = 1125 - 1  ;//场总共需要计数的值
parameter       V_SYNC = 5 - 1      ;//场同步计数值
parameter       V_START = 41 - 1    ;//场图像数据有效开始计数值
parameter       V_END = 1121 - 1    ;//场图像数据有效结束计数值

//显示位置及大小

/*
parameter 		WI = w  + 1;
parameter 		HI = h  +  1;
parameter       SQUARE_X    =   (100 * x) ;//图像起始x
parameter       SQUARE_Y    =   (100 * y) ;//图像起始y
parameter       SCREEN_X    =   (100 * w);//图像宽度
parameter       SCREEN_Y    =   (100 * h);//图像高
*/

parameter       SQUARE_X    =   300 ;//图像起始x
parameter       SQUARE_Y    =   300  ;//图像起始y
parameter       SCREEN_X    =   10000 ; //图像宽度
parameter       SCREEN_Y    =   10000 ; //图像高

reg [12:0]	cnt_h;//行计数器
reg [12:0]	cnt_v;//场计数器
reg [7:0]   rgb_b;
reg [7:0]   rgb_g;
reg [7:0]   rgb_r;
wire de_valid;
reg de_delay;


 //行计数器
always @(posedge vpg_pclk ) begin
	if (rst==1'b1) begin
		cnt_h <= 'd0;
	end
	else if (vpg_de == 1'b1) begin//计数到最大值，清零
		
	 cnt_h <= cnt_h + 1'b1;
			
	end
	else begin
		cnt_h <= 1'b0;
	end
end

//场计数器
always @(posedge vpg_pclk ) begin
	if (rst==1'b1) begin
		de_delay <= 'd0;
	end    
    else begin
        de_delay <= vpg_de;
    end
end

assign de_valid = vpg_de&(!de_delay);


always @(posedge vpg_pclk ) begin
	if (rst==1'b1) begin
		cnt_v <= 'd0;
	end 
    else if(de_valid == 1 && vs == 1 )begin
       cnt_v <= cnt_v + 1'b1;
    end
    else if(de_valid == 0 && vs == 1 )begin
            cnt_v <= cnt_v;
    end
    else begin
        cnt_v <= 'd0;
    end
end
assign out_rgb_b = rgb_b;
assign out_rgb_g = rgb_g;
assign out_rgb_r = rgb_r;
//rgb
always @(posedge vpg_pclk ) begin
	if (rst==1'b1) begin
		rgb_r <=8'b0;
		rgb_g <=8'b0;
		rgb_b <=8'b0;
	end
	else if (cnt_v >= SQUARE_X && cnt_v < SCREEN_X && cnt_h >= SQUARE_Y && cnt_h < SCREEN_Y) begin
		rgb_r <= in_rgb_r;
		rgb_g <= in_rgb_g;
		rgb_b <= in_rgb_b;
	end
	else begin
		rgb_r <=8'b0;
		rgb_g <=8'b0;
		rgb_b <=8'b0;
	end
end
endmodule
