// Module : binary_to_7seg
// Description : Décodeur binaire 4 bits vers afficheur 7 segments (hexadécimal 0-F)
// Auteur : Exercice Nandland Go Board
// Date : 2025-11-01

module binary_to_7seg (
    // Entrées : 4 switches pour le code binaire (0x0 - 0xF)
    input wire i_Switch_1,  // bit[0] - LSB
    input wire i_Switch_2,  // bit[1]
    input wire i_Switch_3,  // bit[2]
    input wire i_Switch_4,  // bit[3] - MSB

    // Sorties : 7 segments de l'afficheur 1 (actif bas)
    output wire o_Segment1_A,
    output wire o_Segment1_B,
    output wire o_Segment1_C,
    output wire o_Segment1_D,
    output wire o_Segment1_E,
    output wire o_Segment1_F,
    output wire o_Segment1_G
);

    // Code binaire 4 bits
    wire [3:0] w_Binary;
    assign w_Binary = {i_Switch_4, i_Switch_3, i_Switch_2, i_Switch_1};

    // Segments (logique positive, seront inversés pour la sortie)
    reg [6:0] r_Segments;  // {G, F, E, D, C, B, A}

    // Décodeur hexadécimal 7 segments
    // Disposition des segments :
    //    AAA
    //   F   B
    //    GGG
    //   E   C
    //    DDD
    always @(*) begin
        case (w_Binary)
            4'h0: r_Segments = 7'b0111111;  // 0 : tous sauf G
            4'h1: r_Segments = 7'b0000110;  // 1 : B et C
            4'h2: r_Segments = 7'b1011011;  // 2 : A,B,D,E,G
            4'h3: r_Segments = 7'b1001111;  // 3 : A,B,C,D,G
            4'h4: r_Segments = 7'b1100110;  // 4 : B,C,F,G
            4'h5: r_Segments = 7'b1101101;  // 5 : A,C,D,F,G
            4'h6: r_Segments = 7'b1111101;  // 6 : A,C,D,E,F,G
            4'h7: r_Segments = 7'b0000111;  // 7 : A,B,C
            4'h8: r_Segments = 7'b1111111;  // 8 : tous
            4'h9: r_Segments = 7'b1101111;  // 9 : A,B,C,D,F,G
            4'hA: r_Segments = 7'b1110111;  // A : A,B,C,E,F,G
            4'hB: r_Segments = 7'b1111100;  // b : C,D,E,F,G
            4'hC: r_Segments = 7'b0111001;  // C : A,D,E,F
            4'hD: r_Segments = 7'b1011110;  // d : B,C,D,E,G
            4'hE: r_Segments = 7'b1111001;  // E : A,D,E,F,G
            4'hF: r_Segments = 7'b1110001;  // F : A,E,F,G
            default: r_Segments = 7'b0000000;  // Éteint
        endcase
    end

    // Sorties en logique négative (actif bas pour l'afficheur)
    assign {o_Segment1_G, o_Segment1_F, o_Segment1_E, o_Segment1_D,
            o_Segment1_C, o_Segment1_B, o_Segment1_A} = ~r_Segments;

endmodule
