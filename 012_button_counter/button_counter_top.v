// Top-level module pour button_counter
// Mappe les sorties génériques vers les pins physiques de la Go Board

module button_counter_top(
    input wire i_Clk,
    input wire i_Switch_1,
    input wire i_Switch_2,
    // Afficheur 7 segments droite (Segment 2)
    output wire o_Segment2_A,
    output wire o_Segment2_B,
    output wire o_Segment2_C,
    output wire o_Segment2_D,
    output wire o_Segment2_E,
    output wire o_Segment2_F,
    output wire o_Segment2_G
);

    // Sortie générique du module
    wire [6:0] w_Segments;

    // Instantiation du module button_counter
    button_counter #(
        .DEBOUNCE_TIME(250_000)  // 10 ms @ 25 MHz pour hardware
    ) counter_inst (
        .i_Clk(i_Clk),
        .i_Switch_1(i_Switch_1),
        .i_Switch_2(i_Switch_2),
        .o_Segments(w_Segments)
    );

    // Mapping vers le 7-segment de droite (Segment2)
    assign {o_Segment2_G, o_Segment2_F, o_Segment2_E, o_Segment2_D,
            o_Segment2_C, o_Segment2_B, o_Segment2_A} = w_Segments;

endmodule
