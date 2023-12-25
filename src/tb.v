`default_nettype none
`timescale 1ns/1ns

module tb();
    reg pclk;
    reg presetn;
    reg psel;
    reg [3:0] paddr;
    reg penable;
    reg pwrite;
    reg [7:0] pwdata;
    wire pready;
    wire [7:0] prdata;
    wire pslverr;

    wire clk;
    wire rst_n;
    wire ena;
    wire [7:0] ui_in;
    wire [7:0] uo_out;
    wire [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    assign clk = pclk;
    assign rst_n = presetn;
    assign ena = psel;
    assign ui_in = pwdata;
    assign uo_out = prdata;
    assign uio_in[3:0] = paddr;
    assign uio_in[4] = penable;
    assign uio_in[5] = pwrite;
    assign uio_out[6] = pready;
    assign uio_out[7] = pslverr;

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
        pclk = 1'b1;
        forever begin
            #10 pclk = ~pclk;
        end
    end

    initial begin
        presetn = 1'b0;
        #50 presetn = 1'b1; 
    end

    initial begin
        psel = 1'b0;

        #98
        psel = 1'b1;
        paddr = 3'h0;
        pwrite = 1'b1;
        pwdata = 8'hDE;
        penable = 1'b0;

        #20
        penable = 1'b1;

        #20
        paddr = 3'h1;
        pwdata = 8'hAD;
        penable = 1'b0;

        #20
        penable = 1'b1;

        #20
        paddr = 3'h2;
        pwdata = 8'hBE;
        penable = 1'b0;

        #20
        penable = 1'b1;
        #20
        paddr = 3'h3;
        pwdata = 8'hEF;
        penable = 1'b0;

        #20
        penable = 1'b1;

        #20
        penable = 1'b0;
        paddr = 3'h0;
        pwrite = 1'b0;

        #20
        penable = 1'b1;

        #20
        penable = 1'b0;
        paddr = 3'h1;

        #20
        penable = 1'b1;

        #20
        penable = 1'b0;
        paddr = 3'h2;

        #20
        penable = 1'b1;

        #20
        penable = 1'b0;
        paddr = 3'h3;

        #20
        penable = 1'b1;

        #20
        penable = 1'b0;
    end

endmodule