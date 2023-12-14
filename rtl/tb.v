`timescale 1ns/1ns

module tb();
    reg clk;
    reg rst_n;
    reg ena;

    reg [7:0] ui_in;

    wire [7:0] uo_out;

    reg [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    top top(
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
        clk = 1'b0;
        forever begin
            #10 clk = ~clk;
        end
    end

    initial begin
        rst_n = 1'b0;
        #60 rst_n = 1'b1; 
    end

    initial begin
        ena = 1'b0;
        #100 ena = 1'b1;
    end
endmodule