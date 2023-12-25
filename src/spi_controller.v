`timescale 1ns/1ps
`default_nettype none

module spi_controller
    (
        input wire rst_n,

        //! @virtualbus S_SPI @dir input
        input wire sclk,
        input wire cs,
        input wire [7:0] mosi,
        output reg [7:0] miso,
        //! @end

        output wire [63:0] characters,
        output wire [63:0] masks,
        input wire [7:0] result,

        //! @virtualbus M_AXIS @dir output
        output reg m_axis_tvalid,
        output reg [7:0] m_axis_tdata
        //! @end
    );

    localparam CMD_READ = 8'b00000011;
    localparam CMD_WRITE = 8'b00000010;
    localparam CMD_STREAM = 8'b10000000;

    localparam [2:0]
        STATE_IDLE=3'b000,
        STATE_READ=3'b001,
        STATE_WRITE=3'b010,
        STATE_WRITE_ADDR=3'b011,
        STATE_STREAM=3'b100;

    reg [127:0] mem;
    reg [3:0] addr;
    reg [2:0] state;

    assign characters = mem[63:0];
    assign masks = mem[127:64];

    always @ (posedge sclk) begin
        if (!rst_n) begin
            state <= STATE_IDLE;
        end else begin
            case (state)
                STATE_IDLE: begin
                    if (mosi == CMD_READ) begin
                        state <= STATE_READ;
                    end else if (mosi == CMD_WRITE) begin
                        state <= STATE_WRITE;
                    end else if (mosi == CMD_STREAM) begin
                        state <= STATE_STREAM;
                    end
                end

                STATE_READ: begin
                    if (mosi[4]) begin
                        miso <= result;
                    end else begin
                        miso <= mem[mosi[3:0] * 8 + 7 -: 8];
                    end
                    state <= STATE_IDLE;
                end

                STATE_WRITE: begin
                    addr <= mosi[3:0];
                    state <= STATE_WRITE_ADDR;
                end

                STATE_WRITE_ADDR: begin
                    mem[addr * 8 + 7 -: 8] <= mosi;
                    state <= STATE_IDLE;
                end

                STATE_STREAM: begin
                    state <= STATE_IDLE;
                end

                default: begin
                    state <= STATE_IDLE;
                end
            endcase
        end

        if (state == STATE_STREAM) begin
            m_axis_tdata <= mosi;
            m_axis_tvalid <= 1'b1;
        end else begin
            m_axis_tvalid <= 1'b0;
        end
    end
endmodule