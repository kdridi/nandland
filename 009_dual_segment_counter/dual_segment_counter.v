// Compteur 2 Chiffres (00-99) sur Afficheurs 7 Segments
// Compte de 00 à 99 avec affichage sur les deux afficheurs

module dual_segment_counter #(
    parameter HALF_SECOND = 12_500_000  // Paramétrable pour simulation
)(
    input wire i_Clk,           // Horloge 25 MHz
    // Segment 1 (unités - droite)
    output wire o_Segment1_A,
    output wire o_Segment1_B,
    output wire o_Segment1_C,
    output wire o_Segment1_D,
    output wire o_Segment1_E,
    output wire o_Segment1_F,
    output wire o_Segment1_G,
    // Segment 2 (dizaines - gauche)
    output wire o_Segment2_A,
    output wire o_Segment2_B,
    output wire o_Segment2_C,
    output wire o_Segment2_D,
    output wire o_Segment2_E,
    output wire o_Segment2_F,
    output wire o_Segment2_G
);

    // Diviseur de fréquence (25 MHz → 2 Hz pour incrément 0.5s)
    reg [23:0] r_Clk_Count = 0;
    reg r_Enable = 0;

    // Compteur 0-99 (7 bits suffisent : 2^7 = 128 > 99)
    reg [6:0] r_Counter = 0;

    // Extraction dizaines et unités
    wire [3:0] w_Tens;
    wire [3:0] w_Units;

    assign w_Tens  = r_Counter / 10;  // Division par 10
    assign w_Units = r_Counter % 10;  // Modulo 10

    // Segments pour dizaines et unités
    reg [6:0] r_Segments_Tens;
    reg [6:0] r_Segments_Units;

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

    // Logique du compteur 0-99 avec wrap
    always @(posedge i_Clk) begin
        if (r_Enable) begin
            if (r_Counter == 99)
                r_Counter <= 0;  // Wrap à 0 après 99
            else
                r_Counter <= r_Counter + 1;
        end
    end

    // Décodeur 7 segments pour les dizaines
    always @(*) begin
        case (w_Tens)
            4'd0: r_Segments_Tens = 7'b0111111;  // 0
            4'd1: r_Segments_Tens = 7'b0000110;  // 1
            4'd2: r_Segments_Tens = 7'b1011011;  // 2
            4'd3: r_Segments_Tens = 7'b1001111;  // 3
            4'd4: r_Segments_Tens = 7'b1100110;  // 4
            4'd5: r_Segments_Tens = 7'b1101101;  // 5
            4'd6: r_Segments_Tens = 7'b1111101;  // 6
            4'd7: r_Segments_Tens = 7'b0000111;  // 7
            4'd8: r_Segments_Tens = 7'b1111111;  // 8
            4'd9: r_Segments_Tens = 7'b1101111;  // 9
            default: r_Segments_Tens = 7'b0000000;  // Éteint
        endcase
    end

    // Décodeur 7 segments pour les unités
    always @(*) begin
        case (w_Units)
            4'd0: r_Segments_Units = 7'b0111111;  // 0
            4'd1: r_Segments_Units = 7'b0000110;  // 1
            4'd2: r_Segments_Units = 7'b1011011;  // 2
            4'd3: r_Segments_Units = 7'b1001111;  // 3
            4'd4: r_Segments_Units = 7'b1100110;  // 4
            4'd5: r_Segments_Units = 7'b1101101;  // 5
            4'd6: r_Segments_Units = 7'b1111101;  // 6
            4'd7: r_Segments_Units = 7'b0000111;  // 7
            4'd8: r_Segments_Units = 7'b1111111;  // 8
            4'd9: r_Segments_Units = 7'b1101111;  // 9
            default: r_Segments_Units = 7'b0000000;  // Éteint
        endcase
    end

    // Assignation des sorties Segment 1 (gauche = dizaines - actif bas)
    assign {o_Segment1_G, o_Segment1_F, o_Segment1_E, o_Segment1_D,
            o_Segment1_C, o_Segment1_B, o_Segment1_A} = ~r_Segments_Tens;

    // Assignation des sorties Segment 2 (droite = unités - actif bas)
    assign {o_Segment2_G, o_Segment2_F, o_Segment2_E, o_Segment2_D,
            o_Segment2_C, o_Segment2_B, o_Segment2_A} = ~r_Segments_Units;

endmodule
