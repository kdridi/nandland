// Compteur Décimal sur Afficheur 7 Segments
// Compte de 0 à 9 avec affichage sur 7 segments

module segment_counter #(
    parameter HALF_SECOND = 12_500_000  // Paramétrable pour simulation
)(
    input wire i_Clk,          // Horloge 25 MHz
    output wire o_Segment1_A,  // Segment A
    output wire o_Segment1_B,  // Segment B
    output wire o_Segment1_C,  // Segment C
    output wire o_Segment1_D,  // Segment D
    output wire o_Segment1_E,  // Segment E
    output wire o_Segment1_F,  // Segment F
    output wire o_Segment1_G   // Segment G
);

    // Diviseur de fréquence (25 MHz → 2 Hz pour incrément 0.5s)
    reg [23:0] r_Clk_Count = 0;
    reg r_Enable = 0;

    // Compteur décimal (0-9)
    reg [3:0] r_Counter = 0;

    // Segments 7-segment
    reg [6:0] r_Segments = 7'b0111111;  // Initialiser à 0

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

    // Logique du compteur décimal avec wrap à 9
    always @(posedge i_Clk) begin
        if (r_Enable) begin
            if (r_Counter == 9)
                r_Counter <= 0;  // Wrap à 0 après 9
            else
                r_Counter <= r_Counter + 1;
        end
    end

    // Décodeur 7 segments (actif haut)
    // Format: GFEDCBA
    always @(*) begin
        case (r_Counter)
            4'd0: r_Segments = 7'b0111111;  // 0
            4'd1: r_Segments = 7'b0000110;  // 1
            4'd2: r_Segments = 7'b1011011;  // 2
            4'd3: r_Segments = 7'b1001111;  // 3
            4'd4: r_Segments = 7'b1100110;  // 4
            4'd5: r_Segments = 7'b1101101;  // 5
            4'd6: r_Segments = 7'b1111101;  // 6
            4'd7: r_Segments = 7'b0000111;  // 7
            4'd8: r_Segments = 7'b1111111;  // 8
            4'd9: r_Segments = 7'b1101111;  // 9
            default: r_Segments = 7'b0000000;  // Éteint
        endcase
    end

    // Assignation des sorties (actif bas pour l'afficheur)
    // Format: {G, F, E, D, C, B, A}
    assign {o_Segment1_G, o_Segment1_F, o_Segment1_E, o_Segment1_D,
            o_Segment1_C, o_Segment1_B, o_Segment1_A} = ~r_Segments;

endmodule
