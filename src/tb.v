`default_nettype none
`timescale 1ns/1ns

module tb();
    reg clk;
    reg rst_n;
    reg ena;

    reg cs;
    reg [7:0] mosi;

    wire [7:0] ui_in;
    wire [7:0] uio_in;

    reg test_enable;

    assign uio_in = {7'b0000000, cs};
    assign ui_in = mosi;

    tt_um_pchri03_top top(
        .clk(clk),
        .rst_n(rst_n),
        .ena(ena),
        .ui_in(ui_in),
        .uio_in(uio_in)
    );

    spi_tester #(.FILENAME("../data/test.bin")) tester(
        .enable(test_enable),
        .sclk(clk),
        .cs(cs),
        .mosi(mosi)
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
        test_enable = 1'b0;
        #120
        test_enable = 1'b1;
    end
endmodule