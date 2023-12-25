`default_nettype none
`timescale 1ns/1ns

module tb();
    localparam [7:0]
        CMD_READ = 8'b00000011,
        CMD_WRITE = 8'b00000010,
        CMD_ENABLE = 8'b10000001,
        CMD_STREAM = 8'b10000010,
        CMD_DISABLE = 8'b10000011;
    
    localparam [7:0]
        REG_WORD_SIZE = 8'h00,
        REG_RESULT_MASK = 8'h01,
        REG_CHAR0 = 8'h08,
        REG_CHAR1 = 8'h09,
        REG_CHAR2 = 8'h0A,
        REG_CHAR3 = 8'h0B,
        REG_CHAR4 = 8'h0C,
        REG_CHAR5 = 8'h0D,
        REG_CHAR6 = 8'h0E,
        REG_CHAR7 = 8'h0F,
        REG_MASK0 = 8'h10,
        REG_MASK1 = 8'h11,
        REG_MASK2 = 8'h12,
        REG_MASK3 = 8'h13,
        REG_MASK4 = 8'h14,
        REG_MASK5 = 8'h15,
        REG_MASK6 = 8'h16,
        REG_MASK7 = 8'h17,
        REG_ID0 = 8'h10,
        REG_ID1 = 8'h11,
        REG_ID2 = 8'h12,
        REG_ID3 = 8'h13,
        REG_ID4 = 8'h14,
        REG_ID5 = 8'h15,
        REG_ID6 = 8'h16,
        REG_ID7 = 8'h17;

    reg clk;
    reg rst_n;
    reg ena;

    reg cs;
    reg [7:0] mosi;

    wire [7:0] ui_in;
    wire [7:0] uio_in;

    assign uio_in = {7'b0000000, cs};
    assign ui_in = mosi;

    tt_um_pchri03_top top(
        .clk(clk),
        .rst_n(rst_n),
        .ena(ena),
        .ui_in(ui_in),
        .uio_in(uio_in)
    );

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);

        #20000 $finish;
    end

    initial begin
        clk = 1'b1;
        forever begin
            #10 clk = ~clk;
        end
    end

    initial begin
        rst_n = 1'b0;
        #50
        rst_n = 1'b1;
    end

    initial begin
        ena = 1'b0;
        #90
        ena = 1'b1;
    end

    initial begin
        cs = 1'b1;
        mosi = 8'h00;

        #99
        cs = 1'b0;
        mosi = CMD_WRITE;
        #20
        mosi = REG_WORD_SIZE;
        #20
        mosi = 8'h03;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = REG_RESULT_MASK;
        #20
        mosi = 8'b00000100;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = REG_CHAR0;
        #20
        mosi = 8'h61;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = REG_CHAR1;
        #20
        mosi = 8'h62;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = REG_CHAR2;
        #20
        mosi = 8'h63;


        #20
        mosi = CMD_WRITE;
        #20
        mosi = REG_CHAR3;
        #20
        mosi = 8'h00;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = REG_CHAR4;
        #20
        mosi = 8'h00;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = REG_CHAR5;
        #20
        mosi = 8'h00;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = REG_CHAR6;
        #20
        mosi = 8'h00;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = REG_CHAR7;
        #20
        mosi = 8'h00;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = REG_MASK0;
        #20
        mosi = 8'b00000001;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = REG_MASK1;
        #20
        mosi = 8'b00000010;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = REG_MASK2;
        #20
        mosi = 8'b00000100;

 
        #20
        mosi = CMD_WRITE;
        #20
        mosi = REG_MASK3;
        #20
        mosi = 8'b00000000;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = REG_MASK4;
        #20
        mosi = 8'b00000000;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = REG_MASK5;
        #20
        mosi = 8'b00000000;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = REG_MASK6;
        #20
        mosi = 8'b00000000;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = REG_MASK7;
        #20
        mosi = 8'b00000000;
        
        #20
        mosi = CMD_ENABLE;

        #20
        mosi = CMD_STREAM;
        #20
        mosi = 8'h61;

        #20
        mosi = CMD_STREAM;
        #20
        mosi = 8'h62;

        #20
        mosi = CMD_STREAM;
        #20
        mosi = 8'h63;

        #20
        mosi = CMD_STREAM;
        #20
        mosi = 8'h64;

        #20
        mosi = CMD_STREAM;
        #20
        mosi = 8'h00;

        #20
        cs = 1'b1;
    end
endmodule