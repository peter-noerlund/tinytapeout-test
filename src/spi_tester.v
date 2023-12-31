`timescale 1ns/1ps
`default_nettype none

module spi_tester
    #(
        parameter FILENAME = ""
    )
    (
        input wire enable,

        input wire sclk,
        output reg cs,
        output reg [7:0] mosi
    );

    integer fd;
    integer status;
    reg [7:0] buffer;

    initial begin
        fd = $fopen(FILENAME, "rb");
        cs = 1'b1;
    end

    always @ (posedge sclk) begin
        if (enable) begin
            if ($feof(fd)) begin
                cs <= 1'b1;
            end else begin
                status <= $fread(buffer, fd);
                mosi <= buffer;
                cs <= 1'b0;
            end
        end
    end
endmodule
