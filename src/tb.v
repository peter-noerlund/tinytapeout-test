`default_nettype none
`timescale 1ns/1ns

module tb();
    localparam CMD_READ     = 8'b00000011;
    localparam CMD_WRITE    = 8'b00000010;
    localparam CMD_STREAM   = 8'b10000000;

    reg clk;
    reg rst_n;
    reg ena;

    reg cs;
    reg [7:0] mosi;

    wire [7:0] ui_in;
    wire [7:0] uo_out;
    wire [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    assign uio_in = {7'b0000000, cs};
    assign ui_in = mosi;

    tt_um_pchri03_top top(
        .clk(clk),
        .rst_n(rst_n),
        .ena(ena),
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe)
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
        mosi = 8'h00;
        #20
        mosi = 8'h61;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = 8'h01;
        #20
        mosi = 8'h62;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = 8'h02;
        #20
        mosi = 8'h63;


        #20
        mosi = CMD_WRITE;
        #20
        mosi = 8'h03;
        #20
        mosi = 8'h00;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = 8'h04;
        #20
        mosi = 8'h00;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = 8'h05;
        #20
        mosi = 8'h00;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = 8'h06;
        #20
        mosi = 8'h00;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = 8'h07;
        #20
        mosi = 8'h00;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = 8'h08;
        #20
        mosi = 8'b00000001;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = 8'h09;
        #20
        mosi = 8'b00000010;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = 8'h0A;
        #20
        mosi = 8'b00000100;

 
        #20
        mosi = CMD_WRITE;
        #20
        mosi = 8'h0B;
        #20
        mosi = 8'b00000000;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = 8'h0C;
        #20
        mosi = 8'b00000000;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = 8'h0D;
        #20
        mosi = 8'b00000000;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = 8'h0E;
        #20
        mosi = 8'b00000000;

        #20
        mosi = CMD_WRITE;
        #20
        mosi = 8'h0F;
        #20
        mosi = 8'b00000000;

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
        cs = 1'b1;

        #80
        cs = 1'b0;
        mosi = CMD_READ;
        #20
        mosi = 8'h10;

        #20
        cs = 1'b1;
    end
endmodule