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

    wire sclk;
    wire cs;
    wire [7:0] mosi;
    wire [7:0] miso;

    assign sclk = clk;
    assign cs = uio_in[0];
    assign mosi = ui_in;
    assign miso = uo_out;
    assign uio_oe = 8'b00000000;
    assign uio_out = 8'b00000000;
    
    spi_controller spi_controller(
        .rst_n(rst_n),

        .sclk(sclk),
        .cs(cs),
        .mosi(mosi),
        .miso(miso)
    );

endmodule
