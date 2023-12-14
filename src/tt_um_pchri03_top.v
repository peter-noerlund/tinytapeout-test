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

    reg [7:0] counter;

    assign uio_oe = 8'b00000000;
    assign uio_out = 8'b00000000;
    assign uo_out = counter;

    always @ (posedge clk) begin
        if (!rst_n) begin
            counter <= 8'h00;
        end else if (ena) begin
            counter <= counter + 8'h01;
        end
    end
endmodule
