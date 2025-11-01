// LED Clignotante à 1 Hz
// Utilise l'horloge 25 MHz pour faire clignoter une LED

module blink_led #(
    parameter HALF_SECOND = 12_500_000  // Paramétrable pour simulation
)(
    input wire i_Clk,        // Horloge 25 MHz
    output wire o_LED_1      // LED qui clignote
);

    // Compteur : 24 bits suffisent (2^24 = 16 777 216 > 12 500 000)
    reg [23:0] r_Counter = 0;

    // État de la LED
    reg r_LED = 0;

    // Logique du compteur et toggle
    always @(posedge i_Clk) begin
        if (r_Counter == HALF_SECOND - 1) begin
            // Reset compteur et toggle LED
            r_Counter <= 0;
            r_LED <= ~r_LED;
        end else begin
            // Incrémenter compteur
            r_Counter <= r_Counter + 1;
        end
    end

    // Sortie
    assign o_LED_1 = r_LED;

endmodule
