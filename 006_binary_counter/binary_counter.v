// Compteur Binaire 4-bit
// Incrémente toutes les 0.5s et affiche sur 4 LEDs

module binary_counter #(
    parameter HALF_SECOND = 12_500_000  // Paramétrable pour simulation
)(
    input wire i_Clk,        // Horloge 25 MHz
    output wire o_LED_4,     // Bit 0 (LSB)
    output wire o_LED_3,     // Bit 1
    output wire o_LED_2,     // Bit 2
    output wire o_LED_1      // Bit 3 (MSB)
);

    // Diviseur de fréquence (25 MHz → 2 Hz pour incrément 0.5s)
    reg [23:0] r_Clk_Count = 0;
    reg r_Enable = 0;

    // Compteur 4-bit
    reg [3:0] r_Counter = 0;

    // Logique du diviseur de fréquence
    always @(posedge i_Clk) begin
        if (r_Clk_Count == HALF_SECOND - 1) begin
            r_Clk_Count <= 0;
            r_Enable <= 1;
        end else begin
            r_Clk_Count <= r_Clk_Count + 1;
            r_Enable <= 0;
        end
    end

    // Logique du compteur 4-bit
    always @(posedge i_Clk) begin
        if (r_Enable) begin
            r_Counter <= r_Counter + 1;  // Wrap automatique sur 4 bits
        end
    end

    // Assignation des sorties
    assign o_LED_4 = r_Counter[0];
    assign o_LED_3 = r_Counter[1];
    assign o_LED_2 = r_Counter[2];
    assign o_LED_1 = r_Counter[3];

endmodule
