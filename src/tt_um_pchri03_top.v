`timescale 1ns/1ns

module tt_um_pchri03_top
    (
        input clk,                  //! Clock
        input rst_n,                //! Reset
        input ena,                  //! Enable

        output [7:0] uo_out,        //! Output ports

        output [7:0] uio_oe         //! In/Out ports (Output enable)
    );

    reg [7:0] counter;

    assign uio_oe = 8'b00000000;
    assign uo_out = counter;

    always @ (posedge clk) begin
        if (!rst_n) begin
            counter <= 8'h00;
        end else if (ena) begin
            counter <= counter + 8'h01;
        end
    end
endmodule