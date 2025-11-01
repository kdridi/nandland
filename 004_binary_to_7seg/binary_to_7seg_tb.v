// Testbench pour binary_to_7seg
// Test Driven Development (TDD)

`timescale 1ns/1ps

module binary_to_7seg_tb;

    // Signaux de test
    reg tb_switch_1;  // bit[0]
    reg tb_switch_2;  // bit[1]
    reg tb_switch_3;  // bit[2]
    reg tb_switch_4;  // bit[3]

    wire tb_seg_a;
    wire tb_seg_b;
    wire tb_seg_c;
    wire tb_seg_d;
    wire tb_seg_e;
    wire tb_seg_f;
    wire tb_seg_g;

    // Instanciation du module à tester
    binary_to_7seg uut (
        .i_Switch_1(tb_switch_1),
        .i_Switch_2(tb_switch_2),
        .i_Switch_3(tb_switch_3),
        .i_Switch_4(tb_switch_4),
        .o_Segment1_A(tb_seg_a),
        .o_Segment1_B(tb_seg_b),
        .o_Segment1_C(tb_seg_c),
        .o_Segment1_D(tb_seg_d),
        .o_Segment1_E(tb_seg_e),
        .o_Segment1_F(tb_seg_f),
        .o_Segment1_G(tb_seg_g)
    );

    // Compteur de tests réussis/échoués
    integer tests_passed = 0;
    integer tests_failed = 0;

    // Tâche pour vérifier un résultat
    task check_output;
        input [3:0] value;
        input [6:0] expected_segments;  // {G,F,E,D,C,B,A} logique positive
        input [80*8:1] test_name;
        reg [6:0] actual_segments;
        begin
            // Les sorties sont en logique négative, donc on les inverse pour comparer
            actual_segments = ~{tb_seg_g, tb_seg_f, tb_seg_e, tb_seg_d,
                               tb_seg_c, tb_seg_b, tb_seg_a};

            if (actual_segments === expected_segments) begin
                $display("✓ PASS: %0s", test_name);
                tests_passed = tests_passed + 1;
            end else begin
                $display("✗ FAIL: %0s", test_name);
                $display("  Valeur: 0x%h (%0d)", value, value);
                $display("  Segments attendus: %b (GFEDCBA)", expected_segments);
                $display("  Segments obtenus:  %b (GFEDCBA)", actual_segments);
                tests_failed = tests_failed + 1;
            end
        end
    endtask

    // Tâche pour afficher l'état des segments
    task display_7seg;
        input [3:0] value;
        reg a, b, c, d, e, f, g;
        begin
            // Inverser car sorties en logique négative
            {g, f, e, d, c, b, a} = ~{tb_seg_g, tb_seg_f, tb_seg_e, tb_seg_d,
                                      tb_seg_c, tb_seg_b, tb_seg_a};
            $display("  Affichage 7-seg pour 0x%h:", value);
            $display("   %s%s%s  ", a ? "_" : " ", a ? "_" : " ", a ? "_" : " ");
            $display("  %s   %s ", f ? "|" : " ", b ? "|" : " ");
            $display("   %s%s%s  ", g ? "_" : " ", g ? "_" : " ", g ? "_" : " ");
            $display("  %s   %s ", e ? "|" : " ", c ? "|" : " ");
            $display("   %s%s%s  ", d ? "_" : " ", d ? "_" : " ", d ? "_" : " ");
        end
    endtask

    // Séquence de test
    initial begin
        $display("=== Début des tests pour binary_to_7seg ===");
        $display("");
        $display("Test du décodeur hexadécimal 7 segments (0x0 - 0xF)");
        $display("");

        // Test 0 : 0x0
        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'h0;
        #10;
        check_output(4'h0, 7'b0111111, "0x0 → '0' (tous segments sauf G)");

        // Test 1 : 0x1
        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'h1;
        #10;
        check_output(4'h1, 7'b0000110, "0x1 → '1' (B,C)");

        // Test 2 : 0x2
        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'h2;
        #10;
        check_output(4'h2, 7'b1011011, "0x2 → '2' (A,B,D,E,G)");

        // Test 3 : 0x3
        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'h3;
        #10;
        check_output(4'h3, 7'b1001111, "0x3 → '3' (A,B,C,D,G)");

        // Test 4 : 0x4
        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'h4;
        #10;
        check_output(4'h4, 7'b1100110, "0x4 → '4' (B,C,F,G)");

        // Test 5 : 0x5
        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'h5;
        #10;
        check_output(4'h5, 7'b1101101, "0x5 → '5' (A,C,D,F,G)");

        // Test 6 : 0x6
        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'h6;
        #10;
        check_output(4'h6, 7'b1111101, "0x6 → '6' (A,C,D,E,F,G)");

        // Test 7 : 0x7
        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'h7;
        #10;
        check_output(4'h7, 7'b0000111, "0x7 → '7' (A,B,C)");

        // Test 8 : 0x8
        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'h8;
        #10;
        check_output(4'h8, 7'b1111111, "0x8 → '8' (tous segments)");

        // Test 9 : 0x9
        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'h9;
        #10;
        check_output(4'h9, 7'b1101111, "0x9 → '9' (A,B,C,D,F,G)");

        // Test A : 0xA
        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'hA;
        #10;
        check_output(4'hA, 7'b1110111, "0xA → 'A' (A,B,C,E,F,G)");

        // Test B : 0xB
        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'hB;
        #10;
        check_output(4'hB, 7'b1111100, "0xB → 'b' (C,D,E,F,G)");

        // Test C : 0xC
        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'hC;
        #10;
        check_output(4'hC, 7'b0111001, "0xC → 'C' (A,D,E,F)");

        // Test D : 0xD
        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'hD;
        #10;
        check_output(4'hD, 7'b1011110, "0xD → 'd' (B,C,D,E,G)");

        // Test E : 0xE
        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'hE;
        #10;
        check_output(4'hE, 7'b1111001, "0xE → 'E' (A,D,E,F,G)");

        // Test F : 0xF
        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'hF;
        #10;
        check_output(4'hF, 7'b1110001, "0xF → 'F' (A,E,F,G)");

        // Tests visuels
        $display("");
        $display("=== Visualisation de quelques chiffres ===");

        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'h0; #10;
        display_7seg(4'h0);

        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'h8; #10;
        display_7seg(4'h8);

        {tb_switch_4, tb_switch_3, tb_switch_2, tb_switch_1} = 4'hF; #10;
        display_7seg(4'hF);

        // Résumé des tests
        $display("");
        $display("=== Résumé des tests ===");
        $display("Tests réussis : %0d", tests_passed);
        $display("Tests échoués : %0d", tests_failed);

        if (tests_failed == 0) begin
            $display("");
            $display("✓ Tous les tests sont passés !");
            $display("Vous pouvez maintenant lancer 'make build' puis 'make flash'");
        end else begin
            $display("");
            $display("✗ Certains tests ont échoué. Corrigez le code avant de flasher.");
        end

        $finish;
    end

    // Génération du fichier VCD pour visualisation (optionnel)
    initial begin
        $dumpfile("binary_to_7seg.vcd");
        $dumpvars(0, binary_to_7seg_tb);
    end

endmodule
