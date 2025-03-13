module vga_pwm (
    input ADC_CLK_10,
    input MAX10_CLK1_50,
    input MAX10_CLK2_50,

    output reg [3:0] VGA_R,
    output reg [3:0] VGA_G,
    output reg [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS,

    output [7:0] HEX0,
    output [7:0] HEX1,
    output [7:0] HEX2,
    output [7:0] HEX3,
    output [7:0] HEX4,
    output [7:0] HEX5,

    input [1:0] KEY,
    output [9:0] LEDR,
    input [9:0] SW,

    output GSENSOR_CS_N,
    input [2:1] GSENSOR_INT,
    output GSENSOR_SCLK,
    inout GSENSOR_SDI,
    inout GSENSOR_SDO,

    output [1:0] GPIO  // Salida PWM en GPIO[0], el otro pin no se usa
);

localparam SPI_CLK_FREQ = 200;
localparam UPDATE_FREQ = 1;

wire reset_n = KEY[0];
wire clk, spi_clk, spi_clk_out;
wire data_update;
wire signed [15:0] data_x, data_y, data_z;

PLL ip_inst (
    .inclk0(MAX10_CLK1_50),
    .c0(clk),
    .c1(spi_clk),
    .c2(spi_clk_out)
);

spi_control #(.SPI_CLK_FREQ(SPI_CLK_FREQ), .UPDATE_FREQ(UPDATE_FREQ))
spi_ctrl (
    .reset_n(reset_n), .clk(clk), .spi_clk(spi_clk), .spi_clk_out(spi_clk_out),
    .data_update(data_update),
    .data_x(data_x), .data_y(data_y), .data_z(data_z),
    .SPI_SDI(GSENSOR_SDI), .SPI_SDO(GSENSOR_SDO), .SPI_CSN(GSENSOR_CS_N),
    .SPI_CLK(GSENSOR_SCLK), .interrupt()
);

// ---------------- PWM Controlado por Cambios en X ---------------- //
reg [7:0] duty_cycle_x = 0;  // Inicia en 50% de ciclo de trabajo
reg signed [15:0] prev_x = 0;  // Almacena el último valor de X

always @(posedge clk) begin
    if (data_x != prev_x) begin
        if (data_x > prev_x) begin
            // Si X aumenta, incrementa el ciclo de trabajo
            duty_cycle_x <= (duty_cycle_x < 100) ? duty_cycle_x + 5 : 100;
        end else begin
            // Si X disminuye, reduce el ciclo de trabajo
            duty_cycle_x <= (duty_cycle_x > 0) ? duty_cycle_x - 5 : 0;
        end
        prev_x <= data_x;
    end
end

pwm pwm_x (
    .clk(MAX10_CLK1_50),
    .enable(1),
    .duty_cycle(duty_cycle_x),
    .PWM(GPIO[0])
);

endmodule

// ----------------------- MÓDULO PWM -----------------------
module pwm (
    input clk,                  // Reloj del sistema
    input enable,               // Habilitación del PWM
    input [7:0] duty_cycle,     // Ciclo de trabajo (0-100)
    output reg PWM              // Señal PWM de salida
);
    
    reg [7:0] counter = 0;

    always @(posedge clk) begin
        if (enable) begin
            counter <= counter + 1;
            PWM <= (counter < duty_cycle) ? 1 : 0;
        end else begin
            PWM <= 0;
        end
    end

endmodule