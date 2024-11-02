module FIFO_sync_tb;
reg clk;
reg rst;
reg wr_en; 
/*reg [7:0] din;*/   
reg rd_en; 
wire valid; 
wire [7:0] dout;  
wire empty; 
wire full;
reg [15:0] cnt;

parameter CLK_PERIOD=20;
always# (CLK_PERIOD/2) clk=~clk;

FIFO_sync FIFO_sync_u(
        .clk  (clk  )   ,
        .rst  (rst  )   ,
        .wr_en(wr_en)   , 
        .din  (cnt  )   ,   
        .rd_en(rd_en)   , 
        .valid(valid)   , 
        .dout (dout )   ,  
        .empty(empty)   , 
        .full (full )  
);

always @(posedge clk or posedge rst) 
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
    clk=0;
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
