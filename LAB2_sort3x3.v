module compare_swap (
    input [7:0] a, b,
    output reg [7:0] min,max;
);
always @(*) begin
    if (a < b) begin
        min = a;
        max = b;
    end else begin
        min = b;
        max = a;
    end
end
endmodule

module sort3 (
    input [7:0] a, b, c
    output [7:0] max, med, min;
); 
    wire [7:0] l1, l2, h1, h2;
    //so sanh a, b
    compare_swap c1 ( .a(a), .b(b), .min(l1), .max(h1));
    //so sanh min voi c
    compare_swap c2 ( .a(l1), .b(c), .min(min), .max(h2));
    //so sanh h1, h2 
    compare_swap c3 ( .a(h1), .b(h2), .min(med), .max(max));
endmodule

module median_filter (
    input [7:0] p0, p1, p2, //row 1
    input [7:0] p3, p4, p5, //row 2
    input [7:0] p6, p7, p8, //row 3
    output [7:0] out
);
    wire [7:0] r1_min, r1_med, r1_max;
    wire [7:0] r2_min, r2_med, r2_max;
    wire [7:0] r3_min, r3_med, r3_max;

    //sort row
    sort3 r1 (p0, p1, p2, r1_max, r1_med, r1_min);
    sort3 r2 (p3, p4, p5, r2_max, r2_med, r2_min);
    sort3 r3 (p6, p7, p8, r3_max, r3_med, r3_min);

    //tim min(max), med(med), max(min)
    wire [7:0] min_of_max, med_of_med, max_of_min;
    wire [7:0] tmp1,tmp2, tmp3, tmp4, tmp5, tmp6;

    //min of max
    sort3 col_min (r1_max, r2_max, r3_max, tmp1, tmp2, min_of_max);
    //med of med
    sort3 col_med (r1_med, r2_med, r3_med, tmp3, med_of_med, tmp4);
    //max of min
    sort3 col_max (r1_min, r2_min, r3_min, max_of_min, tmp5, tmp6);

    wire [7:0] tmp7, tmp8;
    //sort min_of_max, med_of_med, max_of_min
    sort3 final_sort (min_of_max, med_of_med, max_of_min, tmp7, out, tmp8);
    
endmodule