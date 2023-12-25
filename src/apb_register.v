`timescale 1ns/1ns
`default_nettype none

module apb_register
    #(
        parameter integer ADDR_WIDTH = 3,
        parameter integer DATA_WIDTH = 8
    )
    (
        (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk CLK" *)
        (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF S_APB, ASSOCIATED_RESET presetn" *)
        input wire pclk,

        (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 presetn RST" *)
        input wire presetn,

        (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PADDR" *)
        //! @virtualbus S_APB @dir input
        input wire [ADDR_WIDTH - 1 : 0] paddr,
        (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PPROT" *)
        input wire [2:0] pprot,
        (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PSEL" *)
        input wire psel,
        (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PENABLE" *)
        input wire penable,
        (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PWRITE" *)
        input wire pwrite,
        (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PWDATA" *)
        input wire [DATA_WIDTH - 1 : 0] pwdata,
        (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PSTRB" *)
        input wire [DATA_WIDTH / 8 - 1 : 0] pstrb,
        (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PREADY" *)
        output reg pready,
        (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PRDATA" *)
        output reg [DATA_WIDTH - 1 : 0] prdata,
        (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PSLVERR" *)
        output wire pslverr
        //! @end
    );

    localparam REGISTER_COUNT = 2**ADDR_WIDTH;

    reg [REGISTER_COUNT * DATA_WIDTH - 1 : 0] mem;
    integer i;

    assign pslverr = 1'b0;

    always @ (posedge pclk) begin
        if (presetn && psel && penable) begin
            pready <= 1'b1;
            if (pwrite) begin
                if (DATA_WIDTH == 8) begin
                    mem[paddr * DATA_WIDTH + 7 -: 8] <= pwdata;
                end else begin
                    for (i = 0; i != DATA_WIDTH / 8; i = i + 1) begin
                        if (pstrb[i]) begin
                            mem[paddr * DATA_WIDTH + i * 8 + 7 -: 8] <= pwdata[i * 8 + 7 -: 8];
                        end
                    end
                end
            end else begin
                prdata <= mem[paddr * DATA_WIDTH + DATA_WIDTH - 1 -: DATA_WIDTH];
            end
        end else begin
            pready <= 1'b0;
        end
    end
endmodule
