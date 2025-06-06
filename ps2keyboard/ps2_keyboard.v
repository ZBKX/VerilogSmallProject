module ps2_keyboard(
    input fpga_clk,
    input ps2_clk,
    input reset,
    input ps2_data,
    input con_read,
    output [26:0]test1,//test
    output [7:0]data,
    output [1:0]out_contrl
);
    
    reg [2:0]ps2_clk_time;
    always @(posedge fpga_clk) 
    begin
        ps2_clk_time <= {ps2_clk_time[1:0], ps2_clk};
    end
    wire ps2_clk_flag;
    assign ps2_clk_flag = ps2_clk_time[2] & ~ps2_clk_time[1];
    
    reg [3:0]count;

    reg [10:0]buffer;
    reg [7:0]fifo[7:0];
    reg [2:0]wpot;
    reg [2:0]rpot;
    reg ready;
    reg overflow;

    assign test1 = {count,wpot,rpot,buffer};//test1

    always @(posedge fpga_clk) 
    begin
        if (reset)
        begin
            wpot <= 3'd0;
            rpot <= 3'd0;
            count <= 4'd0;
            buffer <= 11'd0;
            ready <= 1'b0;
            overflow <= 1'b0;
        end
        else
        begin
            if (ready)
            begin
                if (con_read)
                begin
                    rpot <= rpot + 3'd1;
                    if (wpot == (rpot + 3'd1))
                    begin
                        ready <= 1'b0;
                    end
                end
            end
            if (ps2_clk_flag)
            begin
                if (count == 4'd10)
                begin
                    if (^buffer[9:1] & ~buffer[0] & ps2_data)
                    begin
                        fifo[wpot] <= buffer[8:1];
                        wpot <= wpot + 3'd1;
                        ready <= 1'b1;
                        overflow <= overflow | (rpot == (wpot + 3'd1));
                    end
                    count <= 4'd0;
                end
                else
                begin
                    buffer[count] <= ps2_data;
                    count <= count + 4'd1;
                end
            end
        end
    end
    assign out_contrl = {overflow, ready};
    assign data = fifo[rpot];

endmodule