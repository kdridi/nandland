// Compteur Binaire 4-bit Contrôlable par Switches
// Switch_1 : Enable comptage (1=compte, 0=pause)
// Switch_2 : Reset (1=reset, 0=normal)

module switch_counter #(
    parameter HALF_SECOND = 12_500_000  // Paramétrable pour simulation
)(
    input wire i_Clk,         // Horloge 25 MHz
    input wire i_Switch_1,    // Enable comptage
    input wire i_Switch_2,    // Reset
    output wire o_LED_1,      // Bit 3 (MSB)
    output wire o_LED_2,      // Bit 2
    output wire o_LED_3,      // Bit 1
    output wire o_LED_4       // Bit 0 (LSB)
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

    // Logique du compteur 4-bit avec contrôle
    always @(posedge i_Clk) begin
        if (i_Switch_2) begin
            // Reset a priorité sur tout
            r_Counter <= 0;
        end else if (r_Enable && i_Switch_1) begin
            // Compte seulement si enable pulse ET switch_1 actif
            r_Counter <= r_Counter + 1;  // Wrap automatique sur 4 bits
        end
        // Sinon : garde la valeur (pause)
    end

    // Assignation des sorties
    assign o_LED_1 = r_Counter[3];  // MSB
    assign o_LED_2 = r_Counter[2];
    assign o_LED_3 = r_Counter[1];
    assign o_LED_4 = r_Counter[0];  // LSB

endmodule
