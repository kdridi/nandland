// Top-level module pour stopwatch
// Mappe les sorties génériques vers les pins physiques de la Go Board

module stopwatch_top(
    input wire i_Clk,
    input wire i_Switch_1,
    input wire i_Switch_2,
    // Afficheurs 7 segments
    output wire o_Segment1_A,
    output wire o_Segment1_B,
    output wire o_Segment1_C,
    output wire o_Segment1_D,
    output wire o_Segment1_E,
    output wire o_Segment1_F,
    output wire o_Segment1_G,
    output wire o_Segment2_A,
    output wire o_Segment2_B,
    output wire o_Segment2_C,
    output wire o_Segment2_D,
    output wire o_Segment2_E,
    output wire o_Segment2_F,
    output wire o_Segment2_G
);

    // Sorties génériques du module
    wire [6:0] w_Segments1;
    wire [6:0] w_Segments2;

    // Instantiation du module stopwatch
    stopwatch #(
        .DEBOUNCE_TIME(250_000),  // 10 ms @ 25 MHz
        .CENTISECOND(250_000)     // 0.01s @ 25 MHz
    ) stopwatch_inst (
        .i_Clk(i_Clk),
        .i_Switch_1(i_Switch_1),
        .i_Switch_2(i_Switch_2),
        .o_Segments1(w_Segments1),
        .o_Segments2(w_Segments2)
    );

    // Mapping vers les 7-segments physiques
    // Segment1 = gauche (dizaines)
    assign {o_Segment1_G, o_Segment1_F, o_Segment1_E, o_Segment1_D,
            o_Segment1_C, o_Segment1_B, o_Segment1_A} = w_Segments1;

    // Segment2 = droite (unités)
    assign {o_Segment2_G, o_Segment2_F, o_Segment2_E, o_Segment2_D,
            o_Segment2_C, o_Segment2_B, o_Segment2_A} = w_Segments2;

endmodule
