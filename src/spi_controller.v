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

        output reg [7:0] word_size,
        output reg [7:0] result_mask,
        output reg [63:0] characters,
        output reg [63:0] masks,
        input wire [63:0] result_ids,

        output wire aclk,
        output reg aresetn,

        //! @virtualbus M_AXIS @dir output
        output reg m_axis_tvalid,
        output reg [7:0] m_axis_tdata,
        output reg m_axis_tuser
        //! @end
    );

    /*
    Memory layout:

    00xx0   Search word length
    00xx1   Mask
    01xxx   Character
    10xxx   Mask
    11xxx   Result ids
    */

    localparam [7:0]
        CMD_READ = 8'b00000011,
        CMD_WRITE = 8'b00000010,
        CMD_ENABLE = 8'b10000001,
        CMD_STREAM = 8'b10000010,
        CMD_DISABLE = 8'b10000011;

    localparam [1:0]
        AREA_CONTROL = 2'b00,
        AREA_CHAR = 2'b01,
        AREA_MASK = 2'b10,
        AREA_RESULT = 2'b11;

    localparam [2:0]
        STATE_IDLE=3'b000,
        STATE_READ=3'b001,
        STATE_WRITE=3'b010,
        STATE_WRITE_ADDR=3'b011,
        STATE_STREAM=3'b100;

    reg [1:0] write_area;
    reg [3:0] write_addr;
    reg [2:0] state;

    wire [1:0] read_area;
    wire [3:0] read_addr;

    integer i;
    
    assign read_addr = mosi[4:0];
    assign aclk = sclk;

    always @ (posedge sclk) begin
        if (!rst_n) begin
            state <= STATE_IDLE;
            aresetn <= 1'b0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    if (mosi == CMD_READ) begin
                        state <= STATE_READ;
                    end else if (mosi == CMD_WRITE) begin
                        state <= STATE_WRITE;
                    end else if (mosi == CMD_ENABLE) begin
                        aresetn <= 1'b1;
                    end else if (mosi == CMD_STREAM) begin
                        state <= STATE_STREAM;
                    end else if (mosi == CMD_DISABLE) begin
                        aresetn <= 1'b0;
                    end
                end

                STATE_READ: begin
                    case (read_area)
                        AREA_CONTROL: begin
                            if (read_addr[0]) begin
                                miso <= result_mask;
                            end else begin
                                miso <= word_size;
                            end
                        end
                        AREA_CHAR: miso <= characters[read_addr * 8 + 7 -: 8];
                        AREA_MASK: miso <= masks[read_addr * 8 + 7 -: 8];
                        AREA_RESULT: miso <= result_ids[read_addr * 8 + 7 -: 8];
                    endcase
                    state <= STATE_IDLE;
                end

                STATE_WRITE: begin
                    write_area <= mosi[4:3];
                    write_addr <= mosi[2:0];
                    state <= STATE_WRITE_ADDR;
                end

                STATE_WRITE_ADDR: begin
                    case (write_area)
                        AREA_CONTROL: begin
                            if (write_addr[0]) begin
                                result_mask <= mosi;
                            end else begin
                                word_size <= mosi;
                            end
                        end
                        AREA_CHAR: characters[write_addr * 8 + 7 -: 8] <= mosi;
                        AREA_MASK: masks[write_addr * 8 + 7 -: 8] <= mosi;
                        AREA_RESULT: begin
                        end
                    endcase
                    state <= STATE_IDLE;
                end

                STATE_STREAM: begin
                    state <= STATE_IDLE;
                end

                default: begin
                    state <= STATE_IDLE;
                end
            endcase

            if (state == STATE_STREAM) begin
                m_axis_tdata <= mosi;
                m_axis_tvalid <= 1'b1;
                m_axis_tuser <= mosi == 8'h00;
            end else begin
                m_axis_tvalid <= 1'b0;
            end
        end
    end
endmodule