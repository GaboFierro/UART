module receiver #(
    parameter COUNTS_PER_BIT = 434,
    parameter DATA_BITS = 8,
    parameter CLOCK_CTR_WIDTH = 32,
    parameter D_IDX_WIDTH = (DATA_BITS > 1) ? $clog2(DATA_BITS) : 1
)(
    input serial_data_in,
    input clk,
    input rst, 
    output reg [7:0] received_data // Modificado para enviar datos a VGADemo
);

    localparam base_freq = 50_000_000;
    localparam baudrate  = 115_200;
   
    localparam counts_per_bit_calc = base_freq / baudrate;

    localparam RX_IDLE   = 0;
    localparam RX_START  = 1;
    localparam RX_DATA   = 2;
    localparam RX_STOP   = 3;

    reg [2:0] active_state;
    reg [CLOCK_CTR_WIDTH-1:0] clock_ctr;
    reg [D_IDX_WIDTH-1:0] d_idx;
    reg [DATA_BITS-1:0] data_reg; 

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            active_state    <= RX_IDLE;
            received_data   <= 8'h00;
            data_reg        <= 0;
            clock_ctr       <= 0;
            d_idx           <= 0;
        end else begin
            case (active_state)
                RX_IDLE: begin
                    d_idx <= 0;
                    clock_ctr <= 0;
                    if (~serial_data_in)
                        active_state <= RX_START;
                end

                RX_START: begin
                    if (clock_ctr < ((counts_per_bit_calc - 1)/2))
                        clock_ctr <= clock_ctr + 1;
                    else begin
                        if (~serial_data_in) begin 
                            clock_ctr   <= 0;
                            active_state <= RX_DATA;
                        end else
                            active_state <= RX_IDLE; 
                    end
                end

                RX_DATA: begin
                    if (clock_ctr < counts_per_bit_calc - 1)
                        clock_ctr <= clock_ctr + 1;
                    else begin
                        data_reg[d_idx] <= serial_data_in;
                        clock_ctr <= 0;
                        d_idx <= (d_idx < DATA_BITS - 1) ? d_idx + 1 : 0;
                        active_state <= (d_idx == DATA_BITS - 1) ? RX_STOP : RX_DATA;
                    end
                end

                RX_STOP: begin
                    if (clock_ctr < counts_per_bit_calc - 1)
                        clock_ctr <= clock_ctr + 1;
                    else begin
                        clock_ctr   <= 0;
                        received_data <= data_reg; // Se envía el dato a VGADemo
                        active_state <= RX_IDLE;
                    end
                end

                default: active_state <= RX_IDLE;
            endcase
        end
    end
endmodule
