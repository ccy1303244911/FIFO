module FIFO_async_tb;
reg wclk;
reg rclk;
reg rst;
reg wr_en;
reg rd_en;
reg [7:0] wdata;
wire [7:0] rdata;
wire full;
wire empty;
reg [15:0] cnt;

parameter WCLK_PERIOD=20;   //写时钟50Mhz
parameter RCLK_PERIOD=10;   //读时钟100Mhz
always# (WCLK_PERIOD/2) wclk=~wclk;
always# (RCLK_PERIOD/2) rclk=~rclk;

FIFO_async FIFO_async_u(
    .wclk (wclk )  ,
    .rclk (rclk )  ,
    .rst  (rst  )  ,
    .wr_en(wr_en)  ,
    .rd_en(rd_en)  ,
    .wdata(cnt)  ,
    .rdata(rdata)  ,
    .full (full )  ,
    .empty(empty)
);

always @(posedge wclk or posedge rst) 
begin
    if (rst) 
    begin
        cnt<=0;    
    end    
    else if (cnt==15) 
    begin
        cnt<=0;    
    end
    else 
        cnt<=cnt+1;
end

initial 
begin
    wclk=0;
    rclk=0;
    rst=1;
    wr_en=0;
    rd_en=0;
    #201    //200-4200ns
    rst=0;
    wr_en=1;
    #4000       //4200-8200ns
    wr_en=0;
    rd_en=1;
    #4000       //8200-12200ns
    wr_en=1;
    rd_en=0;
    #4000       //12200-16200ns
    rd_en=1;
    #4000       //16200-20200ns
    wr_en=0;
    rd_en=0;
end

endmodule


