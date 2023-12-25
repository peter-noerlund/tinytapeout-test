`timescale 1ns/1ps
`default_nettype none

module spi_controller
    (
        //! @virtualbus S_SPI @dir input
        input wire cs,
        input wire [7:0] mosi,
        output reg [7:0] miso,
        //! @end

        output reg [7:0] word_size,
        output reg [7:0] result_mask,
        output reg [63:0] characters,
        output reg [63:0] masks,

        input wire aclk,
        input wire aresetn,

        //! @virtualbus M_AXIS @dir output
        output reg m_axis_tvalid,
        output reg [7:0] m_axis_tdata,
        output reg m_axis_tuser,
        //! @end

        //! @virtualbus S_AXIS @dir input
        input wire s_axis_tvalid,
        input wire [7:0] s_axis_tdata
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
        CMD_NOOP  = 8'b00000000,
        CMD_END   = 8'b00000001,
        CMD_READ  = 8'b00000010,
        CMD_WRITE = 8'b00000011;

    localparam [1:0]
        AREA_CONTROL = 2'b00,
        AREA_CHAR = 2'b01,
        AREA_MASK = 2'b10,
        AREA_RESULT = 2'b11;

    localparam [1:0]
        STATE_IDLE=2'b00,
        STATE_READ=2'b01,
        STATE_WRITE=2'b10,
        STATE_WRITE_ADDR=2'b11;

    localparam [3:0]
        REG_WORD_SIZE=4'h0,
        REG_MASK=4'h1,
        REG_OFFSET=4'h2;

    reg [1:0] write_area;
    reg [3:0] write_addr;
    reg [1:0] state;
    reg [2:0] offset;
    reg [63:0] result_ids;

    wire [1:0] read_area;
    wire [2:0] read_addr;

    integer i;
    
    assign read_area = mosi[4:3];
    assign read_addr = mosi[2:0];

    always @ (posedge aclk) begin
        if (!aresetn) begin
            state <= STATE_IDLE;
            m_axis_tvalid <= 1'b0;
        end else begin
            if (!cs) begin
                case (state)
                    STATE_IDLE: begin
                        if (mosi == CMD_READ) begin
                            state <= STATE_READ;
                            m_axis_tvalid <= 1'b0;
                        end else if (mosi == CMD_WRITE) begin
                            state <= STATE_WRITE;
                            m_axis_tvalid <= 1'b0;
                        end else if (mosi == CMD_END) begin
                            m_axis_tvalid <= 1'b1;
                            m_axis_tuser <= 1'b1;
                            m_axis_tdata <= mosi;
                        end else begin
                            m_axis_tvalid <= 1'b1;
                            m_axis_tuser <= 1'b0;
                            m_axis_tdata <= mosi;
                        end
                    end

                    STATE_READ: begin
                        case (read_area)
                            AREA_CONTROL: begin
                                case (read_addr)
                                    REG_WORD_SIZE: miso <= word_size;
                                    REG_MASK: miso <= result_mask;
                                    REG_OFFSET: miso <= {5'h00, offset};
                                    default: miso <= 8'h00;
                                endcase
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
                                if (write_addr == REG_WORD_SIZE) begin
                                    word_size <= mosi;
                                end else if (write_addr == REG_MASK) begin
                                    result_mask <= mosi;
                                end else if (write_addr == REG_OFFSET) begin
                                    offset <= mosi[2:0];
                                end
                            end
                            AREA_CHAR: characters[write_addr * 8 + 7 -: 8] <= mosi;
                            AREA_MASK: masks[write_addr * 8 + 7 -: 8] <= mosi;
                            AREA_RESULT: begin
                            end
                        endcase
                        state <= STATE_IDLE;
                    end

                    default: begin
                        state <= STATE_IDLE;
                    end
                endcase
            end else begin
                m_axis_tvalid <= 1'b0;
            end
        end
    end

    always @ (posedge aclk) begin
        if (s_axis_tvalid) begin
            result_ids[offset * 8 + 7 -: 8] <= s_axis_tdata;
            offset <= offset + 1;
        end
    end
endmodule
