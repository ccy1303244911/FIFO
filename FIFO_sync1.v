module FIFO_sync
(
    input wire       clk,
    input wire       rst,
    input wire       wr_en,     //写使能
    input wire [7:0] din,       //数据输入
    input wire       rd_en,     //读使能
    output reg       valid,     //读有效
    output reg [7:0] dout,      //读出数据
    output reg       empty,     //空信号(实际的空满信号时序还有待优化，这里使用的其实是快空满信号)
    output reg       full       //满信号
    );
reg [7:0] FIFO[15:0] ;  //深度为16，位宽为8的储存空间
reg [3:0] wr_ptr;       //写指针
reg [3:0] rd_ptr;       //读指针
reg [7:0] din_reg;
reg [7:0] dout_reg;
reg almost_full;    //快满信号
reg almost_empty;   //快空信号

always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        din_reg<=0;    
    end
    else
        din_reg<=din;
end
//写指针wr_ptr
always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        wr_ptr<=0;    
    end    
    else if (wr_en&&!full) //使能来到且没写满的时候指针自加,写满时即自动暂停
    begin
        wr_ptr<=wr_ptr+1;    
    end
    else if (wr_ptr==15&&rd_en&&wr_en) //同时读写的时候写满清零
    begin
        wr_ptr<=0;    
    end
    else if (empty) 
    begin   
        wr_ptr<=wr_ptr;              //读指针撞到写指针的时候，为空状态，两指针均保持不变  
    end
end
//读指针rd_ptr
always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        rd_ptr<=0;    
    end    
    else if (rd_en&&!empty) //非空状态指针自加，空状态后指针自动暂停
    begin
        rd_ptr<=rd_ptr+1;    
    end
    else if (rd_ptr==15&&wr_en&&rd_en)  //同时读写状态下读空清零
    begin
        rd_ptr<=0;    
    end
    else if (full) 
    begin
        rd_ptr<=rd_ptr;         //写指针撞到读指针的时候，为满状态，读指针保持不变,等待wr_en到来写入数据
    end
end
//快空信号almost_empty
always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        almost_empty<=1;    
    end     //只读不写情况下，读指针若撞到写指针，为空状态，        
    else if ((wr_ptr==(rd_ptr+1))&&!wr_en&&rd_en)   
    begin
        almost_empty<=1;
    end
    else if (wr_en) 
    begin
        almost_empty<=0;    
    end
end
//快满信号almost_full
always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        almost_full<=0;    
    end    //只写不读状态下，写指针撞到读指针，为满状态
    else if (((((wr_ptr+1)==rd_ptr)&&rd_ptr)||(wr_ptr==14&&rd_ptr==0))&&!rd_en&&wr_en) 
    begin   //full:1-读指针rd_ptr不为0时写撞读，此时两指针可重合且保持  2-rd_ptr=0时，两指针不重合↓
        almost_full<=1;    //                                               ↑(指不将写指针清零，而是保持在最大值)
    end
    else if (rd_en) 
    begin
        almost_full<=0;    
    end
end
//实际空信号empty
always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        empty<=1;    
    end    
    else if (wr_ptr==rd_ptr&&!wr_en&&rd_en)    //读撞到写的时候为空
    begin
        empty<=1;    
    end
    else if (wr_en) 
    begin
        empty<=0;    
    end
end
//实际满信号full   
always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        full<=0;    
    end    
    else if ((((wr_ptr==rd_ptr)&&rd_ptr)||(wr_ptr==15&&rd_ptr==0))&&!rd_en&&wr_en)      //写即将撞到读的时候为满
    begin
        full<=1;    
    end
    else if (rd_en) 
    begin
        full<=0;    
    end
end

integer i;
always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin 
        for (i=0;i<=15;i=i+1) 
        begin
            FIFO[i]<=0;    
        end
    end    
    else if (wr_en&&!full) 
    begin
        FIFO[wr_ptr]<=din_reg;
    end
end

always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        dout_reg<=0;    
    end    
    else if (rd_en&!empty) 
    begin
        dout_reg<=FIFO[rd_ptr];    
    end
end

always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        valid<=0;    
    end    
    else if (rd_en&!empty) 
    begin
        valid<=1;    
    end
end

always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        dout<=0;
    end  
    else 
        dout<=dout_reg;
end

endmodule
