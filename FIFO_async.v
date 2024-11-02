//设计一个深度为16，宽度为8位的异步FIFO
module FIFO_async#(parameter ADDR_WIDTH=3)(
input    wire       wclk,
input    wire       rclk,
input    wire       rst_n,
input    wire       wr_en,
input    wire       rd_en,
input    wire [7:0] wdata,
output    reg [7:0] rdata,
output    reg       full,
output    reg       empty
);
reg [7:0] FIFO[15:0];
reg [ADDR_WIDTH:0] wr_ptr;
reg [ADDR_WIDTH:0] rd_ptr;
reg [7:0] wdata_reg;
reg [7:0] rdata_reg;
reg [ADDR_WIDTH:0] wr_ptr_gray_d0;       //格雷码读写指针打拍寄存器
reg [ADDR_WIDTH:0] wr_ptr_gray_d1;
reg [ADDR_WIDTH:0] rd_ptr_gray_d0;
reg [ADDR_WIDTH:0] rd_ptr_gray_d1;
wire [ADDR_WIDTH:0] wr_ptr_gray;
wire [ADDR_WIDTH:0] rd_ptr_gray;

//二进制转格雷码
assign wr_ptr_gray=wr_ptr^(wr_ptr>>1);  //二进制移位异或得到格雷码
assign rd_ptr_gray=rd_ptr^(rd_ptr>>1);  //计数器指针转到格雷码方便同步时钟域
//写指针wr_ptr
always @(posedge wclk or posedge rst_n) 
begin
    if (!rst_n) 
    begin
        wr_ptr<=0;    
    end
    else if (wr_en&&!full) 
    begin
        wr_ptr<=wr_ptr+1;    
    end
end
//读指针rd_ptr
always @(posedge rclk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        rd_ptr<=0;    
    end    
    else if (rd_en&&!empty) 
    begin
        rd_ptr<=rd_ptr+1;
    end
end
//读写指针打拍同步
always @(posedge rclk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        wr_ptr_gray_d0<=0;
        wr_ptr_gray_d1<=0;    
    end    
    else 
        wr_ptr_gray_d0<=wr_ptr_gray;
        wr_ptr_gray_d1<=wr_ptr_gray_d0;
end
always @(posedge wclk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        rd_ptr_gray_d0<=0;
        rd_ptr_gray_d1<=0;    
    end    
    else
        rd_ptr_gray_d0<=rd_ptr_gray;
        rd_ptr_gray_d1<=rd_ptr_gray_d0;
end
//产生空满信号
always @(*) 
begin
    if (!rst_n) 
    begin
        full<=0;    
    end     //写指针在读指针前一位的时候位写满
    else if (wr_ptr_gray=={~rd_ptr_gray_d1[ADDR_WIDTH:ADDR_WIDTH-1],rd_ptr_gray_d1[ADDR_WIDTH-2:0]}) 
    begin   //根据格雷码，最高位相反，其他位相同即写在读前一位
        full<=1;    
    end
    else
        full<=0;
end

always @(*) 
begin
    if (!rst_n) 
    begin
        empty<=0;    
    end      //读指针与写指针重合的时候为读空  
    else if (rd_ptr_gray==wr_ptr_gray_d1) 
    begin
        empty<=1;    
    end
    else
        empty<=0;
end

//储存器输入输出
always @(posedge wclk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        wdata_reg<=0;    
    end    
    else 
        wdata_reg<=wdata;
end

integer i;
always @(posedge wclk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        for (i=0;i<=ADDR_WIDTH;i=i+1) 
        begin
            FIFO[i]<=0;    
        end
    end
    else if (wr_en&&!full) 
    begin
        FIFO[wr_ptr]<=wdata_reg;    
    end
end

always @(posedge rclk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        rdata_reg<=0;    
    end    
    else if (rd_en&&!empty) 
    begin
        rdata_reg<=FIFO[rd_ptr];    
    end
end

always @(posedge rclk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        rdata<=0;
    end 
    else
        rdata<=rdata_reg;
end

endmodule