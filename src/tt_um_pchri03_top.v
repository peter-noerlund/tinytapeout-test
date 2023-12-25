`default_nettype none
`timescale 1ns/1ns

module tt_um_pchri03_top
    (
        input wire clk,                  //! Clock
        input wire rst_n,                //! Reset
        input wire ena,                  //! Enable

        input wire [7:0] ui_in,          //! Input ports

        output wire [7:0] uo_out,        //! Output ports

        input wire [7:0] uio_in,         //! In/Out ports (In)
        output wire [7:0] uio_out,       //! In/Out ports (Out)
        output wire [7:0] uio_oe         //! In/Out ports (Output enable)
    );

    assign uio_oe = 8'b01100000;

    assign uio_out[7] = 1'b0;

    apb_register #(.ADDR_WIDTH(3), .DATA_WIDTH(8)) ram(
        .pclk(clk),
        .presetn(rst_n),
        .paddr(uio_in[2:0]),
        .pprot(3'b000),
        .psel(ena),
        .penable(uio_in[3]),
        .pwrite(uio_in[4]),
        .pwdata(ui_in),
        .pstrb(1'b1),
        .pready(uio_out[5]),
        .prdata(uio_out),
        .pslverr(uio_out[6])
    );

endmodule
